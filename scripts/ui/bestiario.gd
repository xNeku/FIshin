extends CanvasLayer
## El bestiario: todas las especies, las pescadas con su mejor calidad y las demás en silueta. Pausa el juego.

@export var escena_ficha: PackedScene
## Píxeles por segundo al desplazar la lista con el stick o la cruceta.
@export var velocidad_scroll: float = 1400.0

@onready var raiz: Control = $Raiz
@onready var progreso: Label = $Raiz/Panel/Margen/Contenido/Cabecera/Progreso
@onready var rejilla: GridContainer = $Raiz/Panel/Margen/Contenido/Lista/Rejilla
@onready var boton_cerrar: Button = $Raiz/Panel/Margen/Contenido/Cerrar
@onready var scroll: ScrollContainer = $Raiz/Panel/Margen/Contenido/Lista

var abierto: bool = false


func _ready() -> void:
	raiz.visible = false
	boton_cerrar.pressed.connect(cerrar)


func _input(event: InputEvent) -> void:
	if not abierto:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("menu") \
			or (event is InputEventKey and event.is_action_pressed("interactuar")):
		get_viewport().set_input_as_handled()
		cerrar()
	elif event.is_action("ui_up") or event.is_action("ui_down"):
		# El desplazamiento lo lleva _process; así no salta el foco al botón de cerrar.
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if not abierto:
		return
	var eje: float = Input.get_axis("ui_up", "ui_down")
	if absf(eje) > 0.2:
		scroll.scroll_vertical += int(eje * velocidad_scroll * delta)


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
	boton_cerrar.release_focus()
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
