extends Node3D
## El náufrago de chill en su donut: pose según la pesca, caña con sedal hasta el corcho,
## lanzado y recogida del corcho, y ondas en el agua. Solo visual; reacciona a la Pesca.
## El donut va encima de la ola (lo dice el Agua), con sombra y espuma pegadas al agua.
## Capas, de atrás a delante: DonutAtras, Protagonista, DonutDelante, Piernas (mismo lienzo).

@export var pesca: Pesca
@export var agua: Agua

@export_group("Poses")
@export var textura_chill: Texture2D
@export var textura_tira: Texture2D
## Píxel de la punta de la caña en cada sprite (para atar el sedal).
@export var punta_chill: Vector2i = Vector2i(63, 19)
@export var punta_tira: Vector2i = Vector2i(63, 17)

@export_group("Flotar")
## Cuánto asoma el donut por encima del agua (metros).
@export var flotacion: float = 0.04
## Cuánto se inclina con la pendiente de la ola (0 = nada, 1 = como el agua).
@export var inclinacion_ola: float = 0.6
## La sombra se adelanta un poco hacia la cámara para que se vea bajo el aro.
@export var desfase_sombra: Vector3 = Vector3(0.1, 0.0, 0.25)
@export var escala_espuma: float = 1.9

@export_group("Balanceo")
@export var balanceo_grados: float = 1.5
@export var velocidad_balanceo: float = 1.1
@export var flote: float = 0.04
## Balanceo extra al tope de intensidad (tensión).
@export var balanceo_tension: float = 3.0

@export_group("Corcho")
## Dónde cae el corcho, relativo al donut.
@export var punto_corcho: Vector3 = Vector3(1.4, 0.0, -1.7)
@export var duracion_lanzado: float = 0.55
@export var altura_lanzado: float = 1.6
@export var hundimiento_picada: float = 0.18
## Picoteos mientras esperas: el de mentira y el aviso de justo antes de picar.
@export var hundimiento_picoteo: float = 0.05
@export var hundimiento_aviso: float = 0.1
@export var temblor_maximo: float = 0.12

@export_group("Ondas")
@export var periodo_calma: float = 2.0
@export var periodo_picada: float = 0.45
@export var escala_onda: float = 2.2

@onready var protagonista: Sprite3D = $Protagonista
@onready var punta: Marker3D = $Cana/Punta
@onready var sedal: Node3D = $Sedal
@onready var flotador: Node3D = $Flotador
@onready var ondas: Sprite3D = $Ondas
@onready var salpicadura: CPUParticles3D = $Salpicadura
@onready var sombra: Sprite3D = $Sombra
@onready var espuma: Sprite3D = $Espuma

var _t: float = 0.0
var _intensidad: float = 0.0
var _hundido: float = 0.0
var _corcho_en_agua: bool = false
var _volando: bool = false
var _t_onda: float = 0.0


func _ready() -> void:
	_poner_pose(textura_chill, punta_chill)
	flotador.global_position = punta.global_position
	ondas.visible = false
	if pesca:
		pesca.estado_cambiado.connect(_on_estado)
		pesca.pez_pica.connect(func(_p: PezData) -> void:
			_hundido = hundimiento_picada
			_poner_pose(textura_tira, punta_tira)
			_salpicar(18))
		pesca.picoteo.connect(func(aviso: bool) -> void:
			_hundido = hundimiento_aviso if aviso else hundimiento_picoteo
			_salpicar(4 if aviso else 2))
		pesca.acierto.connect(func(_i: int, _n: int) -> void: _apretar())
		pesca.intensidad_cambiada.connect(func(i: float) -> void: _intensidad = i)
		_on_estado(pesca.estado)


func _on_estado(e: Pesca.Estado) -> void:
	match e:
		Pesca.Estado.ESPERANDO:
			_poner_pose(textura_chill, punta_chill)
			if not _corcho_en_agua:
				_lanzar()
		Pesca.Estado.RESULTADO, Pesca.Estado.INACTIVO:
			_recoger()


func _process(delta: float) -> void:
	_t += delta
	var tension: float = _intensidad * balanceo_tension
	var base := Vector3(global_position.x, 0.0, global_position.z)
	var y_agua: float = agua.altura(global_position) if agua else 0.0
	var pend: Vector2 = agua.pendiente(global_position) if agua else Vector2.ZERO
	rotation_degrees.z = sin(_t * velocidad_balanceo) * (balanceo_grados + tension) - rad_to_deg(atan(pend.x)) * inclinacion_ola
	position.y = y_agua + flotacion + sin(_t * velocidad_balanceo * 1.3) * flote
	espuma.scale = Vector3.ONE * escala_espuma * (1.0 + sin(_t * 1.7) * 0.04)
	_pegar_al_agua(sombra, base + desfase_sombra, 0.06)
	_pegar_al_agua(espuma, base, 0.07)

	if _corcho_en_agua and not _volando:
		var activo: bool = pesca != null and pesca.en_curso()
		_hundido = lerpf(_hundido, 0.06 if activo else 0.0, 1.0 - exp(-3.0 * delta))
		var temblor := Vector3.ZERO
		if activo:
			var amp: float = 0.02 + temblor_maximo * _intensidad
			temblor = Vector3(randf_range(-amp, amp), 0.0, randf_range(-amp, amp))
		flotador.global_position = _punto_agua() + Vector3(0.0, sin(_t * 2.0) * 0.03 - _hundido, 0.0) + temblor
		_animar_ondas(delta, activo)
	_colocar_sedal()


func _punto_agua() -> Vector3:
	var p: Vector3 = global_position * Vector3(1, 0, 1) + punto_corcho
	return p + Vector3.UP * ((agua.altura(p) if agua else 0.0) + 0.05)


func _pegar_al_agua(nodo: Sprite3D, p: Vector3, alto: float) -> void:
	if agua:
		agua.pegar(nodo, p, alto)
	else:
		nodo.global_position = Vector3(p.x, alto, p.z)


## Coloca la pose y mueve la punta de la caña al píxel que toca en ese sprite.
func _poner_pose(textura: Texture2D, pixel: Vector2i) -> void:
	if textura:
		protagonista.texture = textura
	var t: Texture2D = protagonista.texture
	var ps: float = protagonista.pixel_size
	var o: Vector2 = protagonista.offset
	punta.position = protagonista.position + Vector3((pixel.x - t.get_width() * 0.5 + o.x) * ps, (t.get_height() * 0.5 - pixel.y + o.y) * ps, 0.02)


func _lanzar() -> void:
	_volando = true
	ondas.visible = false
	var desde: Vector3 = punta.global_position
	var hasta: Vector3 = _punto_agua()
	var tw := create_tween()
	tw.tween_method(func(k: float) -> void:
		flotador.global_position = desde.lerp(hasta, k) + Vector3.UP * sin(k * PI) * altura_lanzado, 0.0, 1.0, duracion_lanzado).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
	_volando = false
	_corcho_en_agua = true
	_salpicar(8)
	_t_onda = periodo_calma


func _recoger() -> void:
	if not _corcho_en_agua:
		return
	_corcho_en_agua = false
	_volando = true
	ondas.visible = false
	var desde: Vector3 = flotador.global_position
	var tw := create_tween()
	tw.tween_method(func(k: float) -> void:
		flotador.global_position = desde.lerp(punta.global_position, k) + Vector3.UP * sin(k * PI) * 0.6, 0.0, 1.0, 0.35)
	await tw.finished
	_volando = false


func _animar_ondas(delta: float, activo: bool) -> void:
	var periodo: float = periodo_picada if activo else periodo_calma
	_t_onda += delta
	if _t_onda >= periodo:
		_t_onda = 0.0
	var k: float = _t_onda / periodo
	ondas.visible = true
	ondas.scale = Vector3.ONE * lerpf(0.4, escala_onda, k)
	_pegar_al_agua(ondas, _punto_agua(), 0.03)
	ondas.modulate.a = 1.0 - k


func _salpicar(cantidad: int) -> void:
	salpicadura.global_position = flotador.global_position
	salpicadura.amount = maxi(1, cantidad)
	salpicadura.restart()
	salpicadura.emitting = true


func _colocar_sedal() -> void:
	var a: Vector3 = punta.global_position
	var b: Vector3 = flotador.global_position + Vector3.UP * 0.12
	var dir: Vector3 = b - a
	var largo: float = dir.length()
	if largo < 0.05:
		sedal.visible = false
		return
	sedal.visible = protagonista.visible
	var base := Basis(Quaternion(Vector3.UP, dir / largo)) * Basis.from_scale(Vector3(1.0, largo, 1.0))
	sedal.global_transform = Transform3D(base, a + dir * 0.5)


func _apretar() -> void:
	var tw := create_tween()
	protagonista.scale = Vector3(1.08, 0.94, 1.0)
	tw.tween_property(protagonista, "scale", Vector3.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
