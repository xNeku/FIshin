class_name StatsPesca
extends Resource
## Valores base del minijuego. Lo que depende de la caña va en CanaData.

@export var tiempo_inicial: float = 1.5
## Cada botón dura esto multiplicado por el anterior.
@export var factor_tiempo: float = 0.88
@export var tiempo_minimo: float = 0.4
@export var mult_tiempo_doble: float = 1.4
@export var espera_min: float = 1.5
@export var espera_max: float = 3.5

@export_group("Calidad")
## Multiplicador de valor con 0 aciertos (1.0 con todos).
@export var mult_calidad_min: float = 0.3
@export var mult_perfecto: float = 2.0
## Penalización al valor por cada barra de machacar no llenada.
@export var penalizacion_machacar: float = 0.25
