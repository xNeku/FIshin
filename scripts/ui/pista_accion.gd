class_name PistaAccion
extends HBoxContainer
## Pista de un botón en los menús: el dibujo de la tecla o del botón del mando (según lo último que tocaste)
## y un texto. Se pone como instancia de scenes/ui/pista_accion.tscn y se elige la acción en el inspector.

@export var accion: StringName = &"ui_accept"
@export var texto: String = "Aceptar":
	set(v):
		texto = v
		if is_node_ready():
			etiqueta.text = v

@onready var icono: TextureRect = $Icono
@onready var etiqueta: Label = $Texto

var _dispositivo: String = ""


func _ready() -> void:
	etiqueta.text = texto
	_refrescar()


func _input(event: InputEvent) -> void:
	# Con el juego en pausa nadie más mira qué se ha tocado: lo miran las pistas de los menús.
	IconosInput.detectar(event)


func _process(_delta: float) -> void:
	if IconosInput.dispositivo != _dispositivo:
		_refrescar()


func _refrescar() -> void:
	_dispositivo = IconosInput.dispositivo
	icono.texture = IconosInput.icono(accion)
