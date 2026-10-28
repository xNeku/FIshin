extends Node
## Atajos para probar: F1 rublos, F2 peces pescados, F3 minutos de juego, F4 mejor combo. Solo en builds de depuración.

@export var rublos_por_pulsacion: float = 100.0
@export var peces_por_pulsacion: int = 50
@export var minutos_por_pulsacion: float = 5.0
@export var combo_por_pulsacion: int = 5
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
	elif event.is_action_pressed("debug_tiempo"):
		Juego.stats.tiempo_jugado += minutos_por_pulsacion * 60.0
		_avisar("Truco: +%d min (llevas %s)" % [minutos_por_pulsacion, Formato.tiempo(Juego.stats.tiempo_jugado)])
	elif event.is_action_pressed("debug_combo"):
		Juego.stats.mejor_combo = int(Juego.stats.mejor_combo) + combo_por_pulsacion
		_avisar("Truco: mejor combo x%d" % Juego.stats.mejor_combo)


func _avisar(texto: String) -> void:
	if hud and hud.has_method("aviso_rapido"):
		hud.aviso_rapido(texto)
