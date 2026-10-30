class_name NivelTuristasData
extends Resource
## Un tipo de turistas (acumulativo: al desbloquear uno nuevo, los que vienen se reparten entre todos).
## Cada .tres en data/turistas/ es uno.

@export var nivel: int = 1
@export var nombre: String = ""
## Dibujos de las personas (se elige uno al azar para cada turista).
@export var personas: Array[Texture2D] = []
## Barcos en los que llegan, y cuánta gente cabe en cada uno (mismo orden).
@export var barcos: Array[Texture2D] = []
@export var plazas: Array[int] = []
## Altura a la que van de pie los pasajeros en cada barco (mismo orden; si falta, en el fondo).
@export var alturas_cubierta: Array[float] = []
## Clientes servidos en total por el restaurante para que empiecen a venir.
@export var clientes_para_desbloquear: int = 0
