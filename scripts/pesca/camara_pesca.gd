extends Camera3D
## Zoom y shake que crecen con la progresión de la pesca: cada acierto te mete más dentro.

@export var pesca: Pesca
## Hacia dónde se acerca la cámara (la cabeza del náufrago).
@export var objetivo: Node3D

@export_group("Zoom")
@export var fov_zoom_maximo: float = 18.0
## Fracción del camino hacia el objetivo al llegar al perfect (0..1).
@export_range(0.0, 0.95) var acercamiento: float = 0.5
## Opcional: forma del zoom según el progreso (x = progreso, y = zoom).
@export var curva_zoom: Curve
@export var suavizado: float = 5.0
## Golpe de fov en cada acierto (grados).
@export var patada_fov: float = 2.5

@export_group("Shake")
@export var shake_base: float = 0.0
@export var shake_maximo: float = 0.08
@export var golpe_picada: float = 0.12
@export var golpe_acierto: float = 0.05
@export var golpe_fallo: float = 0.3
@export var golpe_captura: float = 0.4
@export var decaimiento_golpe: float = 5.0
@export var giro_maximo_grados: float = 3.0
@export var frecuencia: float = 22.0

@export_group("Impacto")
## Congelado breve al capturar (segundos reales). 0 = nada.
@export var pausa_captura: float = 0.08
@export var pausa_perfecto: float = 0.18

var _pos_base: Vector3
var _mirar_base: Vector3
var _fov_base: float
var _progreso_objetivo: float = 0.0
var _progreso: float = 0.0
var _golpe: float = 0.0
var _patada: float = 0.0
var _t: float = 0.0
var _ruido := FastNoiseLite.new()


func _ready() -> void:
	_pos_base = global_position
	_fov_base = fov
	var adelante: Vector3 = -global_basis.z
	var d: float = -_pos_base.y / adelante.y if absf(adelante.y) > 0.001 else 10.0
	_mirar_base = _pos_base + adelante * d
	_ruido.frequency = 1.0
	if pesca:
		pesca.progreso_cambiado.connect(func(p: float) -> void: _progreso_objetivo = p)
		pesca.pez_pica.connect(func(_p: PezData) -> void: _golpe += golpe_picada)
		pesca.acierto.connect(_on_acierto)
		pesca.fallo.connect(func() -> void: _golpe += golpe_fallo)
		pesca.machacar_progreso.connect(func(_g: int, _n: int) -> void: _golpe += golpe_acierto * 0.4)
		pesca.pez_capturado.connect(_on_capturado)


func _process(delta: float) -> void:
	var dt: float = delta / maxf(Engine.time_scale, 0.001)
	_t += dt
	_progreso = lerpf(_progreso, _progreso_objetivo, 1.0 - exp(-suavizado * dt))
	var z: float = curva_zoom.sample(_progreso) if curva_zoom else _progreso
	var obj: Vector3 = objetivo.global_position if objetivo else _mirar_base
	global_position = _pos_base.lerp(obj, acercamiento * z)
	look_at(_mirar_base.lerp(obj, z))
	_patada = lerpf(_patada, 0.0, 1.0 - exp(-10.0 * dt))
	fov = lerpf(_fov_base, fov_zoom_maximo, z) - _patada
	_golpe = lerpf(_golpe, 0.0, 1.0 - exp(-decaimiento_golpe * dt))
	var trauma: float = shake_base + shake_maximo * z * z + _golpe
	var tn: float = _t * frecuencia
	h_offset = _ruido.get_noise_2d(tn, 0.0) * trauma
	v_offset = _ruido.get_noise_2d(0.0, tn) * trauma
	rotate_object_local(Vector3.BACK, deg_to_rad(giro_maximo_grados) * _ruido.get_noise_2d(tn, tn) * minf(trauma * 4.0, 1.0))


func _on_acierto(indice: int, total: int) -> void:
	_golpe += golpe_acierto * (1.0 + float(indice) / float(total))
	_patada += patada_fov


func _on_capturado(captura: Dictionary, _pez: PezData) -> void:
	_golpe += golpe_captura * (2.0 if captura.perfecto else 1.0)
	_congelar(pausa_perfecto if captura.perfecto else pausa_captura)


func _congelar(segundos: float) -> void:
	if segundos <= 0.0:
		return
	Engine.time_scale = 0.05
	await get_tree().create_timer(segundos, true, false, true).timeout
	Engine.time_scale = 1.0
