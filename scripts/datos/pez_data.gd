class_name PezData
extends Resource
## Un tipo de pez. Cada .tres en data/peces/ es un pez.

enum Rareza { COMUN, RARO, EXTRANO, LEGENDARIO }

@export var id: StringName
@export var nombre: String = ""
@export var rareza: Rareza = Rareza.COMUN
@export var icono: Texture2D
@export var color: Color = Color.WHITE

@export_group("Economía")
@export var valor_base: float = 5.0
@export var peso_min: float = 0.5
@export var peso_max: float = 2.0
## Peso relativo en la tirada de qué pez pica.
@export var probabilidad: float = 1.0

@export_group("Minijuego")
## Pulsaciones necesarias para el perfect.
@export var pasos_perfect: int = 6
## Multiplica el tiempo de reacción de cada botón (>1 = más fácil).
@export var mult_tiempo: float = 1.0
## Probabilidad de que un paso sea doble (número + flecha).
@export_range(0.0, 1.0) var prob_doble: float = 0.0
## Cada cuántos pasos hay un tramo de machacar. 0 = nunca.
@export var machacar_cada: int = 0
@export var pulsaciones_machacar: int = 10
@export var tiempo_machacar: float = 2.0


## Los raros de verdad se escapan si no llenas la barra; los normales salen peores.
func escapa_si_falla_machacar() -> bool:
	return rareza >= Rareza.EXTRANO
