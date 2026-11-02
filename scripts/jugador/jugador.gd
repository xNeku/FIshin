extends Node3D
## El náufrago fuera de la barca. Con "cambiar_modo" (Q) se baja a andar o vuelve a pescar.
## Anda solo por casillas pisables (barca + lo que ha llegado) y salta el agua hacia la siguiente.

signal modo_cambiado(andando: bool)

@export var mundo: Node
@export var pesca: Pesca
@export var camara: CamaraPesca
@export var celebracion: Node
@export var tienda: Tienda
@export var bestiario: Node
@export var dialogo: Node
@export var comercio: Node
## Árbol de habilidades (lo abre el viejo).
@export var arbol: Node
## El donut: de pie en él, sube y baja con la ola.
@export var barca: Node3D
## Lo de la barca que se esconde mientras andas (el náufrago pescando, la caña...).
@export var ocultar_al_andar: Array[Node3D] = []

@export_group("Movimiento")
@export var velocidad: float = 4.0
## Altura de los pies sobre cada suelo (en el donut, sobre la base del donut).
@export var altura_barca: float = 0.54
## Profundidad dentro del donut: entre el aro de atrás y el de delante.
@export var fondo_barca: float = 0.02
@export var altura_tierra: float = 0.27
## Margen hasta el borde de la casilla.
@export var margen_borde: float = 0.25
@export var alejar_camara: float = 1.5

@export_group("Salto")
## Segundos empujando contra el agua antes de saltar.
@export var espera_salto: float = 0.12
@export var duracion_salto: float = 0.5
@export var altura_salto: float = 1.3

@export_group("Hozazo")
## Metros alrededor del náufrago que siega de una pasada.
@export var radio_hozazo: float = 3.6
@export var duracion_hozazo: float = 0.32
## Distancia de la hoz al cuerpo mientras gira.
@export var giro_hoz: float = 1.0

@export_group("Andar")
@export var bote: float = 0.06
@export var frecuencia_bote: float = 12.0

@onready var sprite: Sprite3D = $Sprite
@onready var sfx_salto: AudioStreamPlayer = $SfxSalto
@onready var cubo_mano: Sprite3D = $CuboMano
@onready var sombra: Node3D = $Sombra
@onready var hoz: Sprite3D = get_node_or_null("Hoz")
@onready var sfx_hozazo: AudioStreamPlayer = get_node_or_null("SfxHozazo")

var _segando: bool = false

var andando: bool = false
var saltando: bool = false
var cercano: Interactuable
var _empuje: float = 0.0
var _t: float = 0.0
var _y_sprite: float


func _ready() -> void:
	visible = false
	_y_sprite = sprite.position.y
	Juego.cubo_cambiado.connect(_refrescar_cubo)
	_refrescar_cubo()


func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	if event.is_action_pressed("cambiar_modo"):
		get_viewport().set_input_as_handled()
		if andando:
			intentar_volver()
		else:
			intentar_bajar()
	elif andando and not saltando and event.is_action_pressed("interactuar") and cercano:
		get_viewport().set_input_as_handled()
		interactuar(cercano)


func puede_bajar() -> bool:
	return not andando and mundo.celdas_pisables().size() > 1 and not mundo.ocupado() \
		and not pesca.en_curso() and not (celebracion and celebracion.celebrando)


func en_barca() -> bool:
	return mundo.mundo_a_celda(position) == Vector2i.ZERO


func intentar_bajar() -> void:
	if not puede_bajar():
		return
	andando = true
	Juego.en_movimiento = true
	pesca.pausar()
	# Se pone de pie dentro del donut.
	position = Vector3(0.0, _y_barca(), fondo_barca)
	visible = true
	for n: Node3D in ocultar_al_andar:
		n.visible = false
	camara.seguir(self, alejar_camara)
	modo_cambiado.emit(true)


func intentar_volver() -> void:
	if not andando or saltando or not en_barca() or Juego.cubo_en_mano:
		return
	andando = false
	Juego.en_movimiento = false
	visible = false
	cercano = null
	for n: Node3D in ocultar_al_andar:
		n.visible = true
	camara.seguir(null)
	pesca.reanudar()
	modo_cambiado.emit(false)


func interactuar(i: Interactuable) -> void:
	if i.accion == Interactuable.Accion.VENTA:
		comercio.vender_todo(i)
		return
	if i.clave_primera_vez != "" and not i.lineas_primera_vez.is_empty() and not Juego.flags.get(i.clave_primera_vez, false):
		Juego.flags[i.clave_primera_vez] = true
		dialogo.abrir(i.nombre, i.lineas_primera_vez)
		return
	# Con el cubo en la mano, cualquiera que compre peces se lo queda.
	if Juego.cubo_en_mano and i.compra_peces:
		comercio.vender_cubo(i)
		return
	if i.recibe_cosecha and Juego.total_cosecha() > 0:
		await _entregar_cosecha(i)
		return
	match i.accion:
		Interactuable.Accion.TIENDA:
			tienda.abrir(i)
		Interactuable.Accion.BESTIARIO:
			bestiario.abrir()
		Interactuable.Accion.ARBOL:
			if arbol:
				arbol.abrir(i)
		Interactuable.Accion.DIALOGO:
			dialogo.abrir(i.nombre, i.lineas)
		Interactuable.Accion.CUBO:
			if not Juego.cubo_en_mano:
				Juego.coger_cubo()
		Interactuable.Accion.COSECHAR:
			_hozazo()


## Giro con la hoz: siega todo lo listo en `radio_hozazo` y lo cosechado vuela hacia ti.
func _hozazo() -> void:
	if _segando:
		return
	_segando = true
	if sfx_hozazo:
		sfx_hozazo.play()
	var segadas: Array[Planta] = []
	for n: Node in get_tree().get_nodes_in_group("plantas"):
		var p := n as Planta
		if p and p.lista() and Vector2(p.global_position.x - position.x, p.global_position.z - position.z).length() <= radio_hozazo * (1.0 + Juego.efecto(&"radio_hozazo")):
			segadas.append(p)
	if hoz:
		hoz.visible = true
		var tw := create_tween()
		tw.tween_method(func(a: float) -> void:
			hoz.position = Vector3(cos(a) * giro_hoz, 0.7, sin(a) * giro_hoz * 0.6)
			hoz.rotation.z = -a * 2.0
			sprite.flip_h = cos(a) < 0.0, 0.0, TAU, duracion_hozazo)
		# Las plantas caen a medida que pasa la hoz.
		for p: Planta in segadas:
			_segar_en(p)
		await tw.finished
		hoz.visible = false
	else:
		for p: Planta in segadas:
			_segar_en(p)
	_segando = false


func _segar_en(p: Planta) -> void:
	var lado: float = atan2(p.global_position.z - position.z, p.global_position.x - position.x)
	await get_tree().create_timer(fposmod(lado, TAU) / TAU * duracion_hozazo, false).timeout
	var n: int = p.cosechar()
	if n <= 0 or p.cultivo == null:
		return
	if randf() < Juego.efecto(&"cosecha_doble"):
		n *= 2
	camara.sacudir(0.03)
	# Un solo icono por planta (más limpio): al llegar suma todo lo que da.
	var id: StringName = p.cultivo.id
	Vuelos.enviar(p, self, [p.cultivo.icono] as Array[Texture2D], func(_i: int) -> void: Juego.sumar_cosecha(id, n), Vuelos.sfx_pez, 1.4)


## Lo cosechado sale volando de ti hacia quien lo recibe (un icono por unidad, hasta un tope).
func _entregar_cosecha(i: Interactuable) -> void:
	var texturas: Array[Texture2D] = []
	var dado: Dictionary = Juego.entregar_cosecha()
	var dinero: float = dado.get("dinero", 0.0)
	Juego.dinero_en_camino += dinero
	for id: String in dado:
		var c: CultivoData = Juego.cultivos.get(StringName(id))
		if c and c.icono:
			for k in mini(8, ceili(int(dado[id]) / 4.0)):
				texturas.append(c.icono)
	await Vuelos.enviar(self, i, texturas, Callable(), null, 1.4)
	# O Mar te lo paga al momento.
	Juego.dinero_en_camino -= dinero
	Vuelos.enviar_dinero(i, self, dinero)


## El cubo de la mano desaparece para salir volando hacia su sitio.
func soltar_cubo_visual() -> void:
	cubo_mano.visible = false


func _refrescar_cubo() -> void:
	cubo_mano.visible = Juego.cubo_en_mano


## Con qué se puede interactuar ahora (el HUD pinta el botón encima de su cabeza). null si nada.
func objetivo_interaccion() -> Interactuable:
	if not andando or saltando or cercano == null:
		return null
	if cercano.accion == Interactuable.Accion.VENTA and comercio.peces_para_vender() == 0:
		return null
	return cercano


## Acciones de la caja de abajo a la derecha, como "[Q] Texto" (el HUD las enseña y alterna).
## Lo de interactuar (E) no va aquí: sale encima de la cabeza de con quien hablas.
func acciones() -> Array[String]:
	var lista: Array[String] = []
	if andando:
		if Juego.cubo_en_mano and (cercano == null or not cercano.compra_peces):
			lista.append("Lleva el cubo a un comerciante")
	# Bajar y volver a pescar no van aquí: el botón sale encima del náufrago cuando pisa el donut (HUD).
	return lista


## Andando encima del donut, sin cubo: se puede sentar a pescar con "cambiar_modo".
func puede_sentarse() -> bool:
	return andando and not saltando and en_barca() and not Juego.cubo_en_mano


func _process(delta: float) -> void:
	if not andando or saltando:
		return
	var entrada := Input.get_vector("mover_izq", "mover_der", "mover_arriba", "mover_abajo")
	var dir := Vector3(entrada.x, 0.0, entrada.y)
	if dir.length() > 0.05:
		_t += delta
		_mover(dir.limit_length(1.0) * velocidad * delta, delta)
		if absf(entrada.x) > 0.1:
			sprite.flip_h = entrada.x < 0.0
		sprite.position.y = _y_sprite + absf(sin(_t * frecuencia_bote)) * bote
	else:
		_empuje = 0.0
		sprite.position.y = lerpf(sprite.position.y, _y_sprite, 1.0 - exp(-12.0 * delta))
	var sobre_donut: bool = en_barca()
	position.y = _y_barca() if sobre_donut else altura_tierra + mundo.altura_en(position)
	sombra.visible = not sobre_donut
	_buscar_cercano()


func _y_barca() -> float:
	return (barca.global_position.y if barca else 0.0) + altura_barca


func _mover(paso: Vector3, delta: float) -> void:
	var pisables: Array[Vector2i] = mundo.celdas_pisables()
	var bloqueado := false
	# Eje a eje para deslizar por los bordes.
	for eje: Vector3 in [Vector3(paso.x, 0, 0), Vector3(0, 0, paso.z)]:
		if eje == Vector3.ZERO:
			continue
		var nueva: Vector3 = position + eje
		var tanteo: Vector3 = nueva + eje.normalized() * margen_borde
		# Sin escalones: solo se pasa a otra altura por las escaleras (subiendo de frente).
		var mismo_nivel: bool = absf(mundo.altura_en(tanteo) - mundo.altura_en(position)) < 0.3
		if _pisable(tanteo, pisables) and mismo_nivel:
			position = nueva
		else:
			bloqueado = true
	if not bloqueado:
		_empuje = 0.0
		return
	# Empujando contra el agua: si al otro lado (una casilla) hay suelo, salta.
	_empuje += delta
	if _empuje < espera_salto:
		return
	var cardinal: Vector3 = Vector3(signf(paso.x), 0, 0) if absf(paso.x) > absf(paso.z) else Vector3(0, 0, signf(paso.z))
	var tam: float = mundo.tamano_celda
	var celda: Vector2i = mundo.mundo_a_celda(position)
	var d := Vector2i(roundi(cardinal.x), -roundi(cardinal.z))
	var perp := Vector2i(d.y, d.x)
	var medio: Vector2i = celda + d
	# Suelo a dos casillas: justo enfrente o una casilla hacia un lado (la barca es solo 1x1).
	var salto_a := Vector2i(999, 999)
	for c: Vector2i in [celda + d * 2, celda + d * 2 + perp, celda + d * 2 - perp]:
		if c in pisables and mundo.salto_valido(celda, c):
			salto_a = c
			break
	if salto_a.x != 999 and not medio in pisables:
		var destino: Vector3 = position + cardinal * tam * 2.0
		# Que caiga dentro de la casilla destino aunque salga desde un borde.
		var centro: Vector3 = Vector3(salto_a.x * tam, 0, -salto_a.y * tam)
		var limite: float = tam * 0.5 - margen_borde
		destino.x = clampf(destino.x, centro.x - limite, centro.x + limite)
		destino.z = clampf(destino.z, centro.z - limite, centro.z + limite)
		_saltar(destino, salto_a == Vector2i.ZERO)
	_empuje = 0.0


func _pisable(p: Vector3, pisables: Array[Vector2i]) -> bool:
	return mundo.mundo_a_celda(p) in pisables


func _saltar(destino: Vector3, a_barca: bool) -> void:
	saltando = true
	cercano = null
	sfx_salto.play()
	var origen: Vector3 = position
	destino.y = _y_barca() if a_barca else altura_tierra + mundo.altura_en(destino)
	if a_barca:
		destino.z = fondo_barca
	var tw := create_tween()
	tw.tween_method(func(k: float) -> void:
		position = origen.lerp(destino, k) + Vector3.UP * sin(k * PI) * altura_salto, 0.0, 1.0, duracion_salto)
	await tw.finished
	camara.sacudir(0.05)
	sprite.scale = Vector3(1.15, 0.85, 1.0)
	create_tween().tween_property(sprite, "scale", Vector3.ONE, 0.15)
	saltando = false


func _buscar_cercano() -> void:
	cercano = null
	var mejor: float = INF
	for n: Node in get_tree().get_nodes_in_group("interactuables"):
		var i := n as Interactuable
		if not i.is_visible_in_tree():
			continue
		var d: float = Vector2(i.global_position.x - position.x, i.global_position.z - position.z).length()
		if d > i.radio:
			continue
		# Gana la prioridad; a igual prioridad, el más cercano.
		var nota: float = d - i.prioridad * 100.0
		if nota < mejor:
			mejor = nota
			cercano = i
