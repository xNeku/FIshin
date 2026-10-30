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
## Cuando no llega navegando (el camino cierra el paso), aparca y sigue a pie.
@export var velocidad_andar: float = 3.5
@export var altura_suelo: float = 0.25
@export var duracion_salto: float = 0.4
@export var altura_salto: float = 1.0
## Un paso andando cuenta como estos metros navegando al elegir dónde aparcar (andar cansa más).
@export var coste_paso: float = 2.0
@export_group("")

@onready var sombra: Node3D = get_node_or_null("Sombra")
@onready var comerciante: Sprite3D = get_node_or_null("Comerciante")


var presente: bool = false
var listo: bool = false
var _t: float = 0.0
var _y_base: float
var _casa: Vector3
var _ruta: Array[Vector3] = []
var _mira_derecha: bool = false
var _a_pie: bool = false
var _bajada: Vector2i
var _pos_comerciante: Vector3

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
	if comerciante:
		_pos_comerciante = comerciante.position
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


## Lleva algo a pie hasta `destino` (la lonja): navega hasta donde mejor pueda aparcar, baja, anda
## (saltando una casilla de agua como todos) y se queda allí. `await` hasta que llega; false si no hay
## forma. Después hay que llamar a `volver_a_pie()`.
func ir_a_pie(destino: Vector3) -> bool:
	if mundo == null:
		return false
	var pisables: Array[Vector2i] = mundo.celdas_pisables()
	var meta: Vector2i = mundo.mundo_a_celda(destino)
	if not meta in pisables:
		var mejor: float = INF
		for c: Vector2i in pisables:
			var d: float = Vector2(c - meta).length()
			if c != Vector2i.ZERO and d < mejor:
				mejor = d
				meta = c
	var a_pie: Dictionary = mundo.distancias_a_pie(meta)
	var tierra: Dictionary = _tierra()
	var mar: Dictionary = _mar_alcanzable(tierra)
	var pasos_mar: Dictionary = {}
	var aparcar: Vector2i
	var bajada: Vector2i
	var coste: float = INF
	for w: Vector2i in mar:
		var n: int = 0 if mar[w] == w else pasos_mar[mar[w]] + 1
		pasos_mar[w] = n
		for d: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
			var t: Vector2i = w + d
			if t == Vector2i.ZERO or not a_pie.has(t):
				continue
			var k: float = n * mundo.tamano_celda + a_pie[t] * mundo.tamano_celda * coste_paso
			if k < coste:
				coste = k
				aparcar = w
				bajada = t
	if coste == INF:
		return false
	listo = false
	await _recorrer(_puntos_hasta(aparcar, mar, tierra))
	_bajada = bajada
	_a_pie = true
	comerciante.top_level = true
	# Del barco a tierra, de un salto.
	_mirar_a_pie(bajada.x > aparcar.x)
	await _saltar_a(mundo.celda_a_mundo(bajada) + Vector3.UP * (altura_suelo + mundo.altura_celda(bajada) + _pies()), false)
	await _andar(mundo.ruta(bajada, meta))
	return true


## Vuelve andando al barco aparcado y sube. Luego, `volver()` para navegar a casa.
func volver_a_pie() -> void:
	if not _a_pie:
		return
	var celdas: Array[Vector2i] = mundo.ruta(mundo.mundo_a_celda(comerciante.global_position), _bajada)
	await _andar(celdas)
	await _saltar_a(global_position + _pos_comerciante, true)
	comerciante.top_level = false
	comerciante.position = _pos_comerciante * Vector3(-1.0 if _mira_derecha else 1.0, 1.0, 1.0)
	comerciante.flip_h = _mira_derecha
	_a_pie = false


func _andar(celdas: Array[Vector2i]) -> void:
	for c: Vector2i in celdas:
		var obj: Vector3 = mundo.celda_a_mundo(c) + Vector3.UP * (altura_suelo + mundo.altura_celda(c) + _pies())
		var actual: Vector3 = comerciante.global_position
		var plano := Vector2(obj.x - actual.x, obj.z - actual.z)
		if absf(plano.x) > 0.05:
			_mirar_a_pie(plano.x > 0.0)
		if plano.length() > mundo.tamano_celda * 1.2 or absf(obj.y - actual.y) > 0.3:
			await _saltar_a(obj, false)
			continue
		var tw := create_tween()
		tw.tween_method(func(k: float) -> void:
			comerciante.global_position = actual.lerp(obj, k) + Vector3.UP * absf(sin(k * PI * 2.0)) * 0.06,
			0.0, 1.0, plano.length() / velocidad_andar)
		await tw.finished


func _saltar_a(obj: Vector3, al_barco: bool) -> void:
	var origen: Vector3 = comerciante.global_position
	var tw := create_tween()
	tw.tween_method(func(k: float) -> void:
		var o: Vector3 = (global_position + _pos_comerciante) if al_barco else obj
		comerciante.global_position = origen.lerp(o, k) + Vector3.UP * sin(k * PI) * altura_salto,
		0.0, 1.0, duracion_salto)
	await tw.finished


## Alto entre el centro del dibujo y sus pies, para ponerlo de pie sobre el suelo.
func _pies() -> float:
	if comerciante.texture == null:
		return 0.0
	return (comerciante.texture.get_height() * 0.5 - comerciante.offset.y) * comerciante.pixel_size


func _mirar_a_pie(derecha: bool) -> void:
	comerciante.flip_h = derecha


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


## Casillas que cuentan como tierra para el barco: todo lo que ha llegado y el donut.
func _tierra() -> Dictionary:
	var tierra: Dictionary = {Vector2i.ZERO: true}
	for c: Vector2i in mundo.celdas_ocupadas():
		tierra[c] = true
	return tierra


## BFS por el agua desde donde está el barco: {celda: celda anterior} de todo el mar al que llega.
func _mar_alcanzable(tierra: Dictionary) -> Dictionary:
	var centro: Vector2i = mundo.mundo_a_celda(_casa)
	var desde: Vector2i = mundo.mundo_a_celda(global_position)
	var previo: Dictionary = {desde: desde}
	var cola: Array[Vector2i] = [desde]
	while not cola.is_empty():
		var c: Vector2i = cola.pop_front()
		for d: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = c + d
			if previo.has(n) or tierra.has(n) or absi(n.x - centro.x) > radio_busqueda or absi(n.y - centro.y) > radio_busqueda:
				continue
			previo[n] = c
			cola.append(n)
	return previo


## Camino navegando hasta la casilla de agua más cercana a `destino` (si empata, la de camino más
## corto). Devuelve puntos del mundo en líneas rectas; vacío si ya está.
func _camino(destino: Vector3) -> Array[Vector3]:
	var tierra: Dictionary = _tierra()
	var previo: Dictionary = _mar_alcanzable(tierra)
	var meta := Vector2(destino.x, destino.z)
	var fin: Vector2i = mundo.mundo_a_celda(global_position)
	var mejor: float = INF
	# El diccionario guarda el orden de la BFS: a igual distancia gana el que se alcanzó antes.
	for c: Vector2i in previo:
		var p3: Vector3 = mundo.celda_a_mundo(c)
		var dist: float = Vector2(p3.x, p3.z).distance_to(meta)
		if dist < mejor - 0.01:
			mejor = dist
			fin = c
	return _puntos_hasta(fin, previo, tierra)


## Del barco a `fin` siguiendo `previo`, enderezado en líneas rectas mientras no pise tierra.
func _puntos_hasta(fin: Vector2i, previo: Dictionary, tierra: Dictionary) -> Array[Vector3]:
	var desde: Vector2i = mundo.mundo_a_celda(global_position)
	var celdas: Array[Vector2i] = []
	var p: Vector2i = fin
	while p != desde:
		celdas.push_front(p)
		p = previo[p]
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
