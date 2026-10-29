class_name BarcoComerciante
extends Node3D
## Barco que aparece tras las primeras capturas. Con "interactuar" abre su tienda.

signal llegado

@export var nombre: String = "Comerciante"
@export var articulos: Array[ArticuloData] = []
## Para la tienda: este vendedor compra lo de la barca.
var compra_peces: bool = true
@export var tienda: Tienda
@export var capturas_para_aparecer: int = 3
@export var distancia_entrada: float = 25.0
@export var duracion_entrada: float = 3.5
@export var balanceo_grados: float = 3.0
## Para ir encima de la ola. El casco se mete un poco en el agua (flotación negativa).
@export var agua: Agua
@export var flotacion: float = -0.12
@export var inclinacion_ola: float = 0.5
## Altura sobre el barco a la que sale el botón de hablar (encima de la cabeza del comerciante).
@export var altura_icono: float = 1.7

@onready var sombra: Node3D = get_node_or_null("Sombra")


var presente: bool = false
var listo: bool = false
var _t: float = 0.0
var _y_base: float


func _ready() -> void:
	var i: Interactuable = get_node_or_null("Interaccion")
	if i:
		i.nombre = nombre
		i.articulos = articulos
	visible = false
	_y_base = position.y
	if Juego.flags.get("barco_comerciante", false):
		_aparecer(true)
	else:
		Juego.inventario_cambiado.connect(_on_inventario)


func _process(delta: float) -> void:
	if not presente:
		_on_inventario()
		return
	_t += delta
	var y_agua: float = agua.altura(global_position) if agua else 0.0
	var pend: Vector2 = agua.pendiente(global_position) if agua else Vector2.ZERO
	rotation_degrees.z = sin(_t * 0.9 + 1.0) * balanceo_grados - rad_to_deg(atan(pend.x)) * inclinacion_ola
	position.y = _y_base + y_agua + flotacion + sin(_t * 1.2) * 0.05
	if agua and sombra:
		agua.pegar(sombra, global_position * Vector3(1, 0, 1) + Vector3(0.1, 0, 0.3), 0.06)


func _unhandled_input(event: InputEvent) -> void:
	if listo and tienda and not Juego.en_movimiento and event.is_action_pressed("interactuar"):
		get_viewport().set_input_as_handled()
		tienda.abrir(self)


func puede_hablar() -> bool:
	return listo and not Juego.en_movimiento


func _on_inventario() -> void:
	if not presente and Juego.stats.peces_pescados >= capturas_para_aparecer:
		_aparecer(false)


func _aparecer(instantaneo: bool) -> void:
	presente = true
	visible = true
	Juego.flags["barco_comerciante"] = true
	if not instantaneo:
		var destino: Vector3 = position
		position += Vector3(distancia_entrada, 0.0, 0.0)
		var tw := create_tween()
		tw.tween_property(self, "position:x", destino.x, duracion_entrada).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await tw.finished
	listo = true
	llegado.emit()
