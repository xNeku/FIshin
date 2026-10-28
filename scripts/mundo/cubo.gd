extends Node3D
## El cubo del puerto. Los pescadores lo llenan; el náufrago lo coge (E), lo vende y vuelve solo.

@onready var sprite: Sprite3D = $Sprite
@onready var cuenta: Label3D = $Cuenta
@onready var interaccion: Interactuable = $Interaccion


func _ready() -> void:
	add_to_group("cubo")
	Juego.cubo_cambiado.connect(_refrescar)
	_refrescar()


func _refrescar() -> void:
	var aqui: bool = not Juego.cubo_en_mano
	sprite.visible = aqui
	cuenta.visible = aqui and not Juego.cubo_capturas.is_empty()
	cuenta.text = "%d peces" % Juego.cubo_capturas.size()
	interaccion.texto_accion = "Coger el cubo (%d peces)" % Juego.cubo_capturas.size()
	# Mientras no esté aquí no se puede coger.
	if aqui:
		interaccion.add_to_group("interactuables")
	else:
		interaccion.remove_from_group("interactuables")
