class_name Interactuable
extends Node3D
## Algo con lo que el náufrago puede interactuar (E) al estar cerca: un vendedor, el bestiario...

## VENTA: vende de golpe todo lo que llevas (barca y cubo), sin menú.
enum Accion { TIENDA, BESTIARIO, DIALOGO, CUBO, VENTA, ARBOL }

@export var accion: Accion = Accion.TIENDA
## Texto de la ayuda: "[E] <texto>".
@export var texto_accion: String = "Hablar"
@export var radio: float = 1.8
## Si hay varios a mano, gana el de más prioridad (el cubo antes que una charla).
@export var prioridad: int = 0
## Altura sobre este nodo a la que sale el botón de interactuar cuando estás cerca (su cabeza).
@export var altura_icono: float = 2.0

@export_group("Tienda")
@export var nombre: String = ""
@export var articulos: Array[ArticuloData] = []
@export var compra_peces: bool = false
@export var saludos: Array[String] = []

@export_group("Diálogo")
## Frases que dice, una tras otra (E para avanzar). El nombre se toma de "nombre".
@export_multiline var lineas: Array[String] = []


func _ready() -> void:
	add_to_group("interactuables")
