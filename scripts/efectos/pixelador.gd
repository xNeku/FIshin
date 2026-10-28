extends CanvasLayer
## Estilo del juego: el mundo 3D se dibuja a baja resolución y se escala sin suavizar (todo pixelado).
## El HUD y los menús van por encima a resolución completa. En las cinemáticas entra un desenfoque
## de profundidad (efecto maqueta).

## Cámara del juego que se copia cada frame (zoom, shake...).
@export var camara_fuente: Camera3D
## Cuánto se reduce la resolución del mundo (4 = una cuarta parte).
@export_range(1, 8) var encogimiento: int = 4

@export_group("Cinemáticas (desenfoque)")
@export var desenfoque: float = 0.14
## Metros alrededor del punto enfocado que quedan nítidos.
@export var margen_nitido: float = 3.0
@export var transicion: float = 4.0
@export var duracion_fundido: float = 0.6

@onready var contenedor: SubViewportContainer = $Contenedor
@onready var vista: SubViewport = $Contenedor/Vista
@onready var camara: Camera3D = $Contenedor/Vista/CamaraPixel

var _atributos: CameraAttributesPractical
var _tween: Tween
var _enfocando: bool = false
var _punto: Vector3 = Vector3.ZERO


func _ready() -> void:
	add_to_group("pixelador")
	contenedor.stretch_shrink = encogimiento
	# El 3D solo se dibuja en la vista pixelada; el principal queda para la interfaz.
	get_viewport().disable_3d = true
	_atributos = camara.attributes as CameraAttributesPractical
	if _atributos:
		_atributos.dof_blur_amount = 0.0
		_atributos.dof_blur_far_enabled = false
		_atributos.dof_blur_near_enabled = false
	camara.current = true


func _process(_delta: float) -> void:
	if camara_fuente == null:
		return
	camara.global_transform = camara_fuente.global_transform
	camara.fov = camara_fuente.fov
	camara.h_offset = camara_fuente.h_offset
	camara.v_offset = camara_fuente.v_offset
	# La cámara se acerca durante la cinemática: el foco se recalcula cada frame.
	if _enfocando:
		_enfocar()


func _enfocar() -> void:
	var d: float = camara.global_position.distance_to(_punto)
	_atributos.dof_blur_far_distance = d + margen_nitido
	_atributos.dof_blur_near_distance = maxf(0.1, d - margen_nitido)


## Activa o quita el desenfoque de maqueta, enfocando un punto del mundo.
func cine(activo: bool, punto: Vector3 = Vector3.ZERO) -> void:
	if _atributos == null:
		return
	if _tween:
		_tween.kill()
	_enfocando = activo
	if activo:
		_punto = punto
		_enfocar()
		_atributos.dof_blur_far_transition = transicion
		_atributos.dof_blur_near_transition = transicion * 0.5
		_atributos.dof_blur_far_enabled = true
		_atributos.dof_blur_near_enabled = true
	_tween = create_tween()
	_tween.tween_property(_atributos, "dof_blur_amount", desenfoque if activo else 0.0, duracion_fundido)
	if not activo:
		_tween.tween_callback(func() -> void:
			_atributos.dof_blur_far_enabled = false
			_atributos.dof_blur_near_enabled = false)
