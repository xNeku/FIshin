extends Node3D
## Barca del náufrago: balanceo, caña, sedal y flotador. Solo visual; reacciona a la pesca.

@export var pesca: Pesca

@export_group("Balanceo")
@export var balanceo_grados: float = 2.5
@export var velocidad_balanceo: float = 1.1
@export var flote: float = 0.04
## Balanceo extra al tope de progreso (tensión).
@export var balanceo_tension: float = 4.0

@export_group("Caña")
## Lo que se dobla la caña al tope de progreso (grados).
@export var doblez_cana: float = 25.0

@export_group("Flotador")
@export var hundimiento_picada: float = 0.25
@export var temblor_maximo: float = 0.12

@onready var protagonista: Sprite3D = $Protagonista
@onready var cana: Node3D = $Cana
@onready var punta: Node3D = $Cana/Punta
@onready var sedal: Node3D = $Sedal
@onready var flotador: Node3D = $Flotador

var _t: float = 0.0
var _pos_flotador: Vector3
var _rot_cana: Vector3
var _escala_prota: Vector3
var _hundido: float = 0.0
var _progreso: float = 0.0


func _ready() -> void:
	_pos_flotador = flotador.global_position
	_rot_cana = cana.rotation
	_escala_prota = protagonista.scale
	if pesca:
		pesca.pez_pica.connect(func(_p: PezData) -> void: _hundido = hundimiento_picada)
		pesca.acierto.connect(func(_i: int, _n: int) -> void: _apretar())
		pesca.progreso_cambiado.connect(func(p: float) -> void: _progreso = p)


func _process(delta: float) -> void:
	_t += delta
	var tension: float = _progreso * balanceo_tension
	rotation_degrees.z = sin(_t * velocidad_balanceo) * (balanceo_grados + tension)
	rotation_degrees.x = sin(_t * velocidad_balanceo * 0.7) * (balanceo_grados + tension) * 0.5
	position.y = sin(_t * velocidad_balanceo * 1.3) * flote
	cana.rotation = _rot_cana + Vector3(deg_to_rad(doblez_cana * _progreso), 0.0, 0.0)

	var activo: bool = pesca != null and pesca.estado in [Pesca.Estado.PASO, Pesca.Estado.ENTRE_PASOS]
	_hundido = lerpf(_hundido, 0.08 if activo else 0.0, 1.0 - exp(-3.0 * delta))
	var temblor := Vector3.ZERO
	if activo:
		var amp: float = 0.02 + temblor_maximo * _progreso
		temblor = Vector3(randf_range(-amp, amp), randf_range(-amp, amp) * 0.5, randf_range(-amp, amp))
	flotador.global_position = _pos_flotador + Vector3(0.0, sin(_t * 2.0) * 0.03 - _hundido, 0.0) + temblor
	_colocar_sedal()


func _colocar_sedal() -> void:
	var a: Vector3 = punta.global_position
	var b: Vector3 = flotador.global_position
	var dir: Vector3 = b - a
	var largo: float = dir.length()
	if largo < 0.001:
		return
	var base := Basis(Quaternion(Vector3.UP, dir / largo)) * Basis.from_scale(Vector3(1.0, largo, 1.0))
	sedal.global_transform = Transform3D(base, a + dir * 0.5)


func _apretar() -> void:
	var tw := create_tween()
	protagonista.scale = _escala_prota * Vector3(1.12, 0.9, 1.0)
	tw.tween_property(protagonista, "scale", _escala_prota, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
