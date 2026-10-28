extends CanvasLayer
## Caja de diálogo tipo Pokémon: nombre, texto que se escribe solo y E para avanzar. Pausa el juego.

signal terminado

@export var letras_por_segundo: float = 45.0

@onready var raiz: Control = $Raiz
@onready var nombre: Label = $Raiz/Caja/Margen/Contenido/Nombre
@onready var texto: Label = $Raiz/Caja/Margen/Contenido/Texto
@onready var seguir: Label = $Raiz/Caja/Margen/Contenido/Seguir

var abierto: bool = false
var _lineas: Array[String] = []
var _i: int = 0
var _tween: Tween


func _ready() -> void:
	raiz.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not abierto:
		return
	if event.is_action_pressed("interactuar"):
		get_viewport().set_input_as_handled()
		avanzar()
	elif event.is_action_pressed("menu"):
		get_viewport().set_input_as_handled()
		cerrar()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and abierto:
		cerrar()


func abrir(quien: String, lineas: Array[String]) -> void:
	if lineas.is_empty():
		return
	_lineas = lineas
	_i = 0
	abierto = true
	raiz.visible = true
	get_tree().paused = true
	nombre.text = quien
	_mostrar()


## Si la frase se está escribiendo la completa; si no, pasa a la siguiente.
func avanzar() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
		texto.visible_ratio = 1.0
		seguir.visible = true
		return
	_i += 1
	if _i >= _lineas.size():
		cerrar()
	else:
		_mostrar()


func cerrar() -> void:
	abierto = false
	raiz.visible = false
	get_tree().paused = false
	terminado.emit()


func _mostrar() -> void:
	texto.text = _lineas[_i]
	texto.visible_ratio = 0.0
	seguir.visible = false
	_tween = create_tween()
	_tween.tween_property(texto, "visible_ratio", 1.0, maxf(0.1, texto.text.length() / letras_por_segundo))
	_tween.tween_callback(func() -> void: seguir.visible = true)
