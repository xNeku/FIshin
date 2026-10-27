extends PanelContainer
## Una fila de la tienda: artículo, precio y botón de compra.

signal comprar(articulo: ArticuloData)

@onready var icono: TextureRect = $Fila/Icono
@onready var nombre: Label = $Fila/Textos/Nombre
@onready var descripcion: Label = $Fila/Textos/Descripcion
@onready var precio: Label = $Fila/Precio
@onready var boton: Button = $Fila/Comprar

var articulo: ArticuloData
var _texto_boton: String


func _ready() -> void:
	_texto_boton = boton.text
	boton.pressed.connect(func() -> void: comprar.emit(articulo))


func mostrar(art: ArticuloData) -> void:
	articulo = art
	icono.texture = art.icono
	nombre.text = art.nombre
	descripcion.text = art.descripcion
	precio.text = Formato.dinero(Juego.precio(art))
	var motivo: String = Juego.motivo_no_comprar(art)
	boton.disabled = motivo != ""
	boton.text = _texto_boton if motivo == "" else motivo
