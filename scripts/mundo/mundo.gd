extends Node3D
## El mundo que crece: vigila las condiciones de cada AparicionData y la trae con su animación.
## Lo que ya apareció se guarda en Juego.flags y se coloca directamente al cargar.

signal aparicion_empezada(datos: AparicionData)
## Momento de llegada (toca el agua o termina de atracar).
signal aparicion_llegada(datos: AparicionData)
signal aparicion_terminada(datos: AparicionData)

@export var apariciones: Array[AparicionData] = []
@export var pesca: Pesca
@export var camara: CamaraPesca
@export var celebracion: Node
## Sombra que crece en el agua antes de que algo caiga del cielo.
@export var sombra: MeshInstance3D
@export var sfx_mar: AudioStreamPlayer
@export var sfx_caida: AudioStreamPlayer
@export var sfx_impacto: AudioStreamPlayer
@export var sfx_pieza: AudioStreamPlayer
@export var tamano_celda: float = 2.0
## Para buscar caminos a pie: cuánto "cuesta" un salto sobre el agua comparado con un paso.
@export var coste_salto: float = 2.5
## Agua donde los pescadores no se ponen a pescar (la zona de la barca, el barco comerciante...).
@export var celdas_no_pesca: Array[Vector2i] = [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, -1)]

@export_group("Llegada por mar")
@export var distancia_mar: float = 35.0
@export var duracion_mar: float = 4.5
@export var hundida_mar: float = 0.6
@export var balanceo_mar_grados: float = 5.0

@export_group("Construcción")
## Segundos entre pieza y pieza.
@export var ritmo_construccion: float = 0.12
@export var subida_pieza: float = 1.2

@export_group("Emerger del fondo")
@export var profundidad_emerger: float = 7.0
@export var duracion_emerger: float = 3.2
@export var golpe_emerger: float = 0.35

@export_group("Caída del cielo")
@export var altura_cielo: float = 45.0
## Tiempo de sombra creciendo antes de que se vea caer.
@export var aviso_cielo: float = 1.6
@export var duracion_caida: float = 1.1
@export var giro_caida_grados: float = 200.0
@export var golpe_impacto: float = 0.9
@export var pausa_impacto: float = 0.12
@export var escala_sombra: float = 7.0
## Tiempo mirando la isla tras caer.
@export var reposo_cielo: float = 2.2

var _ocupado: bool = false
var _pisables: Array[Vector2i] = []
var _firma_pisables: int = -1
var _frame_pisables: int = -1
var _llegando: AparicionData
var _alturas: Dictionary = {}
var _rampas: Dictionary = {}


func _ready() -> void:
	if sombra:
		sombra.visible = false
	for a: AparicionData in apariciones:
		if ya_aparecio(a):
			var n: Node3D = _instanciar(a)
			if n.has_method("colocada"):
				n.colocada()


func _process(_delta: float) -> void:
	if _ocupado or (pesca and pesca.en_curso()) or (celebracion and celebracion.celebrando):
		return
	var pendientes: Array[AparicionData] = apariciones.filter(func(a: AparicionData) -> bool: return not ya_aparecio(a) and cumple(a))
	if pendientes.is_empty():
		return
	pendientes.sort_custom(func(a: AparicionData, b: AparicionData) -> bool: return a.orden < b.orden)
	traer(pendientes[0])


## True mientras algo está llegando (no se puede cambiar de modo).
func ocupado() -> bool:
	return _ocupado


## Casillas por las que se puede andar: la barca y todo lo que ya ha llegado.
func celdas_pisables() -> Array[Vector2i]:
	# Se pregunta miles de veces por fotograma (alturas, rutas, turistas): la firma se calcula una vez por
	# fotograma y la lista se guarda hasta que algo llega.
	var frame: int = Engine.get_process_frames()
	if frame == _frame_pisables:
		return _pisables
	_frame_pisables = frame
	var firma: int = hash([Juego.flags, _llegando])
	if firma == _firma_pisables:
		return _pisables
	var r: Array[Vector2i] = [Vector2i.ZERO]
	for a: AparicionData in apariciones:
		if ya_aparecio(a) and a != _llegando:
			for c: Vector2i in a.celdas:
				if not c in a.celdas_bloqueadas:
					r.append(c)
	_pisables = r
	_firma_pisables = firma
	_alturas.clear()
	_rampas.clear()
	for a: AparicionData in apariciones:
		if ya_aparecio(a) and a != _llegando:
			for c: Vector2i in a.celdas:
				_alturas[c] = a.alturas_celda.get(c, a.altura)
			for c: Vector2i in a.rampas:
				_rampas[c] = a.rampas[c]
	return r


# --- Alturas (dos niveles: el de pesca y el puerto alto, unidos por escaleras) ---

## Altura de una casilla sobre el nivel de pesca. Agua y donut = 0. En una escalera, la de su mitad.
func altura_celda(c: Vector2i) -> float:
	celdas_pisables()
	if _rampas.has(c):
		var d: Vector2i = _rampas[c]
		return (_alturas.get(c - d, 0.0) + _alturas.get(c + d, 0.0)) * 0.5
	return _alturas.get(c, 0.0)


func es_rampa(c: Vector2i) -> bool:
	celdas_pisables()
	return _rampas.has(c)


## Altura del suelo en un punto (en las escaleras sube poco a poco).
func altura_en(p: Vector3) -> float:
	var c: Vector2i = mundo_a_celda(p)
	celdas_pisables()
	if not _rampas.has(c):
		return _alturas.get(c, 0.0)
	var d: Vector2i = _rampas[c]
	var centro: Vector3 = celda_a_mundo(c)
	var k: float = clampf((p - centro).dot(Vector3(d.x, 0.0, -d.y)) / tamano_celda + 0.5, 0.0, 1.0)
	return lerpf(_alturas.get(c - d, 0.0), _alturas.get(c + d, 0.0), k)


## Altura del borde de `c` que da hacia `d`. INF si por ahí no se entra (el lateral de una escalera).
func _altura_borde(c: Vector2i, d: Vector2i) -> float:
	if not _rampas.has(c):
		return _alturas.get(c, 0.0)
	var r: Vector2i = _rampas[c]
	if d == r:
		return _alturas.get(c + r, 0.0)
	if d == -r:
		return _alturas.get(c - r, 0.0)
	return INF


## Se puede pasar andando de `a` a su vecina `b` (misma altura, o por la escalera).
func paso_valido(a: Vector2i, b: Vector2i) -> bool:
	celdas_pisables()
	var d: Vector2i = b - a
	var ha: float = _altura_borde(a, d)
	var hb: float = _altura_borde(b, -d)
	return ha != INF and hb != INF and absf(ha - hb) < 0.35


## Se puede saltar de `a` a `b` por encima del agua: misma altura y ninguna es escalera.
func salto_valido(a: Vector2i, b: Vector2i) -> bool:
	celdas_pisables()
	return not _rampas.has(a) and not _rampas.has(b) and absf(_alturas.get(a, 0.0) - _alturas.get(b, 0.0)) < 0.35


## Casillas hechas de tablones (caminos, pantalanes): ahí los pescadores se sientan al borde.
func es_tablon(c: Vector2i) -> bool:
	for a: AparicionData in apariciones:
		if a.pieza_por_celda and ya_aparecio(a) and c in a.celdas:
			return true
	return false


## Todas las casillas con algo encima (pisables o no). Para lo que navega: por aquí no se pasa.
func celdas_ocupadas() -> Array[Vector2i]:
	var r: Array[Vector2i] = []
	for a: AparicionData in apariciones:
		if ya_aparecio(a):
			r.append_array(a.celdas)
	return r


## Bordes desde los que se puede pescar: {celda, dir} con agua libre enfrente. La barca no cuenta.
func puestos_de_pesca() -> Array[Dictionary]:
	var pisables: Array[Vector2i] = celdas_pisables()
	var r: Array[Dictionary] = []
	for c: Vector2i in pisables:
		# Se pesca desde abajo: el puerto alto queda para pasear.
		if c == Vector2i.ZERO or altura_celda(c) > 0.1 or es_rampa(c):
			continue
		for d: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = c + d
			if not n in pisables and not n in celdas_no_pesca:
				r.append({"celda": c, "dir": d})
	return r


## Camino por casillas pisables, saltando una casilla de agua como el náufrago. No incluye el origen.
func ruta(desde: Vector2i, hasta: Vector2i) -> Array[Vector2i]:
	var previo: Dictionary = _recorrer_a_pie(desde, hasta)
	var r: Array[Vector2i] = []
	if not previo.has(hasta):
		return r
	var p: Vector2i = hasta
	while p != desde:
		r.push_front(p)
		p = previo[p]
	return r


## Coste a pie (con saltos) desde `desde` hasta cada casilla pisable a la que se llega: {celda: coste}.
## Un paso cuesta 1 y un salto `coste_salto`.
func distancias_a_pie(desde: Vector2i) -> Dictionary:
	var coste: Dictionary = {}
	_recorrer_a_pie(desde, Vector2i(1 << 20, 0), coste)
	return coste


## Dijkstra a pie desde `desde` (se para al llegar a `hasta`): mejor andar que saltar. Devuelve
## {celda: celda anterior}; si se pasa `coste`, lo rellena con el coste de cada casilla.
func _recorrer_a_pie(desde: Vector2i, hasta: Vector2i, coste: Dictionary = {}) -> Dictionary:
	var pisables: Dictionary = {}
	for c: Vector2i in celdas_pisables():
		pisables[c] = true
	var previo: Dictionary = {desde: desde}
	coste[desde] = 0.0
	var abiertas: Array[Vector2i] = [desde]
	var cerradas: Dictionary = {}
	while not abiertas.is_empty():
		var i_min: int = 0
		for i: int in abiertas.size():
			if coste[abiertas[i]] < coste[abiertas[i_min]]:
				i_min = i
		var c: Vector2i = abiertas[i_min]
		abiertas.remove_at(i_min)
		if cerradas.has(c):
			continue
		cerradas[c] = true
		if c == hasta:
			break
		for d: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
			var vecinas: Array[Vector2i] = [c + d]
			var paso: float = 1.0
			var saltando: bool = not pisables.has(c + d)
			if saltando:
				var perp := Vector2i(d.y, d.x)
				vecinas = [c + d * 2, c + d * 2 + perp, c + d * 2 - perp]
				paso = coste_salto
			for n: Vector2i in vecinas:
				if not pisables.has(n) or cerradas.has(n):
					continue
				if not (salto_valido(c, n) if saltando else paso_valido(c, n)):
					continue
				var k: float = coste[c] + paso
				if k < coste.get(n, INF):
					coste[n] = k
					previo[n] = c
					abiertas.append(n)
	return previo


func mundo_a_celda(p: Vector3) -> Vector2i:
	return Vector2i(roundi(p.x / tamano_celda), roundi(-p.z / tamano_celda))


func ya_aparecio(a: AparicionData) -> bool:
	return Juego.flags.get("aparecido_" + String(a.id), false)


func cumple(a: AparicionData) -> bool:
	for r: StringName in a.requiere:
		if not Juego.flags.get("aparecido_" + String(r), false):
			return false
	match a.condicion:
		AparicionData.Condicion.PECES_PESCADOS:
			return Juego.stats.peces_pescados >= a.valor
		AparicionData.Condicion.RUBLOS_TOTALES:
			return Juego.rublos_totales >= a.valor
		AparicionData.Condicion.COMBO_MAXIMO:
			return Juego.stats.mejor_combo >= a.valor
		AparicionData.Condicion.MINUTOS_JUGADOS:
			return Juego.stats.tiempo_jugado >= a.valor * 60.0
		AparicionData.Condicion.PUNTOS_PESCA:
			return Juego.stats.puntos_pesca >= a.valor
		AparicionData.Condicion.PESCADORES:
			return Juego.trabajadores >= a.valor
		AparicionData.Condicion.CLIENTES:
			return Juego.stats.clientes >= a.valor
		AparicionData.Condicion.DIAS_TRAS_REQUISITO:
			var desde: float = 0.0
			for r: StringName in a.requiere:
				desde = maxf(desde, float(Juego.flags.get("reloj_" + String(r), Juego.reloj)))
			return Juego.reloj - desde >= a.valor * Juego.reloj_data.duracion_ciclo()
	return false


func celda_a_mundo(c: Vector2i) -> Vector3:
	return Vector3(c.x * tamano_celda, 0.0, -c.y * tamano_celda)


func traer(a: AparicionData) -> void:
	_ocupado = true
	_llegando = a
	Juego.flags["aparecido_" + String(a.id)] = true
	Juego.flags["reloj_" + String(a.id)] = Juego.reloj
	Juego.guardar()
	var n: Node3D = _instanciar(a)
	aparicion_empezada.emit(a)
	match a.llegada:
		AparicionData.Llegada.MAR:
			await _por_mar(n, a)
		AparicionData.Llegada.CIELO:
			await _desde_cielo(n, a)
		AparicionData.Llegada.CONSTRUIR:
			await _construir(n, a)
		AparicionData.Llegada.EMERGER:
			await _emerger(n, a)
	aparicion_terminada.emit(a)
	_llegando = null
	_ocupado = false


func _instanciar(a: AparicionData) -> Node3D:
	var n: Node3D = a.escena.instantiate()
	n.name = String(a.id)
	add_child(n)
	n.position = celda_a_mundo(a.ancla) + Vector3.UP * a.altura
	if a.pieza_por_celda or a.pieza_rampa or a.pieza_bajo_celda:
		_poner_piezas(n, a)
	return n


## Una pieza por casilla, girada según hacia dónde sigue el camino.
func _poner_piezas(n: Node3D, a: AparicionData) -> void:
	var destino: Node3D = n.get_node_or_null("Piezas")
	if destino == null:
		destino = n
	for c: Vector2i in a.celdas:
		var h: float = a.alturas_celda.get(c, a.altura)
		var base: Vector3 = celda_a_mundo(c) - n.position
		if a.rampas.has(c) and a.pieza_rampa:
			# Escalera: arranca a la altura de la casilla de detrás y mira hacia donde sube.
			var r: Vector2i = a.rampas[c]
			var p: Node3D = a.pieza_rampa.instantiate()
			p.name = "Escalera_%d_%d" % [c.x, c.y]
			destino.add_child(p)
			var abajo: float = a.alturas_celda.get(c - r, a.altura) if (c - r) in a.celdas else 0.0
			p.position = base + Vector3.UP * abajo
			# La pieza sube hacia su -Z local: se gira para que suba hacia `r`.
			p.rotation.y = atan2(-r.x, r.y)
			p.add_to_group("piezas_" + String(a.id))
			continue
		if a.pieza_por_celda:
			var p: Node3D = a.pieza_por_celda.instantiate()
			p.name = "Pieza_%d_%d" % [c.x, c.y]
			destino.add_child(p)
			p.position = base + Vector3.UP * h
			var horizontal: bool = (c + Vector2i.LEFT) in a.celdas or (c + Vector2i.RIGHT) in a.celdas
			var vertical: bool = (c + Vector2i.UP) in a.celdas or (c + Vector2i.DOWN) in a.celdas
			if vertical and not horizontal:
				p.rotation_degrees.y = 90.0
			p.add_to_group("piezas_" + String(a.id))
		if a.pieza_bajo_celda and h > 0.1:
			var s: Node3D = a.pieza_bajo_celda.instantiate()
			s.name = "Pilotes_%d_%d" % [c.x, c.y]
			destino.add_child(s)
			s.position = base + Vector3.UP * h


func _por_mar(n: Node3D, a: AparicionData) -> void:
	var destino: Vector3 = n.position
	var dir: Vector3 = _lado_de_llegada(a, destino)
	n.position = destino + dir * distancia_mar + Vector3.DOWN * hundida_mar
	pesca.bloquear(duracion_mar + 1.0)
	camara.enfocar(destino, duracion_mar + 0.8, 3.0)
	if sfx_mar:
		sfx_mar.play()
	var tw := create_tween().set_parallel(true)
	tw.tween_property(n, "position:x", destino.x, duracion_mar).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(n, "position:z", destino.z, duracion_mar).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(n, "position:y", destino.y, duracion_mar * 0.6).set_delay(duracion_mar * 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_method(func(k: float) -> void:
		n.rotation_degrees.z = sin(k * TAU * 2.0) * balanceo_mar_grados * (1.0 - k), 0.0, 1.0, duracion_mar)
	await tw.finished
	n.rotation_degrees.z = 0.0
	camara.sacudir(0.15)
	if n.has_method("llegar"):
		n.llegar()
	aparicion_llegada.emit(a)


## Por qué lado del mar llega: el punto cardinal donde está la isla vista desde la barca
## (la del sur viene del sur, la del oeste del oeste...). Llega en línea recta por ese eje.
func _lado_de_llegada(a: AparicionData, destino: Vector3) -> Vector3:
	var centro: Vector3 = destino
	if not a.celdas.is_empty():
		centro = Vector3.ZERO
		for c: Vector2i in a.celdas:
			centro += celda_a_mundo(c)
		centro /= a.celdas.size()
	if absf(centro.x) >= absf(centro.z):
		return Vector3(signf(centro.x) if centro.x != 0.0 else 1.0, 0.0, 0.0)
	return Vector3(0.0, 0.0, signf(centro.z))


func _construir(n: Node3D, a: AparicionData) -> void:
	var piezas: Array[Node] = get_tree().get_nodes_in_group("piezas_" + String(a.id))
	# Crece desde el lado de la barca hacia fuera.
	piezas.sort_custom(func(p: Node3D, q: Node3D) -> bool: return p.global_position.length() < q.global_position.length())
	var extras: Array[Node3D] = []
	for h: Node in n.get_children():
		if h is Node3D and h.name != "Piezas" and not h.is_in_group("piezas_" + String(a.id)):
			extras.append(h)
			(h as Node3D).visible = false
	var total: float = piezas.size() * ritmo_construccion + 1.5
	pesca.bloquear(total + 1.0)
	var c: Vector3 = Vector3.ZERO
	for p: Node in piezas:
		c += (p as Node3D).global_position
	camara.enfocar(c / maxf(1.0, piezas.size()), total, 3.0)
	for p: Node in piezas:
		(p as Node3D).visible = false
	for p: Node in piezas:
		var pieza := p as Node3D
		var y: float = pieza.position.y
		pieza.position.y = y - subida_pieza
		pieza.visible = true
		create_tween().tween_property(pieza, "position:y", y, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if sfx_pieza:
			sfx_pieza.pitch_scale = randf_range(0.9, 1.15)
			sfx_pieza.play()
		await get_tree().create_timer(ritmo_construccion).timeout
	for e: Node3D in extras:
		e.visible = true
		var esc: Vector3 = e.scale
		e.scale = Vector3.ZERO
		create_tween().tween_property(e, "scale", esc, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.4).timeout
	camara.sacudir(0.1)
	if n.has_method("llegar"):
		n.llegar()
	aparicion_llegada.emit(a)
	await get_tree().create_timer(1.0).timeout


func _emerger(n: Node3D, a: AparicionData) -> void:
	var destino: Vector3 = n.position
	var total: float = duracion_emerger + 1.8
	pesca.bloquear(total + 1.0)
	camara.enfocar(destino, total, 4.0)
	n.position = destino + Vector3.DOWN * profundidad_emerger
	var burbujas: CPUParticles3D = n.get_node_or_null("Burbujas")
	if burbujas:
		# Las burbujas salen en la superficie, encima de donde viene.
		burbujas.top_level = true
		burbujas.global_position = destino + Vector3.UP * 0.1
		burbujas.emitting = true
	if sfx_mar:
		sfx_mar.play()
	var tw := create_tween()
	tw.tween_property(n, "position:y", destino.y, duracion_emerger).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tw.finished
	if burbujas:
		burbujas.emitting = false
	camara.sacudir(golpe_emerger)
	if sfx_impacto:
		sfx_impacto.play()
	if n.has_method("llegar"):
		n.llegar()
	aparicion_llegada.emit(a)
	await get_tree().create_timer(1.8).timeout


func _desde_cielo(n: Node3D, a: AparicionData) -> void:
	var destino: Vector3 = n.position
	var total: float = aviso_cielo + duracion_caida + reposo_cielo
	pesca.bloquear(total + 1.0)
	camara.enfocar(destino, total, 6.0)
	n.visible = false
	n.position = destino + Vector3.UP * altura_cielo
	if sombra:
		sombra.position = Vector3(destino.x, 0.18, destino.z)
		sombra.scale = Vector3.ONE * 0.2
		sombra.visible = true
		create_tween().tween_property(sombra, "scale", Vector3.ONE * escala_sombra, aviso_cielo + duracion_caida).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	if sfx_caida:
		sfx_caida.play()
	await get_tree().create_timer(aviso_cielo).timeout
	n.visible = true
	n.rotation_degrees.y = giro_caida_grados
	var tw := create_tween().set_parallel(true)
	tw.tween_property(n, "position:y", destino.y, duracion_caida).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(n, "rotation_degrees:y", 0.0, duracion_caida).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tw.finished
	# Impacto
	if sombra:
		sombra.visible = false
	if sfx_impacto:
		sfx_impacto.play()
	camara.sacudir(golpe_impacto)
	if n.has_method("llegar"):
		n.llegar()
	aparicion_llegada.emit(a)
	var rebote := create_tween()
	rebote.tween_property(n, "position:y", destino.y - 0.4, 0.12).set_ease(Tween.EASE_OUT)
	rebote.tween_property(n, "position:y", destino.y, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if pausa_impacto > 0.0:
		Engine.time_scale = 0.05
		await get_tree().create_timer(pausa_impacto, true, false, true).timeout
		Engine.time_scale = 1.0
	await get_tree().create_timer(reposo_cielo).timeout
