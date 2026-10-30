class_name Piti
extends Node3D
## El piti del náufrago: de noche echa humo y la brasa ilumina un poco la cara. De vez en cuando, calada.
## Se coloca solo en el píxel de la brasa del dibujo que lleve `sprite` (si ese dibujo tiene piti).

@export var sprite: Sprite3D
## Píxel de la brasa en esos dibujos.
@export var pixel: Vector2i = Vector2i(37, 24)
## Dibujos en los que sale fumando (en los demás, nada).
@export var texturas: Array[Texture2D] = []
@export_group("Brasa")
@export var energia: float = 2.2
@export var energia_calada: float = 5.0
## Segundos entre calada y calada.
@export var cada_calada_min: float = 5.0
@export var cada_calada_max: float = 11.0
@export var duracion_calada: float = 1.1
## Desde qué oscuridad se nota (0 = día, 1 = noche cerrada).
@export_range(0.0, 1.0) var desde_noche: float = 0.25

@onready var brasa: OmniLight3D = $Brasa
@onready var humo: CPUParticles3D = $Humo
## Brillo alrededor de la brasa (los dibujos no reciben luz: esto es lo que se ve en la cara).
@onready var halo: Node3D = get_node_or_null("Halo")

var _t: float = 0.0
var _t_calada: float = 0.0
var _calada: float = 0.0


func _ready() -> void:
	_t_calada = randf_range(cada_calada_min, cada_calada_max)


func _process(delta: float) -> void:
	var rd: RelojData = Juego.reloj_data
	var noche: float = rd.factor_noche(Juego.reloj) if rd else 0.0
	var fumando: bool = sprite != null and sprite.is_visible_in_tree() and sprite.texture in texturas and noche > desde_noche
	humo.emitting = fumando
	brasa.visible = fumando
	if halo:
		halo.visible = fumando
	if not fumando:
		return
	_colocar()
	_t += delta
	_t_calada -= delta
	if _t_calada <= 0.0:
		_t_calada = randf_range(cada_calada_min, cada_calada_max)
		_calada = duracion_calada
	_calada = maxf(0.0, _calada - delta)
	# La calada sube y baja; el resto del tiempo titila un poco.
	var c: float = sin(clampf(_calada / duracion_calada, 0.0, 1.0) * PI)
	var titilar: float = 0.85 + 0.15 * sin(_t * 9.0) * sin(_t * 3.7)
	brasa.light_energy = lerpf(energia, energia_calada, c) * titilar * noche
	humo.speed_scale = 1.0 + c * 0.8
	if halo:
		halo.scale = Vector3.ONE * (0.7 + 0.6 * c) * titilar * noche


func _colocar() -> void:
	var t: Texture2D = sprite.texture
	var ps: float = sprite.pixel_size
	var x: float = (pixel.x - t.get_width() * 0.5 + sprite.offset.x) * ps
	if sprite.flip_h:
		x = -x
	var y: float = (t.get_height() * 0.5 - pixel.y + sprite.offset.y) * ps
	global_position = sprite.global_position + Vector3(x, y, 0.05)
