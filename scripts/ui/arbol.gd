extends CanvasLayer
## Árbol de habilidades del viejo. Los nodos se colocan a mano en la escena (Lienzo/Nodos) y cada
## uno lleva su NodoArbolData; los caminos de agua se trazan solos según los requisitos.
## Se abre hablando con el viejo; pausa el juego mientras está abierto.

@export var escena_conexion: PackedScene
@export var tienda: Tienda
@export_group("Animación")
## Lo que tarda el agua en llegar a un nodo al comprarlo.
@export var duracion_agua: float = 0.45
## Al abrir, el agua corre desde el viejo hacia fuera: retraso por cada salto.
@export var retraso_cascada: float = 0.06
@export var zooms: Array[float] = [0.5, 0.75, 1.0, 1.25]
@export var suavizado_camara: float = 10.0
@export_group("Mando")
## Al mantener la cruceta o el stick: espera antes de repetir y cada cuánto repite (segundos).
@export var retardo_repeticion: float = 0.32
@export var ritmo_repeticion: float = 0.13
## Cuánto se abre el cono de búsqueda del siguiente nodo (0.35 ≈ 70° a cada lado).
@export var cono_navegacion: float = 0.35

@onready var raiz: Control = $Raiz
@onready var vista: Control = $Raiz/Vista
@onready var lienzo: Control = $Raiz/Vista/Lienzo
@onready var conexiones: Control = $Raiz/Vista/Lienzo/Conexiones
@onready var nodos: Control = $Raiz/Vista/Lienzo/Nodos
@onready var origen: Control = $Raiz/Vista/Lienzo/Origen
@onready var chispas: CPUParticles2D = $Raiz/Vista/Lienzo/Chispas
@onready var rublos: Label = $Raiz/Cabecera/Filas/Arriba/Rublos
@onready var chips: Container = $Raiz/Cabecera/Filas/Ramas
@onready var ficha: PanelContainer = $Raiz/Ficha
@onready var ficha_icono: TextureRect = $Raiz/Ficha/Contenido/Arriba/Icono
@onready var ficha_nombre: Label = $Raiz/Ficha/Contenido/Arriba/Textos/Nombre
@onready var ficha_rama: Label = $Raiz/Ficha/Contenido/Arriba/Textos/Rama
@onready var ficha_desc: Label = $Raiz/Ficha/Contenido/Descripcion
@onready var ficha_nivel: Label = $Raiz/Ficha/Contenido/Abajo/Nivel
@onready var ficha_coste: Label = $Raiz/Ficha/Contenido/Abajo/Coste
@onready var ficha_motivo: Label = $Raiz/Ficha/Contenido/Motivo
@onready var pista_mejorar: TextureRect = $Raiz/Pie/Mejorar/Icono
@onready var pista_salir: TextureRect = $Raiz/Pie/Salir/Icono
@onready var pista_tienda: Control = get_node_or_null("Raiz/Pie/PistaTienda")
@onready var boton_tienda: Button = $Raiz/BotonTienda
@onready var sfx_mejorar: AudioStreamPlayer = $SfxMejorar
@onready var sfx_no: AudioStreamPlayer = $SfxNo
@onready var sfx_agua: AudioStreamPlayer = $SfxAgua
@onready var sfx_max: AudioStreamPlayer = $SfxMax

var abierto: bool = false
var _vendedor: Interactuable
var _todos: Array[NodoArbol] = []
var _por_id: Dictionary = {}
var _caminos: Array[ConexionArbol] = []
var _sel: NodoArbol
var _objetivo: Vector2
var _zoom: int = 2
var _arrastrando: bool = false
var _comprando: bool = false
var _en_tienda: bool = false
var _dispositivo: String = ""
var _dir_nav: Vector2 = Vector2.ZERO
var _t_nav: float = 0.0


func _ready() -> void:
	raiz.visible = false
	for n: Node in nodos.get_children():
		var na: NodoArbol = n as NodoArbol
		if na == null or na.datos == null:
			continue
		_todos.append(na)
		_por_id[na.datos.id] = na
		na.elegido.connect(_elegir)
		na.accionado.connect(_comprar)
	_trazar_caminos()
	_animar_nodos(false)
	vista.gui_input.connect(_input_vista)
	boton_tienda.pressed.connect(_abrir_tienda)
	Juego.rublos_cambiados.connect(func(_r: float) -> void:
		if abierto:
			_refrescar())


func abrir(vendedor: Interactuable = null) -> void:
	_vendedor = vendedor
	boton_tienda.visible = vendedor != null and not vendedor.articulos.is_empty()
	if pista_tienda:
		pista_tienda.visible = boton_tienda.visible
	abierto = true
	raiz.visible = true
	get_tree().paused = true
	_animar_nodos(true)
	_refrescar()
	_cascada()
	var primero: NodoArbol = _sel if _sel else _primero_disponible()
	if primero:
		primero.grab_focus()
		_elegir(primero)
	_centrar(primero.centro() if primero else origen.position + origen.size * 0.5, true)


func cerrar() -> void:
	abierto = false
	raiz.visible = false
	get_tree().paused = false
	var foco: Control = get_viewport().gui_get_focus_owner()
	if foco and raiz.is_ancestor_of(foco):
		foco.release_focus()
	_animar_nodos(false)


## Los nodos solo laten mientras el árbol está abierto.
func _animar_nodos(si: bool) -> void:
	for na: NodoArbol in _todos:
		na.set_process(si)


func _process(delta: float) -> void:
	if not abierto:
		return
	rublos.text = Formato.dinero(Juego.rublos)
	if not _arrastrando:
		lienzo.position = lienzo.position.lerp(_objetivo, 1.0 - exp(-suavizado_camara * delta))
	_colocar_ficha()
	_navegar_mando(delta)
	if IconosInput.dispositivo != _dispositivo:
		_dispositivo = IconosInput.dispositivo
		pista_mejorar.texture = IconosInput.icono(&"interactuar")
		pista_salir.texture = IconosInput.icono(&"ui_cancel")


func _input(event: InputEvent) -> void:
	if not abierto:
		return
	IconosInput.detectar(event)
	if _en_tienda:
		return
	# La cruceta y el stick los lleva _navegar_mando: el foco automático de Godot salta mal entre nodos sueltos.
	for a: StringName in [&"ui_left", &"ui_right", &"ui_up", &"ui_down"]:
		if event.is_action(a):
			get_viewport().set_input_as_handled()
			return


func _unhandled_input(event: InputEvent) -> void:
	if not abierto or _en_tienda:
		return
	if event.is_action_pressed("menu") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		cerrar()
	elif event is InputEventKey and event.is_action_pressed("interactuar") and _sel:
		# En mando, el botón de aceptar ya pulsa el nodo enfocado.
		get_viewport().set_input_as_handled()
		_comprar(_sel)
	elif event.is_action_pressed("pestana_anterior") or event.is_action_pressed("pestana_siguiente"):
		get_viewport().set_input_as_handled()
		_saltar_rama(-1 if event.is_action_pressed("pestana_anterior") else 1)
	elif event.is_action_pressed("accion_extra") and boton_tienda.visible:
		get_viewport().set_input_as_handled()
		_abrir_tienda()


# --- Mando ---

## Cruceta o stick: salta al nodo visible más cercano en esa dirección; al mantener, repite.
func _navegar_mando(delta: float) -> void:
	if _en_tienda or _comprando:
		return
	var v: Vector2 = Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down")
	if v.length() < 0.5:
		_dir_nav = Vector2.ZERO
		return
	var d: Vector2 = v.normalized()
	if _dir_nav == Vector2.ZERO or _dir_nav.dot(d) < 0.7:
		_t_nav = retardo_repeticion
	else:
		_t_nav -= delta
		if _t_nav > 0.0:
			return
		_t_nav = ritmo_repeticion
	_dir_nav = d
	var siguiente: NodoArbol = _vecino(d)
	if siguiente:
		siguiente.grab_focus()


func _vecino(d: Vector2) -> NodoArbol:
	var desde: Vector2 = _sel.centro() if _sel else origen_centro()
	var mejor: NodoArbol = null
	var nota_mejor: float = INF
	for na: NodoArbol in _todos:
		if na == _sel or not na.visible:
			continue
		var o: Vector2 = na.centro() - desde
		var dist: float = o.length()
		var coseno: float = o.dot(d) / maxf(dist, 0.001)
		if coseno < cono_navegacion:
			continue
		# Cerca y en línea gana; lo que está muy de lado cuenta como más lejos.
		var nota: float = dist * (1.0 + 2.5 * (1.0 - coseno))
		if nota < nota_mejor:
			nota_mejor = nota
			mejor = na
	return mejor


## L1/R1: salta a la rama anterior o siguiente (al nodo que puedes comprar más cerca del viejo).
func _saltar_rama(paso: int) -> void:
	if Juego.arbol == null or Juego.arbol.ramas.is_empty():
		return
	var ramas: Array = Juego.arbol.ramas
	var i: int = ramas.find(_sel.datos.rama) if _sel and _sel.datos.rama else -1
	for k in range(1, ramas.size() + 1):
		var rama: Resource = ramas[(i + paso * k + ramas.size() * 4) % ramas.size()]
		var elegido: NodoArbol = null
		var nota_mejor: float = INF
		for na: NodoArbol in _todos:
			if na.datos.rama != rama or not na.visible:
				continue
			# Primero lo que se puede comprar; luego lo comprado; lo bloqueado al final.
			var peso: float = {NodoArbol.Estado.DISPONIBLE: 0.0, NodoArbol.Estado.COMPRADO: 1.0, NodoArbol.Estado.MAX: 1.0}.get(na.estado, 2.0)
			var nota: float = peso * 100000.0 + na.centro().distance_to(origen_centro())
			if nota < nota_mejor:
				nota_mejor = nota
				elegido = na
		if elegido:
			elegido.grab_focus()
			_centrar(elegido.centro())
			return


# --- Caminos ---

func _trazar_caminos() -> void:
	for na: NodoArbol in _todos:
		var color: Color = na.datos.rama.color if na.datos.rama else Color.WHITE
		var vertical: bool = absf(na.centro().y - origen_centro().y) > absf(na.centro().x - origen_centro().x)
		var padres: Array[Vector2] = []
		for r: Resource in na.datos.requisitos:
			var p: NodoArbol = _por_id.get((r as NodoArbolData).id)
			if p:
				padres.append(p.centro())
		if padres.is_empty():
			padres.append(origen_centro())
		for desde: Vector2 in padres:
			var c: ConexionArbol = escena_conexion.instantiate()
			conexiones.add_child(c)
			c.hijo = na.datos
			c.trazar(desde, na.centro(), vertical, color)
			_caminos.append(c)


func origen_centro() -> Vector2:
	return origen.position + origen.size * 0.5


func _caminos_a(d: NodoArbolData) -> Array[ConexionArbol]:
	var r: Array[ConexionArbol] = []
	for c: ConexionArbol in _caminos:
		if c.hijo == d:
			r.append(c)
	return r


## Al abrir, el agua recorre desde el viejo todos los caminos que ya tienes.
func _cascada() -> void:
	for c: ConexionArbol in _caminos:
		if Juego.nivel_habilidad(c.hijo) > 0:
			c.llenar(0.3, _profundidad(c.hijo) * retraso_cascada)


func _profundidad(d: NodoArbolData) -> int:
	var p: int = 0
	for r: Resource in d.requisitos:
		p = maxi(p, _profundidad(r as NodoArbolData) + 1)
	return p


# --- Estado y ficha ---

func _refrescar() -> void:
	for na: NodoArbol in _todos:
		na.refrescar()
	for c: ConexionArbol in _caminos:
		c.poner(Juego.nivel_habilidad(c.hijo) > 0, Juego.habilidad_disponible(c.hijo))
	for chip: Node in chips.get_children():
		if chip.has_method("refrescar"):
			chip.refrescar()
	_rellenar_ficha()


func _elegir(na: NodoArbol) -> void:
	if _sel == na:
		return
	_sel = na
	_rellenar_ficha()
	# Con teclado o mando, la cámara sigue a la selección si se sale de la vista.
	if IconosInput.dispositivo != "teclado" or not _raton_encima():
		var p: Vector2 = lienzo.position + na.centro() * lienzo.scale
		var r: Rect2 = Rect2(Vector2.ZERO, vista.size).grow(-minf(vista.size.x, vista.size.y) * 0.15)
		if not r.has_point(p):
			_centrar(na.centro())


func _rellenar_ficha() -> void:
	ficha.visible = _sel != null
	if _sel == null:
		return
	var d: NodoArbolData = _sel.datos
	var nv: int = Juego.nivel_habilidad(d)
	var motivo: String = Juego.motivo_no_mejorar(d)
	var por_flag: bool = d.requiere_flag != "" and not Juego.flags.get(d.requiere_flag, false)
	ficha_icono.texture = _sel.icono_rect.texture
	ficha_icono.modulate = d.rama.color if d.rama else Color.WHITE
	ficha_nombre.text = "???" if por_flag and nv == 0 else d.nombre
	ficha_rama.text = (d.rama.nombre if d.rama else "") + ("  ·  clave" if d.clave else "")
	ficha_rama.modulate = d.rama.color if d.rama else Color.WHITE
	ficha_desc.text = d.texto_descripcion(nv)
	ficha_nivel.text = "Nv. %d / %d" % [nv, d.niveles]
	if motivo == "MAX":
		ficha_coste.text = "MAX"
	else:
		ficha_coste.text = Formato.dinero(Juego.coste_habilidad(d))
	ficha_motivo.visible = motivo != "" and motivo != "MAX"
	ficha_motivo.text = motivo
	ficha_motivo.modulate = Color(1.0, 0.45, 0.45) if motivo == "Faltan rublos" else Color.WHITE


func _colocar_ficha() -> void:
	if _sel == null or not ficha.visible:
		return
	var esc: Vector2 = lienzo.scale
	var nodo_pos: Vector2 = vista.position + lienzo.position + _sel.position * esc
	var nodo_tam: Vector2 = _sel.size * esc
	var p: Vector2 = nodo_pos + Vector2(nodo_tam.x + 24.0, -12.0)
	var pantalla: Vector2 = raiz.size
	if p.x + ficha.size.x > pantalla.x - 24.0:
		p.x = nodo_pos.x - ficha.size.x - 24.0
	p.y = clampf(p.y, vista.position.y, pantalla.y - ficha.size.y - 110.0)
	ficha.position = p


# --- Comprar ---

func _comprar(na: NodoArbol) -> void:
	if _comprando:
		return
	if _sel != na:
		_elegir(na)
	var d: NodoArbolData = na.datos
	var motivo: String = Juego.motivo_no_mejorar(d)
	if motivo != "":
		na.sacudir()
		sfx_no.play()
		_parpadear_motivo()
		return
	var primera: bool = Juego.nivel_habilidad(d) == 0
	var antes: Dictionary = {}
	for o: NodoArbol in _todos:
		antes[o] = Juego.habilidad_disponible(o.datos)
	Juego.mejorar_habilidad(d)
	_comprando = true
	if primera:
		# El agua corre desde el padre hasta el nodo y entonces se enciende.
		sfx_agua.play()
		var tw: Tween = null
		for c: ConexionArbol in _caminos_a(d):
			tw = c.llenar(duracion_agua)
		if tw:
			await tw.finished
	_comprando = false
	na.refrescar()
	na.pop()
	_chispas(na)
	if Juego.nivel_habilidad(d) >= d.niveles:
		sfx_max.play()
	else:
		sfx_mejorar.play()
	_refrescar()
	# Los que se acaban de abrir parpadean y su camino empieza a gotear.
	var i: int = 0
	for o: NodoArbol in _todos:
		if not antes[o] and Juego.habilidad_disponible(o.datos):
			o.despertar(0.1 + i * 0.08)
			i += 1


func _chispas(na: NodoArbol) -> void:
	chispas.position = na.centro()
	chispas.color = na.datos.rama.color if na.datos.rama else Color.WHITE
	chispas.restart()
	chispas.emitting = true


func _parpadear_motivo() -> void:
	ficha_motivo.visible = true
	var tw := create_tween()
	for k in 2:
		tw.tween_property(ficha_motivo, "modulate:a", 0.2, 0.06)
		tw.tween_property(ficha_motivo, "modulate:a", 1.0, 0.06)


func _primero_disponible() -> NodoArbol:
	for na: NodoArbol in _todos:
		if na.estado == NodoArbol.Estado.DISPONIBLE:
			return na
	return _todos[0] if not _todos.is_empty() else null


# --- Cámara: arrastrar y zoom ---

func _centrar(punto: Vector2, de_golpe: bool = false) -> void:
	_objetivo = vista.size * 0.5 - punto * lienzo.scale
	if de_golpe:
		lienzo.position = _objetivo


func _input_vista(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var b: InputEventMouseButton = event
		if b.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			_arrastrando = b.pressed
			if not b.pressed:
				_objetivo = lienzo.position
		elif b.pressed and b.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var antes: int = _zoom
			_zoom = clampi(_zoom + (1 if b.button_index == MOUSE_BUTTON_WHEEL_UP else -1), 0, zooms.size() - 1)
			if _zoom != antes:
				# Zoom hacia donde está el ratón.
				var punto: Vector2 = (b.position - lienzo.position) / lienzo.scale
				lienzo.scale = Vector2.ONE * zooms[_zoom]
				lienzo.position = b.position - punto * lienzo.scale
				_objetivo = lienzo.position
	elif event is InputEventMouseMotion and _arrastrando:
		lienzo.position += (event as InputEventMouseMotion).relative
		_objetivo = lienzo.position


func _raton_encima() -> bool:
	return vista.get_global_rect().has_point(vista.get_global_mouse_position())


# --- Tienda del viejo ---

func _abrir_tienda() -> void:
	if tienda == null or _vendedor == null:
		return
	_en_tienda = true
	raiz.visible = false
	tienda.abrir(_vendedor)
	await tienda.cerrada
	_en_tienda = false
	if abierto:
		raiz.visible = true
		get_tree().paused = true
		_refrescar()
