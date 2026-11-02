class_name CanaData
extends Resource
## Una caña. Cada .tres en data/canas/ es una. Se carga por id: res://data/canas/<id>.tres

@export var id: StringName
@export var nombre: String = ""
@export_multiline var descripcion: String = ""
@export var icono: Texture2D
## NORMAL: el minijuego de siempre. VOLUMEN (caña rápida) y TROFEO (caña tocha): minijuego de carril
## (scripts/pesca/ritmo.gd). Volumen: un banco, cada nota es un pez. Trofeo: solo raros, pelea larga.
enum Modo { NORMAL, VOLUMEN, TROFEO }

@export var modo: Modo = Modo.NORMAL
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
## extra alarga el máximo; quitar_sesgo (0..1) reparte más los largos (árbol, rama Pesca).
func tirar_largo_cadena(extra: int = 0, quitar_sesgo: float = 0.0) -> int:
	var opciones: int = maxi(1, cadena_max + extra - cadena_min + 1)
	# Sesgo > 1 tira a cadenas cortas; < 1, a largas (picadas que han tardado mucho).
	var sesgo: float = maxf(0.45, sesgo_cadena * (1.0 - clampf(quitar_sesgo, 0.0, 0.85)))
	return cadena_min + mini(opciones - 1, floori(opciones * pow(randf(), sesgo)))
