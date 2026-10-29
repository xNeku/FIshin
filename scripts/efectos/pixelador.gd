extends CanvasLayer
## Estilo del juego: el mundo 3D se dibuja a baja resolución y se escala sin suavizar (todo pixelado).
## El HUD y los menús van por encima a resolución completa.

## Cámara del juego que se copia cada frame (zoom, shake...).
@export var camara_fuente: Camera3D
## Cuánto se reduce la resolución del mundo (4 = una cuarta parte, píxeles grandes; 2 = píxeles finos).
## El jugador lo cambia en Opciones; esto es lo que sale la primera vez.
@export_range(1, 8) var encogimiento: int = 3

@onready var contenedor: SubViewportContainer = $Contenedor
@onready var vista: SubViewport = $Contenedor/Vista
@onready var camara: Camera3D = $Contenedor/Vista/CamaraPixel


func _ready() -> void:
	add_to_group("pixelador")
	poner_encogimiento(int(Juego.opcion("pixel_mundo", encogimiento)))
	# El 3D solo se dibuja en la vista pixelada; el principal queda para la interfaz.
	get_viewport().disable_3d = true
	camara.current = true


func poner_encogimiento(n: int) -> void:
	encogimiento = clampi(n, 1, 8)
	contenedor.stretch_shrink = encogimiento


func _process(_delta: float) -> void:
	_noche()
	if camara_fuente == null:
		return
	camara.global_transform = camara_fuente.global_transform
	camara.fov = camara_fuente.fov
	camara.h_offset = camara_fuente.h_offset
	camara.v_offset = camara_fuente.v_offset


## Oscurece y tiñe el mundo según la hora (reloj del juego; colores en data/reloj.tres).
func _noche() -> void:
	var rd: RelojData = Juego.reloj_data
	var m: ShaderMaterial = contenedor.material as ShaderMaterial
	if rd == null or m == null:
		return
	m.set_shader_parameter("noche", rd.factor_noche(Juego.reloj))
	m.set_shader_parameter("ocaso", rd.factor_ocaso(Juego.reloj))
	m.set_shader_parameter("tinte_noche", rd.tinte_noche)
	m.set_shader_parameter("tinte_ocaso", rd.tinte_ocaso)
