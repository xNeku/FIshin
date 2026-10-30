class_name BarcoComerciante
extends Node3D
## Barco que aparece tras las primeras capturas. Con "interactuar" abre su tienda.

signal llegado

@export var nombre: String = "Comerciante"
@export var articulos: Array[ArticuloData] = []
## Para la tienda: este vendedor compra lo de la barca.
var compra_peces: bool = true
@export var tienda: Tienda
@export var capturas_para_aparecer: int = 3
@export var distancia_entrada: float = 25.0
@export var duracion_entrada: float = 3.5
@export var balanceo_grados: float = 3.0
## Para ir encima de la ola. El casco se mete un poco en el agua (flotación negativa).
@export var agua: Agua
@export var flotacion: float = -0.12
@export var inclinacion_ola: float = 0.5
## Altura sobre el barco a la que sale el botón de hablar (encima de la cabeza del comerciante).
@export var altura_icono: float = 1.7
@export_group("Viaje del porteador")
## Para buscar el camino por el agua esquivando islas.
@export var mundo: Node3D
## Metros por segundo navegando (va rapidillo).
@export var velocidad_viaje: float = 9.0
## Casillas como mucho que se aleja de su sitio buscando camino.
@export var radio_busqueda: int = 24
@export_group("")

@onready var sombra: Node3D = get_node_or_null("Sombra")


var presente: bool = false
var listo: bool = false
var _t: float = 0.0
var _y_base: float
var _casa: Vector3
var _ruta: Array[Vector3] = []
var _mira_derecha: bool = false

signal _ruta_hecha


func _ready() -> void:
	var i: Interactuable = get_node_or_null("Interaccion")
	if i:
		i.nombre = nombre
		i.articulos = articulos
	add_to_group("barco_comerciante")
	visible = false
	_y_base = position.y
	_casa = position
	if Juego.flags.get("barco_comerciante", false):
		_aparecer(true)
	else:
		Juego.inventario_cambiado.connect(_on_inventario)


func _process(delta: float) -> void:
	if not presente:
		_on_inventario()
		return
	_t += delta
	_navegar(delta)
	var y_agua: float = agua.altura(global_position) if agua else 0.0
	var pend: Vector2 = agua.pendiente(global_position) if agua else Vector2.ZERO
	rotation_degrees.z = sin(_t * 0.9 + 1.0) * balanceo_grados - rad_to_deg(atan(pend.x)) * inclinacion_ola
	position.y = _y_base + y_agua + flotacion + sin(_t * 1.2) * 0.05
	if agua and sombra:
		agua.pegar(sombra, global_position * Vector3(1, 0, 1) + Vector3(0.1, 0, 0.3), 0.06)


func _unhandled_input(event: InputEvent) -> void:
	if listo and tienda and not Juego.en_movimiento and event.is_action_pressed("interactuar"):
		get_viewport().set_input_as_handled()
		tienda.abrir(self)


func puede_hablar() -> bool:
	return listo and not Juego.en_movimiento


func _on_inventario() -> void:
	if not presente and Juego.stats.peces_pescados >= capturas_para_aparecer:
		_aparecer(false)


func _aparecer(instantaneo: bool) -> void:
	presente = true
	visible = true
	Juego.flags["barco_comerciante"] = true
	if not instantaneo:
		var destino: Vector3 = position
		position += Vector3(distancia_entrada, 0.0, 0.0)
		var tw := create_tween()
		tw.tween_property(self, "position:x", destino.x, duracion_entrada).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await tw.finished
	listo = true
	llegado.emit()


## Va navegando hasta el agua más cercana a `destino` sin pasar por tierra. false si no hay camino.
## Mientras viaja no se puede hablar con él.
func ir_a(destino: Vector3) -> bool:
	if mundo == null or (listo and tienda and tienda.abierta):
		return false
	var puntos: Array[Vector3] = _camino(destino)
	if puntos.is_empty() and not _cerca_de(destino):
		return false
	listo = false
	await _recorrer(puntos)
	return true


## Vuelve a su sitio de siempre y queda listo para hablar.
func volver() -> void:
	var puntos: Array[Vector3] = _camino(_casa)
	puntos.append(_casa)
	await _recorrer(puntos)
	listo = true


func _cerca_de(destino: Vector3) -> bool:
	return Vector2(destino.x - position.x, destino.z - position.z).length() <= mundo.tamano_celda * 1.5


func _recorrer(puntos: Array[Vector3]) -> void:
	_ruta = puntos
	if not _ruta.is_empty():
		await _ruta_hecha


func _navegar(delta: float) -> void:
	if _ruta.is_empty():
		return
	var plano := Vector2(position.x, position.z)
	var paso: float = velocidad_viaje * delta
	while paso > 0.0 and not _ruta.is_empty():
		var obj := Vector2(_ruta[0].x, _ruta[0].z)
		var d: float = plano.distance_to(obj)
		if absf(obj.x - plano.x) > 0.05:
			_mirar(obj.x > plano.x)
		if d <= paso:
			plano = obj
			paso -= d
			_ruta.pop_front()
		else:
			plano += (obj - plano) / d * paso
			paso = 0.0
	position.x = plano.x
	position.z = plano.y
	if _ruta.is_empty():
		_ruta_hecha.emit()


func _mirar(derecha: bool) -> void:
	if derecha == _mira_derecha:
		return
	_mira_derecha = derecha
	for h: Node in get_children():
		if h is Sprite3D and not h.top_level:
			h.flip_h = derecha
			h.position.x = -h.position.x


## Camino por casillas de agua (BFS) hasta la casilla de agua más cercana a `destino` (si empata, la
## de camino más corto). Devuelve puntos del mundo ya simplificados en líneas rectas; vacío si ya está.
func _camino(destino: Vector3) -> Array[Vector3]:
	var tierra: Dictionary = {Vector2i.ZERO: true}
	for c: Vector2i in mundo.celdas_ocupadas():
		tierra[c] = true
	var centro: Vector2i = mundo.mundo_a_celda(_casa)
	var desde: Vector2i = mundo.mundo_a_celda(global_position)
	var meta := Vector2(destino.x, destino.z)
	var previo: Dictionary = {desde: desde}
	var cola: Array[Vector2i] = [desde]
	var fin: Vector2i = desde
	var mejor: float = INF
	while not cola.is_empty():
		var c: Vector2i = cola.pop_front()
		var p3: Vector3 = mundo.celda_a_mundo(c)
		var dist: float = Vector2(p3.x, p3.z).distance_to(meta)
		if dist < mejor - 0.01:
			mejor = dist
			fin = c
		for d: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = c + d
			if previo.has(n) or tierra.has(n) or absi(n.x - centro.x) > radio_busqueda or absi(n.y - centro.y) > radio_busqueda:
				continue
			previo[n] = c
			cola.append(n)
	var celdas: Array[Vector2i] = []
	var p: Vector2i = fin
	while p != desde:
		celdas.push_front(p)
		p = previo[p]
	# Línea recta mientras no pise tierra: no hace eses de casilla en casilla.
	var r: Array[Vector3] = []
	var desde_p: Vector3 = position
	var i: int = 0
	while i < celdas.size():
		var j: int = celdas.size() - 1
		while j > i and not _recta_libre(desde_p, mundo.celda_a_mundo(celdas[j]), tierra):
			j -= 1
		desde_p = mundo.celda_a_mundo(celdas[j])
		desde_p.y = position.y
		r.append(desde_p)
		i = j + 1
	return r


func _recta_libre(a: Vector3, b: Vector3, tierra: Dictionary) -> bool:
	var pasos: int = maxi(1, ceili(a.distance_to(b) / 0.4))
	var lado := Vector3(b.z - a.z, 0.0, a.x - b.x).normalized() * 0.7
	for k: int in pasos + 1:
		var q: Vector3 = a.lerp(b, float(k) / pasos)
		for o: Vector3 in [Vector3.ZERO, lado, -lado]:
			if tierra.has(mundo.mundo_a_celda(q + o)):
				return false
	return true
