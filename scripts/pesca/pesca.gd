class_name Pesca
extends Node
## Lógica del minijuego de pesca. No toca nada visual: emite señales y lo visual reacciona.

signal estado_cambiado(estado: Estado)
signal pez_pica(pez: PezData)
signal paso_nuevo(paso: Paso, indice: int)
signal acierto(indice: int, total_perfect: int)
signal fallo
signal machacar_progreso(golpes: int, necesarios: int)
signal machacar_fallido(escapa: bool)
## 0..1 respecto a las pulsaciones del perfect del pez actual.
signal progreso_cambiado(progreso: float)
signal pez_capturado(captura: Dictionary, pez: PezData)
signal pez_escapado(pez: PezData)
## Pez capturado pero sin hueco en la barca: se suelta.
signal barca_llena(pez: PezData)

enum Estado { INACTIVO, ESPERANDO, PASO, ENTRE_PASOS, RESULTADO }
enum Tipo { SIMPLE, DOBLE, MACHACAR }

const NUMEROS: Array[StringName] = [&"pesca_1", &"pesca_2", &"pesca_3", &"pesca_4"]
const FLECHAS: Array[StringName] = [&"pesca_arriba", &"pesca_abajo", &"pesca_izq", &"pesca_der"]


class Paso:
	var tipo: int = 0
	var acciones: Array[StringName] = []
	var tiempo: float = 1.0
	var pulsaciones: int = 0


@export var stats: StatsPesca
## Peces que pueden picar. Se filtran por la profundidad de la caña.
@export var peces: Array[PezData] = []
@export var activa: bool = true
@export var pausa_entre_pasos: float = 0.12
@export var duracion_resultado: float = 1.6

var estado: Estado = Estado.INACTIVO
var pez: PezData
var cana: CanaData
var pasos: Array[Paso] = []
var indice: int = 0
var aciertos: int = 0
var machacar_fallados: int = 0
var tiempo_restante: float = 0.0
var golpes: int = 0
var _pulsadas: Array[StringName] = []
var _contador: float = 0.0


func _ready() -> void:
	if activa:
		esperar()


func _process(delta: float) -> void:
	match estado:
		Estado.ESPERANDO:
			_contador -= delta
			if _contador <= 0.0:
				_picar()
		Estado.PASO:
			tiempo_restante -= delta
			if tiempo_restante <= 0.0:
				_tiempo_agotado()
		Estado.ENTRE_PASOS:
			_contador -= delta
			if _contador <= 0.0:
				_iniciar_paso()
		Estado.RESULTADO:
			_contador -= delta
			if _contador <= 0.0:
				esperar()


func _unhandled_input(event: InputEvent) -> void:
	if estado != Estado.PASO or event.is_echo():
		return
	var accion: StringName = _accion_de(event)
	if accion == &"":
		return
	get_viewport().set_input_as_handled()
	pulsar(accion)


## Ejecuta una pulsación del minijuego. Pública para poder llamarla desde input táctil o pruebas.
func pulsar(accion: StringName) -> void:
	if estado != Estado.PASO:
		return
	var p: Paso = pasos[indice]
	match p.tipo:
		Tipo.SIMPLE:
			if accion == p.acciones[0]:
				_acertar()
			else:
				_fallar()
		Tipo.DOBLE:
			if accion in p.acciones:
				if not accion in _pulsadas:
					_pulsadas.append(accion)
				if _pulsadas.size() >= p.acciones.size():
					_acertar()
			else:
				_fallar()
		Tipo.MACHACAR:
			# En el machaque las teclas equivocadas no penalizan.
			if accion == p.acciones[0]:
				golpes += 1
				machacar_progreso.emit(golpes, p.pulsaciones)
				if golpes >= p.pulsaciones:
					_acertar()


func esperar() -> void:
	pez = null
	_contador = randf_range(stats.espera_min, stats.espera_max) * Juego.cana().mult_espera * Juego.mult_espera_cebo()
	_cambiar_estado(Estado.ESPERANDO)
	progreso_cambiado.emit(0.0)


## True mientras hay un pez enganchado (botones en pantalla o entre botones).
func en_curso() -> bool:
	return estado == Estado.PASO or estado == Estado.ENTRE_PASOS


func progreso() -> float:
	if pez == null:
		return 0.0
	return clampf(float(indice) / float(pez.pasos_perfect), 0.0, 1.0)


func paso_actual() -> Paso:
	return pasos[indice] if estado == Estado.PASO else null


func _picar() -> void:
	cana = Juego.cana()
	pez = _tirar_pez()
	if pez == null:
		esperar()
		return
	indice = 0
	aciertos = 0
	machacar_fallados = 0
	_generar_pasos()
	pez_pica.emit(pez)
	_iniciar_paso()


func _tirar_pez() -> PezData:
	var posibles: Array[PezData] = []
	var pesos: Array[float] = []
	var total: float = 0.0
	for p: PezData in peces:
		if p.profundidad > cana.profundidad:
			continue
		var w: float = p.probabilidad * (1.0 if p.rareza == PezData.Rareza.COMUN else cana.mult_rareza)
		posibles.append(p)
		pesos.append(w)
		total += w
	var r: float = randf() * total
	for i in posibles.size():
		r -= pesos[i]
		if r <= 0.0:
			return posibles[i]
	return posibles.back() if not posibles.is_empty() else null


func _generar_pasos() -> void:
	pasos.clear()
	var todas: Array[StringName] = []
	todas.append_array(NUMEROS)
	todas.append_array(FLECHAS)
	var n: int = mini(pez.pasos_perfect, cana.limite_cadena)
	var mult: float = pez.mult_tiempo * cana.mult_tiempo * Juego.mult_tiempo_cebo()
	var anterior: StringName = &""
	for i in n:
		var p := Paso.new()
		p.tiempo = maxf(stats.tiempo_minimo, stats.tiempo_inicial * pow(stats.factor_tiempo, i)) * mult
		if pez.machacar_cada > 0 and i > 0 and (i + 1) % pez.machacar_cada == 0:
			p.tipo = Tipo.MACHACAR
			p.acciones = [todas.pick_random()]
			p.pulsaciones = pez.pulsaciones_machacar
			p.tiempo = pez.tiempo_machacar * mult
		elif i > 0 and randf() < pez.prob_doble:
			p.tipo = Tipo.DOBLE
			p.acciones = [NUMEROS.pick_random(), FLECHAS.pick_random()]
			p.tiempo *= stats.mult_tiempo_doble
		else:
			p.tipo = Tipo.SIMPLE
			var a: StringName = todas.pick_random()
			while a == anterior:
				a = todas.pick_random()
			p.acciones = [a]
		anterior = p.acciones[0]
		pasos.append(p)


func _iniciar_paso() -> void:
	var p: Paso = pasos[indice]
	tiempo_restante = p.tiempo
	golpes = 0
	_pulsadas.clear()
	_cambiar_estado(Estado.PASO)
	paso_nuevo.emit(p, indice)


func _acertar() -> void:
	aciertos += 1
	acierto.emit(indice + 1, pez.pasos_perfect)
	_avanzar()


func _avanzar() -> void:
	indice += 1
	progreso_cambiado.emit(progreso())
	if indice >= pasos.size():
		_capturar()
	else:
		_contador = pausa_entre_pasos
		_cambiar_estado(Estado.ENTRE_PASOS)


func _tiempo_agotado() -> void:
	if pasos[indice].tipo == Tipo.MACHACAR:
		var escapa: bool = pez.escapa_si_falla_machacar()
		machacar_fallido.emit(escapa)
		if escapa:
			_escapar()
		else:
			machacar_fallados += 1
			_avanzar()
	else:
		_fallar()


func _fallar() -> void:
	fallo.emit()
	if aciertos == 0 and not cana.auto_primer_boton:
		_escapar()
	else:
		_capturar()


func _escapar() -> void:
	Juego.anadir_escapado()
	pez_escapado.emit(pez)
	_terminar()


func _capturar() -> void:
	var ratio: float = float(aciertos) / float(pez.pasos_perfect)
	var perfecto: bool = aciertos >= pez.pasos_perfect
	var peso: float = randf_range(pez.peso_min, pez.peso_max)
	var mult: float = lerpf(stats.mult_calidad_min, 1.0, ratio)
	mult *= maxf(0.1, 1.0 - stats.penalizacion_machacar * machacar_fallados)
	if perfecto:
		mult *= stats.mult_perfecto
	var valor: float = pez.valor_base * (peso / ((pez.peso_min + pez.peso_max) * 0.5)) * mult
	var captura: Dictionary = {
		"id": String(pez.id), "peso": peso, "calidad": ratio, "perfecto": perfecto, "valor": valor,
	}
	if Juego.anadir_captura(captura, pez):
		pez_capturado.emit(captura, pez)
	else:
		barca_llena.emit(pez)
	_terminar()


func _terminar() -> void:
	Juego.consumir_cebo()
	# El zoom se mantiene durante el resultado y se suelta al volver a esperar.
	_contador = duracion_resultado
	_cambiar_estado(Estado.RESULTADO)


func _cambiar_estado(e: Estado) -> void:
	estado = e
	estado_cambiado.emit(e)


func _accion_de(event: InputEvent) -> StringName:
	for a: StringName in NUMEROS:
		if event.is_action_pressed(a):
			return a
	for a: StringName in FLECHAS:
		if event.is_action_pressed(a):
			return a
	return &""
