extends CanvasLayer
## Menú de pausa (acción "menu"): Barca, Stats, Árbol y Opciones.

@export var escena_hueco: PackedScene
@export var escena_variante: PackedScene

@onready var raiz: Control = $Raiz
@onready var pestanas: TabContainer = $Raiz/Panel/Margen/Pestanas
@onready var rejilla: GridContainer = $Raiz/Panel/Margen/Pestanas/Barca/Huecos/Rejilla
@onready var detalle_nombre: Label = $Raiz/Panel/Margen/Pestanas/Barca/Detalle/Nombre
@onready var detalle_resumen: Label = $Raiz/Panel/Margen/Pestanas/Barca/Detalle/Resumen
@onready var variantes: VBoxContainer = $Raiz/Panel/Margen/Pestanas/Barca/Detalle/Lista/Variantes
@onready var stats_texto: Label = $Raiz/Panel/Margen/Pestanas/Stats/Texto
@onready var boton_volver: Button = $Raiz/Panel/Margen/Pestanas/Opciones/Volver
@onready var boton_borrar: Button = $Raiz/Panel/Margen/Pestanas/Opciones/Borrar
@onready var boton_salir: Button = $Raiz/Panel/Margen/Pestanas/Opciones/Salir

var abierto: bool = false
var _seleccion: String = ""
var _texto_borrar: String


func _ready() -> void:
	raiz.visible = false
	_texto_borrar = boton_borrar.text
	boton_volver.pressed.connect(cerrar)
	boton_borrar.pressed.connect(_on_borrar)
	boton_salir.pressed.connect(func() -> void:
		Juego.guardar()
		get_tree().quit())
	Juego.inventario_cambiado.connect(func() -> void:
		if abierto:
			_refrescar_barca())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu") and _alternar():
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	# Botón "atrás" de Android (quit_on_go_back está desactivado en el proyecto).
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_alternar()


## Abre o cierra el menú. Devuelve false si no hizo nada (otra ventana tiene la pausa).
func _alternar() -> bool:
	if abierto:
		cerrar()
	elif not get_tree().paused:
		abrir()
	else:
		return false
	return true


func abrir() -> void:
	abierto = true
	raiz.visible = true
	get_tree().paused = true
	boton_borrar.text = _texto_borrar
	_refrescar_barca()
	_refrescar_stats()


func cerrar() -> void:
	abierto = false
	raiz.visible = false
	get_tree().paused = false


func _refrescar_barca() -> void:
	for n: Node in rejilla.get_children():
		n.queue_free()
	var especies: Array[String] = Juego.especies()
	if not _seleccion in especies:
		_seleccion = especies[0] if not especies.is_empty() else ""
	for i in Juego.huecos:
		var h: Node = escena_hueco.instantiate()
		rejilla.add_child(h)
		if i < especies.size():
			h.mostrar(especies[i], Juego.pez_data(especies[i]), Juego.capturas_de(especies[i]).size())
			h.elegido.connect(_elegir)
		else:
			h.mostrar_vacio()
	_refrescar_detalle()


func _elegir(id_pez: String) -> void:
	_seleccion = id_pez
	_refrescar_detalle()


func _refrescar_detalle() -> void:
	for n: Node in variantes.get_children():
		n.queue_free()
	if _seleccion == "":
		detalle_nombre.text = "La barca está vacía"
		detalle_resumen.text = "Ve a pescar, máquina."
		return
	var pez: PezData = Juego.pez_data(_seleccion)
	var lista: Array[Dictionary] = Juego.capturas_de(_seleccion)
	lista.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.valor > b.valor)
	var total: float = 0.0
	for c: Dictionary in lista:
		total += c.valor
	detalle_nombre.text = pez.nombre
	detalle_resumen.text = "%d capturas · %s" % [lista.size(), Formato.dinero(total)]
	for c: Dictionary in lista:
		var f: Node = escena_variante.instantiate()
		variantes.add_child(f)
		f.mostrar(c)


func _refrescar_stats() -> void:
	var s: Dictionary = Juego.stats
	stats_texto.text = "\n".join([
		"Tiempo jugado: %s" % Formato.tiempo(s.tiempo_jugado),
		"Rublos ganados en total: %s" % Formato.dinero(Juego.rublos_totales),
		"Peces pescados: %d" % s.peces_pescados,
		"Perfectos: %d" % s.perfectos,
		"Escapados: %d" % s.escapados,
		"Legendarios: %d" % s.legendarios,
		"Mejor combo: x%d" % s.mejor_combo,
		"Colección: %d / %d especies" % [Juego.coleccion.size(), Juego.total_especies()],
		"Caña: %s" % Juego.cana().nombre,
	])


func _on_borrar() -> void:
	# Doble pulsación para confirmar.
	if boton_borrar.text == _texto_borrar:
		boton_borrar.text = "¿Seguro? Pulsa otra vez"
		return
	Juego.borrar_partida()
	cerrar()
	get_tree().reload_current_scene()
