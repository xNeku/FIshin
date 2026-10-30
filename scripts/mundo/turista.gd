class_name Turista
extends Node3D
## Un turista. Llega montado en un barco, salta a tierra, va andando al restaurante y allí pasea y come
## de vez en cuando. Al acabar la visita vuelve al muelle y espera a que su barco lo recoja.

signal en_muelle

enum Modo { EMBARCADO, ANDANDO, PASEANDO, ESPERANDO }

@export var velocidad: float = 2.0
@export var altura_suelo: float = 0.27
@export var duracion_salto: float = 0.45
@export var altura_salto: float = 1.0
## Segundos quieto entre paseo y paseo por el restaurante.
@export var pausa_min: float = 3.0
@export var pausa_max: float = 9.0
## Lo que se aparta del centro de la casilla, para que no se amontonen.
@export var dispersion: float = 0.65

@onready var cuerpo: Sprite3D = $Cuerpo
@onready var sombra: Node3D = get_node_or_null("Sombra")

var modo: Modo = Modo.EMBARCADO
var barco: Node3D
var asiento: Vector3

var _mundo: Node
var _restaurante: Node
var _paseo: Array[Vector2i] = []
var _puntos: Array[Vector3] = []
var _saltos: Array[bool] = []
var _tras_andar: Modo = Modo.PASEANDO
var _saltando: bool = false
var _t: float = 0.0
var _t_pausa: float = 0.0
var _t_comer: float = 0.0
var _cada_comer: float = INF


func preparar(textura: Texture2D, mundo: Node, restaurante: Node, paseo: Array[Vector2i]) -> void:
	_mundo = mundo
	_restaurante = restaurante
	_paseo = paseo
	cuerpo.texture = textura
	cuerpo.offset.y = textura.get_height() * 0.5
	_t = randf() * TAU


func montar(en: Node3D, sitio: Vector3) -> void:
	barco = en
	asiento = sitio
	modo = Modo.EMBARCADO


func _process(delta: float) -> void:
	_t += delta
	if sombra:
		sombra.visible = modo != Modo.EMBARCADO and not _saltando
	match modo:
		Modo.EMBARCADO:
			if barco:
				global_position = barco.global_position + asiento
		Modo.ANDANDO:
			_andar(delta)
		Modo.PASEANDO:
			_t_pausa -= delta
			if _t_pausa <= 0.0 and not _paseo.is_empty():
				_ir_a(_paseo.pick_random(), Modo.PASEANDO)
			_comer(delta)
		Modo.ESPERANDO:
			cuerpo.position.y = 0.0


## Salta del barco a `celda` y se va al restaurante. Comerá cada `cada_comer` segundos.
func bajar(celda: Vector2i, cada_comer: float) -> void:
	_cada_comer = cada_comer
	_t_comer = randf() * cada_comer * 0.5
	modo = Modo.ANDANDO
	_saltando = true
	await _saltar(_punto(celda))
	_saltando = false
	_ir_a(_paseo.pick_random() if not _paseo.is_empty() else celda, Modo.PASEANDO)


## Vuelve andando a `celda` (el muelle) y espera allí al barco.
func irse(celda: Vector2i) -> void:
	_cada_comer = INF
	_ir_a(celda, Modo.ESPERANDO)


## Salta al barco que lo ha venido a buscar.
func subir(en: Node3D, sitio: Vector3) -> void:
	barco = en
	asiento = sitio
	modo = Modo.ANDANDO
	_saltando = true
	await _saltar(en.global_position + sitio)
	_saltando = false
	modo = Modo.EMBARCADO


func _comer(delta: float) -> void:
	_t_comer += delta
	if _t_comer < _cada_comer or _restaurante == null:
		return
	_t_comer = 0.0
	if _restaurante.servir(true):
		# Saltito de contento.
		var tw := create_tween()
		tw.tween_property(cuerpo, "position:y", 0.25, 0.12).set_ease(Tween.EASE_OUT)
		tw.tween_property(cuerpo, "position:y", 0.0, 0.18).set_ease(Tween.EASE_IN)


func _ir_a(celda: Vector2i, despues: Modo) -> void:
	var desde: Vector2i = _mundo.mundo_a_celda(global_position)
	var celdas: Array[Vector2i] = _mundo.ruta(desde, celda)
	_puntos.clear()
	_saltos.clear()
	var previa: Vector2i = desde
	for c: Vector2i in celdas:
		_puntos.append(_punto(c))
		_saltos.append((c - previa).length_squared() > 1)
		previa = c
	if celdas.is_empty() and desde == celda:
		_puntos.append(_punto(celda))
		_saltos.append(false)
	_tras_andar = despues
	modo = Modo.ANDANDO


func _andar(delta: float) -> void:
	if _saltando:
		return
	if _puntos.is_empty():
		modo = _tras_andar
		_t_pausa = randf_range(pausa_min, pausa_max)
		cuerpo.position.y = 0.0
		if modo == Modo.ESPERANDO:
			en_muelle.emit()
		return
	var obj: Vector3 = _puntos[0]
	if _saltos[0]:
		_saltando = true
		_puntos.pop_front()
		_saltos.pop_front()
		await _saltar(obj)
		_saltando = false
		return
	var hacia := Vector3(obj.x - global_position.x, 0.0, obj.z - global_position.z)
	var paso: float = velocidad * delta
	if absf(hacia.x) > 0.05:
		cuerpo.flip_h = hacia.x < 0.0
	cuerpo.position.y = absf(sin(_t * 11.0)) * 0.05
	if hacia.length() <= paso:
		global_position = obj
		_puntos.pop_front()
		_saltos.pop_front()
	else:
		global_position += hacia.normalized() * paso
		global_position.y = altura_suelo + _mundo.altura_en(global_position)


func _saltar(destino: Vector3) -> void:
	var origen: Vector3 = global_position
	if absf(destino.x - origen.x) > 0.05:
		cuerpo.flip_h = destino.x < origen.x
	var tw := create_tween()
	tw.tween_method(func(k: float) -> void:
		global_position = origen.lerp(destino, k) + Vector3.UP * sin(k * PI) * altura_salto, 0.0, 1.0, duracion_salto)
	await tw.finished


func _punto(c: Vector2i) -> Vector3:
	var p: Vector3 = _mundo.celda_a_mundo(c)
	var q := Vector3(p.x + randf_range(-dispersion, dispersion), 0.0, p.z + randf_range(-dispersion, dispersion))
	# En una escalera, sin apartarse a los lados (se caería).
	if _mundo.es_rampa(c):
		q = p
	q.y = altura_suelo + _mundo.altura_en(q)
	return q
