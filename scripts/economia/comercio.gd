extends Node
## Ventas con animación: primero tus peces vuelan al comprador y, cuando acaban, el dinero vuela hacia ti.
## Puedes moverte mientras: las piezas te siguen.

signal venta_terminada(total: float)

@export var jugador: Node3D
## El náufrago cuando está pescando en la barca.
@export var barca_origen: Node3D


## Quién entrega y recibe: el náufrago andando o el de la barca.
func origen() -> Node3D:
	return jugador if Juego.en_movimiento else barca_origen


## Vende todo lo de la barca.
func vender_barca(comprador: Node3D) -> float:
	return await _vender(Juego.sacar_capturas(), origen(), comprador)


func _vender(capturas: Array[Dictionary], desde: Node3D, comprador: Node3D) -> float:
	if capturas.is_empty():
		return 0.0
	var total: float = 0.0
	for c: Dictionary in capturas:
		total += c.valor
	await Vuelos.enviar_peces(desde, comprador, capturas)
	await Vuelos.enviar_dinero(comprador, desde, total)
	venta_terminada.emit(total)
	return total
