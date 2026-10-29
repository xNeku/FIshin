class_name StatsPesca
extends Resource
## Valores base del minijuego. Lo que depende de la caña va en CanaData.

@export var tiempo_inicial: float = 1.5
## Cada botón dura esto multiplicado por el anterior.
@export var factor_tiempo: float = 0.88
@export var tiempo_minimo: float = 0.4
@export var mult_tiempo_doble: float = 1.4
## Las dobles solo pueden salir a partir de este botón de la cadena (1 = desde el primero).
@export var dobles_desde_boton: int = 5
## Segundos hasta que pica (al azar entre los dos). Pesca tranquila: entre picada y picada hay calma.
@export var espera_min: float = 8.0
@export var espera_max: float = 20.0
## Picoteos de mentira mientras esperas (el corcho tiembla un poco): cada cuánto, al azar entre los dos.
@export var picoteo_min: float = 2.5
@export var picoteo_max: float = 6.0
## El último picoteo avisa de que va a picar: este tiempo antes de la picada de verdad.
@export var aviso_picada: float = 0.9

@export_group("Sensación")
## Botones seguidos que hacen falta para el máximo de zoom, shake y efectos.
## Pensado para los combos de final de juego (~50): al principio todo es muy ligero.
@export var botones_intensidad_maxima: int = 50

@export_group("Flow (nodo Leer el agua)")
## Desde este botón de la cadena se ven los siguientes (si tienes el nodo del árbol).
@export var cola_desde_boton: int = 15
## Con la cola a la vista los botones van más rápidos (0.85 = un 15 % menos de tiempo).
@export var mult_tiempo_cola: float = 0.85

@export_group("Calidad")
## Multiplicador de valor con 0 aciertos (1.0 con todos).
@export var mult_calidad_min: float = 0.3
@export var mult_perfecto: float = 2.0
## Penalización al valor por cada barra de machacar no llenada.
@export var penalizacion_machacar: float = 0.25

@export_group("Racha (combo)")
## Cada botón acertado paga una parte del pez; desde el botón racha_desde[i], cada botón paga racha_mult[i] veces.
## Así una cadena larga rinde más por segundo que muchas cortas (ver docs/INCREMENTAL.md).
## Pez perfecto de x5 = ×1,05 de media; x20 = ×1,36; x50 = ×1,9; x100 = ×2,6; x200 = ×3,6.
@export var racha_desde: Array[int] = [5, 10, 20, 35, 50, 75, 100, 150, 200]
@export var racha_mult: Array[float] = [1.25, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 5.0, 6.0]

@export_group("Maestría (bestiario)")
## Al pescar X ejemplares de una especie, esa especie vale más para siempre (hitos tipo AdVenture Capitalist).
@export var maestria_desde: Array[int] = [10, 50, 200, 1000]
@export var maestria_mult: Array[float] = [1.1, 1.25, 1.5, 2.0]


## Nivel de maestría con estas capturas (0 = ninguno).
func nivel_maestria(capturas: int) -> int:
	var n: int = 0
	for i in maestria_desde.size():
		if capturas >= maestria_desde[i]:
			n = i + 1
	return n


func mult_maestria(capturas: int) -> float:
	var n: int = nivel_maestria(capturas)
	return maestria_mult[n - 1] if n > 0 and n <= maestria_mult.size() else 1.0


## Multiplicador del botón i de la cadena (1 = el primero).
func racha(i: int) -> float:
	var m: float = 1.0
	for n in mini(racha_desde.size(), racha_mult.size()):
		if i >= racha_desde[n]:
			m = racha_mult[n]
	return m


## Tramo de racha en el que está el botón i (0 = sin tramo). Para lo visual.
func tramo_racha(i: int) -> int:
	var t: int = 0
	for n in racha_desde.size():
		if i >= racha_desde[n]:
			t = n + 1
	return t


## Lo que suman los primeros 'aciertos' botones.
func suma_racha(aciertos: int) -> float:
	var s: float = 0.0
	for i in range(1, aciertos + 1):
		s += racha(i)
	return s
