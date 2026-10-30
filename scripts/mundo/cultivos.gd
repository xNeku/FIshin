class_name Cultivos
extends Isla
## Los cultivos. Con el Chaval del huerto (rama Cosecha), un chaval cosecha solo cada rato lo que esté
## listo y se lo lleva a O Mar (vuela directo a su despensa).

## El chaval (se ve solo cuando lo tienes).
@export var chaval: Node3D
## Segundos entre pasada y pasada (la Carretilla lo acorta).
@export var cada_pasada: float = 75.0

var _t: float = 0.0


func _process(delta: float) -> void:
	var lo_tienes: bool = Juego.efecto(&"cosechador") > 0.0
	if chaval:
		chaval.visible = lo_tienes
	if not lo_tienes:
		return
	_t += delta
	if _t < cada_pasada * maxf(0.2, 1.0 - Juego.efecto(&"cosechador_ritmo")):
		return
	_t = 0.0
	var restaurante: Node3D = get_tree().get_first_node_in_group("restaurante")
	for n: Node in get_tree().get_nodes_in_group("plantas"):
		var p := n as Planta
		if p == null or not is_ancestor_of(p) or not p.lista():
			continue
		var k: int = p.cosechar()
		if randf() < Juego.efecto(&"cosecha_doble"):
			k *= 2
		var id: String = String(p.cultivo.id)
		Juego.despensa[id] = int(Juego.despensa.get(id, 0)) + k
		if restaurante:
			Vuelos.enviar(p, restaurante.casa if restaurante.casa else restaurante, [p.cultivo.icono] as Array[Texture2D], Callable(), null, 1.2)
