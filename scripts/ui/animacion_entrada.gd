extends Node
## Animación de entrada retro para el Control padre. Se lanza sola cada vez que el padre aparece.
## LINEA: sale como una raya que se abre a saltos (tele vieja encendiéndose).
## CAIDA: baja un poco desde arriba a saltos. PARPADEO: aparece parpadeando. FUNDIDO: se funde a saltos.
## Pon esta escena (animacion_entrada.tscn) como hija de la ventana o del popup que quieras animar.

enum Estilo { LINEA, CAIDA, PARPADEO, FUNDIDO }

@export var estilo: Estilo = Estilo.LINEA
@export var duracion: float = 0.22
## Saltos de la animación: pocos = más retro, muchos = más suave.
@export_range(2, 30) var pasos: int = 7
## Cuánto baja en CAIDA (píxeles).
@export var altura_caida: float = 40.0
@export var sonar: bool = true

@onready var sonido: AudioStreamPlayer = get_node_or_null("Sonido")

var _objetivo: Control
var _tween: Tween
var _pos_base: Vector2


func _ready() -> void:
	_objetivo = get_parent() as Control
	if _objetivo:
		_objetivo.visibility_changed.connect(_on_visibilidad)


func _on_visibilidad() -> void:
	if _objetivo.is_visible_in_tree():
		entrar()


func entrar() -> void:
	if _tween:
		_tween.kill()
		_terminar()
	_pos_base = _objetivo.position
	_aplicar(0.0)
	_tween = create_tween()
	_tween.tween_method(_aplicar, 0.0, 1.0, duracion)
	_tween.tween_callback(_terminar)
	if sonar and sonido and sonido.stream:
		sonido.play()


func _aplicar(k: float) -> void:
	# A saltos: el progreso se redondea a 'pasos' escalones.
	var q: float = 1.0 if k >= 1.0 else floorf(k * pasos) / pasos
	_objetivo.pivot_offset = _objetivo.size * 0.5
	match estilo:
		Estilo.LINEA:
			var a: float = clampf(q * 2.0, 0.0, 1.0)
			var b: float = clampf(q * 2.0 - 1.0, 0.0, 1.0)
			_objetivo.scale = Vector2(lerpf(0.08, 1.0, a), lerpf(0.04, 1.0, b))
		Estilo.CAIDA:
			_objetivo.position = _pos_base + Vector2(0.0, -altura_caida * (1.0 - q))
			_objetivo.modulate.a = q
		Estilo.PARPADEO:
			var paso: int = int(floorf(k * pasos))
			_objetivo.modulate.a = 1.0 if (k >= 1.0 or paso % 2 == 1) else 0.0
		Estilo.FUNDIDO:
			_objetivo.modulate.a = q


func _terminar() -> void:
	_objetivo.scale = Vector2.ONE
	_objetivo.modulate.a = 1.0
	if estilo == Estilo.CAIDA:
		_objetivo.position = _pos_base
