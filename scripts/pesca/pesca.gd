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
## 0..1 según cuántos botones llevas en esta cadena (ver StatsPesca.botones_intensidad_maxima).
## Lo visual (zoom, shake, efectos, frases) crece con esto: con cadenas cortas apenas se nota.
signal intensidad_cambiada(intensidad: float)
signal pez_capturado(captura: Dictionary, pez: PezData)
signal pez_escapado(pez: PezData)
## Pez capturado pero sin hueco en la barca: se suelta.
signal barca_llena(pez: PezData)
## La barca está llena y no se pesca hasta vender (true) o ya hay sitio otra vez (false).
signal bloqueo_barca_llena(llena: bool)
## La suerte dio un pez de más (rama Suerte).
signal captura_doble(pez: PezData)

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

@export_group("Piloto automático (rama Chill)")
## Qué parte del tiempo de cada botón espera el piloto antes de pulsar solo.
@export_range(0.05, 0.95) var piloto_retraso: float = 0.35
## Cada cuánto machaca el piloto (segundos).
@export var piloto_ritmo_machacar: float = 0.09
## Calidad de lo que pesca el piloto (se le suma el efecto "piloto_calidad").
@export_range(0.0, 1.0) var piloto_calidad: float = 0.5

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
var _bloqueo: float = 0.0
var _llena: bool = false
## Esta picada la está haciendo el piloto automático.
var _piloto: bool = false
var _t_piloto: float = 0.0


func _ready() -> void:
	if activa:
		esperar()


func _process(delta: float) -> void:
	if _bloqueo > 0.0:
		_bloqueo -= delta
		if estado == Estado.ESPERANDO:
			return
	match estado:
		Estado.ESPERANDO:
			var llena: bool = Juego.barca_llena()
			if llena != _llena:
				_llena = llena
				bloqueo_barca_llena.emit(llena)
			if llena:
				return
			# De chill pican antes (rama Chill).
			_contador -= delta * (1.0 + (Juego.efecto(&"espera_chill") if Juego.de_chill() else 0.0))
			if _contador <= 0.0:
				_picar()
		Estado.PASO:
			tiempo_restante -= delta
			_pilotar(delta)
			if estado == Estado.PASO and tiempo_restante <= 0.0:
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
	_contador = randf_range(stats.espera_min, stats.espera_max) * Juego.cana().mult_espera * Juego.mult_espera_cebo() \
		* maxf(0.3, 1.0 - Juego.efecto(&"espera"))
	_cambiar_estado(Estado.ESPERANDO)
	intensidad_cambiada.emit(0.0)


## Deja de pescar (el náufrago se baja a andar).
func pausar() -> void:
	_cambiar_estado(Estado.INACTIVO)
	intensidad_cambiada.emit(0.0)


func reanudar() -> void:
	if estado == Estado.INACTIVO:
		esperar()


## True mientras hay un pez enganchado (botones en pantalla o entre botones).
func en_curso() -> bool:
	return estado == Estado.PASO or estado == Estado.ENTRE_PASOS


func intensidad() -> float:
	return clampf(float(indice) / float(maxi(1, stats.botones_intensidad_maxima)), 0.0, 1.0)


## Durante estos segundos no pica nada (cinemáticas del mundo).
func bloquear(segundos: float) -> void:
	_bloqueo = maxf(_bloqueo, segundos)


## Alarga la pausa tras el resultado (para celebraciones).
func retener(segundos: float) -> void:
	if estado == Estado.RESULTADO:
		_contador = maxf(_contador, segundos)


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
	_piloto = false
	_generar_pasos()
	pez_pica.emit(pez)
	_iniciar_paso()


func _tirar_pez() -> PezData:
	var posibles: Array[PezData] = []
	var pesos: Array[float] = []
	var total: float = 0.0
	var hondo: int = cana.profundidad + int(Juego.efecto(&"profundidad"))
	var suerte: float = 1.0 + Juego.efecto(&"raros") + (Juego.efecto(&"raros_tormenta") if Juego.lloviendo else 0.0)
	for p: PezData in peces:
		if p.profundidad > hondo:
			continue
		var w: float = p.probabilidad
		if p.rareza != PezData.Rareza.COMUN:
			w *= cana.mult_rareza * suerte
		if p.rareza == PezData.Rareza.LEGENDARIO:
			w *= 1.0 + Juego.efecto(&"legendarios")
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
	# Cada picada da un largo distinto: muchas veces solo 1 o 2 botones. Solo llegas al perfect si sale largo.
	var n: int = mini(pez.pasos_perfect, cana.tirar_largo_cadena(int(Juego.efecto(&"cadena_extra")), Juego.efecto(&"sesgo_cadena")))
	var mult: float = pez.mult_tiempo * cana.mult_tiempo * Juego.mult_tiempo_cebo() * (1.0 + Juego.efecto(&"tiempo_reaccion"))
	var dobles_desde: int = stats.dobles_desde_boton + int(Juego.efecto(&"dobles_tarde"))
	var pulsaciones: int = maxi(1, ceili(pez.pulsaciones_machacar / (1.0 + Juego.efecto(&"machacar"))))
	var anterior: StringName = &""
	for i in n:
		var p := Paso.new()
		p.tiempo = maxf(stats.tiempo_minimo, stats.tiempo_inicial * pow(stats.factor_tiempo, i)) * mult
		if pez.machacar_cada > 0 and i > 0 and (i + 1) % pez.machacar_cada == 0:
			p.tipo = Tipo.MACHACAR
			p.acciones = [todas.pick_random()]
			p.pulsaciones = pulsaciones
			p.tiempo = pez.tiempo_machacar * mult
		elif i + 1 >= dobles_desde and randf() < pez.prob_doble:
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
	_t_piloto = 0.0
	_pulsadas.clear()
	_cambiar_estado(Estado.PASO)
	paso_nuevo.emit(p, indice)


func _acertar() -> void:
	aciertos += 1
	# Lo que hace el piloto no cuenta para los hitos de combo.
	if not _piloto:
		Juego.registrar_combo(indice + 1)
	acierto.emit(indice + 1, pez.pasos_perfect)
	_avanzar()


func _avanzar() -> void:
	indice += 1
	intensidad_cambiada.emit(intensidad())
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
	elif Juego.efecto(&"auto_pesca") > 0.0:
		# Pesca de memoria: si no pulsas, te quedas el pez igualmente con lo que llevas.
		_capturar()
	else:
		_fallar()


func _fallar() -> void:
	fallo.emit()
	if aciertos == 0 and not (cana.auto_primer_boton or Juego.efecto(&"auto_primer_boton") > 0.0):
		# Segunda oportunidad (rama Suerte): a veces no se escapa.
		if randf() < Juego.efecto(&"segunda_oportunidad"):
			_capturar()
		else:
			_escapar()
	else:
		_capturar()


## Piloto automático (rama Chill): si no tocas nada, el náufrago pesca solo, con menos calidad.
func _pilotar(delta: float) -> void:
	if Juego.efecto(&"piloto") <= 0.0 or not Juego.de_chill():
		return
	var p: Paso = pasos[indice]
	_t_piloto += delta
	if p.tipo == Tipo.MACHACAR:
		if _t_piloto >= piloto_ritmo_machacar:
			_t_piloto = 0.0
			_piloto = true
			pulsar(p.acciones[0])
	elif _t_piloto >= p.tiempo * piloto_retraso:
		_piloto = true
		for a: StringName in p.acciones:
			pulsar(a)


func _escapar() -> void:
	Juego.anadir_escapado()
	pez_escapado.emit(pez)
	_terminar()


func _capturar() -> void:
	var ratio: float = float(aciertos) / float(pez.pasos_perfect)
	var perfecto: bool = aciertos >= pez.pasos_perfect
	var peso: float = randf_range(pez.peso_min, pez.peso_max) * (1.0 + Juego.efecto(&"peso"))
	ratio = minf(1.0, ratio + Juego.efecto(&"calidad"))
	if _piloto:
		ratio = minf(ratio, piloto_calidad + Juego.efecto(&"piloto_calidad"))
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
		# Pesca doble (rama Suerte): sale otro igual.
		if randf() < Juego.efecto(&"pesca_doble") and Juego.anadir_captura(captura.duplicate(), pez):
			captura_doble.emit(pez)
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
