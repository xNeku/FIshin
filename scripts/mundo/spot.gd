class_name Spot
extends Isla
## Spot de pesca activa (llega como aparición). El donut viene remando hasta `punto_barca` y aquí se juega
## el minijuego de su SpotData. Lo visual (rocas, boyas, cartel) son nodos sueltos de la escena.

@export var datos: SpotData
## Dónde se para el donut (mueve este nodo en el editor).
@export var punto_barca: Marker3D


func _ready() -> void:
	add_to_group("spots")


func posicion_barca() -> Vector3:
	return punto_barca.global_position if punto_barca else global_position
