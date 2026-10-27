extends Node
## Sonidos del minijuego. El tono de los aciertos sube con la cadena y el latido aparece y acelera con la intensidad.

@export var pesca: Pesca
@export var subida_tono_por_acierto: float = 0.06
## El latido no suena hasta llegar a esta intensidad: se descubre con cadenas largas.
@export var latido_desde: float = 0.25
@export var latido_volumen_min_db: float = -30.0
@export var latido_volumen_max_db: float = 0.0
@export var latido_tono_min: float = 0.8
@export var latido_tono_max: float = 1.8

@onready var acierto: AudioStreamPlayer = $Acierto
@onready var fallo: AudioStreamPlayer = $Fallo
@onready var picada: AudioStreamPlayer = $Picada
@onready var golpe: AudioStreamPlayer = $Golpe
@onready var captura: AudioStreamPlayer = $Captura
@onready var perfecto: AudioStreamPlayer = $Perfecto
@onready var escapa: AudioStreamPlayer = $Escapa
@onready var latido: AudioStreamPlayer = $Latido

var _intensidad: float = 0.0


func _ready() -> void:
	if pesca == null:
		return
	pesca.pez_pica.connect(func(_p: PezData) -> void: picada.play())
	pesca.acierto.connect(_on_acierto)
	pesca.fallo.connect(func() -> void: fallo.play())
	pesca.machacar_progreso.connect(func(_g: int, _n: int) -> void:
		golpe.pitch_scale = randf_range(0.9, 1.2)
		golpe.play())
	pesca.pez_capturado.connect(func(c: Dictionary, _p: PezData) -> void:
		(perfecto if c.perfecto else captura).play())
	pesca.pez_escapado.connect(func(_p: PezData) -> void: escapa.play())
	pesca.barca_llena.connect(func(_p: PezData) -> void: escapa.play())
	pesca.intensidad_cambiada.connect(func(i: float) -> void: _intensidad = i)


func _process(_delta: float) -> void:
	if pesca and pesca.en_curso() and _intensidad >= latido_desde and not latido.playing:
		var k: float = inverse_lerp(latido_desde, 1.0, _intensidad)
		latido.volume_db = lerpf(latido_volumen_min_db, latido_volumen_max_db, k)
		latido.pitch_scale = lerpf(latido_tono_min, latido_tono_max, k)
		latido.play()


func _on_acierto(indice: int, _total: int) -> void:
	acierto.pitch_scale = 1.0 + subida_tono_por_acierto * float(indice - 1)
	acierto.play()
