class_name Taladro
extends Isla
## Taladro de coral. Extrae coral solo y lo junta al lado; con R2 lo recoges y vuela hacia ti.
## El coral es un material: se gasta en mejoras del ayuntamiento y en las cañas del mid game.

@export var maquina: Node3D
@export var monton: Node3D
@export var interaccion: Node3D
@export var coral_textura: Texture2D
## Coral por minuto (rama Cosecha y mejoras del taladro lo suben).
@export var coral_por_minuto: float = 3.0
## Lo que cabe junto al taladro antes de que deje de sacar.
@export var tope: float = 60.0
@export var temblor: float = 0.04

var _t: float = 0.0


func _process(delta: float) -> void:
	var stock: float = float(Juego.flags.get("taladro_coral", 0.0))
	var lleno: bool = stock >= tope + Juego.efecto(&"taladro_tope")
	if not lleno:
		var ritmo: float = coral_por_minuto * (1.0 + Juego.efecto(&"coral") + Juego.efecto(&"taladro_ritmo"))
		stock = minf(tope + Juego.efecto(&"taladro_tope"), stock + ritmo * delta / 60.0)
		Juego.flags["taladro_coral"] = stock
	_t += delta
	# Mientras perfora, la máquina tiembla un poco.
	if maquina:
		maquina.position.x = sin(_t * 40.0) * temblor if not lleno else 0.0
	if monton:
		monton.scale = Vector3.ONE * clampf(0.4 + stock / 30.0, 0.4, 1.6)
		monton.visible = stock >= 1.0
	if interaccion:
		interaccion.visible = stock >= 1.0


## Te llevas todo el coral junto (a veces doble, con Coral de la suerte).
func recoger(quien: Node3D) -> void:
	var n: int = int(float(Juego.flags.get("taladro_coral", 0.0)))
	if n <= 0:
		return
	Juego.flags["taladro_coral"] = float(Juego.flags.get("taladro_coral", 0.0)) - n
	if randf() < Juego.efecto(&"coral_doble"):
		n *= 2
	var texturas: Array[Texture2D] = []
	for k in mini(8, ceili(n / 5.0)):
		texturas.append(coral_textura)
	await Vuelos.enviar(monton if monton else self, quien, texturas, Callable(), Vuelos.sfx_pez, 1.5)
	Juego.sumar_material("coral", n)
