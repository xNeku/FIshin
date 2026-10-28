extends CanvasLayer
## Estilo del juego: el mundo 3D se dibuja a baja resolución y se escala sin suavizar (todo pixelado).
## El HUD y los menús van por encima a resolución completa.

## Cámara del juego que se copia cada frame (zoom, shake...).
@export var camara_fuente: Camera3D
## Cuánto se reduce la resolución del mundo (4 = una cuarta parte).
@export_range(1, 8) var encogimiento: int = 4

@onready var contenedor: SubViewportContainer = $Contenedor
@onready var vista: SubViewport = $Contenedor/Vista
@onready var camara: Camera3D = $Contenedor/Vista/CamaraPixel


func _ready() -> void:
	add_to_group("pixelador")
	contenedor.stretch_shrink = encogimiento
	# El 3D solo se dibuja en la vista pixelada; el principal queda para la interfaz.
	get_viewport().disable_3d = true
	camara.current = true


func _process(_delta: float) -> void:
	if camara_fuente == null:
		return
	camara.global_transform = camara_fuente.global_transform
	camara.fov = camara_fuente.fov
	camara.h_offset = camara_fuente.h_offset
	camara.v_offset = camara_fuente.v_offset
