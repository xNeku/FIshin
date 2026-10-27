class_name Tienda
extends CanvasLayer
## Tienda de un comerciante: comprar sus artículos y venderle todo lo de la barca. Pausa el juego.

@export var escena_fila: PackedScene
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
var _barco: BarcoComerciante


func _ready() -> void:
	raiz.visible = false
	boton_vender.pressed.connect(_vender)
	boton_cerrar.pressed.connect(cerrar)


func _unhandled_input(event: InputEvent) -> void:
	if abierta and (event.is_action_pressed("menu") or event.is_action_pressed("interactuar")):
		get_viewport().set_input_as_handled()
		cerrar()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and abierta:
		cerrar()


func abrir(barco: BarcoComerciante) -> void:
	_barco = barco
	abierta = true
	raiz.visible = true
	get_tree().paused = true
	titulo.text = barco.nombre
	dialogo.text = saludos.pick_random() if not saludos.is_empty() else ""
	_refrescar()


func cerrar() -> void:
	abierta = false
	raiz.visible = false
	get_tree().paused = false


func _refrescar() -> void:
	rublos.text = Formato.dinero(Juego.rublos)
	for n: Node in lista.get_children():
		n.queue_free()
	for art: ArticuloData in _barco.articulos:
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
		_refrescar()


func _vender() -> void:
	if Juego.capturas.is_empty():
		dialogo.text = frase_sin_peces
		return
	var total: float = _barco.vender()
	dialogo.text = frase_venta % Formato.dinero(total)
	_refrescar()
