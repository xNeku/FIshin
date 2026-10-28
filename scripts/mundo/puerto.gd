extends Isla
## Puerto pesquero: el cubo y los pescadores contratados. El primero empieza en su puesto;
## los demás buscan un borde con agua, cerca de algún compañero.

@export var escena_trabajador: PackedScene
@export var cubo: Node3D
## Casilla del cubo (de aquí salen y aquí dejan los peces).
@export var celda_cubo: Vector2i = Vector2i(2, 0)
## Puesto del primer pescador y hacia dónde mira (agua).
@export var puesto_inicial: Vector2i = Vector2i(4, -1)
@export var dir_inicial: Vector2i = Vector2i(0, -1)
## Lo que dice el primer pescador al hablar con él.
@export_multiline var lineas_primero: Array[String] = []
## Probabilidad de sentarse al borde cuando el puesto es de tablones.
@export_range(0.0, 1.0) var prob_sentado: float = 0.6
@export var contenedor: Node3D

var trabajadores: Array[Trabajador] = []
var _pez_barato: PezData


func llegar() -> void:
	super.llegar()
	_poblar()


func colocada() -> void:
	super.colocada()
	_poblar()


func _ready() -> void:
	Juego.trabajadores_cambiados.connect(func(_n: int) -> void:
		if is_inside_tree() and visible:
			_poblar())


## Punto junto al cubo donde se para quien va a dejar peces.
func punto_entrega() -> Vector3:
	var m: Node = get_parent()
	return m.celda_a_mundo(celda_cubo) + Vector3(randf_range(-0.5, 0.5), 0.25, randf_range(0.3, 0.7))


func _poblar() -> void:
	if Juego.trabajadores < 1:
		Juego.contratar_trabajador()
	while trabajadores.size() < Juego.trabajadores:
		_contratar()


func _contratar() -> void:
	var m: Node = get_parent()
	var puesto: Dictionary = _elegir_puesto(m)
	if puesto.is_empty():
		push_warning("No queda ningún borde libre para otro pescador")
		return
	var t: Trabajador = escena_trabajador.instantiate()
	(contenedor if contenedor else self).add_child(t)
	var sentado: bool = m.es_tablon(puesto.celda) and randf() < prob_sentado
	var primero: bool = trabajadores.is_empty()
	t.iniciar(m, self, _pez_mas_barato(), puesto, sentado, puesto.celda if primero else celda_cubo)
	if primero and not lineas_primero.is_empty():
		t.charla.lineas = lineas_primero
	trabajadores.append(t)


func _elegir_puesto(m: Node) -> Dictionary:
	var ocupados: Array = trabajadores.map(func(t: Trabajador) -> Array: return [t.puesto.celda, t.puesto.dir])
	var libres: Array[Dictionary] = []
	for p: Dictionary in m.puestos_de_pesca():
		if p.celda != celda_cubo and not [p.celda, p.dir] in ocupados:
			libres.append(p)
	if libres.is_empty():
		return {}
	if trabajadores.is_empty():
		for p: Dictionary in libres:
			if p.celda == puesto_inicial and p.dir == dir_inicial:
				return p
	# Cerca de un compañero, con algo de azar.
	var mejor: Dictionary = libres[0]
	var mejor_nota: float = INF
	for p: Dictionary in libres:
		# Lo mejor es la casilla de al lado de un compañero; compartir casilla se evita.
		var d: float = 99.0
		for t: Trabajador in trabajadores:
			var dist: float = float((t.puesto.celda - p.celda).length())
			d = minf(d, 4.0 if dist == 0.0 else dist)
		var nota: float = d + randf() * 1.5
		if nota < mejor_nota:
			mejor_nota = nota
			mejor = p
	return mejor


func _pez_mas_barato() -> PezData:
	if _pez_barato:
		return _pez_barato
	for f: String in DirAccess.get_files_at("res://data/peces"):
		var limpio: String = f.trim_suffix(".remap")
		if limpio.ends_with(".tres"):
			var p: PezData = load("res://data/peces/" + limpio)
			if _pez_barato == null or p.valor_base < _pez_barato.valor_base:
				_pez_barato = p
	return _pez_barato
