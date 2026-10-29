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
## El corcho tiembla mientras esperas. aviso = true: es el de justo antes de picar.
signal picoteo(aviso: bool)
## Estabas de chill y no tocaste nada: el pez se va sin más (sin X, no cuenta como escapado).
signal pez_se_va(pez: PezData)
## La cadena entra en un tramo de racha nuevo (StatsPesca.racha_desde). Para lo visual.
signal racha_subida(tramo: int)

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
var _bloqueo: float = 0.0
var _llena: bool = false
## Esta picada llega tras un rato de chill (rama Chill: Meditación y Ron de coco).
var _tras_chill: bool = false
## Se ha pulsado algo del minijuego en esta picada.
var _tocado: bool = false
var _t_picoteo: float = 0.0
var _avisado: bool = false


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
			_picotear(delta)
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
	_tocado = true
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
	# Las rebajas de espera del árbol van en hiperbólica: +100 % = la mitad de espera, nunca cero.
	_contador = randf_range(stats.espera_min, stats.espera_max) * Juego.cana().mult_espera * Juego.mult_espera_cebo() \
		/ (1.0 + Juego.efecto(&"espera"))
	_t_picoteo = randf_range(stats.picoteo_min, stats.picoteo_max)
	_avisado = false
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


## Cuántos botones siguientes se ven en el paso i (0 = ninguno). Nodo Leer el agua del árbol.
func cola(i: int = -1) -> int:
	if i < 0:
		i = indice
	return int(Juego.efecto(&"vista_siguiente")) if i + 1 >= stats.cola_desde_boton else 0


func hay_cola(i: int) -> bool:
	return cola(i) > 0


func paso_actual() -> Paso:
	return pasos[indice] if estado == Estado.PASO else null


func _picotear(delta: float) -> void:
	if not _avisado and _contador <= stats.aviso_picada:
		_avisado = true
		picoteo.emit(true)
		return
	_t_picoteo -= delta
	if _t_picoteo <= 0.0 and _contador > stats.aviso_picada + 0.5:
		_t_picoteo = randf_range(stats.picoteo_min, stats.picoteo_max)
		picoteo.emit(false)


func _picar() -> void:
	cana = Juego.cana()
	_tras_chill = Juego.de_chill()
	_tocado = false
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
	var hondo: int = cana.profundidad + int(Juego.efecto(&"profundidad"))
	var suerte: float = 1.0 + Juego.efecto(&"raros") + (Juego.efecto(&"raros_tormenta") if Juego.lloviendo else 0.0) \
		+ (Juego.efecto(&"raros_tras_chill") if _tras_chill else 0.0)
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
	var mult: float = pez.mult_tiempo * cana.mult_tiempo * Juego.mult_tiempo_cebo() * (1.0 + Juego.efecto(&"tiempo_reaccion") + (Juego.efecto(&"tiempo_tras_chill") if _tras_chill else 0.0))
	var dobles_desde: int = stats.dobles_desde_boton + int(Juego.efecto(&"dobles_tarde"))
	var pulsaciones: int = maxi(1, ceili(pez.pulsaciones_machacar / (1.0 + Juego.efecto(&"machacar"))))
	var anterior: StringName = &""
	for i in n:
		var p := Paso.new()
		var t_base: float = stats.tiempo_inicial * pow(stats.factor_tiempo, i)
		p.tiempo = maxf(stats.tiempo_minimo, t_base) * mult
		# Modo flow: viendo lo que viene, se va bastante más rápido (y puede bajar del mínimo normal).
		if hay_cola(i):
			p.tiempo = maxf(stats.tiempo_minimo_cola, maxf(stats.tiempo_minimo, t_base) * stats.mult_tiempo_cola) * mult
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
	_pulsadas.clear()
	_cambiar_estado(Estado.PASO)
	paso_nuevo.emit(p, indice)


func _acertar() -> void:
	aciertos += 1
	Juego.registrar_combo(indice + 1)
	acierto.emit(indice + 1, pez.pasos_perfect)
	var tramo: int = stats.tramo_racha(indice + 1)
	if tramo > stats.tramo_racha(indice):
		racha_subida.emit(tramo)
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
	# De chill y sin tocar nada: le dejas ir. Así se puede estar tumbado sin pescar mientras trabajan los demás
	# (y la caña Sabia o la Pesca de memoria no pescan solas).
	if indice == 0 and not _tocado and _tras_chill:
		pez_se_va.emit(pez)
		esperar()
		return
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


func _escapar() -> void:
	Juego.anadir_escapado()
	pez_escapado.emit(pez)
	_terminar()


func _capturar() -> void:
	var perfect: float = float(pez.pasos_perfect)
	var perfecto: bool = aciertos >= pez.pasos_perfect
	var peso: float = randf_range(pez.peso_min, pez.peso_max) * (1.0 + Juego.efecto(&"peso"))
	var ratio: float = minf(1.0, float(aciertos) / perfect + Juego.efecto(&"calidad"))
	# Cada botón acertado paga 1/perfect del pez, multiplicado por su tramo de racha: los combos largos
	# a mano son los que dan el dinero gordo. Con pocos botones, al menos mult_calidad_min.
	var mult: float = maxf(stats.mult_calidad_min, stats.suma_racha(aciertos) / perfect + Juego.efecto(&"calidad"))
	mult *= maxf(0.1, 1.0 - stats.penalizacion_machacar * machacar_fallados)
	if perfecto:
		mult *= stats.mult_perfecto
	# Maestría: cuantas más llevas de esta especie, más vale (se cuenta la que entra ahora).
	mult *= stats.mult_maestria(Juego.capturas_especie(pez.id) + 1)
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
