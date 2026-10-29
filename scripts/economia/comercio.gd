extends Node
## Ventas con animación: primero tus peces vuelan al comprador y, cuando acaban, el dinero vuela hacia ti.
## Puedes moverte mientras: las piezas te siguen.

signal venta_terminada(total: float)

@export var jugador: Node3D
## El náufrago cuando está pescando en la barca.
@export var barca_origen: Node3D
@export var textura_cubo: Texture2D


func _ready() -> void:
	add_to_group("comercio")


## Quién entrega y recibe: el náufrago andando o el de la barca.
func origen() -> Node3D:
	return jugador if Juego.en_movimiento else barca_origen


## Vende todo lo de la barca.
func vender_barca(comprador: Node3D) -> float:
	return await _vender(Juego.sacar_capturas(), origen(), comprador)


## Vende de golpe todo lo que llevas: lo de la barca y, si lo tienes en la mano, el cubo.
func vender_todo(comprador: Node3D) -> float:
	var capturas: Array[Dictionary] = Juego.sacar_capturas()
	var con_cubo: bool = Juego.cubo_en_mano
	if con_cubo:
		capturas.append_array(Juego.vaciar_cubo())
	var total: float = await _vender(capturas, origen(), comprador)
	if con_cubo:
		await _devolver_cubo()
	return total


## Lo que se puede vender ahora mismo (barca + cubo en la mano).
func peces_para_vender() -> int:
	return Juego.capturas.size() + (Juego.cubo_capturas.size() if Juego.cubo_en_mano else 0)


## Vende el cubo que lleva el náufrago. Después el cubo vuelve volando a su sitio.
func vender_cubo(comprador: Node3D) -> float:
	var total: float = await _vender(Juego.vaciar_cubo(), jugador, comprador)
	await _devolver_cubo()
	return total


## Vende el cubo sin el náufrago (el porteador del árbol): los peces salen del cubo y el dinero vuelve a él.
func vender_cubo_solo(comprador: Node3D) -> float:
	var cubo: Node3D = get_tree().get_first_node_in_group("cubo")
	if cubo == null or Juego.cubo_capturas.is_empty():
		return 0.0
	return await _vender(Juego.vaciar_cubo(), cubo, comprador)


func _devolver_cubo() -> void:
	var cubo: Node3D = get_tree().get_first_node_in_group("cubo")
	if cubo and textura_cubo:
		jugador.soltar_cubo_visual()
		await Vuelos.enviar(jugador, cubo, [textura_cubo], Callable(), null, 2.0)
	Juego.soltar_cubo()


func _vender(capturas: Array[Dictionary], desde: Node3D, comprador: Node3D) -> float:
	if capturas.is_empty():
		return 0.0
	# Carisma (y la lonja) suben el precio; el dado trucado (Suerte) a veces paga doble un pez.
	var en_lonja: bool = comprador is Interactuable and (comprador as Interactuable).accion == Interactuable.Accion.VENTA
	var total: float = 0.0
	for c: Dictionary in capturas:
		total += c.valor * (2.0 if randf() < Juego.efecto(&"venta_doble") else 1.0)
	total *= Juego.mult_venta(en_lonja)
	# La lonja paga más que el comerciante (Interactuable.mult_precio).
	if comprador is Interactuable:
		total *= (comprador as Interactuable).mult_precio
	Juego.dinero_en_camino += total
	await Vuelos.enviar_peces(desde, comprador, capturas)
	Juego.dinero_en_camino -= total
	await Vuelos.enviar_dinero(comprador, desde, total)
	venta_terminada.emit(total)
	return total
