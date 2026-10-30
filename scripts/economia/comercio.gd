extends Node
## Ventas con animación: primero tus peces vuelan al comprador y, cuando acaban, el dinero vuela hacia ti.
## Puedes moverte mientras: las piezas te siguen.

signal venta_terminada(total: float)

@export var jugador: Node3D
## El náufrago cuando está pescando en la barca.
@export var barca_origen: Node3D
@export var textura_cubo: Texture2D
## Desde que llega la lonja, todas las ventas valen esto más (sea a quien sea).
@export var bonus_lonja: float = 1.3
## Aparición a la que lleva el comerciante los cubos del porteador.
@export var id_lonja: StringName = &"lonja"


func _ready() -> void:
	add_to_group("comercio")
	Juego.bonus_lonja = bonus_lonja


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


func _devolver_cubo() -> void:
	var cubo: Node3D = get_tree().get_first_node_in_group("cubo")
	if cubo and textura_cubo:
		jugador.soltar_cubo_visual()
		await Vuelos.enviar(jugador, cubo, [textura_cubo], Callable(), null, 2.0)
	Juego.soltar_cubo()


## Lo que pagan por estas capturas: Carisma y la lonja suben el precio; el dado trucado (Suerte) a veces
## paga doble un pez.
func _precio(capturas: Array[Dictionary]) -> float:
	var total: float = 0.0
	for c: Dictionary in capturas:
		total += c.valor * (2.0 if randf() < Juego.efecto(&"venta_doble") else 1.0)
	return total * Juego.mult_venta()


## Porteador (árbol): los pescadores le dan el cubo al comerciante. Si ya hay lonja, él la lleva allí:
## navega hasta donde pueda aparcar y sigue a pie. Luego vuelve y el dinero llega al náufrago.
## Devuelve lo ganado (0 si no pudo).
func vender_cubo_con_barco() -> float:
	var barco: Node3D = get_tree().get_first_node_in_group("barco_comerciante")
	var cubo: Node3D = get_tree().get_first_node_in_group("cubo")
	if barco == null or cubo == null or not barco.listo or Juego.cubo_capturas.is_empty() \
			or not await barco.ir_a(cubo.global_position):
		return 0.0
	var capturas: Array[Dictionary] = Juego.vaciar_cubo()
	var total: float = _precio(capturas)
	Juego.dinero_en_camino += total
	await Vuelos.enviar_peces(cubo, barco, capturas)
	var lonja: Node3D = barco.mundo.get_node_or_null(String(id_lonja)) if Juego.lonja_abierta() else null
	if lonja and await barco.ir_a_pie(lonja.global_position):
		await Vuelos.enviar_peces(barco.comerciante, lonja, capturas)
		await barco.volver_a_pie()
	await barco.volver()
	Juego.dinero_en_camino -= total
	await Vuelos.enviar_dinero(barco, origen(), total)
	venta_terminada.emit(total)
	return total


func _vender(capturas: Array[Dictionary], desde: Node3D, comprador: Node3D) -> float:
	if capturas.is_empty():
		return 0.0
	var total: float = _precio(capturas)
	Juego.dinero_en_camino += total
	await Vuelos.enviar_peces(desde, comprador, capturas)
	Juego.dinero_en_camino -= total
	await Vuelos.enviar_dinero(comprador, desde, total)
	venta_terminada.emit(total)
	return total
