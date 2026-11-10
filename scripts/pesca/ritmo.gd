class_name Ritmo
extends CanvasLayer
## Minijuego de carril de los spots de banco y trofeo. Cuatro carriles, uno por botón de símbolo (pesca_1..4):
## las notas viajan por el sedal hasta la zona de golpe y hay que pulsar su botón al llegar.
## - Banco: cada nota acertada es un pez; el ritmo se acelera; fallar solo pierde ese pez.
## - Pelea (trofeo): canción larga con notas que hay que mantener (el pez tira); los fallos bajan la
##   tensión y, si se vacía, el pez se escapa.
## La lógica cuenta con tiempos; lo visual (pista, notas) son nodos de ritmo.tscn y nota_ritmo.tscn.

const ACCIONES: Array[StringName] = [&"pesca_1", &"pesca_2", &"pesca_3", &"pesca_4"]

@export var escena_nota: PackedScene
## Segundos que tarda una nota en cruzar la pista hasta la zona de golpe.
@export var antelacion: float = 1.8
@export var ventana_perfecta: float = 0.07
@export var ventana_buena: float = 0.15
@export_group("Banco")
@export var bpm_banco: float = 120.0
## Cada nota, el ritmo se acelera esto.
@export var acelera_banco: float = 0.012
## Desde qué nota pueden salir corcheas (medio pulso).
@export var corcheas_desde: int = 5
## Hueco mínimo entre dos notas (s), por mucho que acelere.
@export var separacion_minima: float = 0.18
@export_group("Pelea (trofeo)")
@export var bpm_pelea: float = 96.0
@export var prob_larga: float = 0.22
## Pulsos que dura una nota larga.
@export var pulsos_larga_min: int = 1
@export var pulsos_larga_max: int = 3
## Probabilidad de acorde (dos botones a la vez) en peces épicos o mejores.
@export var prob_acorde: float = 0.15
@export var dano_fallo: float = 0.14
@export var cura_acierto: float = 0.025

@onready var raiz: Control = $Raiz
@onready var pista: Control = $Raiz/Panel/Lista/Pista
@onready var notas: Control = $Raiz/Panel/Lista/Pista/Notas
@onready var golpe: Control = $Raiz/Panel/Lista/Pista/Golpe
@onready var combo: Label = $Raiz/Panel/Lista/Arriba/Combo
@onready var contador: Label = $Raiz/Panel/Lista/Arriba/Contador
@onready var tension: ProgressBar = $Raiz/Panel/Lista/Arriba/Tension

var activo: bool = false
var _pesca: Node
var _modo: SpotData.Modo
var _t: float = 0.0
## Notas: {t, carril, dur, nodo, estado (0 pendiente, 1 acertada, 2 fallada), mantenida}
var _lista: Array[Dictionary] = []
var _aciertos: int = 0
## Suma de los multiplicadores de racha de cada acierto (es lo que se cobra).
var _suma: float = 0.0
var _combo: int = 0
var _vida: float = 1.0
var _manteniendo: Dictionary = {}
var _pez: PezData


func _ready() -> void:
	raiz.visible = false


func empezar(pesca: Node, pez: PezData, spot: SpotData) -> void:
	_pesca = pesca
	_pez = pez
	_modo = spot.modo
	_t = 0.0
	_aciertos = 0
	_suma = 0.0
	_combo = 0
	_vida = 1.0
	_manteniendo.clear()
	for n: Node in notas.get_children():
		n.queue_free()
	_lista.clear()
	_generar(spot)
	tension.visible = _modo == SpotData.Modo.TROFEO
	_pintar_botones()
	_refrescar_textos()
	raiz.visible = true
	activo = true


func _generar(spot: SpotData) -> void:
	var t: float = antelacion + 0.4
	var ultimo: int = -1
	var repetido: int = 0
	if _modo == SpotData.Modo.BANCO:
		var n: int = randi_range(spot.notas_min, spot.notas_max) + int(Juego.efecto(&"cadena_extra"))
		var pulso: float = 60.0 / bpm_banco
		for i in n:
			var c: int = _carril_nuevo(ultimo, repetido)
			repetido = repetido + 1 if c == ultimo else 0
			ultimo = c
			_lista.append({"t": t, "carril": c, "dur": 0.0, "estado": 0})
			t += maxf(separacion_minima, pulso * (0.5 if i >= corcheas_desde and randf() < 0.3 else 1.0))
			pulso *= 1.0 - acelera_banco
	else:
		var n2: int = clampi(_pez.pasos_perfect * 2, 20, 60) + int(Juego.efecto(&"cadena_extra"))
		var pulso2: float = 60.0 / bpm_pelea
		var i: int = 0
		while i < n2:
			var c: int = _carril_nuevo(ultimo, repetido)
			repetido = repetido + 1 if c == ultimo else 0
			ultimo = c
			var dur: float = 0.0
			if i > 2 and randf() < prob_larga:
				dur = pulso2 * randi_range(pulsos_larga_min, pulsos_larga_max)
			_lista.append({"t": t, "carril": c, "dur": dur, "estado": 0})
			i += 1
			# Acorde: otra nota a la vez en otro carril (peces épicos o mejores).
			if dur == 0.0 and _pez.rareza >= PezData.Rareza.EPICO and i < n2 and randf() < prob_acorde:
				_lista.append({"t": t, "carril": (c + randi_range(1, 3)) % 4, "dur": 0.0, "estado": 0})
				i += 1
			t += dur + pulso2 * (0.5 if randf() < 0.2 else 1.0)
	for nota: Dictionary in _lista:
		var nodo: Control = escena_nota.instantiate()
		notas.add_child(nodo)
		nodo.get_node("Icono").texture = IconosInput.icono(ACCIONES[nota.carril])
		nota.nodo = nodo


func _carril_nuevo(ultimo: int, repetido: int) -> int:
	var c: int = randi() % 4
	while c == ultimo and repetido >= 1:
		c = randi() % 4
	return c


func _unhandled_input(event: InputEvent) -> void:
	if not activo or event.is_echo():
		return
	for k in ACCIONES.size():
		if event.is_action_pressed(ACCIONES[k]):
			get_viewport().set_input_as_handled()
			_pulsar(k)
		elif event.is_action_released(ACCIONES[k]):
			_soltar(k)


func _pulsar(k: int) -> void:
	var mejor: Dictionary = {}
	var dist: float = INF
	for nota: Dictionary in _lista:
		if nota.estado == 0 and nota.carril == k:
			var d: float = absf(_t - nota.t)
			if d <= ventana_buena and d < dist:
				dist = d
				mejor = nota
	_flash(k)
	if mejor.is_empty():
		return
	mejor.estado = 1
	_aciertos += 1
	_combo += 1
	_suma += _pesca.stats.racha(_combo)
	_vida = minf(1.0, _vida + cura_acierto)
	if mejor.dur > 0.0:
		_manteniendo[k] = mejor
	else:
		_quitar(mejor, dist <= ventana_perfecta)
	_pesca.acierto.emit(_combo, _lista.size())
	var stats: StatsPesca = _pesca.stats
	if stats.tramo_racha(_combo) > stats.tramo_racha(_combo - 1):
		_pesca.racha_subida.emit(stats.tramo_racha(_combo))
	_refrescar_textos()


func _soltar(k: int) -> void:
	if not _manteniendo.has(k):
		return
	var nota: Dictionary = _manteniendo[k]
	_manteniendo.erase(k)
	# Soltar antes de tiempo: el pez tira y gana un poco de sedal.
	if _t < nota.t + nota.dur - ventana_buena:
		_vida -= dano_fallo * 0.5
		_combo = 0
		_pesca.fallo.emit()
		_refrescar_textos()
	_quitar(nota, false)


func _process(delta: float) -> void:
	if not activo or get_tree().paused:
		return
	_t += delta
	var largo: float = pista.size.x - golpe.position.x
	var alto: float = pista.size.y / 4.0
	for nota: Dictionary in _lista:
		var nodo: Control = nota.get("nodo")
		if nodo == null or not is_instance_valid(nodo):
			continue
		var x: float = golpe.position.x + (nota.t - _t) / antelacion * largo
		nodo.position = Vector2(x - nodo.size.x * 0.5, (nota.carril + 0.5) * alto - nodo.size.y * 0.5)
		nodo.visible = x < pista.size.x + 40.0
		var cola: Control = nodo.get_node_or_null("Cola")
		if cola:
			cola.visible = nota.dur > 0.0
			var fin: float = maxf(0.0, (nota.t + nota.dur - maxf(_t, nota.t)) / antelacion * largo)
			cola.size.x = fin
			if nota.estado == 1:
				nodo.position.x = golpe.position.x - nodo.size.x * 0.5
		# Se pasó sin pulsarla.
		if nota.estado == 0 and _t > nota.t + ventana_buena:
			nota.estado = 2
			_combo = 0
			_vida -= dano_fallo
			_pesca.fallo.emit()
			nodo.modulate = Color(1, 0.3, 0.3, 0.6)
			_refrescar_textos()
	# Notas largas mantenidas hasta el final.
	for k: int in _manteniendo.keys():
		var n: Dictionary = _manteniendo[k]
		if _t >= n.t + n.dur:
			_manteniendo.erase(k)
			_quitar(n, true)
	if _modo == SpotData.Modo.TROFEO:
		tension.value = _vida * 100.0
		if _vida <= 0.0:
			_fin(true)
			return
	if _lista.all(func(n: Dictionary) -> bool: return n.estado != 0) and _manteniendo.is_empty() \
			and _t > _lista.back().t + _lista.back().dur + 0.3:
		_fin(false)


func _quitar(nota: Dictionary, bien: bool) -> void:
	var nodo: Control = nota.get("nodo")
	if nodo == null or not is_instance_valid(nodo):
		return
	nota.nodo = null
	var tw := nodo.create_tween()
	nodo.pivot_offset = nodo.size * 0.5
	tw.tween_property(nodo, "scale", Vector2.ONE * (1.6 if bien else 1.2), 0.1)
	tw.parallel().tween_property(nodo, "modulate:a", 0.0, 0.15)
	tw.tween_callback(nodo.queue_free)


func _fin(escapado: bool) -> void:
	activo = false
	raiz.visible = false
	_pesca.terminar_ritmo(_aciertos, _lista.size(), escapado, _suma)


func _flash(k: int) -> void:
	var b: Control = golpe.get_child(k)
	b.scale = Vector2.ONE * 1.25
	b.pivot_offset = b.size * 0.5
	create_tween().tween_property(b, "scale", Vector2.ONE, 0.12)


func _pintar_botones() -> void:
	for k in ACCIONES.size():
		var b: TextureRect = golpe.get_child(k)
		b.texture = IconosInput.icono(ACCIONES[k])
		b.position.y = (k + 0.5) * pista.size.y / 4.0 - b.size.y * 0.5


func _refrescar_textos() -> void:
	combo.text = "x%d" % _combo if _combo > 1 else ""
	if _modo == SpotData.Modo.BANCO:
		contador.text = "%s ×%d" % [_pez.nombre, _aciertos]
	else:
		contador.text = _pez.nombre
