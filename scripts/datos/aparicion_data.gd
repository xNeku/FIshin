class_name AparicionData
extends Resource
## Algo que se pega al mundo al cumplir una condición (islas, edificios...). Viene de la Carta de Fishin.

enum Condicion { PECES_PESCADOS, RUBLOS_TOTALES }
enum Llegada { MAR, CIELO }

@export var id: StringName
@export var nombre: String = ""
## Escena con el contenido, montada alrededor de su casilla ancla.
@export var escena: PackedScene
## Casilla de la carta donde va el origen de la escena (barca = 0,0; y hacia arriba = -Z).
@export var ancla: Vector2i
## Casillas que ocupa, como en la carta (informativo y para colisiones futuras).
@export var celdas: Array[Vector2i] = []
## Si dos se cumplen a la vez, llega antes la de orden menor.
@export var orden: int = 1

@export_group("Condición")
@export var condicion: Condicion = Condicion.RUBLOS_TOTALES
@export var valor: float = 100.0

@export_group("Llegada")
@export var llegada: Llegada = Llegada.MAR
## Texto grande al llegar. Vacío = "¡Ha llegado <nombre>!".
@export var texto_llegada: String = ""
