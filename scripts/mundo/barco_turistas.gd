class_name BarcoTuristas
extends Node3D
## Barco que trae o recoge turistas (barca, velero, catamarán...). Navega en línea recta y flota en la ola.

signal llegado

@export var velocidad: float = 6.0
@export var flotacion: float = -0.08
@export var balanceo_grados: float = 3.0
## Altura de los pasajeros sobre el barco (el casco les tapa las piernas).
@export var altura_asientos: float = -0.05

@onready var casco: Sprite3D = $Casco

var agua: Node
var _destino: Vector3
var _moviendo: bool = false
var _t: float = 0.0


func preparar(textura: Texture2D, mar: Node, cubierta: float = NAN) -> void:
	agua = mar
	if not is_nan(cubierta):
		altura_asientos = cubierta
	casco.texture = textura
	# Que solo se hunda la quilla: la base del dibujo queda un poco bajo el agua.
	casco.offset.y = textura.get_height() * 0.5 - 3.0
	_t = randf() * TAU


func navegar_a(p: Vector3) -> void:
	_destino = p
	_moviendo = true
	await llegado


## Lo ancho que es el barco (en metros).
func ancho() -> float:
	return casco.texture.get_width() * casco.pixel_size if casco.texture else 2.0


## Sitios para `n` pasajeros, repartidos a lo ancho (un poco por detrás del casco).
func asientos(n: int) -> Array[Vector3]:
	var ancho: float = casco.texture.get_width() * casco.pixel_size * 0.55
	var r: Array[Vector3] = []
	for i in n:
		var k: float = 0.5 if n == 1 else float(i) / (n - 1)
		r.append(Vector3(lerpf(-ancho * 0.5, ancho * 0.5, k), altura_asientos, -0.15 - (i % 2) * 0.1))
	return r


func _process(delta: float) -> void:
	_t += delta
	if _moviendo:
		var hacia := Vector3(_destino.x - global_position.x, 0.0, _destino.z - global_position.z)
		var paso: float = velocidad * delta
		if absf(hacia.x) > 0.05:
			casco.flip_h = hacia.x > 0.0
		if hacia.length() <= paso:
			global_position.x = _destino.x
			global_position.z = _destino.z
			_moviendo = false
			llegado.emit()
		else:
			global_position += hacia.normalized() * paso
	var y: float = agua.altura(global_position) if agua else 0.0
	global_position.y = y + flotacion + sin(_t * 1.3) * 0.04
	rotation_degrees.z = sin(_t * 0.9) * balanceo_grados
