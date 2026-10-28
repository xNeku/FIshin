class_name ClimaData
extends Resource
## Un tipo de tiempo. El nodo Clima pasa de uno a otro poco a poco. Cada .tres en data/climas/ es uno.

@export var id: StringName
@export var nombre: String = ""
## Peso al sortear el siguiente.
@export var probabilidad: float = 1.0
@export var duracion_min: float = 90.0
@export var duracion_max: float = 180.0

@export_group("Cielo y luz")
@export var cielo_arriba: Color = Color(0.32, 0.52, 0.82)
@export var cielo_horizonte: Color = Color(0.95, 0.75, 0.58)
@export_range(0.0, 1.0) var nubes: float = 0.25
@export var color_nubes: Color = Color(1, 1, 1)
@export var color_sol: Color = Color(1, 0.93, 0.82)
@export var energia_sol: float = 1.0
@export var energia_ambiente: float = 1.0
@export var niebla: float = 0.0
@export var color_niebla: Color = Color(0.7, 0.75, 0.8)

@export_group("Mar")
@export var agua_profundo: Color = Color(0.04, 0.22, 0.38)
@export var agua_claro: Color = Color(0.14, 0.56, 0.68)
@export var altura_ola: float = 0.14
@export var velocidad_ola: float = 1.0
@export var rugosidad: float = 0.06

@export_group("Lluvia y tormenta")
@export_range(0.0, 1.0) var lluvia: float = 0.0
@export var relampagos: bool = false
