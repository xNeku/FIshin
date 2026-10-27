class_name StatsPesca
extends Resource
## Valores del jugador para el minijuego. Las mejoras y el árbol los irán subiendo.

## Límite natural de la cadena de botones (la caña).
@export var limite_cadena: int = 8
@export var tiempo_inicial: float = 1.5
## Cada botón dura esto multiplicado por el anterior.
@export var factor_tiempo: float = 0.88
@export var tiempo_minimo: float = 0.4
@export var mult_tiempo_doble: float = 1.4
@export var espera_min: float = 1.5
@export var espera_max: float = 3.5
## Si es true, fallar el primer botón no hace escapar al pez.
@export var auto_primer_boton: bool = false

@export_group("Calidad")
## Multiplicador de valor con 0 aciertos (1.0 con todos).
@export var mult_calidad_min: float = 0.3
@export var mult_perfecto: float = 2.0
## Penalización al valor por cada barra de machacar no llenada.
@export var penalizacion_machacar: float = 0.25
