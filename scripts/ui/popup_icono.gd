extends TextureRect
## Icono que salta, tiembla y se desvanece (la X roja de fallo). Se instancia desde popup_icono.tscn.

@export var duracion: float = 0.7
@export var escala_inicial: float = 1.8
@export var temblor: float = 10.0


func mostrar(centro: Vector2, escala: float = 1.0) -> void:
	position = centro - size * 0.5
	pivot_offset = size * 0.5
	scale = Vector2.ONE * escala_inicial * escala
	var x0: float = position.x
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "scale", Vector2.ONE * escala, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_method(func(k: float) -> void: position.x = x0 + sin(k * 40.0) * temblor * (1.0 - k), 0.0, 1.0, duracion * 0.5)
	tw.tween_property(self, "modulate:a", 0.0, duracion * 0.4).set_delay(duracion * 0.6)
	tw.chain().tween_callback(queue_free)
