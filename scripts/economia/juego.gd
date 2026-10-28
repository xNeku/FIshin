extends Node
## Autoload "Juego": estado de la partida y guardado.

signal rublos_cambiados(total: float)
signal inventario_cambiado
signal cana_cambiada(cana: CanaData)
signal cebo_cambiado

const VERSION_SAVE := 2
const RUTA_SAVE := "user://partida.json"
const RUTA_CANAS := "res://data/canas/%s.tres"
const RUTA_PECES := "res://data/peces/%s.tres"

@export var segundos_autoguardado: float = 20.0
@export var huecos_iniciales: int = 6
@export var cana_inicial: StringName = &"cana_rota"

var rublos: float = 0.0
var rublos_totales: float = 0.0
## Inventario de la barca: [{id, peso, calidad, perfecto, valor}]. Se apila por especie (id).
var capturas: Array[Dictionary] = []
## Huecos de la barca: cada especie distinta ocupa uno.
var huecos: int = 6
var cana_id: StringName = &"cana_rota"
## Cebo activo: {pescas, mult_tiempo, mult_espera}. Vacío = sin cebo.
var cebo: Dictionary = {}
## id de artículo -> veces comprado
var compras: Dictionary = {}
var stats: Dictionary = {
	"peces_pescados": 0, "perfectos": 0, "escapados": 0, "legendarios": 0, "mejor_combo": 0, "tiempo_jugado": 0.0,
}
## id de pez -> mejor calidad conseguida
var coleccion: Dictionary = {}
## Hitos y cosas desbloqueadas (ej. "barco_comerciante": true)
var flags: Dictionary = {}

## true mientras el náufrago anda fuera de la barca (no se guarda).
var en_movimiento: bool = false

var _t_guardado: float = 0.0
var _cana: CanaData


func _ready() -> void:
	huecos = huecos_iniciales
	cana_id = cana_inicial
	cargar()


func _process(delta: float) -> void:
	stats.tiempo_jugado += delta
	_t_guardado += delta
	if _t_guardado >= segundos_autoguardado:
		_t_guardado = 0.0
		guardar()


## Delta sin el time_scale (para efectos que siguen durante el congelado de impacto).
static func delta_real(delta: float) -> float:
	return delta / maxf(Engine.time_scale, 0.001)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		guardar()


# --- Caña y cebo ---

func cana() -> CanaData:
	if _cana == null or _cana.id != cana_id:
		_cana = load(RUTA_CANAS % cana_id)
	return _cana


func cambiar_cana(nueva: CanaData) -> void:
	cana_id = nueva.id
	_cana = nueva
	cana_cambiada.emit(nueva)


func mult_tiempo_cebo() -> float:
	return cebo.get("mult_tiempo", 1.0)


func mult_espera_cebo() -> float:
	return cebo.get("mult_espera", 1.0)


## Se llama al acabar cada pesca (pez capturado, escapado o soltado).
func consumir_cebo() -> void:
	if cebo.is_empty():
		return
	cebo.pescas = int(cebo.pescas) - 1
	if cebo.pescas <= 0:
		cebo.clear()
	cebo_cambiado.emit()


# --- Inventario ---

func pez_data(id_pez: String) -> PezData:
	return load(RUTA_PECES % id_pez) as PezData


## Cuántas especies existen (para la colección).
func total_especies() -> int:
	var n: int = 0
	for f: String in DirAccess.get_files_at("res://data/peces"):
		if f.trim_suffix(".remap").ends_with(".tres"):
			n += 1
	return n


## Especies en la barca, en orden de llegada.
func especies() -> Array[String]:
	var lista: Array[String] = []
	for c: Dictionary in capturas:
		if not c.id in lista:
			lista.append(c.id)
	return lista


## Todos los huecos ocupados: no se puede seguir pescando hasta vender.
func barca_llena() -> bool:
	return huecos_usados() >= huecos


func huecos_usados() -> int:
	return especies().size()


func cabe(id_pez: String) -> bool:
	return id_pez in especies() or huecos_usados() < huecos


func capturas_de(id_pez: String) -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	for c: Dictionary in capturas:
		if c.id == id_pez:
			lista.append(c)
	return lista


## Devuelve false si no hay hueco para una especie nueva.
func anadir_captura(captura: Dictionary, pez: PezData) -> bool:
	if not cabe(captura.id):
		return false
	capturas.append(captura)
	stats.peces_pescados += 1
	if captura.perfecto:
		stats.perfectos += 1
	if pez.rareza == PezData.Rareza.LEGENDARIO:
		stats.legendarios += 1
	coleccion[String(pez.id)] = maxf(coleccion.get(String(pez.id), 0.0), captura.calidad)
	inventario_cambiado.emit()
	return true


func registrar_combo(botones: int) -> void:
	stats.mejor_combo = maxi(int(stats.mejor_combo), botones)


func anadir_escapado() -> void:
	stats.escapados += 1


func valor_inventario() -> float:
	var total: float = 0.0
	for c: Dictionary in capturas:
		total += c.valor
	return total


## Saca todo el inventario de la barca (para venderlo con animación).
func sacar_capturas() -> Array[Dictionary]:
	var r: Array[Dictionary] = capturas.duplicate()
	capturas.clear()
	inventario_cambiado.emit()
	return r


## Vende todo el inventario de la barca de golpe, sin animación. Devuelve lo ganado.
func vender_todo() -> float:
	var total: float = valor_inventario()
	capturas.clear()
	sumar_rublos(total)
	inventario_cambiado.emit()
	return total


func sumar_rublos(cantidad: float) -> void:
	rublos += cantidad
	if cantidad > 0.0:
		rublos_totales += cantidad
	rublos_cambiados.emit(rublos)


# --- Compras ---

func veces_comprado(art: ArticuloData) -> int:
	return int(compras.get(String(art.id), 0))


func precio(art: ArticuloData) -> float:
	return art.precio_actual(veces_comprado(art))


## "" si se puede comprar; si no, el motivo.
func motivo_no_comprar(art: ArticuloData) -> String:
	if art.max_compras > 0 and veces_comprado(art) >= art.max_compras:
		return "Agotado"
	if art.tipo == ArticuloData.Tipo.CANA and art.cana and art.cana.profundidad <= cana().profundidad:
		return "Ya tienes algo mejor"
	if art.tipo == ArticuloData.Tipo.CEBO and not cebo.is_empty():
		return "Ya llevas cebo"
	if rublos < precio(art):
		return "Faltan rublos"
	return ""


func comprar(art: ArticuloData) -> bool:
	if motivo_no_comprar(art) != "":
		return false
	sumar_rublos(-precio(art))
	compras[String(art.id)] = veces_comprado(art) + 1
	match art.tipo:
		ArticuloData.Tipo.CANA:
			cambiar_cana(art.cana)
		ArticuloData.Tipo.CEBO:
			cebo = {"pescas": art.cebo_pescas, "mult_tiempo": art.cebo_mult_tiempo, "mult_espera": art.cebo_mult_espera}
			cebo_cambiado.emit()
		ArticuloData.Tipo.HUECO:
			huecos += art.huecos
			inventario_cambiado.emit()
	return true


# --- Guardado ---

func guardar() -> void:
	var datos: Dictionary = {
		"version": VERSION_SAVE, "rublos": rublos, "rublos_totales": rublos_totales,
		"capturas": capturas, "huecos": huecos, "cana": String(cana_id), "cebo": cebo, "compras": compras,
		"stats": stats, "coleccion": coleccion, "flags": flags,
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
	# v1 no tenía huecos, caña, cebo ni compras: se quedan los valores por defecto.
	rublos = datos.get("rublos", 0.0)
	rublos_totales = datos.get("rublos_totales", 0.0)
	capturas.clear()
	for c: Variant in datos.get("capturas", []):
		capturas.append(c)
	huecos = int(datos.get("huecos", huecos_iniciales))
	cana_id = StringName(datos.get("cana", String(cana_inicial)))
	if not ResourceLoader.exists(RUTA_CANAS % cana_id):
		cana_id = cana_inicial
	cebo = datos.get("cebo", {})
	compras = datos.get("compras", {})
	for k: String in datos.get("stats", {}):
		stats[k] = datos.stats[k]
	for k: String in ["peces_pescados", "perfectos", "escapados", "legendarios", "mejor_combo"]:
		stats[k] = int(stats[k])
	coleccion = datos.get("coleccion", {})
	flags = datos.get("flags", {})


func borrar_partida() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(RUTA_SAVE))
	rublos = 0.0
	rublos_totales = 0.0
	capturas.clear()
	huecos = huecos_iniciales
	cana_id = cana_inicial
	cebo.clear()
	compras.clear()
	for k: String in stats:
		stats[k] = 0.0 if k == "tiempo_jugado" else 0
	coleccion.clear()
	flags.clear()
	rublos_cambiados.emit(rublos)
	inventario_cambiado.emit()
	cana_cambiada.emit(cana())
	cebo_cambiado.emit()
