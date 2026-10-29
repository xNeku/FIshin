extends CanvasLayer
## El bestiario: todas las especies, las pescadas con su mejor calidad y las demás en silueta. Pausa el juego.

@export var escena_ficha: PackedScene

@onready var raiz: Control = $Raiz
@onready var progreso: Label = $Raiz/Panel/Margen/Contenido/Cabecera/Progreso
@onready var rejilla: GridContainer = $Raiz/Panel/Margen/Contenido/Lista/Rejilla
@onready var boton_cerrar: Button = $Raiz/Panel/Margen/Contenido/Cerrar

var abierto: bool = false


func _ready() -> void:
	raiz.visible = false
	boton_cerrar.pressed.connect(cerrar)


func _unhandled_input(event: InputEvent) -> void:
	if abierto and (event.is_action_pressed("menu") or event.is_action_pressed("interactuar")):
		get_viewport().set_input_as_handled()
		cerrar()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and abierto:
		cerrar()


func abrir() -> void:
	abierto = true
	raiz.visible = true
	get_tree().paused = true
	_refrescar()


func cerrar() -> void:
	abierto = false
	raiz.visible = false
	get_tree().paused = false


func _refrescar() -> void:
	for n: Node in rejilla.get_children():
		n.queue_free()
	var peces: Array[PezData] = []
	for f: String in DirAccess.get_files_at("res://data/peces"):
		var limpio: String = f.trim_suffix(".remap")
		if limpio.ends_with(".tres"):
			peces.append(load("res://data/peces/" + limpio))
	peces.sort_custom(func(a: PezData, b: PezData) -> bool:
		# Por profundidad (lo que vas descubriendo con cada caña) y dentro, por rareza.
		if a.profundidad != b.profundidad:
			return a.profundidad < b.profundidad
		return a.rareza < b.rareza if a.rareza != b.rareza else a.valor_base < b.valor_base)
	for p: PezData in peces:
		var ficha: Node = escena_ficha.instantiate()
		rejilla.add_child(ficha)
		ficha.mostrar(p, Juego.coleccion.get(String(p.id), -1.0))
	progreso.text = "%d / %d especies" % [Juego.coleccion.size(), peces.size()]
