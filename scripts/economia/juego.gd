extends Node
## Autoload "Juego": estado de la partida y guardado.

signal rublos_cambiados(total: float)
signal capturas_cambiadas(cantidad: int)

const VERSION_SAVE := 1
const RUTA_SAVE := "user://partida.json"

@export var segundos_autoguardado: float = 20.0

var rublos: float = 0.0
var rublos_totales: float = 0.0
## Inventario de la barca: [{id, peso, calidad, perfecto, valor}]
var capturas: Array[Dictionary] = []
var stats: Dictionary = {
	"peces_pescados": 0, "perfectos": 0, "escapados": 0, "legendarios": 0, "tiempo_jugado": 0.0,
}
## id de pez -> mejor calidad conseguida
var coleccion: Dictionary = {}
## Hitos y cosas desbloqueadas (ej. "barco_comerciante": true)
var flags: Dictionary = {}

var _t_guardado: float = 0.0


func _ready() -> void:
	cargar()


func _process(delta: float) -> void:
	stats.tiempo_jugado += delta
	_t_guardado += delta
	if _t_guardado >= segundos_autoguardado:
		_t_guardado = 0.0
		guardar()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		guardar()


func anadir_captura(captura: Dictionary, pez: PezData) -> void:
	capturas.append(captura)
	stats.peces_pescados += 1
	if captura.perfecto:
		stats.perfectos += 1
	if pez.rareza == PezData.Rareza.LEGENDARIO:
		stats.legendarios += 1
	coleccion[String(pez.id)] = maxf(coleccion.get(String(pez.id), 0.0), captura.calidad)
	capturas_cambiadas.emit(capturas.size())


func anadir_escapado() -> void:
	stats.escapados += 1


func valor_inventario() -> float:
	var total: float = 0.0
	for c: Dictionary in capturas:
		total += c.valor
	return total


## Vende todo el inventario de la barca. Devuelve lo ganado.
func vender_todo() -> float:
	var total: float = valor_inventario()
	capturas.clear()
	sumar_rublos(total)
	capturas_cambiadas.emit(0)
	return total


func sumar_rublos(cantidad: float) -> void:
	rublos += cantidad
	if cantidad > 0.0:
		rublos_totales += cantidad
	rublos_cambiados.emit(rublos)


func guardar() -> void:
	var datos: Dictionary = {
		"version": VERSION_SAVE, "rublos": rublos, "rublos_totales": rublos_totales,
		"capturas": capturas, "stats": stats, "coleccion": coleccion, "flags": flags,
		"fecha": Time.get_unix_time_from_system(),
	}
	var f := FileAccess.open(RUTA_SAVE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(datos))


func cargar() -> void:
	if not FileAccess.file_exists(RUTA_SAVE):
		return
	var datos: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_SAVE))
	if not datos is Dictionary:
		push_warning("Save corrupto, se ignora")
		return
	rublos = datos.get("rublos", 0.0)
	rublos_totales = datos.get("rublos_totales", 0.0)
	capturas.clear()
	for c: Variant in datos.get("capturas", []):
		capturas.append(c)
	for k: String in datos.get("stats", {}):
		stats[k] = datos.stats[k]
	for k: String in ["peces_pescados", "perfectos", "escapados", "legendarios"]:
		stats[k] = int(stats[k])
	coleccion = datos.get("coleccion", {})
	flags = datos.get("flags", {})


func borrar_partida() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(RUTA_SAVE))
	rublos = 0.0
	rublos_totales = 0.0
	capturas.clear()
	for k: String in stats:
		stats[k] = 0.0 if k == "tiempo_jugado" else 0
	coleccion.clear()
	flags.clear()
	rublos_cambiados.emit(rublos)
	capturas_cambiadas.emit(0)
