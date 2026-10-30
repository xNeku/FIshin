class_name Tienda
extends CanvasLayer

signal cerrada
## Tienda de un vendedor (barco comerciante, viejo...). Pausa el juego.
## El vendedor es cualquier nodo con: nombre, articulos, compra_peces y, opcionalmente, saludos y vender().

@export var escena_fila: PackedScene
## Si está, la venta se hace con animación (peces al comprador y dinero de vuelta).
@export var comercio: Node
@export var saludos: Array[String] = [
	"Ey, náufrago. ¿Otra vez oliendo a ron?",
	"Pescado fresco, rublos frescos.",
	"Tú pescas, yo pago. Poco, pero pago.",
]
@export var frase_compra: String = "Trato hecho. Sin devoluciones."
@export var frase_venta: String = "Te doy %s por todo. Ni un rublo más."
@export var frase_sin_peces: String = "¿Vender qué? Ahí no hay ni una raspa."

@onready var raiz: Control = $Raiz
@onready var titulo: Label = $Raiz/Panel/Margen/Contenido/Cabecera/Titulo
@onready var rublos: Label = $Raiz/Panel/Margen/Contenido/Cabecera/Rublos
@onready var dialogo: Label = $Raiz/Panel/Margen/Contenido/Dialogo
@onready var lista: VBoxContainer = $Raiz/Panel/Margen/Contenido/Lista
@onready var boton_vender: Button = $Raiz/Panel/Margen/Contenido/Botones/Vender
@onready var boton_cerrar: Button = $Raiz/Panel/Margen/Contenido/Botones/Cerrar
@onready var sfx_compra: AudioStreamPlayer = $SfxCompra

var abierta: bool = false
var _vendedor: Node


func _ready() -> void:
	raiz.visible = false
	boton_vender.pressed.connect(_vender)
	boton_cerrar.pressed.connect(cerrar)


func _input(event: InputEvent) -> void:
	if not abierta:
		return
	# Va en _input (antes que la interfaz) para que Tab o Círculo cierren aunque haya un botón con el foco.
	# La E solo cierra con teclado: en el mando, el botón de interactuar es el de aceptar.
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("menu") \
			or (event is InputEventKey and event.is_action_pressed("interactuar")):
		get_viewport().set_input_as_handled()
		cerrar()
	elif event.is_action_pressed("accion_extra") and boton_vender.visible:
		get_viewport().set_input_as_handled()
		_vender()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and abierta:
		cerrar()


func abrir(vendedor: Node) -> void:
	_vendedor = vendedor
	abierta = true
	raiz.visible = true
	get_tree().paused = true
	titulo.text = vendedor.nombre
	var frases: Array[String] = saludos
	if "saludos" in vendedor and not vendedor.saludos.is_empty():
		frases = vendedor.saludos
	dialogo.text = frases.pick_random() if not frases.is_empty() else ""
	boton_vender.visible = vendedor.compra_peces
	_refrescar()
	_enfocar.call_deferred(0)


func cerrar() -> void:
	abierta = false
	raiz.visible = false
	# Que ningún botón escondido se quede con el foco (en el mando, aceptar es el botón de interactuar).
	var foco: Control = get_viewport().gui_get_focus_owner()
	if foco and raiz.is_ancestor_of(foco):
		foco.release_focus()
	get_tree().paused = false
	cerrada.emit()


func _refrescar() -> void:
	rublos.text = Formato.dinero(Juego.rublos)
	for n: Node in lista.get_children():
		n.queue_free()
	for art: ArticuloData in _vendedor.articulos:
		if not art.a_la_venta():
			continue
		var f: Node = escena_fila.instantiate()
		lista.add_child(f)
		f.mostrar(art)
		f.comprar.connect(_comprar)
	var valor: float = Juego.valor_inventario()
	boton_vender.text = "Vender todo (%s)" % Formato.dinero(valor)
	boton_vender.disabled = Juego.capturas.is_empty()


func _comprar(art: ArticuloData) -> void:
	if Juego.comprar(art):
		sfx_compra.play()
		dialogo.text = frase_compra
		var i: int = _indice_enfocado()
		_refrescar()
		# Las filas se rehacen: el foco vuelve a la misma fila para seguir con el mando.
		_enfocar.call_deferred(i)


## Pone el foco en el botón de la fila i (o el más cercano que se pueda pulsar); si no, en vender o cerrar.
func _enfocar(i: int) -> void:
	if not abierta:
		return
	var botones: Array[Button] = []
	for f: Node in lista.get_children():
		if not f.is_queued_for_deletion() and "boton" in f:
			botones.append(f.boton)
	for b: Button in botones.slice(i) + botones.slice(0, i):
		if not b.disabled:
			b.grab_focus()
			return
	if boton_vender.visible and not boton_vender.disabled:
		boton_vender.grab_focus()
	else:
		boton_cerrar.grab_focus()


func _indice_enfocado() -> int:
	var foco: Control = get_viewport().gui_get_focus_owner()
	var i: int = 0
	for f: Node in lista.get_children():
		if "boton" in f and f.boton == foco:
			return i
		i += 1
	return 0


func _vender() -> void:
	if Juego.capturas.is_empty():
		dialogo.text = frase_sin_peces
		return
	if comercio:
		# Se cierra para ver volar los peces y el dinero.
		var comprador: Node3D = _vendedor as Node3D
		cerrar()
		comercio.vender_barca(comprador)
		return
	var total: float = Juego.vender_todo()
	dialogo.text = frase_venta % Formato.dinero(total)
	_refrescar()
