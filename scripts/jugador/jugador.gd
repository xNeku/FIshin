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
## Lo de la barca que se esconde mientras andas (el náufrago pescando, la caña...).
@export var ocultar_al_andar: Array[Node3D] = []

@export_group("Movimiento")
@export var velocidad: float = 4.0
## Altura de los pies sobre cada suelo.
@export var altura_barca: float = 0.2
@export var altura_tierra: float = 0.27
## Margen hasta el borde de la casilla.
@export var margen_borde: float = 0.25
@export var alejar_camara: float = 1.5

@export_group("Salto")
## Segundos empujando contra el agua antes de saltar.
@export var espera_salto: float = 0.12
@export var duracion_salto: float = 0.5
@export var altura_salto: float = 1.3

@export_group("Andar")
@export var bote: float = 0.06
@export var frecuencia_bote: float = 12.0

@onready var sprite: Sprite3D = $Sprite
@onready var sfx_salto: AudioStreamPlayer = $SfxSalto
@onready var cubo_mano: Sprite3D = $CuboMano

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
	# Se pone de pie sobre el donut.
	position = Vector3(0.0, altura_barca, 0.1)
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
	# Con el cubo en la mano, cualquiera que compre peces se lo queda.
	if Juego.cubo_en_mano and i.compra_peces:
		comercio.vender_cubo(i)
		return
	match i.accion:
		Interactuable.Accion.TIENDA:
			tienda.abrir(i)
		Interactuable.Accion.BESTIARIO:
			bestiario.abrir()
		Interactuable.Accion.DIALOGO:
			dialogo.abrir(i.nombre, i.lineas)
		Interactuable.Accion.CUBO:
			if not Juego.cubo_en_mano:
				Juego.coger_cubo()


## El cubo de la mano desaparece para salir volando hacia su sitio.
func soltar_cubo_visual() -> void:
	cubo_mano.visible = false


func _refrescar_cubo() -> void:
	cubo_mano.visible = Juego.cubo_en_mano


## Texto de ayuda para el HUD.
func ayuda() -> String:
	if andando:
		if cercano:
			if cercano.accion == Interactuable.Accion.VENTA:
				var n: int = comercio.peces_para_vender()
				return "[E] Vender todo (%d peces)" % n if n > 0 else "Lonja: no llevas nada que vender"
			if Juego.cubo_en_mano and cercano.compra_peces:
				return "[E] Vender el cubo (%d peces)" % Juego.cubo_capturas.size()
			return "[E] " + cercano.texto_accion
		if Juego.cubo_en_mano:
			return "Lleva el cubo a un comerciante"
		return "[Q] Volver a pescar" if en_barca() else ""
	return "[Q] Bajar a tierra" if puede_bajar() else ""


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
	position.y = altura_barca if en_barca() else altura_tierra
	_buscar_cercano()


func _mover(paso: Vector3, delta: float) -> void:
	var pisables: Array[Vector2i] = mundo.celdas_pisables()
	var bloqueado := false
	# Eje a eje para deslizar por los bordes.
	for eje: Vector3 in [Vector3(paso.x, 0, 0), Vector3(0, 0, paso.z)]:
		if eje == Vector3.ZERO:
			continue
		var nueva: Vector3 = position + eje
		if _pisable(nueva + eje.normalized() * margen_borde, pisables):
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
		if c in pisables:
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
	destino.y = altura_barca if a_barca else altura_tierra
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
