extends Node3D
## Fuego (hoguera, antorcha): llama que tiembla y luz que parpadea. Se enciende con activar().

@export var encendido_al_inicio: bool = false
@export var energia: float = 2.5
@export var parpadeo: float = 0.35
@export var velocidad: float = 9.0

@onready var luz: OmniLight3D = $Luz
@onready var llama: Node3D = $Llama

var encendido: bool = false
var _t: float = 0.0


func _ready() -> void:
	encendido = encendido_al_inicio
	_aplicar()


func activar() -> void:
	encendido = true
	_aplicar()


func _aplicar() -> void:
	llama.visible = encendido
	luz.visible = encendido
	var brasas: Node = get_node_or_null("Brasas")
	if brasas is CPUParticles3D:
		(brasas as CPUParticles3D).emitting = encendido


func _process(delta: float) -> void:
	if not encendido:
		return
	_t += delta
	var r: float = sin(_t * velocidad) * 0.5 + sin(_t * velocidad * 2.3) * 0.3 + randf_range(-0.2, 0.2)
	luz.light_energy = energia * (1.0 + parpadeo * r)
	llama.scale = Vector3.ONE * (1.0 + 0.12 * r)
