class_name AparicionData
extends Resource
## Algo que se pega al mundo al cumplir una condición (islas, edificios...). Viene de la Carta de Fishin.

## PUNTOS_PESCA: la suma de la racha de cada pez (×2 si perfecto). Premia pescar bien: el que encadena llega antes.
## CLIENTES: clientes servidos por el restaurante. DIAS_TRAS_REQUISITO: días del reloj del juego desde que
## llegó el último de `requiere`.
enum Condicion { PECES_PESCADOS, RUBLOS_TOTALES, COMBO_MAXIMO, MINUTOS_JUGADOS, PUNTOS_PESCA, PESCADORES, CLIENTES, DIAS_TRAS_REQUISITO }
## MAR: llega navegando. CIELO: cae con cinemática. CONSTRUIR: sus piezas salen del agua una a una.
## EMERGER: sube desde el fondo del mar.
enum Llegada { MAR, CIELO, CONSTRUIR, EMERGER }

@export var id: StringName
@export var nombre: String = ""
## Escena con el contenido, montada alrededor de su casilla ancla.
@export var escena: PackedScene
## Casilla de la carta donde va el origen de la escena (barca = 0,0; y hacia arriba = -Z).
@export var ancla: Vector2i
## Casillas que ocupa, como en la carta. Todas se pueden pisar.
@export var celdas: Array[Vector2i] = []
## Si se pone, se coloca una copia en cada casilla (tablones de caminos y pantalanes).
## Así la forma se cambia solo editando las celdas, sin tocar la escena.
@export var pieza_por_celda: PackedScene
## Casillas que ocupa pero no se pueden pisar (donde está la casa de un edificio).
@export var celdas_bloqueadas: Array[Vector2i] = []
## Si dos se cumplen a la vez, llega antes la de orden menor.
@export var orden: int = 1

@export_group("Altura")
## Metros por encima del nivel de pesca (0 = abajo, con el donut). El puerto alto va a `altura` 1,2.
@export var altura: float = 0.0
## Casillas con otra altura que el resto (en metros, absoluta). Ej.: el principio del camino 1, abajo.
@export var alturas_celda: Dictionary[Vector2i, float] = {}
## Escaleras: casilla -> hacia dónde sube (Vector2i.UP = hacia arriba en la carta). Une la altura de la
## casilla de detrás con la de delante.
@export var rampas: Dictionary[Vector2i, Vector2i] = {}
## Pieza que se pone en las casillas de rampa (en lugar de pieza_por_celda).
@export var pieza_rampa: PackedScene
## Pieza que se pone debajo de cada casilla elevada (los pilotes de madera que la sujetan).
@export var pieza_bajo_celda: PackedScene

@export_group("Condición")
@export var condicion: Condicion = Condicion.RUBLOS_TOTALES
@export var valor: float = 100.0
## Ids de apariciones que tienen que haber llegado antes (p. ej. el camino que lleva hasta aquí).
@export var requiere: Array[StringName] = []

@export_group("Llegada")
@export var llegada: Llegada = Llegada.MAR
