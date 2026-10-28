class_name Interactuable
extends Node3D
## Algo con lo que el náufrago puede interactuar (E) al estar cerca: un vendedor, el bestiario...

enum Accion { TIENDA, BESTIARIO }

@export var accion: Accion = Accion.TIENDA
## Texto de la ayuda: "[E] <texto>".
@export var texto_accion: String = "Hablar"
@export var radio: float = 1.8

@export_group("Tienda")
@export var nombre: String = ""
@export var articulos: Array[ArticuloData] = []
@export var compra_peces: bool = false
@export var saludos: Array[String] = []


func _ready() -> void:
	add_to_group("interactuables")
