extends Node
## Atajos para probar: F1 suma rublos, F2 suma peces pescados. Solo en builds de depuración.

@export var rublos_por_pulsacion: float = 100.0
@export var peces_por_pulsacion: int = 50
@export var hud: Node


func _ready() -> void:
	if not OS.is_debug_build():
		set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_rublos"):
		Juego.sumar_rublos(rublos_por_pulsacion)
		_avisar("Truco: +" + Formato.dinero(rublos_por_pulsacion))
	elif event.is_action_pressed("debug_peces"):
		Juego.stats.peces_pescados += peces_por_pulsacion
		_avisar("Truco: +%d peces pescados (total %d)" % [peces_por_pulsacion, Juego.stats.peces_pescados])


func _avisar(texto: String) -> void:
	if hud and hud.has_method("aviso_rapido"):
		hud.aviso_rapido(texto)
