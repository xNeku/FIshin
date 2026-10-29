extends CanvasLayer
## HUD de pesca y dinero. Solo visual: lee la Pesca y el Juego.

@export var pesca: Pesca
@export var barco: BarcoComerciante
@export var celebracion: Node
@export var mundo: Node
@export var jugador: Node
@export var comercio: Node
@export var escena_popup: PackedScene
## La X roja de fallo o escape (popup_icono.tscn).
@export var escena_x: PackedScene
@export var escala_x: float = 1.0
## Para poner la X encima de la cabeza: la cámara del juego y el punto de la cabeza en el donut.
@export var camara: Camera3D
@export var cabeza: Node3D
## Altura de la X sobre los pies del náufrago cuando va andando.
@export var altura_cabeza_andando: float = 2.0
@export var velocidad_contador: float = 6.0
## Iconos de teclas: <carpeta>/<teclado|xbox|ps>_<accion>[_pulsada].png. Redibuja los PNG para cambiarlos.
@export_dir var carpeta_teclas: String = "res://art/ui/teclas"
## Dibujos para un mando que no se reconoce por su nombre.
@export_enum("ps", "xbox") var mando_por_defecto: String = "ps"
## Con varias acciones posibles a la vez, cada cuánto cambia la caja de abajo a la derecha (segundos).
@export var cambio_acciones: float = 2.0
## Al machacar, cada cuánto se aprieta sola la tecla dibujada (segundos).
@export var ritmo_machacar: float = 0.12
## Cuánto salta de sitio el botón al tope de intensidad (píxeles).
@export var salto_prompt_maximo: float = 220.0
@export var color_numeros: Color = Color("ff9a3c")
@export var color_flechas: Color = Color("4fd6ff")
@export var color_perfecto: Color = Color("ffd84a")
@export var color_fallo: Color = Color("ff4a4a")
@export var colores_rareza: Array[Color] = [Color("e8e8e8"), Color("4fa3ff"), Color("b56bff"), Color("ffb02e")]
## Frase de cada acierto según cuántos botones llevas: la palabra i sale desde el botón umbrales_palabras[i].
@export var palabras_acierto: Array[String] = ["Bien", "Genial", "¡Brutal!", "¡LOCURA!", "¡¡DIOS!!", "¡¡¡INHUMANO!!!"]
@export var umbrales_palabras: Array[int] = [1, 5, 10, 20, 35, 50]

@export_group("Destellos de pantalla (0..1)")
@export var destello_picada: float = 0.15
@export var destello_acierto_min: float = 0.05
@export var destello_acierto_max: float = 0.6
@export var destello_captura: float = 0.2
@export var destello_perfecto: float = 0.5

## Letras de las pistas "[E] ..." y su acción del Input Map.
const TECLA_A_ACCION: Dictionary = {"E": &"interactuar", "Q": &"cambiar_modo", "Tab": &"menu"}
const NOMBRES_RAREZA: Array[String] = ["Común", "Raro", "Extraño", "Legendario"]

@onready var efecto: ColorRect = $EfectoPantalla
@onready var rublos: Label = $Info/Lista/Rublos
@onready var barca: Label = $Info/Lista/Barca
@onready var cana: Label = $Info/Lista/Cana
@onready var cebo: Label = $Info/Lista/Cebo
@onready var estado: Label = $Estado
@onready var prompt: Control = $Prompt
@onready var teclas: Control = $Prompt/Teclas
@onready var tecla1: TextureRect = $Prompt/Teclas/Tecla1
@onready var tecla2: TextureRect = $Prompt/Teclas/Tecla2
@onready var mas: Label = $Prompt/Teclas/Mas
@onready var barra_tiempo: ProgressBar = $Prompt/BarraTiempo
@onready var barra_machacar: ProgressBar = $Prompt/BarraMachacar
@onready var combo: Label = $Combo
@onready var popups: Control = $Popups
@onready var resultado: PanelContainer = $Resultado
@onready var icono: TextureRect = $Resultado/Margen/Fila/Icono
@onready var nombre: Label = $Resultado/Margen/Fila/Textos/Nombre
@onready var detalle: Label = $Resultado/Margen/Fila/Textos/Detalle
@onready var caja_accion: PanelContainer = $Accion

var _rublos_mostrados: float = 0.0
var _intensidad_objetivo: float = 0.0
var _intensidad: float = 0.0
var _destello: float = 0.0
var _pos_prompt: Vector2
var _mat: ShaderMaterial
var _ultima_x: int = -1000
var _dispositivo: String = "teclado"
var _iconos: Dictionary = {}
var _accion_machacar: StringName = &""
var _t_machacar: float = 0.0
var _acciones: Array[String] = []
var _t_accion: float = 0.0
var _i_accion: int = 0


func _ready() -> void:
	_mat = efecto.material as ShaderMaterial
	_rublos_mostrados = Juego.rublos
	_pos_prompt = prompt.position
	prompt.visible = false
	resultado.visible = false
	combo.visible = false
	estado.visible = false
	if pesca:
		pesca.estado_cambiado.connect(_on_estado)
		pesca.pez_pica.connect(_on_pica)
		pesca.paso_nuevo.connect(_on_paso)
		pesca.acierto.connect(_on_acierto)
		pesca.fallo.connect(_on_fallo)
		pesca.machacar_progreso.connect(_on_machacar_progreso)
		pesca.machacar_fallido.connect(_on_machacar_fallido)
		pesca.pez_capturado.connect(_on_capturado)
		pesca.pez_escapado.connect(_on_escapado)
		pesca.barca_llena.connect(_on_barca_llena)
		pesca.bloqueo_barca_llena.connect(_on_bloqueo_barca_llena)
		pesca.intensidad_cambiada.connect(func(i: float) -> void: _intensidad_objetivo = i)
		_on_estado(pesca.estado)
	if comercio:
		comercio.venta_terminada.connect(_on_vendido)
	if celebracion:
		celebracion.empezada.connect(func(_pez: PezData) -> void: combo.visible = false)


func _process(delta: float) -> void:
	var dt: float = Juego.delta_real(delta)
	_rublos_mostrados = lerpf(_rublos_mostrados, Juego.rublos, 1.0 - exp(-velocidad_contador * dt))
	if absf(_rublos_mostrados - Juego.rublos) < 0.05:
		_rublos_mostrados = Juego.rublos
	rublos.text = Formato.dinero(_rublos_mostrados)
	barca.text = "Barca: %d/%d huecos · %d peces (%s)" % [Juego.huecos_usados(), Juego.huecos, Juego.capturas.size(), Formato.dinero(Juego.valor_inventario())]
	cana.text = Juego.cana().nombre
	cebo.visible = not Juego.cebo.is_empty()
	if cebo.visible:
		cebo.text = "Cebo: %d pescas" % int(Juego.cebo.pescas)
	_mostrar_acciones(dt)
	# Machacando, la tecla dibujada se aprieta sola para que se vea qué hay que hacer.
	if _accion_machacar != &"":
		_t_machacar += dt
		var abajo: bool = fmod(_t_machacar, ritmo_machacar * 2.0) >= ritmo_machacar
		tecla1.texture = _icono(_accion_machacar, abajo)
	if Juego.en_movimiento:
		resultado.visible = false

	var p: Pesca.Paso = pesca.paso_actual() if pesca else null
	if p:
		barra_tiempo.value = pesca.tiempo_restante / p.tiempo * 100.0

	_intensidad = lerpf(_intensidad, _intensidad_objetivo, 1.0 - exp(-4.0 * dt))
	_destello = lerpf(_destello, 0.0, 1.0 - exp(-8.0 * dt))
	if _mat:
		_mat.set_shader_parameter("intensidad", _intensidad)
		_mat.set_shader_parameter("destello", _destello)


func _on_estado(e: Pesca.Estado) -> void:
	if e != Pesca.Estado.PASO:
		_accion_machacar = &""
	match e:
		Pesca.Estado.ESPERANDO:
			prompt.visible = false
			combo.visible = false
		Pesca.Estado.PASO:
			prompt.visible = true
		_:
			prompt.visible = false


func _on_pica(_pez: PezData) -> void:
	resultado.visible = false
	_destello = destello_picada


func _on_paso(p: Pesca.Paso, _i: int) -> void:
	var doble: bool = p.tipo == Pesca.Tipo.DOBLE
	var mash: bool = p.tipo == Pesca.Tipo.MACHACAR
	_pintar_tecla(tecla1, p.acciones[0])
	tecla2.visible = doble
	mas.visible = doble
	if doble:
		_pintar_tecla(tecla2, p.acciones[1])
	_accion_machacar = p.acciones[0] if mash else &""
	barra_machacar.visible = mash
	barra_tiempo.visible = true
	if mash:
		barra_machacar.max_value = p.pulsaciones
		barra_machacar.value = 0
	# Cuanto más dentro, más loco salta el botón por la pantalla.
	var salto: float = salto_prompt_maximo * _intensidad_objetivo * _intensidad_objetivo
	prompt.position = _pos_prompt + Vector2(randf_range(-salto, salto), randf_range(-salto, salto) * 0.5)
	teclas.pivot_offset = teclas.size * 0.5
	teclas.scale = Vector2.ONE * 1.5
	create_tween().tween_property(teclas, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _pintar_tecla(tecla: TextureRect, accion: StringName) -> void:
	tecla.texture = _icono(accion)
	tecla.set_meta("accion", accion)


## Icono dibujado de una acción para el último dispositivo usado (teclado o mando).
func _icono(accion: StringName, pulsada: bool = false) -> Texture2D:
	var ruta: String = "%s/%s_%s%s.png" % [carpeta_teclas, _dispositivo, accion, "_pulsada" if pulsada else ""]
	if not _iconos.has(ruta):
		_iconos[ruta] = load(ruta) if ResourceLoader.exists(ruta) else null
	return _iconos[ruta]


## Xbox o PlayStation según el nombre que da el mando; si no se sabe, mando_por_defecto.
func _tipo_mando(dispositivo: int) -> String:
	var nombre: String = Input.get_joy_name(dispositivo).to_lower()
	for clave: String in ["xbox", "xinput", "microsoft"]:
		if nombre.contains(clave):
			return "xbox"
	for clave: String in ["playstation", "dualsense", "dualshock", "sony", "ps3", "ps4", "ps5", "wireless controller"]:
		if nombre.contains(clave):
			return "ps"
	return mando_por_defecto


## Caja de abajo a la derecha: lo que se puede hacer ahora. Si hay varias cosas, van alternando.
func _mostrar_acciones(dt: float) -> void:
	var lista: Array[String] = jugador.acciones() if jugador else []
	if barco and barco.puede_hablar() and not (celebracion and celebracion.celebrando) and not (pesca and pesca.en_curso()):
		lista.push_front("[E] Hablar con el comerciante")
	caja_accion.visible = not lista.is_empty()
	if lista.is_empty():
		_t_accion = 0.0
		return
	if lista != _acciones:
		_acciones = lista
		_t_accion = 0.0
	_t_accion += dt
	var i: int = int(_t_accion / maxf(0.1, cambio_acciones)) % lista.size()
	if i != _i_accion and lista.size() > 1:
		# Al pasar a la siguiente acción, la caja parpadea como al aparecer.
		var entrada: Node = caja_accion.get_node_or_null("Entrada")
		if entrada:
			entrada.entrar()
	_i_accion = i
	_pista(caja_accion, lista[i])


## Pista "[E] Texto": la letra entre corchetes se cambia por el dibujo de su tecla.
func _pista(caja: PanelContainer, texto: String) -> void:
	var icono: TextureRect = caja.get_node("Fila/Icono")
	var etiqueta: Label = caja.get_node("Fila/Texto")
	var accion: StringName = &""
	if texto.begins_with("["):
		var fin: int = texto.find("]")
		accion = TECLA_A_ACCION.get(texto.substr(1, fin - 1), &"")
		texto = texto.substr(fin + 1).strip_edges()
	var tex: Texture2D = _icono(accion) if accion != &"" else null
	icono.texture = tex
	icono.visible = tex != null
	etiqueta.text = texto


func _input(event: InputEvent) -> void:
	# El último dispositivo usado decide qué dibujos salen.
	var dispositivo: String = _dispositivo
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf((event as InputEventJoypadMotion).axis_value) > 0.5):
		dispositivo = _tipo_mando(event.device)
	elif event is InputEventKey or event is InputEventMouseButton:
		dispositivo = "teclado"
	if dispositivo != _dispositivo:
		_dispositivo = dispositivo
		for t: TextureRect in [tecla1, tecla2]:
			if t.has_meta("accion"):
				_pintar_tecla(t, t.get_meta("accion"))


func _on_acierto(indice: int, _total: int) -> void:
	var k: float = clampf(float(indice) / float(maxi(1, pesca.stats.botones_intensidad_maxima)), 0.0, 1.0)
	_destello = lerpf(destello_acierto_min, destello_acierto_max, k)
	combo.visible = indice >= 2
	combo.text = "x%d" % indice
	combo.pivot_offset = combo.size * 0.5
	combo.scale = Vector2.ONE * (1.2 + k)
	create_tween().tween_property(combo, "scale", Vector2.ONE * (0.8 + 0.6 * k), 0.15)
	# Frases de acierto ("Genial", "¡Brutal!"...): quitadas por ahora, se retomarán más adelante.
	#var c: Color = color_numeros.lerp(color_perfecto, k)
	#_popup_en(_palabra(indice), c, prompt.position + teclas.position + teclas.size * 0.5 + Vector2(0, -120), 0.7 + 0.7 * k)


func _palabra(indice: int) -> String:
	var texto: String = palabras_acierto[0] if not palabras_acierto.is_empty() else ""
	for n in mini(palabras_acierto.size(), umbrales_palabras.size()):
		if indice >= umbrales_palabras[n]:
			texto = palabras_acierto[n]
	return texto

func _on_fallo() -> void:
	_equis()


func _on_machacar_progreso(golpes: int, _necesarios: int) -> void:
	barra_machacar.value = golpes
	_destello = maxf(_destello, destello_acierto_min)


func _on_machacar_fallido(escapa: bool) -> void:
	_equis(1.0 if escapa else 0.7)


func _on_capturado(c: Dictionary, pez: PezData) -> void:
	var col: Color = colores_rareza[pez.rareza]
	resultado.visible = true
	icono.texture = pez.icono
	nombre.text = "%s  ·  %s" % [pez.nombre, NOMBRES_RAREZA[pez.rareza]]
	nombre.modulate = col
	detalle.text = "%s  ·  %s  ·  %s" % [Formato.calidad(c.calidad, c.perfecto), Formato.peso(c.peso), Formato.dinero(c.valor)]
	_destello = destello_perfecto if c.perfecto else destello_captura


func _on_escapado(pez: PezData) -> void:
	_equis(1.4 if pez.rareza >= PezData.Rareza.RARO else 1.0)


func _on_barca_llena(_pez: PezData) -> void:
	_equis()


func _on_bloqueo_barca_llena(llena: bool) -> void:
	# Único texto arriba: avisa de que hay que vender para seguir pescando.
	estado.visible = llena
	if llena:
		estado.text = "¡Barca llena! Ve a vender"


## Texto rápido en pantalla (trucos, avisos).
func aviso_rapido(texto: String) -> void:
	_popup(texto, Color.WHITE, Vector2(0.5, 0.75), 0.8)


func _on_vendido(total: float) -> void:
	_popup_en("+" + Formato.dinero(total), color_perfecto, rublos.global_position + Vector2(rublos.size.x * 0.5, 80), 1.4)


func _equis(escala: float = 1.0) -> void:
	# Un fallo que hace escapar al pez lanza dos avisos seguidos: solo se ve una X.
	var ahora: int = Time.get_ticks_msec()
	if escena_x == null or ahora - _ultima_x < 300:
		return
	_ultima_x = ahora
	var x: Node = escena_x.instantiate()
	popups.add_child(x)
	x.mostrar(_sobre_la_cabeza(), escala * escala_x)


## Punto de pantalla (en coordenadas de Popups) encima de la cabeza del náufrago.
func _sobre_la_cabeza() -> Vector2:
	if camara == null:
		return popups.size * Vector2(0.5, 0.4)
	var p: Vector3
	if Juego.en_movimiento and jugador:
		p = jugador.global_position + Vector3.UP * altura_cabeza_andando
	elif cabeza:
		p = cabeza.global_position
	else:
		return popups.size * Vector2(0.5, 0.4)
	return popups.get_global_transform().affine_inverse() * camara.unproject_position(p)


## Popup en coordenadas relativas de pantalla (0..1).
func _popup(texto: String, color: Color, relativo: Vector2, escala: float) -> void:
	_popup_en(texto, color, popups.size * relativo, escala)


func _popup_en(texto: String, color: Color, centro: Vector2, escala: float) -> void:
	if escena_popup == null:
		return
	var p: Node = escena_popup.instantiate()
	popups.add_child(p)
	p.mostrar(texto, color, centro, escala)
