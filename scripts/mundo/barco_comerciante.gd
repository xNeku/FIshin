class_name BarcoComerciante
extends Node3D
## Barco que aparece tras las primeras capturas. Con "interactuar" abre su tienda.

signal llegado
signal vendido(total: float)

@export var nombre: String = "Comerciante"
@export var articulos: Array[ArticuloData] = []
## Para la tienda: este vendedor compra lo de la barca.
var compra_peces: bool = true
@export var tienda: Tienda
@export var capturas_para_aparecer: int = 3
@export var distancia_entrada: float = 25.0
@export var duracion_entrada: float = 3.5
@export var balanceo_grados: float = 3.0

@onready var sfx_venta: AudioStreamPlayer = $SfxVenta

var presente: bool = false
var listo: bool = false
var _t: float = 0.0
var _y_base: float


func _ready() -> void:
	visible = false
	_y_base = position.y
	if Juego.flags.get("barco_comerciante", false):
		_aparecer(true)
	else:
		Juego.inventario_cambiado.connect(_on_inventario)


func _process(delta: float) -> void:
	_t += delta
	rotation_degrees.z = sin(_t * 0.9 + 1.0) * balanceo_grados
	position.y = _y_base + sin(_t * 1.2) * 0.05


func _unhandled_input(event: InputEvent) -> void:
	if listo and tienda and not Juego.en_movimiento and event.is_action_pressed("interactuar"):
		get_viewport().set_input_as_handled()
		tienda.abrir(self)


func puede_hablar() -> bool:
	return listo and not Juego.en_movimiento


func vender() -> float:
	var total: float = Juego.vender_todo()
	sfx_venta.play()
	vendido.emit(total)
	return total


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
