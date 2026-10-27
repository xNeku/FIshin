class_name Formato
extends RefCounted
## Formateo común de números y textos.

const SIMBOLO := "₽"
const SUFIJOS: Array[String] = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]


static func numero(v: float) -> String:
	if absf(v) < 1000.0:
		return str(floori(v)) if absf(v) >= 10.0 or is_equal_approx(v, roundf(v)) else "%.1f" % v
	var e: int = floori(log(absf(v)) / log(1000.0))
	if e < SUFIJOS.size():
		return "%.2f%s" % [v / pow(1000.0, e), SUFIJOS[e]]
	return "%.2fe%d" % [v / pow(10.0, floorf(log(absf(v)) / log(10.0))), floori(log(absf(v)) / log(10.0))]


static func dinero(v: float) -> String:
	return "%s %s" % [numero(v), SIMBOLO]


static func calidad(ratio: float, perfecto: bool) -> String:
	if perfecto:
		return "¡PERFECTO!"
	if ratio >= 0.8:
		return "Excelente"
	if ratio >= 0.5:
		return "Buena"
	if ratio >= 0.25:
		return "Normal"
	return "Mala"


static func peso(kg: float) -> String:
	return "%.2f kg" % kg if kg < 10.0 else "%.1f kg" % kg


static func tiempo(segundos: float) -> String:
	var s: int = floori(segundos)
	if s >= 3600:
		return "%dh %02dm" % [s / 3600, (s % 3600) / 60]
	return "%dm %02ds" % [s / 60, s % 60]
