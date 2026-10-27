class_name CamaraPesca
extends Camera3D
## Zoom y shake que crecen con la intensidad de la pesca: cuantos más botones seguidos, más dentro.

@export var pesca: Pesca
## Hacia dónde se acerca la cámara (la cabeza del náufrago).
@export var objetivo: Node3D

@export_group("Zoom")
@export var fov_zoom_maximo: float = 18.0
## Fracción del camino hacia el objetivo al llegar al perfect (0..1).
@export_range(0.0, 0.95) var acercamiento: float = 0.5
## Opcional: forma del zoom según la intensidad (x = intensidad, y = zoom).
@export var curva_zoom: Curve
@export var suavizado: float = 5.0
## Golpe de fov en cada acierto al máximo de intensidad (grados). Con poca intensidad es menor.
@export var patada_fov: float = 2.5
@export var patada_fov_minima: float = 0.3

@export_group("Shake")
@export var shake_base: float = 0.0
@export var shake_maximo: float = 0.08
@export var golpe_picada: float = 0.05
@export var golpe_acierto: float = 0.03
@export var golpe_fallo: float = 0.12
@export var golpe_captura: float = 0.15
@export var decaimiento_golpe: float = 5.0
@export var giro_maximo_grados: float = 3.0
@export var frecuencia: float = 22.0

@export_group("Primer plano (celebración)")
## Zoom (0..1) al que llega la cámara cuando el náufrago levanta el pez.
@export_range(0.0, 1.0) var zoom_primer_plano: float = 0.9
## Cuánto sube el punto de mira (hacia el pez levantado).
@export var altura_primer_plano: float = 0.9

@export_group("Foco (cinemáticas del mundo)")
@export var velocidad_foco: float = 2.0

@export_group("Impacto")
## Congelado breve al capturar (segundos reales). 0 = nada.
@export var pausa_captura: float = 0.08
@export var pausa_perfecto: float = 0.18

var _pos_base: Vector3
var _mirar_base: Vector3
var _fov_base: float
var _intensidad_objetivo: float = 0.0
var _intensidad: float = 0.0
var _t_primer_plano: float = 0.0
var _golpe: float = 0.0
var _zoom_celebracion: float = 0.0
var _patada: float = 0.0
var _foco: Vector3
var _t_foco: float = 0.0
var _peso_foco: float = 0.0
var _alejar_foco: float = 0.0
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
		pesca.intensidad_cambiada.connect(func(i: float) -> void: _intensidad_objetivo = i)
		pesca.pez_pica.connect(func(_p: PezData) -> void: _golpe += golpe_picada)
		pesca.acierto.connect(_on_acierto)
		pesca.fallo.connect(func() -> void: _golpe += golpe_fallo)
		pesca.machacar_progreso.connect(func(_g: int, _n: int) -> void: _golpe += golpe_acierto * 0.4)
		pesca.pez_capturado.connect(_on_capturado)


func _process(delta: float) -> void:
	var dt: float = Juego.delta_real(delta)
	_t += dt
	_intensidad = lerpf(_intensidad, _intensidad_objetivo, 1.0 - exp(-suavizado * dt))
	var z: float = curva_zoom.sample(_intensidad) if curva_zoom else _intensidad
	var obj: Vector3 = objetivo.global_position if objetivo else _mirar_base
	_t_primer_plano = maxf(0.0, _t_primer_plano - dt)
	if _t_primer_plano > 0.0:
		_zoom_celebracion = lerpf(_zoom_celebracion, zoom_primer_plano, 1.0 - exp(-3.0 * dt))
	else:
		_zoom_celebracion = lerpf(_zoom_celebracion, 0.0, 1.0 - exp(-2.0 * dt))
	z = maxf(z, _zoom_celebracion)
	obj += Vector3.UP * altura_primer_plano * _zoom_celebracion
	_t_foco = maxf(0.0, _t_foco - dt)
	_peso_foco = lerpf(_peso_foco, 1.0 if _t_foco > 0.0 else 0.0, 1.0 - exp(-velocidad_foco * dt))
	var desp: Vector3 = (_foco - _mirar_base) * _peso_foco
	var atras: Vector3 = (_pos_base - _mirar_base).normalized() * _alejar_foco * _peso_foco
	global_position = _pos_base.lerp(obj, acercamiento * z) + desp + atras
	look_at(_mirar_base.lerp(obj, z) + desp)
	_patada = lerpf(_patada, 0.0, 1.0 - exp(-10.0 * dt))
	fov = lerpf(_fov_base, fov_zoom_maximo, z) - _patada
	_golpe = lerpf(_golpe, 0.0, 1.0 - exp(-decaimiento_golpe * dt))
	var trauma: float = shake_base + shake_maximo * _intensidad * _intensidad + _golpe
	var tn: float = _t * frecuencia
	h_offset = _ruido.get_noise_2d(tn, 0.0) * trauma
	v_offset = _ruido.get_noise_2d(0.0, tn) * trauma
	rotate_object_local(Vector3.BACK, deg_to_rad(giro_maximo_grados) * _ruido.get_noise_2d(tn, tn) * minf(trauma * 4.0, 1.0))


## Lleva la cámara a mirar un punto del mundo durante unos segundos. alejar > 0 la echa hacia atrás.
func enfocar(punto: Vector3, segundos: float, alejar: float = 0.0) -> void:
	_foco = Vector3(punto.x, 0.0, punto.z)
	_t_foco = segundos
	_alejar_foco = alejar


## Golpe de cámara puntual (impactos).
func sacudir(fuerza: float) -> void:
	_golpe += fuerza


## Acercamiento dramático durante una celebración.
func primer_plano(segundos: float) -> void:
	_t_primer_plano = segundos


func _on_acierto(_indice: int, _total: int) -> void:
	_golpe += golpe_acierto * (0.5 + _intensidad_objetivo)
	_patada += lerpf(patada_fov_minima, patada_fov, _intensidad_objetivo)


func _on_capturado(captura: Dictionary, _pez: PezData) -> void:
	_golpe += golpe_captura * (2.0 if captura.perfecto else 1.0)
	_congelar(pausa_perfecto if captura.perfecto else pausa_captura)


func _congelar(segundos: float) -> void:
	if segundos <= 0.0:
		return
	Engine.time_scale = 0.05
	await get_tree().create_timer(segundos, true, false, true).timeout
	Engine.time_scale = 1.0
