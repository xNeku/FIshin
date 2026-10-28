class_name Isla
extends Node3D
## Raíz de una isla o pieza del mundo. Al llegar dispara sus efectos (salpicadura, fuegos...).

## Partículas que salen al tocar el agua (opcional).
@export var salpicadura: CPUParticles3D
## Nodos con un método "activar()" que se llaman al terminar de llegar (hogueras, antorchas...).
@export var al_llegar_activar: Array[Node] = []


func llegar() -> void:
	if salpicadura:
		salpicadura.restart()
		salpicadura.emitting = true
	for n: Node in al_llegar_activar:
		if n.has_method("activar"):
			n.activar()


## Para cuando la partida ya la tenía: sin efectos de llegada pero todo encendido.
func colocada() -> void:
	for n: Node in al_llegar_activar:
		if n.has_method("activar"):
			n.activar()
