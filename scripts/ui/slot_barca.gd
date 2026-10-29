extends Button
## Un hueco de la barca. Muestra una especie apilada; al pulsarlo se ven sus variantes.

signal elegido(id_pez: String)

@onready var icono: TextureRect = $Icono
@onready var nombre: Label = $Nombre
@onready var cantidad: Label = $Cantidad

var id_pez: String = ""


func _ready() -> void:
	pressed.connect(func() -> void: elegido.emit(id_pez))
	# Con mando, basta con pasar por encima para ver sus variantes.
	focus_entered.connect(func() -> void:
		if id_pez != "":
			elegido.emit(id_pez))


func mostrar(id: String, pez: PezData, n: int) -> void:
	id_pez = id
	disabled = false
	icono.texture = pez.icono
	nombre.text = pez.nombre
	cantidad.text = "x%d" % n


func mostrar_vacio() -> void:
	id_pez = ""
	disabled = true
	icono.texture = null
	nombre.text = "vacío"
	cantidad.text = ""
