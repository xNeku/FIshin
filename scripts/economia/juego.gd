extends Node
## Autoload "Juego": estado de la partida y guardado.

signal rublos_cambiados(total: float)
signal inventario_cambiado
signal cana_cambiada(cana: CanaData)
signal cebo_cambiado
signal cubo_cambiado
signal trabajadores_cambiados(cantidad: int)
signal habilidades_cambiadas
signal cosecha_cambiada

const VERSION_SAVE := 7
const RUTA_SAVE := "user://partida.json"
const RUTA_COPIA := "user://partida.anterior.json"
## Opciones del jugador (filtro, etc.): van aparte para que borrar la partida no las toque.
const RUTA_OPCIONES := "user://opciones.cfg"
const RUTA_CANAS := "res://data/canas/%s.tres"
const RUTA_PECES := "res://data/peces/%s.tres"
const RUTA_ARBOL := "res://data/arbol/arbol.tres"
const RUTA_STATS := "res://data/stats_pesca.tres"
const RUTA_RELOJ := "res://data/reloj.tres"

@export var segundos_autoguardado: float = 20.0
@export var cana_inicial: StringName = &"cana_rota"
## Segundos sin tocar nada para que cuente como "de chill" (rama Chill).
@export var segundos_para_chill: float = 8.0

var rublos: float = 0.0
var rublos_totales: float = 0.0
## Inventario de la barca: [{id, peso, calidad, perfecto, valor}]. Se apila por especie (id). Sin límite.
var capturas: Array[Dictionary] = []
var cana_id: StringName = &"cana_rota"
## Cebo activo: {pescas, mult_tiempo, mult_espera}. Vacío = sin cebo.
var cebo: Dictionary = {}
## id de artículo -> veces comprado
var compras: Dictionary = {}
var stats: Dictionary = {
	"peces_pescados": 0, "perfectos": 0, "escapados": 0, "legendarios": 0, "mejor_combo": 0, "tiempo_jugado": 0.0,
	# Suma de la racha de cada pez (×2 si perfecto): mide lo bien que pescas. Lo usan algunas llegadas.
	"puntos_pesca": 0.0,
	# Restaurante: clientes servidos y visitas de turistas.
	"clientes": 0, "visitas_turistas": 0,
}
## id de pez -> mejor calidad conseguida
var coleccion: Dictionary = {}
## id de pez -> cuántos has pescado tú (maestría del bestiario).
var capturados: Dictionary = {}
## El mismo recurso que usa la Pesca (los valores se tocan en data/stats_pesca.tres).
var stats_pesca: StatsPesca
## Reloj del juego: segundos que han pasado desde el primer amanecer (día, noche y estaciones en data/reloj.tres).
var reloj: float = 0.0
var reloj_data: RelojData
## Multiplica lo rápido que pasa el tiempo (para el futuro edificio del reloj).
var velocidad_reloj: float = 1.0
## Pescadores del puerto contratados.
var trabajadores: int = 0
## Bordes libres donde aún cabe un pescador (lo pone el puerto; no se guarda).
var plazas_trabajadores: int = 99
## Lo que han dejado los pescadores en el cubo del puerto.
var cubo_capturas: Array[Dictionary] = []
## true mientras el náufrago lleva el cubo en la mano.
var cubo_en_mano: bool = false
## Hitos y cosas desbloqueadas (ej. "barco_comerciante": true)
var flags: Dictionary = {}
## Lo cosechado que llevas encima, para dárselo al restaurante: id de cultivo -> cantidad.
var cosecha: Dictionary = {}
## Despensa del restaurante: "raciones" (pescado que le manda la lonja), "valor" (lo que valen en total)
## y lo que le has dado de cada cultivo (id -> cantidad).
var despensa: Dictionary = {"raciones": 0.0, "valor": 0.0}
## Materiales que no son dinero (coral...): id -> cantidad.
var materiales: Dictionary = {}
signal materiales_cambiados
## Crecimiento de cada planta (ruta -> 0..1). Lo mantienen las plantas y se guarda.
var plantas: Dictionary = {}
## Cultivos que existen (data/cultivos), por id.
var cultivos: Dictionary = {}
## Artículos de tipo MEJORA (data/articulos): suman a los efectos según las veces comprados.
var _mejoras: Array[ArticuloData] = []
## Árbol de habilidades: id de nodo -> nivel comprado.
var habilidades: Dictionary = {}
var arbol: ArbolData

## true mientras llueve o hay tormenta (lo pone el Clima, no se guarda).
var lloviendo: bool = false

## true mientras el náufrago anda fuera de la barca (no se guarda).
var en_movimiento: bool = false
## Dinero de una venta que aún va volando (peces o monedas). Se guarda como si ya hubiera llegado,
## para no perderlo si se cierra el juego a mitad de la animación.
var dinero_en_camino: float = 0.0

var _t_guardado: float = 0.0
var _cana: CanaData
var _efectos: Dictionary = {}
var _t_sin_tocar: float = 0.0


func _ready() -> void:
	cana_id = cana_inicial
	if ResourceLoader.exists(RUTA_ARBOL):
		arbol = load(RUTA_ARBOL)
	_cargar_carpeta("res://data/cultivos", func(r: Resource) -> void:
		if r is CultivoData:
			cultivos[r.id] = r)
	_cargar_carpeta("res://data/articulos", func(r: Resource) -> void:
		if r is ArticuloData and r.tipo == ArticuloData.Tipo.MEJORA:
			_mejoras.append(r))
	stats_pesca = load(RUTA_STATS)
	reloj_data = load(RUTA_RELOJ)
	reloj = reloj_data.inicio if reloj_data else 0.0
	cargar()
	_recalcular_efectos()
	IconosInput.forzado = String(opcion("iconos", ""))
	if IconosInput.forzado != "":
		IconosInput.dispositivo = IconosInput.forzado


func _process(delta: float) -> void:
	stats.tiempo_jugado += delta
	reloj += delta * velocidad_reloj
	_t_sin_tocar += delta
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


func capturas_de(id_pez: String) -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	for c: Dictionary in capturas:
		if c.id == id_pez:
			lista.append(c)
	return lista


func anadir_captura(captura: Dictionary, pez: PezData) -> void:
	capturas.append(captura)
	stats.peces_pescados += 1
	if captura.perfecto:
		stats.perfectos += 1
	if pez.rareza >= PezData.Rareza.LEGENDARIO:
		stats.legendarios += 1
	coleccion[String(pez.id)] = maxf(coleccion.get(String(pez.id), 0.0), captura.calidad)
	capturados[String(pez.id)] = int(capturados.get(String(pez.id), 0)) + 1
	inventario_cambiado.emit()


## Si el pez puede picar ahora (estación y hora de su ficha).
func pez_disponible(pez: PezData) -> bool:
	if reloj_data == null:
		return true
	if pez.estaciones != 0 and (pez.estaciones & reloj_data.bit_estacion(reloj)) == 0:
		return false
	match pez.horario:
		1:
			return not reloj_data.es_noche(reloj)
		2:
			return reloj_data.es_noche(reloj)
		3:
			return reloj_data.es_ocaso(reloj)
	return true


## Cuántas has pescado de esa especie y su multiplicador de maestría.
func capturas_especie(id_pez: StringName) -> int:
	return int(capturados.get(String(id_pez), 0))


func mult_maestria(id_pez: StringName) -> float:
	return stats_pesca.mult_maestria(capturas_especie(id_pez)) if stats_pesca else 1.0


func registrar_combo(botones: int) -> void:
	stats.mejor_combo = maxi(int(stats.mejor_combo), botones)


func sumar_puntos_pesca(puntos: float) -> void:
	stats.puntos_pesca = float(stats.get("puntos_pesca", 0.0)) + puntos


func anadir_escapado() -> void:
	stats.escapados += 1


# --- Chill ---

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton \
			or (event is InputEventJoypadMotion and absf((event as InputEventJoypadMotion).axis_value) > 0.5):
		_t_sin_tocar = 0.0


## true si el jugador lleva un rato sin tocar nada (la rama Chill acorta ese rato).
func de_chill() -> bool:
	return _t_sin_tocar >= maxf(3.0, segundos_para_chill - efecto(&"umbral_chill"))


# --- Árbol de habilidades ---

## Suma de lo que dan todos los nodos comprados con ese efecto (0 si ninguno).
func efecto(nombre: StringName) -> float:
	return _efectos.get(nombre, 0.0)


func nivel_habilidad(nodo: NodoArbolData) -> int:
	return int(habilidades.get(String(nodo.id), 0))


## true si se cumplen los requisitos para empezar a comprarlo (no mira el dinero).
func habilidad_disponible(nodo: NodoArbolData) -> bool:
	if nodo.requiere_flag != "" and not flags.get(nodo.requiere_flag, false):
		return false
	for r: Resource in nodo.requisitos:
		if nivel_habilidad(r as NodoArbolData) <= 0:
			return false
	return true


func coste_habilidad(nodo: NodoArbolData) -> float:
	return nodo.coste(nivel_habilidad(nodo))


## "" si se puede mejorar ya; si no, el motivo.
func motivo_no_mejorar(nodo: NodoArbolData) -> String:
	if nivel_habilidad(nodo) >= nodo.niveles:
		return "MAX"
	if nodo.requiere_flag != "" and not flags.get(nodo.requiere_flag, false):
		return nodo.texto_bloqueo if nodo.texto_bloqueo != "" else "Bloqueado"
	for r: Resource in nodo.requisitos:
		if nivel_habilidad(r as NodoArbolData) <= 0:
			return "Necesita: " + (r as NodoArbolData).nombre
	if rublos < coste_habilidad(nodo):
		return "Faltan rublos"
	return ""


func mejorar_habilidad(nodo: NodoArbolData) -> bool:
	if motivo_no_mejorar(nodo) != "":
		return false
	sumar_rublos(-coste_habilidad(nodo))
	habilidades[String(nodo.id)] = nivel_habilidad(nodo) + 1
	_recalcular_efectos()
	habilidades_cambiadas.emit()
	guardar()
	return true


func _recalcular_efectos() -> void:
	_efectos.clear()
	for m: ArticuloData in _mejoras:
		if m.efecto != &"":
			_efectos[m.efecto] = _efectos.get(m.efecto, 0.0) + m.valor_efecto * veces_comprado(m)
	if arbol == null:
		return
	for n: NodoArbolData in arbol.nodos:
		var nv: int = nivel_habilidad(n)
		if nv > 0 and n.efecto != &"":
			_efectos[n.efecto] = _efectos.get(n.efecto, 0.0) + n.valor_por_nivel * nv


## La lonja es el centro de venta: desde que llega, todo lo que vendes vale más, lo vendas donde lo vendas.
## (Lo pone el nodo Comercio de main.tscn, que es donde se ajusta.)
var bonus_lonja: float = 1.3


func lonja_abierta() -> bool:
	return flags.get("aparecido_lonja", false)


## Multiplicador de venta: Carisma, y la lonja (y su rama del árbol) en cuanto existe.
func mult_venta() -> float:
	if not lonja_abierta():
		return 1.0 + efecto(&"precio_venta")
	return (1.0 + efecto(&"precio_venta") + efecto(&"precio_lonja")) * bonus_lonja


## Multiplicador de velocidad de los trabajadores (Carisma, y Chill si no tocas nada o llueve).
func mult_trabajadores() -> float:
	var m: float = 1.0 + efecto(&"trabajador_velocidad")
	if de_chill():
		m += efecto(&"trabajadores_chill")
	if lloviendo:
		m += efecto(&"trabajadores_lluvia")
	return m


# --- Cultivos y restaurante ---

func sumar_cosecha(id: StringName, n: int) -> void:
	cosecha[String(id)] = int(cosecha.get(String(id), 0)) + n
	cosecha_cambiada.emit()


func total_cosecha() -> int:
	var t: int = 0
	for k: String in cosecha:
		t += int(cosecha[k])
	return t


## Se lo das todo a O Mar: te lo paga (devuelve el dinero en "dinero") y lo que sirve para platos se queda en
## su despensa. Devuelve id -> cantidad dada, más "dinero".
func entregar_cosecha() -> Dictionary:
	var dado: Dictionary = cosecha.duplicate()
	var dinero: float = 0.0
	for k: String in cosecha:
		var c: CultivoData = cultivos.get(StringName(k))
		if c == null:
			continue
		dinero += int(cosecha[k]) * precio_cosecha(c)
		if c.a_la_despensa:
			despensa[k] = int(despensa.get(k, 0)) + int(cosecha[k])
	cosecha.clear()
	cosecha_cambiada.emit()
	dado["dinero"] = dinero
	return dado


func sumar_material(id: String, n: float) -> void:
	if n == 0.0:
		return
	materiales[id] = float(materiales.get(id, 0.0)) + n
	materiales_cambiados.emit()


## Cuánto atrae la villa: multiplica lo que pagan los turistas (decoración, mejoras...). Una sola cifra.
func atractivo() -> float:
	return 1.0 + efecto(&"atractivo")


## Lo que paga O Mar por una unidad de este cultivo.
func precio_cosecha(c: CultivoData) -> float:
	return c.precio * (1.0 + efecto(&"valor_cosecha")) * mult_venta()


func _plantas_al_dia() -> Dictionary:
	for n: Node in get_tree().get_nodes_in_group("plantas"):
		plantas["%s/%s" % [n.get_parent().name, n.name]] = n.progreso
	return plantas


func _cargar_carpeta(carpeta: String, hacer: Callable) -> void:
	for f: String in DirAccess.get_files_at(carpeta):
		f = f.trim_suffix(".remap")
		if f.ends_with(".tres"):
			hacer.call(load(carpeta + "/" + f))


# --- Puerto ---

func contratar_trabajador() -> void:
	trabajadores += 1
	trabajadores_cambiados.emit(trabajadores)


func meter_en_cubo(capturas_nuevas: Array[Dictionary]) -> void:
	cubo_capturas.append_array(capturas_nuevas)
	cubo_cambiado.emit()


func coger_cubo() -> void:
	cubo_en_mano = true
	cubo_cambiado.emit()


## Vacía el cubo (para venderlo). Sigue en la mano hasta que vuelve a su sitio.
func vaciar_cubo() -> Array[Dictionary]:
	var r: Array[Dictionary] = cubo_capturas.duplicate()
	cubo_capturas.clear()
	cubo_cambiado.emit()
	return r


func soltar_cubo() -> void:
	cubo_en_mano = false
	cubo_cambiado.emit()


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
	var total: float = valor_inventario() * mult_venta()
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
	return art.precio_actual(veces_comprado(art)) * maxf(0.3, 1.0 - efecto(&"descuento"))


## "" si se puede comprar; si no, el motivo.
func motivo_no_comprar(art: ArticuloData) -> String:
	if art.max_compras > 0 and veces_comprado(art) >= art.max_compras:
		return "Agotado"
	if art.tipo == ArticuloData.Tipo.CANA and art.cana and art.cana.profundidad <= cana().profundidad:
		return "Ya tienes algo mejor"
	if art.tipo == ArticuloData.Tipo.CEBO and not cebo.is_empty():
		return "Ya llevas cebo"
	if art.tipo == ArticuloData.Tipo.TRABAJADOR and plazas_trabajadores <= 0:
		return "No caben más"
	if rublos < precio(art):
		return "Faltan rublos"
	if float(materiales.get("coral", 0.0)) < art.coral_actual(veces_comprado(art)):
		return "Falta coral"
	return ""


func comprar(art: ArticuloData) -> bool:
	if motivo_no_comprar(art) != "":
		return false
	sumar_rublos(-precio(art))
	sumar_material("coral", -art.coral_actual(veces_comprado(art)))
	compras[String(art.id)] = veces_comprado(art) + 1
	match art.tipo:
		ArticuloData.Tipo.CANA:
			cambiar_cana(art.cana)
		ArticuloData.Tipo.CEBO:
			cebo = {"pescas": art.cebo_pescas, "mult_tiempo": art.cebo_mult_tiempo, "mult_espera": art.cebo_mult_espera}
			cebo_cambiado.emit()
		ArticuloData.Tipo.TRABAJADOR:
			contratar_trabajador()
		ArticuloData.Tipo.MEJORA:
			_recalcular_efectos()
			habilidades_cambiadas.emit()
	return true


# --- Opciones ---

func opcion(clave: String, defecto: Variant) -> Variant:
	var cfg := ConfigFile.new()
	if cfg.load(RUTA_OPCIONES) != OK:
		# Saves viejos guardaban las opciones en los flags de la partida.
		return flags.get(clave, defecto)
	return cfg.get_value("opciones", clave, defecto)


func poner_opcion(clave: String, valor: Variant) -> void:
	var cfg := ConfigFile.new()
	cfg.load(RUTA_OPCIONES)
	cfg.set_value("opciones", clave, valor)
	cfg.save(RUTA_OPCIONES)


# --- Guardado ---

func guardar() -> void:
	var datos: Dictionary = {
		"version": VERSION_SAVE, "rublos": rublos + dinero_en_camino, "rublos_totales": rublos_totales + dinero_en_camino,
		"capturas": capturas, "cana": String(cana_id), "cebo": cebo, "compras": compras,
		"stats": stats, "coleccion": coleccion, "capturados": capturados, "flags": flags,
		"trabajadores": trabajadores, "cubo": cubo_capturas, "cubo_en_mano": cubo_en_mano,
		"habilidades": habilidades, "reloj": reloj, "cosecha": cosecha, "despensa": despensa, "plantas": _plantas_al_dia(), "materiales": materiales,
		"fecha": Time.get_unix_time_from_system(),
	}
	# Primero a un temporal y luego se cambia por el bueno: si se corta a medias, el save anterior sigue vivo.
	var tmp: String = RUTA_SAVE + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(datos))
	f.close()
	if FileAccess.file_exists(RUTA_SAVE):
		DirAccess.rename_absolute(RUTA_SAVE, RUTA_COPIA)
	DirAccess.rename_absolute(tmp, RUTA_SAVE)


func _leer_save(ruta: String) -> Dictionary:
	if not FileAccess.file_exists(ruta):
		return {}
	var datos: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	return datos if datos is Dictionary else {}


func cargar() -> void:
	var datos: Dictionary = _leer_save(RUTA_SAVE)
	if datos.is_empty():
		# El save está roto o no existe: se tira de la copia del guardado anterior.
		datos = _leer_save(RUTA_COPIA)
		if datos.is_empty():
			return
		push_warning("Save roto, se carga la copia anterior")
	# v1 no tenía caña, cebo ni compras: se quedan los valores por defecto.
	rublos = datos.get("rublos", 0.0)
	rublos_totales = datos.get("rublos_totales", 0.0)
	capturas.clear()
	for c: Variant in datos.get("capturas", []):
		capturas.append(c)
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
	# v5 no tenía reloj: empieza por la mañana del primer día.
	reloj = float(datos.get("reloj", reloj_data.inicio if reloj_data else 0.0))
	# v4 no tenía maestría: se cuenta desde ahora.
	capturados.clear()
	var cap: Variant = datos.get("capturados", {})
	if cap is Dictionary:
		for k: String in cap:
			capturados[k] = int(cap[k])
	flags = datos.get("flags", {})
	# v2 no tenía puerto.
	trabajadores = int(datos.get("trabajadores", 0))
	cubo_capturas.clear()
	for c: Variant in datos.get("cubo", []):
		cubo_capturas.append(c)
	cubo_en_mano = datos.get("cubo_en_mano", false)
	# v3 no tenía árbol.
	habilidades.clear()
	var h: Variant = datos.get("habilidades", {})
	if h is Dictionary:
		for k: String in h:
			habilidades[k] = int(h[k])
	# v6 no tenía restaurante ni cultivos.
	cosecha.clear()
	var co: Variant = datos.get("cosecha", {})
	if co is Dictionary:
		for k: String in co:
			cosecha[k] = int(co[k])
	despensa = {"raciones": 0.0, "valor": 0.0}
	var de: Variant = datos.get("despensa", {})
	if de is Dictionary:
		for k: String in de:
			despensa[k] = float(de[k]) if k in ["raciones", "valor"] else int(de[k])
	materiales.clear()
	var ma: Variant = datos.get("materiales", {})
	if ma is Dictionary:
		for k: String in ma:
			materiales[k] = float(ma[k])
	plantas.clear()
	var pl: Variant = datos.get("plantas", {})
	if pl is Dictionary:
		for k: String in pl:
			plantas[k] = float(pl[k])
	for k: String in ["clientes", "visitas_turistas"]:
		stats[k] = int(stats.get(k, 0))


func borrar_partida() -> void:
	for ruta: String in [RUTA_SAVE, RUTA_COPIA]:
		if FileAccess.file_exists(ruta):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta))
	dinero_en_camino = 0.0
	rublos = 0.0
	rublos_totales = 0.0
	capturas.clear()
	cana_id = cana_inicial
	cebo.clear()
	compras.clear()
	for k: String in stats:
		stats[k] = 0.0 if k in ["tiempo_jugado", "puntos_pesca"] else 0
	coleccion.clear()
	capturados.clear()
	reloj = reloj_data.inicio if reloj_data else 0.0
	flags.clear()
	trabajadores = 0
	cubo_capturas.clear()
	cubo_en_mano = false
	habilidades.clear()
	cosecha.clear()
	plantas.clear()
	materiales.clear()
	despensa = {"raciones": 0.0, "valor": 0.0}
	_recalcular_efectos()
	habilidades_cambiadas.emit()
	rublos_cambiados.emit(rublos)
	inventario_cambiado.emit()
	cana_cambiada.emit(cana())
	cebo_cambiado.emit()
	cubo_cambiado.emit()
	trabajadores_cambiados.emit(trabajadores)
