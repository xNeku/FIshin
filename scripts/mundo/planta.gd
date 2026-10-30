class_name Planta
extends Node3D
## Una planta de un cultivo (pimiento, alga...). Crece sola por fases y, lista, se cosecha a hozazos.
## Su botón de interactuar (hijo Interaccion) solo se ve cuando está lista.

@export var cultivo: CultivoData

@onready var dibujo: Sprite3D = $Dibujo
@onready var interaccion: Node3D = get_node_or_null("Interaccion")

## 0 recién cortada, 1 lista.
var progreso: float = 0.0
var _fase: int = -1
var _t: float = 0.0


func _ready() -> void:
	add_to_group("plantas")
	# Sin guardar el crecimiento: al cargar, cada una va por un punto distinto (y casi todas listas).
	progreso = randf_range(0.5, 1.0)
	_t = randf() * TAU
	_pintar()


func _process(delta: float) -> void:
	if cultivo == null:
		return
	_t += delta
	if progreso < 1.0:
		# Huerto zen (rama Cosecha): crecen más rápido.
		progreso = minf(1.0, progreso + delta * (1.0 + Juego.efecto(&"cultivos")) / maxf(1.0, cultivo.segundos_crecer))
	_pintar()
	if lista():
		# Lista: se mece un poco para llamar la atención.
		dibujo.rotation.z = sin(_t * 3.0) * 0.06


func lista() -> bool:
	return progreso >= 1.0


## La siega: vuelve a brote y devuelve lo que da.
func cosechar() -> int:
	if not lista():
		return 0
	progreso = 0.0
	dibujo.rotation.z = 0.0
	_pintar()
	var tw := create_tween()
	dibujo.scale = Vector3(1.4, 0.6, 1.0)
	tw.tween_property(dibujo, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return cultivo.por_planta + int(Juego.efecto(&"por_planta"))


func _pintar() -> void:
	if cultivo == null or cultivo.fases.is_empty():
		return
	var n: int = cultivo.fases.size()
	var f: int = n - 1 if lista() else mini(n - 2, int(progreso * (n - 1)))
	if interaccion:
		interaccion.visible = lista()
	if f == _fase:
		return
	_fase = f
	dibujo.texture = cultivo.fases[f]
	dibujo.offset.y = dibujo.texture.get_height() * 0.5
