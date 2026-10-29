extends CanvasLayer
## Filtro retro (tele de tubo) por encima de todo. Se enciende o apaga desde Opciones;
## se guarda en Juego.flags["filtro_crt"]. Los valores del efecto están en el material del nodo Filtro.

@onready var filtro: ColorRect = $Filtro


func _ready() -> void:
	add_to_group("crt")
	filtro.visible = activo()


func activo() -> bool:
	return Juego.flags.get("filtro_crt", true)


func activar(si: bool) -> void:
	Juego.flags["filtro_crt"] = si
	Juego.guardar()
	filtro.visible = si
