class_name CanaData
extends Resource
## Una caña. Cada .tres en data/canas/ es una. Se carga por id: res://data/canas/<id>.tres

@export var id: StringName
@export var nombre: String = ""
@export_multiline var descripcion: String = ""
@export var icono: Texture2D
## Hasta qué profundidad llega. Los peces más profundos no pican.
@export var profundidad: int = 1
## Límite natural de la cadena de botones.
@export var limite_cadena: int = 8
## Multiplica el tiempo de reacción de cada botón (>1 = más fácil).
@export var mult_tiempo: float = 1.0
## Multiplica la espera hasta que pica (<1 = pican antes).
@export var mult_espera: float = 1.0
## Multiplica la probabilidad de los peces no comunes.
@export var mult_rareza: float = 1.0
## Si es true, fallar el primer botón no hace escapar al pez.
@export var auto_primer_boton: bool = false
