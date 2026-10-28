extends Node
## Momento "¡has sacado algo tocho!": el náufrago levanta el pez con las dos manos, luz encima,
## primer plano y fanfarria. Solo visual; la pesca espera mientras dura.

signal empezada(pez: PezData)
signal terminada

@export var pesca: Pesca
@export var camara: CamaraPesca
@export var protagonista: Sprite3D
## Sprite del náufrago con los brazos arriba.
@export var textura_trofeo: Texture2D
@export var pez_levantado: Sprite3D
@export var luz: Light3D
@export var brillos: CPUParticles3D
@export var fanfarria: AudioStreamPlayer
## Lo que se esconde mientras sostiene el pez (caña, sedal, flotador).
@export var ocultar: Array[Node3D] = []

@export_group("Cuándo")
## Se celebra cualquier pez de esta rareza o más.
@export var rareza_minima: PezData.Rareza = PezData.Rareza.EXTRANO
## También se celebra cualquier pez de este peso o más (kg).
@export var peso_minimo: float = 15.0
## Si es true, también se celebra cualquier perfecto.
@export var celebrar_perfectos: bool = false

@export_group("Cómo")
@export var duracion: float = 3.0
@export var energia_luz: float = 8.0
## Lo que sube y baja el pez mientras lo sostiene.
@export var vaiven: float = 0.06

var celebrando: bool = false
var _textura_normal: Texture2D
var _escala_pez: Vector3
var _y_pez: float
var _t: float = 0.0


func _ready() -> void:
	_textura_normal = protagonista.texture
	_escala_pez = pez_levantado.scale
	_y_pez = pez_levantado.position.y
	pez_levantado.visible = false
	luz.light_energy = 0.0
	brillos.emitting = false
	pesca.pez_capturado.connect(_on_capturado)


func _process(delta: float) -> void:
	if celebrando:
		_t += delta
		pez_levantado.position.y = _y_pez + sin(_t * 4.0) * vaiven


func merece(captura: Dictionary, pez: PezData) -> bool:
	return pez.rareza >= rareza_minima or captura.peso >= peso_minimo or (celebrar_perfectos and captura.perfecto)


func _on_capturado(captura: Dictionary, pez: PezData) -> void:
	if merece(captura, pez) and not celebrando:
		celebrar(pez)


func celebrar(pez: PezData) -> void:
	celebrando = true
	_t = 0.0
	pesca.retener(duracion)
	camara.primer_plano(duracion)
	protagonista.texture = textura_trofeo
	for n: Node3D in ocultar:
		n.visible = false
	pez_levantado.texture = pez.icono
	pez_levantado.visible = true
	pez_levantado.scale = Vector3.ZERO
	var tw := create_tween().set_parallel(true)
	tw.tween_property(pez_levantado, "scale", _escala_pez, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(luz, "light_energy", energia_luz, 0.5)
	brillos.emitting = true
	fanfarria.play()
	var pix: Node = get_tree().get_first_node_in_group("pixelador")
	if pix:
		pix.cine(true, pez_levantado.global_position)
	empezada.emit(pez)
	await get_tree().create_timer(duracion - 0.5).timeout
	var fuera := create_tween().set_parallel(true)
	fuera.tween_property(pez_levantado, "scale", Vector3.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	fuera.tween_property(luz, "light_energy", 0.0, 0.5)
	brillos.emitting = false
	await fuera.finished
	pez_levantado.visible = false
	if pix:
		pix.cine(false)
	protagonista.texture = _textura_normal
	for n: Node3D in ocultar:
		n.visible = true
	celebrando = false
	terminada.emit()
