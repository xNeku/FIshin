class_name ViajeSpots
extends Node
## Lleva el donut de la base a los spots y vuelta. Sentado, "accion_extra" cambia de destino:
## base → spots que hayan llegado (por SpotData.orden) → base. En un spot no te puedes levantar.

signal viaje_empezado(destino: Spot)
signal viaje_terminado(destino: Spot)

@export var pesca: Pesca
@export var barca: Node3D
@export var jugador: Node
@export var celebracion: Node
## La cámara sigue al donut mientras rema y mientras está en un spot.
@export var camara: Node
## Segundos remando de un sitio a otro.
@export var duracion_viaje: float = 2.5

var actual: Spot = null
var viajando: bool = false


func _ready() -> void:
	add_to_group("viaje_spots")


func spots() -> Array[Spot]:
	var r: Array[Spot] = []
	for n: Node in get_tree().get_nodes_in_group("spots"):
		if n is Spot and (n as Spot).datos:
			r.append(n)
	r.sort_custom(func(a: Spot, b: Spot) -> bool: return a.datos.orden < b.datos.orden)
	return r


## El siguiente destino (null = la base).
func siguiente() -> Spot:
	var lista: Array[Spot] = spots()
	if lista.is_empty():
		return null
	var i: int = lista.find(actual)
	return lista[i + 1] if i + 1 < lista.size() else null


func puede_viajar() -> bool:
	if viajando or spots().is_empty() or pesca == null or pesca.en_curso():
		return false
	if jugador and jugador.andando:
		return false
	return not (celebracion and celebracion.celebrando)


## Especies de un spot que pican ahora (hora, estación, fondo) y cuántas no tienes en el bestiario.
func resumen(datos: SpotData) -> Vector2i:
	var lista: Array[PezData] = pesca.especies_ahora(datos)
	var nuevas: int = 0
	for p: PezData in lista:
		if not Juego.coleccion.has(String(p.id)):
			nuevas += 1
	return Vector2i(lista.size(), nuevas)


## Texto para la caja de acciones (avisa si ahora pican especies que no tienes).
func texto_accion() -> String:
	if not puede_viajar():
		return ""
	var s: Spot = siguiente()
	if s == null:
		return "[Extra] Volver a la base"
	var r: Vector2i = resumen(s.datos)
	return "[Extra] Ir a %s" % s.datos.nombre + (" (%d nuevas pican ahora)" % r.y if r.y > 0 else "")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("accion_extra") and puede_viajar():
		get_viewport().set_input_as_handled()
		ir_a(siguiente())


func ir_a(destino: Spot) -> void:
	viajando = true
	viaje_empezado.emit(destino)
	pesca.pausar()
	if barca.has_method("poner_asiento"):
		barca.poner_asiento(null)
	if camara:
		camara.seguir(barca)
	var desde: Vector3 = barca.position
	var hasta: Vector3 = destino.posicion_barca() if destino else Vector3.ZERO
	hasta.y = desde.y
	var tw := create_tween()
	tw.tween_method(func(k: float) -> void:
		var p: Vector3 = desde.lerp(hasta, k)
		barca.position.x = p.x
		barca.position.z = p.z, 0.0, 1.0, duracion_viaje).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
	actual = destino
	viajando = false
	if destino and barca.has_method("poner_asiento"):
		barca.poner_asiento(destino.datos)
	if camara and destino == null:
		camara.seguir(null)
	pesca.poner_spot(destino.datos if destino else null)
	pesca.reanudar()
	viaje_terminado.emit(destino)
