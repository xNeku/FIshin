class_name CanaData
extends Resource
## Una caña. Cada .tres en data/canas/ es una. Se carga por id: res://data/canas/<id>.tres

@export var id: StringName
@export var nombre: String = ""
@export_multiline var descripcion: String = ""
@export var icono: Texture2D
## Hasta qué profundidad llega. Los peces más profundos no pican.
@export var profundidad: int = 1
@export_group("Cadena")
## En cada picada se tira el largo de la cadena entre min y max.
@export var cadena_min: int = 1
@export var cadena_max: int = 5
## >1 = salen más cadenas cortas (2 = muy tacaño). 1 = todos los largos igual de probables.
@export var sesgo_cadena: float = 2.0

@export_group("Rates")
## Multiplica el tiempo de reacción de cada botón (>1 = más fácil).
@export var mult_tiempo: float = 1.0
## Multiplica la espera hasta que pica (<1 = pican antes).
@export var mult_espera: float = 1.0
## Multiplica la probabilidad de los peces no comunes.
@export var mult_rareza: float = 1.0
## Si es true, fallar el primer botón no hace escapar al pez.
@export var auto_primer_boton: bool = false


## Largo de la cadena para una picada, sesgado hacia lo corto.
func tirar_largo_cadena() -> int:
	var opciones: int = maxi(1, cadena_max - cadena_min + 1)
	return cadena_min + mini(opciones - 1, floori(opciones * pow(randf(), sesgo_cadena)))
