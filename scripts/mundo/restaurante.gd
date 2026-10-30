class_name Restaurante
extends Isla
## Restaurante O Mar. La lonja le manda gratis una parte de los peces que vendes (tú cobras lo mismo):
## esa es su despensa. Cocina y vende platos a la gente del pueblo poco a poco y, los días de turistas,
## a montones. Lo que le das de la cosecha mejora los platos. El dinero te llega volando.

## Donde aterrizan los peces y de donde sale el dinero.
@export var casa: Node3D
@export_group("Lonja")
@export var id_lonja: StringName = &"lonja"
## Parte de los peces vendidos que la lonja le manda.
@export_range(0.0, 1.0) var parte_lonja: float = 0.3
@export_group("Cocina")
## Raciones de pescado que caben en la despensa (la mejora "despensa" suma más).
@export var capacidad_despensa: float = 120.0
## Lo que cobra por plato respecto a lo que vale la ración (la mejora "precio_plato" suma).
@export var mult_plato: float = 1.25
@export_group("Clientes del pueblo")
## Gente del pueblo que come aquí cada minuto (sin turistas).
@export var locales_por_minuto: float = 0.6
@export var locales_por_pescador: float = 0.15
@export_group("Cobro")
## Cada cuánto te manda lo que ha cobrado.
@export var cada_cobro: float = 6.0

var _resto_parte: float = 0.0
var _t_locales: float = 0.0
var _caja: float = 0.0
var _t_cobro: float = 0.0


func _ready() -> void:
	add_to_group("restaurante")
	# El Comercio puede no estar listo aún (va después en main): se conecta al terminar el frame.
	_conectar.call_deferred()


func _conectar() -> void:
	var comercio: Node = get_tree().get_first_node_in_group("comercio")
	if comercio and not comercio.peces_vendidos.is_connected(_recibir_de_lonja):
		comercio.peces_vendidos.connect(_recibir_de_lonja)


func _process(delta: float) -> void:
	_t_locales += delta * (locales_por_minuto + locales_por_pescador * Juego.trabajadores) / 60.0
	while _t_locales >= 1.0:
		_t_locales -= 1.0
		servir()
	_t_cobro += delta
	if _t_cobro >= cada_cobro and _caja > 0.0:
		_t_cobro = 0.0
		var comercio: Node = get_tree().get_first_node_in_group("comercio")
		var total: float = _caja
		_caja = 0.0
		if comercio:
			Vuelos.enviar_dinero(_origen(), comercio.origen(), total)
		else:
			Juego.sumar_rublos(total)


func capacidad() -> float:
	return capacidad_despensa + Juego.efecto(&"despensa")


func raciones() -> int:
	return int(Juego.despensa.raciones)


## Sirve un plato si queda pescado: lo cobra (a la caja) y gasta una ración y, si hay, cosecha.
## Los turistas pagan según su nivel (`gasto`) y dejan propina (Turista despistado, rama Suerte).
func servir(turista: bool = false, gasto: float = 1.0) -> bool:
	var d: Dictionary = Juego.despensa
	if d.raciones < 1.0:
		return false
	var medio: float = d.valor / d.raciones
	d.raciones -= 1.0
	d.valor = maxf(0.0, d.valor - medio)
	var precio: float = medio * (mult_plato + Juego.efecto(&"precio_plato"))
	var guarnicion: float = 0.0
	var mejora: float = 1.0
	for id: StringName in Juego.cultivos:
		var c: CultivoData = Juego.cultivos[id]
		var n: int = int(d.get(String(id), 0))
		if n <= 0:
			continue
		d[String(id)] = n - 1
		# Unos pican y otros no (rama Cosecha): lo cosechado vale más.
		var v: float = c.valor * (1.0 + Juego.efecto(&"valor_cosecha"))
		if c.uso == CultivoData.Uso.GUARNICION:
			guarnicion += medio * v
		else:
			mejora *= 1.0 + v
	_caja += (precio + guarnicion) * mejora * (gasto * (1.0 + Juego.efecto(&"propinas")) if turista else 1.0)
	Juego.stats.clientes += 1
	return true


## La lonja le lanza una parte de lo vendido, hasta llenar la despensa.
func _recibir_de_lonja(capturas: Array[Dictionary]) -> void:
	var n: float = capturas.size() * parte_lonja + _resto_parte
	var k: int = floori(n)
	_resto_parte = n - k
	k = mini(k, floori(capacidad() - Juego.despensa.raciones))
	if k <= 0:
		return
	var elegidas: Array[Dictionary] = capturas.duplicate()
	elegidas.shuffle()
	elegidas.resize(k)
	for c: Dictionary in elegidas:
		Juego.despensa.raciones += 1.0
		Juego.despensa.valor += c.valor
	var lonja: Node3D = get_parent().get_node_or_null(String(id_lonja))
	if lonja:
		Vuelos.enviar_peces(lonja, _origen(), elegidas)


func _origen() -> Node3D:
	return casa if casa else self
