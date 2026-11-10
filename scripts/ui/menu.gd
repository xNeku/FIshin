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
@onready var boton_filtro: Button = $Raiz/Panel/Margen/Pestanas/Opciones/Filtro
@onready var boton_agua: Button = $Raiz/Panel/Margen/Pestanas/Opciones/Agua
@onready var boton_iconos: Button = get_node_or_null("Raiz/Panel/Margen/Pestanas/Opciones/Iconos")
@onready var boton_pixeles: Button = $Raiz/Panel/Margen/Pestanas/Opciones/Pixeles

## Tamaño de los píxeles del mundo: encogimiento del Pixelador y su nombre en el botón.
const PIXELES: Array[int] = [4, 3, 2]
const NOMBRES_PIXELES: Array[String] = ["grandes", "medianos", "finos"]

var abierto: bool = false
var _seleccion: String = ""
var _texto_borrar: String


func _ready() -> void:
	raiz.visible = false
	_texto_borrar = boton_borrar.text
	# Las pestañas se cambian con L1/R1 (o Q/E), no con el foco.
	pestanas.get_tab_bar().focus_mode = Control.FOCUS_NONE
	pestanas.tab_changed.connect(func(_t: int) -> void: _enfocar_pestana.call_deferred())
	boton_volver.pressed.connect(cerrar)
	boton_borrar.pressed.connect(_on_borrar)
	boton_filtro.pressed.connect(func() -> void:
		var crt: Node = get_tree().get_first_node_in_group("crt")
		if crt:
			crt.activar(not crt.activo())
		_refrescar_filtro())
	_refrescar_filtro.call_deferred()
	boton_agua.pressed.connect(func() -> void:
		var si: bool = not Juego.opcion("agua_bandas", true)
		Juego.poner_opcion("agua_bandas", si)
		for a: Node in get_tree().get_nodes_in_group("agua"):
			a.poner_bandas(si)
		_refrescar_agua())
	_refrescar_agua()
	if boton_iconos:
		boton_iconos.pressed.connect(func() -> void:
			var i: int = (maxi(0, ICONOS.find(IconosInput.forzado)) + 1) % ICONOS.size()
			IconosInput.forzado = ICONOS[i]
			IconosInput.dispositivo = ICONOS[i] if ICONOS[i] != "" else "teclado"
			Juego.poner_opcion("iconos", ICONOS[i])
			_refrescar_iconos())
		_refrescar_iconos()
	boton_pixeles.pressed.connect(func() -> void:
		var pix: Node = get_tree().get_first_node_in_group("pixelador")
		var actual: int = pix.encogimiento if pix else 3
		var i: int = (maxi(0, PIXELES.find(actual)) + 1) % PIXELES.size()
		Juego.poner_opcion("pixel_mundo", PIXELES[i])
		if pix:
			pix.poner_encogimiento(PIXELES[i])
		_refrescar_pixeles())
	_refrescar_pixeles.call_deferred()
	boton_salir.pressed.connect(func() -> void:
		Juego.guardar()
		get_tree().quit())
	Juego.inventario_cambiado.connect(func() -> void:
		if abierto:
			_refrescar_barca())


func _input(event: InputEvent) -> void:
	# En _input (antes que la interfaz): así Tab no lo usa un botón para mover el foco.
	if event.is_action_pressed("menu"):
		if _alternar():
			get_viewport().set_input_as_handled()
	elif not abierto:
		return
	elif event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		cerrar()
	elif event.is_action_pressed("pestana_anterior") or event.is_action_pressed("pestana_siguiente"):
		get_viewport().set_input_as_handled()
		var n: int = pestanas.get_tab_count()
		var paso: int = -1 if event.is_action_pressed("pestana_anterior") else 1
		pestanas.current_tab = (pestanas.current_tab + paso + n) % n
		_enfocar_pestana.call_deferred()


## Pone el foco en lo primero que se pueda pulsar de la pestaña abierta (para el mando).
func _enfocar_pestana() -> void:
	if not abierto:
		return
	var pagina: Control = pestanas.get_current_tab_control()
	var destino: Control = _primer_enfocable(pagina)
	if destino:
		destino.grab_focus()
	else:
		var foco: Control = get_viewport().gui_get_focus_owner()
		if foco:
			foco.release_focus()


func _primer_enfocable(n: Node) -> Control:
	for h: Node in n.get_children():
		if h is Control and (h as Control).is_visible_in_tree():
			var c: Control = h
			if c.focus_mode != Control.FOCUS_NONE and not (c is BaseButton and (c as BaseButton).disabled):
				return c
			var dentro: Control = _primer_enfocable(c)
			if dentro:
				return dentro
	return null


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
	_enfocar_pestana.call_deferred()


func cerrar() -> void:
	abierto = false
	raiz.visible = false
	var foco: Control = get_viewport().gui_get_focus_owner()
	if foco and raiz.is_ancestor_of(foco):
		foco.release_focus()
	get_tree().paused = false


func _refrescar_barca() -> void:
	for n: Node in rejilla.get_children():
		n.queue_free()
	var especies: Array[String] = Juego.especies()
	if not _seleccion in especies:
		_seleccion = especies[0] if not especies.is_empty() else ""
	# Sin huecos: una pila por especie, tantas como haya.
	for id: String in especies:
		var h: Node = escena_hueco.instantiate()
		rejilla.add_child(h)
		h.mostrar(id, Juego.pez_data(id), Juego.capturas_de(id).size())
		h.elegido.connect(_elegir)
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


func _refrescar_pixeles() -> void:
	var pix: Node = get_tree().get_first_node_in_group("pixelador")
	var i: int = PIXELES.find(pix.encogimiento if pix else 3)
	boton_pixeles.text = "Píxeles: %s" % (NOMBRES_PIXELES[i] if i >= 0 else str(pix.encogimiento))


const ICONOS: Array[String] = ["", "xbox", "ps", "teclado"]
const NOMBRES_ICONOS: Array[String] = ["automáticos", "Xbox / Switch", "PlayStation", "teclado"]


func _refrescar_iconos() -> void:
	boton_iconos.text = "Iconos: %s" % NOMBRES_ICONOS[maxi(0, ICONOS.find(IconosInput.forzado))]


func _refrescar_agua() -> void:
	boton_agua.text = "Agua: %s" % ("con bandas" if Juego.opcion("agua_bandas", true) else "realista")


func _refrescar_filtro() -> void:
	var crt: Node = get_tree().get_first_node_in_group("crt")
	boton_filtro.visible = crt != null
	if crt:
		boton_filtro.text = "Filtro retro: %s" % ("sí" if crt.activo() else "no")
