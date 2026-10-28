class_name Trabajador
extends Node3D
## Pescador del puerto: va a su puesto, pesca solo el pez más barato hasta llenar su bolsa
## y la lleva andando al cubo. Sin colisión: nunca bloquea el paso.

enum Estado { YENDO_A_PUESTO, PESCANDO, YENDO_AL_CUBO, ESPERANDO_CUBO, DEJANDO }

@export var textura_pie: Texture2D
@export var textura_sentado: Texture2D
@export var velocidad: float = 2.2
## Segundos de media por pez.
@export var tiempo_por_pez: float = 4.5
@export_range(0.0, 1.0) var variacion: float = 0.4
## Peces que coge antes de ir al cubo.
@export var capacidad: int = 10
## Calidad de sus capturas (0..1). Pescan peor que tú.
@export_range(0.0, 1.0) var calidad: float = 0.3
@export var altura_suelo: float = 0.25
## Cuánto se acerca al borde: de pie y sentado (0 = centro de la casilla, 1 = el borde).
@export var borde_pie: float = 0.6
@export var borde_sentado: float = 0.85
@export var duracion_salto: float = 0.5
@export var altura_salto: float = 1.2

@onready var sprite: Sprite3D = $Sprite
@onready var cuenta: Label3D = $Cuenta
@onready var pez_pescado: Sprite3D = $PezPescado
@onready var charla: Interactuable = $Charla

var estado: Estado = Estado.YENDO_A_PUESTO
var puesto: Dictionary = {}
var sentado: bool = false
var bolsa: Array[Dictionary] = []
var _mundo: Node
var _puerto: Node
var _pez: PezData
var _ruta: Array[Vector2i] = []
var _destino_final: Vector3
var _saltando: bool = false
var _t_pez: float = 0.0
var _y_sprite: float
var _t: float = 0.0


func _ready() -> void:
	_y_sprite = sprite.position.y
	pez_pescado.visible = false
	_actualizar_cuenta()


func iniciar(mundo: Node, puerto: Node, pez: PezData, puesto_asignado: Dictionary, sentarse: bool, celda_inicial: Vector2i) -> void:
	_mundo = mundo
	_puerto = puerto
	_pez = pez
	puesto = puesto_asignado
	sentado = sentarse
	global_position = _mundo.celda_a_mundo(celda_inicial) + Vector3.UP * altura_suelo
	_ir_a(puesto.celda, _pos_puesto())
	estado = Estado.YENDO_A_PUESTO


func _process(delta: float) -> void:
	if _mundo == null:
		return
	_t += delta
	match estado:
		Estado.YENDO_A_PUESTO, Estado.YENDO_AL_CUBO:
			_andar(delta)
		Estado.PESCANDO:
			_pescar(delta)
		Estado.ESPERANDO_CUBO:
			if not Juego.cubo_en_mano:
				_dejar()


func _ir_a(celda: Vector2i, destino_final: Vector3) -> void:
	_ruta = _mundo.ruta(_mundo.mundo_a_celda(global_position), celda)
	_destino_final = destino_final
	sprite.texture = textura_pie


func _andar(delta: float) -> void:
	if _saltando:
		return
	var objetivo: Vector3 = _destino_final
	if not _ruta.is_empty():
		var siguiente: Vector2i = _ruta[0]
		var actual: Vector2i = _mundo.mundo_a_celda(global_position)
		if (siguiente - actual).length_squared() > 1:
			_saltar(_mundo.celda_a_mundo(siguiente) + Vector3.UP * altura_suelo)
			_ruta.pop_front()
			return
		objetivo = _mundo.celda_a_mundo(siguiente) + Vector3.UP * altura_suelo
	var hacia: Vector3 = objetivo - global_position
	hacia.y = 0.0
	var paso: float = velocidad * delta
	if hacia.length() <= paso:
		global_position = Vector3(objetivo.x, altura_suelo, objetivo.z)
		if not _ruta.is_empty():
			_ruta.pop_front()
		else:
			_llegar()
		return
	global_position += hacia.normalized() * paso
	if absf(hacia.x) > 0.05:
		sprite.flip_h = hacia.x < 0.0
	sprite.position.y = _y_sprite + absf(sin(_t * 12.0)) * 0.05


func _saltar(destino: Vector3) -> void:
	_saltando = true
	var origen: Vector3 = global_position
	var tw := create_tween()
	tw.tween_method(func(k: float) -> void:
		global_position = origen.lerp(destino, k) + Vector3.UP * sin(k * PI) * altura_salto, 0.0, 1.0, duracion_salto)
	await tw.finished
	_saltando = false


func _llegar() -> void:
	sprite.position.y = _y_sprite
	match estado:
		Estado.YENDO_A_PUESTO:
			estado = Estado.PESCANDO
			sprite.texture = textura_sentado if sentado else textura_pie
			sprite.flip_h = puesto.dir.x < 0
			_t_pez = _siguiente_pez()
		Estado.YENDO_AL_CUBO:
			estado = Estado.ESPERANDO_CUBO


func _pescar(delta: float) -> void:
	# Pequeño vaivén de la caña.
	sprite.position.y = _y_sprite + sin(_t * 2.0) * 0.015
	_t_pez -= delta
	if _t_pez > 0.0:
		return
	bolsa.append(_crear_captura())
	_actualizar_cuenta()
	_mostrar_pez()
	if bolsa.size() >= capacidad:
		estado = Estado.YENDO_AL_CUBO
		_ir_a(_puerto.celda_cubo, _puerto.punto_entrega())
	else:
		_t_pez = _siguiente_pez()


func _dejar() -> void:
	estado = Estado.DEJANDO
	var entrega: Array[Dictionary] = bolsa.duplicate()
	bolsa.clear()
	_actualizar_cuenta()
	await Vuelos.enviar_peces(self, _puerto.cubo, entrega, func(grupo: Array) -> void:
		var g: Array[Dictionary] = []
		g.assign(grupo)
		Juego.meter_en_cubo(g))
	estado = Estado.YENDO_A_PUESTO
	_ir_a(puesto.celda, _pos_puesto())


func _siguiente_pez() -> float:
	return tiempo_por_pez * randf_range(1.0 - variacion, 1.0 + variacion)


func _crear_captura() -> Dictionary:
	var peso: float = randf_range(_pez.peso_min, _pez.peso_max)
	var media: float = (_pez.peso_min + _pez.peso_max) * 0.5
	return {"id": String(_pez.id), "peso": peso, "calidad": calidad, "perfecto": false,
		"valor": _pez.valor_base * (peso / media) * lerpf(0.3, 1.0, calidad)}


func _pos_puesto() -> Vector3:
	var c: Vector3 = _mundo.celda_a_mundo(puesto.celda)
	var d := Vector3(puesto.dir.x, 0.0, -puesto.dir.y)
	var lateral := Vector3(-d.z, 0.0, d.x) * randf_range(-0.4, 0.4)
	return c + d * _mundo.tamano_celda * 0.5 * (borde_sentado if sentado else borde_pie) + lateral + Vector3.UP * altura_suelo


func _mostrar_pez() -> void:
	pez_pescado.texture = _pez.icono
	pez_pescado.visible = true
	pez_pescado.position.y = 1.4
	var tw := create_tween()
	tw.tween_property(pez_pescado, "position:y", 2.0, 0.6).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void: pez_pescado.visible = false)


func _actualizar_cuenta() -> void:
	cuenta.text = "%d/%d" % [bolsa.size(), capacidad]
	cuenta.visible = bolsa.size() > 0
