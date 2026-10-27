extends Label
## Texto flotante que sube y se desvanece. Se instancia desde popup_texto.tscn.

@export var subida: float = 140.0
@export var duracion: float = 0.9
@export var escala_inicial: float = 1.6


func mostrar(texto: String, color: Color, centro: Vector2, escala: float = 1.0) -> void:
	text = texto
	modulate = color
	position = centro - size * 0.5
	pivot_offset = size * 0.5
	scale = Vector2.ONE * escala_inicial * escala
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "scale", Vector2.ONE * escala, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position:y", position.y - subida, duracion).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(self, "modulate:a", 0.0, duracion * 0.5).set_delay(duracion * 0.5)
	tw.chain().tween_callback(queue_free)
