extends Node
## Ventas con animación: primero tus peces vuelan al comprador y, cuando acaban, el dinero vuela hacia ti.
## Puedes moverte mientras: las piezas te siguen.

signal venta_terminada(total: float)

@export var jugador: Node3D
## El náufrago cuando está pescando en la barca.
@export var barca_origen: Node3D
@export var textura_cubo: Texture2D


## Quién entrega y recibe: el náufrago andando o el de la barca.
func origen() -> Node3D:
	return jugador if Juego.en_movimiento else barca_origen


## Vende todo lo de la barca.
func vender_barca(comprador: Node3D) -> float:
	return await _vender(Juego.sacar_capturas(), origen(), comprador)


## Vende el cubo que lleva el náufrago. Después el cubo vuelve volando a su sitio.
func vender_cubo(comprador: Node3D) -> float:
	var total: float = await _vender(Juego.vaciar_cubo(), jugador, comprador)
	var cubo: Node3D = get_tree().get_first_node_in_group("cubo")
	if cubo and textura_cubo:
		jugador.soltar_cubo_visual()
		await Vuelos.enviar(jugador, cubo, [textura_cubo], Callable(), null, 2.0)
	Juego.soltar_cubo()
	return total


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
