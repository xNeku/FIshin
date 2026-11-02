class_name Turistas
extends Node3D

## Al irse los turistas: cuántos vinieron, platos vendidos y dinero (llega de golpe).
signal visita_terminada(turistas: int, platos: int, dinero: float)
## Visitas de turistas. No vienen todos los días, pero cuando vienen es en masa: llegan en barcos a la
## entrada de turistas en la segunda mitad del día y se quedan hasta la mitad de la noche, comiendo en el
## restaurante. Cuanta más comida tiene el restaurante, más vienen. Los tipos se desbloquean y se suman:
## los que vienen se reparten entre todos los tipos que ya hay.

@export var mundo: Node
@export var agua: Node
@export var escena_turista: PackedScene
@export var escena_barco: PackedScene
@export var niveles: Array[NivelTuristasData] = []
@export var id_entrada: StringName = &"entrada_turistas"
@export var id_restaurante: StringName = &"restaurante"
@export_group("Cuándo vienen")
## Probabilidad de que un día haya visita.
@export_range(0.0, 1.0) var prob_visita: float = 0.5
## Nunca pasan más de estos días seguidos sin visita.
@export var max_dias_sin_visita: int = 2
## Llegan cuando ha pasado esta parte del día (0,5 = a mitad del día)...
@export_range(0.0, 1.0) var llegan_en_dia: float = 0.5
## ...y se van cuando ha pasado esta parte de la noche.
@export_range(0.0, 1.0) var se_van_en_noche: float = 0.5
## Segundos entre el primer barco y el último.
@export var escalonado: float = 50.0
@export_group("Cuántos")
## Platos que come cada turista en una visita: los que vienen = raciones / esto.
@export var platos_por_turista: float = 2.0
@export var min_turistas: int = 3
## Máximo por visita (la mejora "mesas" suma).
@export var max_turistas: int = 16
## Tope de turistas dibujados a la vez (rendimiento); los demás comen igual pero no se ven.
@export var max_visibles: int = 40
@export_group("Barcos")
## Desde lo lejos que llegan los barcos (por el este).
@export var distancia_llegada: float = 45.0
## Suena cuando llega el primer barco de la visita (para que se note aunque estés pescando).
@export var sfx_llegada: AudioStreamPlayer

var activa: bool = false
## Grupos: {barco: BarcoTuristas, turistas: Array[Turista], muelle: Dictionary, nivel: NivelTuristasData}
var _grupos: Array[Dictionary] = []
var _invisibles: int = 0
var _t_invisibles: float = 0.0
var _t_revisar: float = 0.0
var _dia_visita: int = -1
var _bocina_dada: bool = false
var _vinieron: int = 0
var _barcos_traidos: int = 0


func _ready() -> void:
	add_to_group("turistas")


func _process(delta: float) -> void:
	_t_revisar += delta
	if _t_revisar < 0.5:
		_comer_invisibles(delta)
		return
	_t_revisar = 0.0
	var rd: RelojData = Juego.reloj_data
	if rd == null or mundo == null or not Juego.flags.get("aparecido_" + String(id_entrada), false):
		return
	var dia: int = rd.dia(Juego.reloj)
	if int(Juego.flags.get("turistas_dia", -1)) != dia:
		_decidir_dia(dia)
	var en_ventana: bool = _en_ventana(rd)
	if en_ventana and not activa and Juego.flags.get("turistas_vienen", false) \
			and int(Juego.flags.get("turistas_hecho", -1)) != dia and _restaurante() != null:
		_dia_visita = dia
		_empezar(rd)
	elif activa and not en_ventana:
		_terminar()


func _decidir_dia(dia: int) -> void:
	Juego.flags["turistas_dia"] = dia
	var sin: int = int(Juego.flags.get("turistas_sin_visita", max_dias_sin_visita))
	var vienen: bool = sin >= max_dias_sin_visita or randf() < prob_visita
	Juego.flags["turistas_vienen"] = vienen
	Juego.flags["turistas_sin_visita"] = 0 if vienen else sin + 1


func _en_ventana(rd: RelojData) -> bool:
	var m: float = rd.momento(Juego.reloj)
	return m >= rd.duracion_dia * llegan_en_dia and m < rd.duracion_dia + rd.duracion_noche * se_van_en_noche


func _segundos_restantes(rd: RelojData) -> float:
	return rd.duracion_dia + rd.duracion_noche * se_van_en_noche - rd.momento(Juego.reloj)


func cuantos() -> int:
	# Relaciones públicas (Carisma): vienen más, si hay comida para ellos.
	var tope: int = roundi((max_turistas + Juego.efecto(&"mesas") + Juego.efecto(&"muelle")) * (1.0 + Juego.efecto(&"turistas")))
	var raciones: float = 0.0
	for r: Node in _restaurantes():
		raciones += r.raciones()
	return clampi(int(raciones / platos_por_turista), min_turistas, tope)


func niveles_abiertos() -> Array[NivelTuristasData]:
	var r: Array[NivelTuristasData] = []
	for n: NivelTuristasData in niveles:
		if Juego.stats.clientes >= n.clientes_para_desbloquear:
			r.append(n)
	return r


func _empezar(rd: RelojData) -> void:
	activa = true
	_vinieron = 0
	_bocina_dada = false
	if int(Juego.flags.get("turistas_contada", -1)) != _dia_visita:
		Juego.flags["turistas_contada"] = _dia_visita
		Juego.stats.visitas_turistas += 1
	var abiertos: Array[NivelTuristasData] = niveles_abiertos()
	var muelles: Array[Dictionary] = _muelles()
	if abiertos.is_empty() or muelles.is_empty():
		activa = false
		return
	var n: int = cuantos()
	_vinieron = n
	var visibles: int = mini(n, max_visibles)
	_invisibles = n - visibles
	var restante: float = _segundos_restantes(rd)
	var cada_comer: float = maxf(20.0, (restante - escalonado) / (platos_por_turista + 0.5))
	# Se reparten a partes iguales entre los tipos abiertos y se meten en barcos.
	var barcos: Array[Dictionary] = []
	for k: int in abiertos.size():
		var nivel: NivelTuristasData = abiertos[k]
		var suyos: int = visibles / abiertos.size() + (1 if k < visibles % abiertos.size() else 0)
		while suyos > 0:
			var b: int = randi() % nivel.barcos.size()
			var plazas: int = mini(suyos, nivel.plazas[b])
			var cubierta: float = nivel.alturas_cubierta[b] if b < nivel.alturas_cubierta.size() else NAN
			barcos.append({"nivel": nivel, "barco": nivel.barcos[b], "plazas": plazas, "cubierta": cubierta})
			suyos -= plazas
	barcos.shuffle()
	_t_invisibles = restante / maxf(1.0, _invisibles * platos_por_turista)
	for i: int in barcos.size():
		var datos: Dictionary = barcos[i]
		_traer(datos, muelles[i % muelles.size()], cada_comer, escalonado * i / maxf(1.0, barcos.size() - 1))


func _traer(datos: Dictionary, muelle: Dictionary, cada_comer: float, retraso: float) -> void:
	if retraso > 0.0:
		await get_tree().create_timer(retraso, false).timeout
	if not activa:
		return
	var barco: BarcoTuristas = escena_barco.instantiate()
	add_child(barco)
	barco.preparar(datos.barco, agua, datos.cubierta)
	# Los barcos grandes paran más lejos para no meterse encima del muelle.
	var punto: Vector3 = muelle.punto + muelle.fuera * maxf(0.0, barco.ancho() * 0.5 - mundo.tamano_celda * 0.5) * absf(muelle.fuera.x)
	barco.global_position = punto + Vector3(distancia_llegada, 0.0, 0.0)
	var grupo: Dictionary = {"barco": barco, "turistas": [] as Array[Turista], "muelle": muelle, "nivel": datos.nivel, "punto": punto}
	_grupos.append(grupo)
	var sitios: Array[Vector3] = barco.asientos(datos.plazas)
	# Cada barco va a un restaurante (se reparten entre todos los que hay).
	var restaurantes: Array[Node] = _restaurantes()
	var suyo: Node = restaurantes[_barcos_traidos % restaurantes.size()] if not restaurantes.is_empty() else null
	_barcos_traidos += 1
	var paseo: Array[Vector2i] = _celdas_paseo(suyo.name if suyo else id_restaurante)
	for s: Vector3 in sitios:
		var t: Turista = escena_turista.instantiate()
		add_child(t)
		t.preparar(datos.nivel.personas.pick_random(), mundo, suyo, paseo)
		t.gasto = datos.nivel.mult_gasto
		t.montar(barco, s)
		grupo.turistas.append(t)
	await barco.navegar_a(punto)
	if not _bocina_dada and sfx_llegada:
		_bocina_dada = true
		sfx_llegada.play()
	for t: Turista in grupo.turistas:
		t.bajar(muelle.celda, cada_comer)
		await get_tree().create_timer(0.25, false).timeout
	# El barco se va y vuelve a por ellos al final.
	await barco.navegar_a(punto + Vector3(distancia_llegada, 0.0, 0.0))
	barco.visible = false


func _terminar() -> void:
	activa = false
	Juego.flags["turistas_hecho"] = _dia_visita
	_cobrar()
	_invisibles = 0
	for g: Dictionary in _grupos:
		_recoger(g)
	_grupos.clear()


func _recoger(g: Dictionary) -> void:
	var barco: BarcoTuristas = g.barco
	var turistas: Array[Turista] = g.turistas
	for t: Turista in turistas:
		t.irse(g.muelle.celda)
	barco.visible = true
	await barco.navegar_a(g.punto)
	# Espera a que lleguen todos al muelle (o un rato como mucho).
	var espera: float = 0.0
	while espera < 40.0 and turistas.any(func(t: Turista) -> bool: return t.modo != Turista.Modo.ESPERANDO):
		await get_tree().create_timer(0.5, false).timeout
		espera += 0.5
	var sitios: Array[Vector3] = barco.asientos(turistas.size())
	for i: int in turistas.size():
		turistas[i].subir(barco, sitios[i])
		await get_tree().create_timer(0.2, false).timeout
	await get_tree().create_timer(0.5, false).timeout
	await barco.navegar_a(g.punto + Vector3(distancia_llegada, 0.0, 0.0))
	for t: Turista in turistas:
		t.queue_free()
	barco.queue_free()


## Los que no se dibujan también comen, repartidos en el tiempo.
func _comer_invisibles(delta: float) -> void:
	if not activa or _invisibles <= 0:
		return
	_t_invisibles -= delta
	if _t_invisibles > 0.0:
		return
	var lista: Array[Node] = _restaurantes()
	var r: Node = lista.pick_random() if not lista.is_empty() else null
	if r:
		var abiertos: Array[NivelTuristasData] = niveles_abiertos()
		var gasto: float = 0.0
		for n: NivelTuristasData in abiertos:
			gasto += n.mult_gasto / abiertos.size()
		r.servir(true, maxf(1.0, gasto))
	var rd: RelojData = Juego.reloj_data
	_t_invisibles = _segundos_restantes(rd) / maxf(1.0, _invisibles * platos_por_turista) if rd else 30.0


## Todo lo que han gastado llega de golpe desde O Mar, con su aviso.
func _cobrar() -> void:
	var platos: int = 0
	var dinero: float = 0.0
	var comercio: Node = get_tree().get_first_node_in_group("comercio")
	for r: Node in _restaurantes():
		var caja: Dictionary = r.cobrar_visita()
		if caja.platos <= 0:
			continue
		platos += caja.platos
		dinero += caja.dinero
		if comercio:
			Vuelos.enviar_dinero(r.casa if r.casa else r, comercio.origen(), caja.dinero)
		else:
			Juego.sumar_rublos(caja.dinero)
	if platos > 0:
		visita_terminada.emit(_vinieron, platos, dinero)


func _restaurantes() -> Array[Node]:
	return get_tree().get_nodes_in_group("restaurante")


func _restaurante() -> Node:
	return mundo.get_node_or_null(String(id_restaurante)) if mundo else null


func _aparicion(id: StringName) -> AparicionData:
	for a: AparicionData in mundo.apariciones:
		if a.id == id:
			return a
	return null


## Donde se pasean: las casillas pisables del restaurante.
func _celdas_paseo(id: StringName) -> Array[Vector2i]:
	var a: AparicionData = _aparicion(id)
	var r: Array[Vector2i] = []
	if a:
		for c: Vector2i in a.celdas:
			if not c in a.celdas_bloqueadas:
				r.append(c)
	return r


## Muelles: casillas de agua pegadas a la entrada con mar abierto hacia el este (por donde llegan).
## Cada uno: {celda (tierra donde bajan), punto (donde para el barco)}.
func _muelles() -> Array[Dictionary]:
	var a: AparicionData = _aparicion(id_entrada)
	var r: Array[Dictionary] = []
	if a == null:
		return r
	var tierra: Dictionary = {}
	for c: Vector2i in mundo.celdas_ocupadas():
		tierra[c] = true
	for c: Vector2i in a.celdas:
		for d: Vector2i in [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.UP]:
			var w: Vector2i = c + d
			if tierra.has(w):
				continue
			var libre: bool = true
			for k: int in range(1, 25):
				if tierra.has(w + Vector2i(k, 0)):
					libre = false
					break
			if libre and not r.any(func(m: Dictionary) -> bool: return m.punto == mundo.celda_a_mundo(w)):
				r.append({"celda": c, "punto": mundo.celda_a_mundo(w), "fuera": Vector3(d.x, 0.0, -d.y)})
	return r
