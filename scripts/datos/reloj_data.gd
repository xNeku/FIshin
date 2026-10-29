class_name RelojData
extends Resource
## El reloj del juego: cuánto dura el día, la noche y las estaciones, y cómo se ve la noche.
## Se guarda en data/reloj.tres. Juego lleva los segundos que han pasado (Juego.reloj).

const ESTACIONES: Array[String] = ["Primavera", "Verano", "Otoño", "Invierno"]
## Fases de la luna, una por noche (la nueva no se ve).
const FASES: Array[String] = ["nueva", "creciente", "cuarto creciente", "gibosa", "llena", "gibosa", "cuarto menguante", "menguante"]

@export_group("Duraciones (segundos reales)")
## Parte de día y de noche de cada día (12 min + 8 min = un día de 20 min).
@export var duracion_dia: float = 720.0
@export var duracion_noche: float = 480.0
## Lo que tarda en anochecer o amanecer (dentro de esos tiempos).
@export var duracion_transicion: float = 60.0
## Días que dura cada estación (6 días de 20 min = 2 h).
@export var dias_por_estacion: int = 6
## Cuándo empieza una partida nueva: segundos desde el amanecer del primer día de primavera.
@export var inicio: float = 30.0

@export_group("Cómo se ve la noche")
## Color por el que se multiplica el mundo a medianoche (lo muy claro, como el fuego, se salva).
@export var tinte_noche: Color = Color(0.26, 0.32, 0.58)
@export var tinte_ocaso: Color = Color(1.0, 0.78, 0.62)
## Luz del sol y del ambiente de noche (1 = como de día).
@export_range(0.0, 1.0) var luz_noche: float = 0.3
@export_range(0.0, 1.0) var ambiente_noche: float = 0.4


func duracion_ciclo() -> float:
	return duracion_dia + duracion_noche


func dia(t: float) -> int:
	return int(floor(t / duracion_ciclo()))


## Segundos desde el amanecer de hoy.
func momento(t: float) -> float:
	return fposmod(t, duracion_ciclo())


func es_noche(t: float) -> bool:
	return momento(t) >= duracion_dia


## 0 de día, 1 de noche, con anochecer y amanecer suaves (la transición va al final de cada parte).
func factor_noche(t: float) -> float:
	var m: float = momento(t)
	var tr: float = maxf(1.0, duracion_transicion)
	if m < duracion_dia - tr:
		return 0.0
	if m < duracion_dia:
		return (m - (duracion_dia - tr)) / tr
	if m < duracion_ciclo() - tr:
		return 1.0
	return 1.0 - (m - (duracion_ciclo() - tr)) / tr


## 1 en lo más rojo del atardecer (a mitad del anochecer), 0 el resto del día.
func factor_ocaso(t: float) -> float:
	var d: float = absf(momento(t) - centro_ocaso())
	return clampf(1.0 - d / maxf(1.0, duracion_transicion), 0.0, 1.0)


func centro_ocaso() -> float:
	return duracion_dia - duracion_transicion * 0.5


func estacion(t: float) -> int:
	return int(floor(float(dia(t)) / float(maxi(1, dias_por_estacion)))) % 4


## La estación como bit, para comparar con PezData.estaciones (1 primavera, 2 verano, 4 otoño, 8 invierno).
func bit_estacion(t: float) -> int:
	return 1 << estacion(t)


## Día dentro de la estación (1..dias_por_estacion).
func dia_de_estacion(t: float) -> int:
	return dia(t) % maxi(1, dias_por_estacion) + 1


## Hora del reloj: el día va de 06:00 a 18:00 y la noche de 18:00 a 06:00.
func hora(t: float) -> float:
	var m: float = momento(t)
	if m < duracion_dia:
		return 6.0 + m / duracion_dia * 12.0
	return fposmod(18.0 + (m - duracion_dia) / duracion_noche * 12.0, 24.0)


func hora_texto(t: float) -> String:
	var h: float = hora(t)
	return "%02d:%02d" % [int(h), int(fmod(h, 1.0) * 60.0)]


## Fase de la luna de esta noche (0 = nueva ... 4 = llena).
func fase_luna(t: float) -> int:
	return dia(t) % FASES.size()


## Lo que brilla la luna (0 en luna nueva, 1 en llena).
func brillo_luna(t: float) -> float:
	var f: int = fase_luna(t)
	return 1.0 - absf(float(f) - 4.0) / 4.0


## Ocaso: un rato alrededor de la puesta de sol (para los peces de horario Ocaso).
func es_ocaso(t: float) -> bool:
	return absf(momento(t) - centro_ocaso()) <= duracion_transicion
