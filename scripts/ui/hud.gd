extends CanvasLayer
## HUD de pesca y dinero. Solo visual: lee la Pesca y el Juego.

@export var pesca: Pesca
@export var barco: BarcoComerciante
@export var celebracion: Node
@export var mundo: Node
@export var jugador: Node
@export var comercio: Node
@export var escena_popup: PackedScene
## La X roja de fallo o escape (popup_icono.tscn).
@export var escena_x: PackedScene
@export var escala_x: float = 1.0
## Para poner la X encima de la cabeza: la cámara del juego y el punto de la cabeza en el donut.
@export var camara: Camera3D
@export var cabeza: Node3D
## Altura de la X sobre los pies del náufrago cuando va andando.
@export var altura_cabeza_andando: float = 2.0
@export var velocidad_contador: float = 6.0
## Dibujos para un mando que no se reconoce por su nombre (los iconos están en art/ui/teclas).
@export_enum("ps", "xbox") var mando_por_defecto: String = "ps"
## Con varias acciones posibles a la vez, cada cuánto cambia la caja de abajo a la derecha (segundos).
@export var cambio_acciones: float = 2.0
## Cuánto se desplaza la cola al entrar cada botón nuevo (efecto de que vienen hacia ti).
@export var desliz_cola: float = 90.0
## El panel de estado (dinero, barca, caña, reloj): si es false, solo sale al pulsar Select (acción ver_estado).
@export var info_siempre_visible: bool = false
## Carta del pez (abajo a la izquierda): segundos que se queda si es una especie nueva y si no.
@export var duracion_carta_nueva: float = 4.0
@export var duracion_carta: float = 2.5
## Botón de interactuar sobre la cabeza: cuánto bota (píxeles) y cada cuánto se aprieta solo (segundos).
@export var bote_icono: float = 6.0
@export var ritmo_icono: float = 0.7
## Altura del botón de sentarse sobre el náufrago cuando pisa el donut.
@export var altura_icono_sentarse: float = 2.0
## Al machacar, cada cuánto se aprieta sola la tecla dibujada (segundos).
@export var ritmo_machacar: float = 0.12
## Cuánto salta de sitio el botón al tope de intensidad (píxeles).
@export var salto_prompt_maximo: float = 220.0
@export var color_numeros: Color = Color("ff9a3c")
@export var color_perfecto: Color = Color("ffd84a")
## Color del contador de combo según el tramo de racha (StatsPesca.racha_desde): 0 = sin tramo.
@export var colores_racha: Array[Color] = [Color("e8e8e8"), Color("8fe3ff"), Color("4fa3ff"), Color("5fd0c0"), Color("7dff8a"), Color("c8f04a"), Color("ffd84a"), Color("ff9a3c"), Color("ff5a5a"), Color("ff6bd8"), Color("b56bff"), Color("ffffff")]
## Común, poco común, raro, épico, legendario, mítico.
@export var colores_rareza: Array[Color] = [Color("e8e8e8"), Color("7dff8a"), Color("4fa3ff"), Color("b56bff"), Color("ffb02e"), Color("ff5a7a")]
## Frase de cada acierto según cuántos botones llevas: la palabra i sale desde el botón umbrales_palabras[i].
@export var palabras_acierto: Array[String] = ["Bien", "Genial", "¡Brutal!", "¡LOCURA!", "¡¡DIOS!!", "¡¡¡INHUMANO!!!"]
@export var umbrales_palabras: Array[int] = [1, 5, 10, 20, 35, 50]

@export_group("Destellos de pantalla (0..1)")
@export var destello_picada: float = 0.15
@export var destello_acierto_min: float = 0.05
@export var destello_acierto_max: float = 0.6
@export var destello_captura: float = 0.2
@export var destello_perfecto: float = 0.5
## Al subir de tramo de racha.
@export var destello_racha: float = 0.45

## Letras de las pistas "[E] ..." y su acción del Input Map.
const TECLA_A_ACCION: Dictionary = {"E": &"interactuar", "Q": &"cambiar_modo", "Tab": &"menu", "Extra": &"accion_extra"}

@onready var efecto: ColorRect = $EfectoPantalla
@onready var info: Control = $Info
@onready var rublos: Label = $Info/Lista/Rublos
@onready var barca: Label = $Info/Lista/Barca
@onready var cana: Label = $Info/Lista/Cana
@onready var cebo: Label = $Info/Lista/Cebo
@onready var cosecha: Label = get_node_or_null("Info/Lista/Cosecha")
@onready var restaurante: Label = get_node_or_null("Info/Lista/Restaurante")
@onready var reloj: Label = get_node_or_null("Info/Lista/Reloj")
@onready var prompt: Control = $Prompt
@onready var teclas: Control = $Prompt/Teclas
@onready var tecla1: TextureRect = $Prompt/Teclas/Tecla1
@onready var tecla2: TextureRect = $Prompt/Teclas/Tecla2
## Modo flow: los siguientes botones (nodo Leer el agua del árbol).
@onready var cola_box: HBoxContainer = $Prompt/Cola
@onready var mas: Label = $Prompt/Teclas/Mas
@onready var barra_tiempo: ProgressBar = $Prompt/BarraTiempo
@onready var barra_machacar: ProgressBar = $Prompt/BarraMachacar
@onready var combo: Label = $Combo
@onready var popups: Control = $Popups
@onready var resultado: PanelContainer = $Resultado
@onready var icono: TextureRect = $Resultado/Margen/Carta/Icono
@onready var nombre: Label = $Resultado/Margen/Carta/Nombre
@onready var rareza: Label = $Resultado/Margen/Carta/Rareza
@onready var detalle: Label = $Resultado/Margen/Carta/Detalle
@onready var nuevo: Label = $Resultado/Margen/Carta/Nuevo
@onready var caja_accion: PanelContainer = $Accion
## Botón de interactuar que flota encima de la cabeza (opcional: Popups/IconoInteractuar).
@onready var icono_interactuar: TextureRect = get_node_or_null("Popups/IconoInteractuar")

## Botón que salta encima de la cabeza cuando pica en la base (Popups/IconoPicar).
@onready var icono_picar: TextureRect = get_node_or_null("Popups/IconoPicar")
## En un spot: qué pica ahora y cuántas te faltan (SpotInfo).
@onready var spot_info: Label = get_node_or_null("SpotInfo")
## Peces/min y ₽/min de la pesca base (Info/Lista/RitmoPesca).
@onready var ritmo_pesca: Label = get_node_or_null("Info/Lista/RitmoPesca")
## Segundos que se miran para calcular el ritmo de pesca.
@export var ventana_ritmo: float = 90.0
## Tamaño del "+₽" de cada pieza de la base (manual; sin pulsar, un 70 %).
@export var escala_popup_base: float = 0.6

var _rublos_mostrados: float = 0.0
## Piezas recientes de la base: [tiempo, valor].
var _piezas: Array[Vector2] = []
var _t_reloj: float = 0.0
var _spot_mostrado: SpotData = null
var _t_spot_info: float = -1.0
var _intensidad_objetivo: float = 0.0
var _intensidad: float = 0.0
var _destello: float = 0.0
var _color_destello: Color = Color.WHITE
var _turistas: Node
var _pos_prompt: Vector2
var _mat: ShaderMaterial
var _ultima_x: int = -1000
var _accion_machacar: StringName = &""
var _t_machacar: float = 0.0
var _acciones: Array[String] = []
var _t_accion: float = 0.0
var _i_accion: int = 0
var _dispositivo: String = ""
var _accion_icono: StringName = &"interactuar"
var _t_icono: float = 0.0
var _t_carta: float = 0.0


func _ready() -> void:
	IconosInput.mando_por_defecto = mando_por_defecto
	_mat = efecto.material as ShaderMaterial
	_rublos_mostrados = Juego.rublos
	_pos_prompt = prompt.position
	info.visible = info_siempre_visible
	prompt.visible = false
	resultado.visible = false
	combo.visible = false
	if pesca:
		pesca.estado_cambiado.connect(_on_estado)
		pesca.pez_pica.connect(_on_pica)
		pesca.paso_nuevo.connect(_on_paso)
		pesca.acierto.connect(_on_acierto)
		pesca.fallo.connect(_on_fallo)
		pesca.machacar_progreso.connect(_on_machacar_progreso)
		pesca.machacar_fallido.connect(_on_machacar_fallido)
		pesca.pez_capturado.connect(_on_capturado)
		pesca.banco_capturado.connect(_on_banco)
		pesca.pez_escapado.connect(_on_escapado)
		pesca.intensidad_cambiada.connect(func(i: float) -> void: _intensidad_objetivo = i)
		pesca.racha_subida.connect(_on_racha)
		pesca.captura_base.connect(_on_captura_base)
		_on_estado(pesca.estado)
	if comercio:
		comercio.venta_terminada.connect(_on_vendido)
	_conectar_turistas.call_deferred()
	if celebracion:
		celebracion.empezada.connect(func(_pez: PezData) -> void: combo.visible = false)


func _process(delta: float) -> void:
	var dt: float = Juego.delta_real(delta)
	_rublos_mostrados = lerpf(_rublos_mostrados, Juego.rublos, 1.0 - exp(-velocidad_contador * dt))
	if absf(_rublos_mostrados - Juego.rublos) < 0.05:
		_rublos_mostrados = Juego.rublos
	rublos.text = Formato.dinero(_rublos_mostrados)
	barca.text = "Barca: %d peces (%s)" % [Juego.capturas.size(), Formato.dinero(Juego.valor_inventario())]
	cana.text = Juego.cana().nombre
	var rd: RelojData = Juego.reloj_data
	if reloj and rd:
		reloj.text = "%s · día %d · %s" % [RelojData.ESTACIONES[rd.estacion(Juego.reloj)], rd.dia_de_estacion(Juego.reloj), rd.hora_texto(Juego.reloj)]
	cebo.visible = not Juego.cebo.is_empty()
	if cebo.visible:
		cebo.text = "Cebo: %d pescas" % int(Juego.cebo.pescas)
	_info_villa()
	_mostrar_acciones(dt)
	_icono_interactuar(dt)
	_icono_picar(dt)
	_ritmo_pesca(dt)
	_info_spot()
	if resultado.visible:
		_t_carta -= dt
		if _t_carta <= 0.0:
			resultado.visible = false
	_al_cambiar_dispositivo()
	# Machacando, la tecla dibujada se aprieta sola para que se vea qué hay que hacer.
	if _accion_machacar != &"":
		_t_machacar += dt
		var abajo: bool = fmod(_t_machacar, ritmo_machacar * 2.0) >= ritmo_machacar
		tecla1.texture = _icono(_accion_machacar, abajo)
	if Juego.en_movimiento:
		resultado.visible = false

	var p: Pesca.Paso = pesca.paso_actual() if pesca else null
	if p:
		barra_tiempo.value = pesca.tiempo_restante / p.tiempo * 100.0

	_intensidad = lerpf(_intensidad, _intensidad_objetivo, 1.0 - exp(-4.0 * dt))
	_destello = lerpf(_destello, 0.0, 1.0 - exp(-8.0 * dt))
	# Si no hay nada que enseñar se apaga: así no copia la pantalla entera en cada fotograma.
	efecto.visible = _intensidad > 0.005 or _destello > 0.005
	if _mat:
		_mat.set_shader_parameter("intensidad", _intensidad)
		_mat.set_shader_parameter("destello", _destello)
		_mat.set_shader_parameter("color_destello", _color_destello)
		if _destello < 0.01:
			_color_destello = Color.WHITE


func _on_estado(e: Pesca.Estado) -> void:
	if e != Pesca.Estado.PASO:
		_accion_machacar = &""
	match e:
		Pesca.Estado.ESPERANDO:
			prompt.visible = false
			combo.visible = false
		Pesca.Estado.PASO:
			prompt.visible = true
		_:
			prompt.visible = false
			if e != Pesca.Estado.ENTRE_PASOS:
				cola_box.visible = false


func _on_pica(pez: PezData) -> void:
	resultado.visible = false
	# Un pez raro se anuncia: el destello de la picada sale de su color y más fuerte.
	if pez and pez.rareza >= PezData.Rareza.RARO:
		_color_destello = colores_rareza[mini(pez.rareza, colores_rareza.size() - 1)]
		_destello = destello_picada * (2.0 + pez.rareza - PezData.Rareza.RARO)
	else:
		_color_destello = Color.WHITE
		_destello = destello_picada


func _on_paso(p: Pesca.Paso, _i: int) -> void:
	var doble: bool = p.tipo == Pesca.Tipo.DOBLE
	var mash: bool = p.tipo == Pesca.Tipo.MACHACAR
	_pintar_tecla(tecla1, p.acciones[0])
	tecla2.visible = doble
	mas.visible = doble
	if doble:
		_pintar_tecla(tecla2, p.acciones[1])
	_accion_machacar = p.acciones[0] if mash else &""
	barra_machacar.visible = mash
	barra_tiempo.visible = true
	if mash:
		barra_machacar.max_value = p.pulsaciones
		barra_machacar.value = 0
	_pintar_cola()
	# Cuanto más dentro, más loco salta el botón por la pantalla (en modo flow, quieto para leer el ritmo).
	var salto: float = 0.0 if pesca.cola() > 0 else salto_prompt_maximo * _intensidad_objetivo * _intensidad_objetivo
	prompt.position = _pos_prompt + Vector2(randf_range(-salto, salto), randf_range(-salto, salto) * 0.5)
	teclas.pivot_offset = teclas.size * 0.5
	teclas.scale = Vector2.ONE * 1.5
	create_tween().tween_property(teclas, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _pintar_tecla(tecla: TextureRect, accion: StringName) -> void:
	tecla.texture = _icono(accion)
	tecla.set_meta("accion", accion)


## Modo flow: enseña los botones que vienen y los hace entrar desde la derecha.
func _pintar_cola() -> void:
	var n: int = pesca.cola() if pesca else 0
	cola_box.visible = n > 0
	if n == 0:
		return
	for k in cola_box.get_child_count():
		var hueco: Control = cola_box.get_child(k)
		var j: int = pesca.indice + 1 + k
		hueco.visible = k < n and j < pesca.pasos.size()
		if not hueco.visible:
			continue
		var p: Pesca.Paso = pesca.pasos[j]
		var a: TextureRect = hueco.get_node("A")
		var b: TextureRect = hueco.get_node("B")
		a.texture = _icono(p.acciones[0])
		b.visible = p.tipo == Pesca.Tipo.DOBLE
		if b.visible:
			b.texture = _icono(p.acciones[1])
	# Pegada a la tecla de ahora (más lejos si es doble).
	var ancho: float = (tecla1.size.x if not tecla2.visible else teclas.get_combined_minimum_size().x) * 0.5
	var x0: float = ancho + 32.0
	cola_box.position.x = x0 + desliz_cola
	create_tween().tween_property(cola_box, "position:x", x0, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## Icono dibujado de una acción para el último dispositivo usado (teclado o mando).
func _icono(accion: StringName, pulsada: bool = false) -> Texture2D:
	return IconosInput.icono(accion, pulsada)


## Caja de abajo a la derecha: lo que se puede hacer ahora. Si hay varias cosas, van alternando.
func _mostrar_acciones(dt: float) -> void:
	var lista: Array[String] = jugador.acciones() if jugador else []
	var viaje: Node = get_tree().get_first_node_in_group("viaje_spots")
	if viaje and viaje.texto_accion() != "":
		lista.append(viaje.texto_accion())
	caja_accion.visible = not lista.is_empty()
	if lista.is_empty():
		_t_accion = 0.0
		return
	if lista != _acciones:
		_acciones = lista
		_t_accion = 0.0
	_t_accion += dt
	var i: int = int(_t_accion / maxf(0.1, cambio_acciones)) % lista.size()
	if i != _i_accion and lista.size() > 1:
		# Al pasar a la siguiente acción, la caja parpadea como al aparecer.
		var entrada: Node = caja_accion.get_node_or_null("Entrada")
		if entrada:
			entrada.entrar()
	_i_accion = i
	_pista(caja_accion, lista[i])


## El botón de interactuar encima de la cabeza de con quien puedes hablar (o de lo que puedes usar).
func _icono_interactuar(dt: float) -> void:
	if icono_interactuar == null:
		return
	var p: Variant = _punto_interaccion()
	icono_interactuar.visible = p != null and camara != null
	if not icono_interactuar.visible:
		return
	_t_icono += dt
	var pulsada: bool = fmod(_t_icono, ritmo_icono * 2.0) >= ritmo_icono * 1.6
	icono_interactuar.texture = IconosInput.icono(_accion_icono, pulsada)
	var pantalla: Vector2 = popups.get_global_transform().affine_inverse() * camara.unproject_position(p)
	var bote: float = sin(_t_icono * 4.0) * bote_icono
	icono_interactuar.position = pantalla - icono_interactuar.size * 0.5 + Vector2(0.0, bote)


## Pesca base: el botón de picar bota encima de la cabeza mientras se puede pulsar.
func _icono_picar(_dt: float) -> void:
	if icono_picar == null:
		return
	icono_picar.visible = pesca != null and pesca.esperando_boton() and camara != null
	if not icono_picar.visible:
		return
	var pulsada: bool = fmod(_t_icono * 2.0, ritmo_icono * 2.0) >= ritmo_icono
	icono_picar.texture = IconosInput.icono(&"pesca_1", pulsada)
	var bote: float = absf(sin(_t_icono * 9.0)) * -bote_icono * 2.0
	icono_picar.position = _sobre_la_cabeza() - icono_picar.size * 0.5 + Vector2(0.0, -40.0 + bote)
	_t_icono += _dt


func _on_captura_base(c: Dictionary, p: PezData, manual: bool) -> void:
	_piezas.append(Vector2(_t_reloj, c.valor))
	var col: Color = colores_rareza[mini(p.rareza, colores_rareza.size() - 1)]
	var escala: float = escala_popup_base * (1.0 + 0.2 * p.rareza) * (1.0 if manual else 0.7)
	_popup_en("+" + Formato.dinero(c.valor), col, _sobre_la_cabeza() + Vector2(randf_range(-30, 30), -70), escala)
	if p.rareza >= PezData.Rareza.EPICO:
		_destello = maxf(_destello, destello_captura)


func _info_spot() -> void:
	if spot_info == null:
		return
	spot_info.visible = pesca != null and pesca.spot != null and pesca.estado != Pesca.Estado.RITMO
	if not spot_info.visible:
		_spot_mostrado = null
		return
	# Se rehace al cambiar de spot y luego cada medio segundo (la hora y la estación cambian despacio).
	if pesca.spot == _spot_mostrado and _t_reloj - _t_spot_info < 0.5:
		return
	_spot_mostrado = pesca.spot
	_t_spot_info = _t_reloj
	var viaje: Node = get_tree().get_first_node_in_group("viaje_spots")
	var r: Vector2i = viaje.resumen(pesca.spot) if viaje else Vector2i.ZERO
	var rd: RelojData = Juego.reloj_data
	var momento: String = ""
	if rd:
		momento = " · %s, %s" % [RelojData.ESTACIONES[rd.estacion(Juego.reloj)], "ocaso" if rd.es_ocaso(Juego.reloj) else ("noche" if rd.es_noche(Juego.reloj) else "día")]
	if r.x == 0:
		spot_info.text = "%s%s · ahora no pica nada aquí: prueba a otra hora o con mejor caña" % [pesca.spot.nombre, momento]
	else:
		spot_info.text = "%s%s · pican %d especies" % [pesca.spot.nombre, momento, r.x] + (", %d sin descubrir" % r.y if r.y > 0 else ", ¡todas descubiertas!")


## Ritmo de la pesca base en el panel: peces por minuto y lo que dan por minuto.
func _ritmo_pesca(dt: float) -> void:
	_t_reloj += dt
	while not _piezas.is_empty() and _t_reloj - _piezas[0].x > ventana_ritmo:
		_piezas.pop_front()
	if ritmo_pesca == null:
		return
	ritmo_pesca.visible = pesca != null and pesca.spot == null and pesca.estado != Pesca.Estado.INACTIVO
	var minutos: float = minf(ventana_ritmo, maxf(_t_reloj, 20.0)) / 60.0
	var total: float = 0.0
	for v: Vector2 in _piezas:
		total += v.y
	ritmo_pesca.text = "Pescando: %.1f peces/min · %s/min" % [_piezas.size() / minutos, Formato.dinero(total / minutos)]


## Duración del aviso de fin de visita de turistas.
@export var duracion_aviso_visita: float = 5.0

func _conectar_turistas() -> void:
	var t: Node = get_tree().get_first_node_in_group("turistas")
	if t and not t.visita_terminada.is_connected(_on_visita_terminada):
		t.visita_terminada.connect(_on_visita_terminada)


func _on_visita_terminada(turistas: int, platos: int, dinero: float) -> void:
	var panel: Control = get_node_or_null("Visita")
	if panel == null:
		return
	panel.get_node("Lista/Detalle").text = "%d turistas · %d platos vendidos" % [turistas, platos]
	panel.get_node("Lista/Dinero").text = "+%s" % Formato.dinero(dinero)
	panel.visible = true
	panel.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(duracion_aviso_visita - 0.5)
	tw.tween_property(panel, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func() -> void: panel.visible = false)


## Lo cosechado que llevas y la despensa del restaurante (solo si existen).
func _info_villa() -> void:
	if cosecha:
		var coral: int = int(float(Juego.materiales.get("coral", 0.0)))
		cosecha.visible = Juego.total_cosecha() > 0 or coral > 0
		if cosecha.visible:
			var partes: Array[String] = []
			for id: String in Juego.cosecha:
				var c: CultivoData = Juego.cultivos.get(StringName(id))
				partes.append("%d %s" % [Juego.cosecha[id], c.nombre.to_lower() if c else id])
			if coral > 0:
				partes.append("%d coral" % coral)
			cosecha.text = "Llevas: " + " · ".join(partes)
	if restaurante:
		var lista: Array[Node] = get_tree().get_nodes_in_group("restaurante")
		restaurante.visible = not lista.is_empty()
		if not lista.is_empty():
			if _turistas == null:
				_turistas = get_tree().get_first_node_in_group("turistas")
			var hay: bool = _turistas != null and _turistas.activa
			var partes: Array[String] = []
			for r: Node in lista:
				partes.append("%s %d/%d" % [r.nombre_corto, r.raciones(), int(r.capacidad())])
			restaurante.text = " · ".join(partes) + (" · ¡turistas!" if hay else "")


## Punto del mundo donde va el botón de interactuar, o null si no hay nada.
## Deja en `_accion_icono` qué botón dibujar.
func _punto_interaccion() -> Variant:
	_accion_icono = &"interactuar"
	if jugador and jugador.has_method("objetivo_interaccion"):
		var i: Interactuable = jugador.objetivo_interaccion()
		# Cosechando, el botón va encima del náufrago (no saltando de planta en planta).
		if i and i.accion == Interactuable.Accion.COSECHAR:
			return jugador.global_position + Vector3.UP * altura_icono_sentarse
		if i:
			return i.global_position + Vector3.UP * i.altura_icono
		if jugador.puede_sentarse() and not get_tree().paused:
			_accion_icono = &"cambiar_modo"
			return jugador.global_position + Vector3.UP * altura_icono_sentarse
	if barco and barco.puede_hablar() and not (celebracion and celebracion.celebrando) and not (pesca and pesca.en_curso()) \
			and not get_tree().paused:
		return barco.global_position + Vector3.UP * barco.altura_icono
	return null


## Pista "[E] Texto": la letra entre corchetes se cambia por el dibujo de su tecla.
func _pista(caja: PanelContainer, texto: String) -> void:
	var icono: TextureRect = caja.get_node("Fila/Icono")
	var etiqueta: Label = caja.get_node("Fila/Texto")
	var accion: StringName = &""
	if texto.begins_with("["):
		var fin: int = texto.find("]")
		accion = TECLA_A_ACCION.get(texto.substr(1, fin - 1), &"")
		texto = texto.substr(fin + 1).strip_edges()
	var tex: Texture2D = _icono(accion) if accion != &"" else null
	icono.texture = tex
	icono.visible = tex != null
	etiqueta.text = texto


func _input(event: InputEvent) -> void:
	# El último dispositivo usado decide qué dibujos salen.
	IconosInput.detectar(event)
	if event.is_action_pressed("ver_estado") and not get_tree().paused:
		info.visible = not info.visible
	_al_cambiar_dispositivo()


## Repinta las teclas si se ha cambiado de teclado a mando o al revés (aunque lo detectara un menú en pausa).
func _al_cambiar_dispositivo() -> void:
	if IconosInput.dispositivo != _dispositivo:
		_dispositivo = IconosInput.dispositivo
		for t: TextureRect in [tecla1, tecla2]:
			if t.has_meta("accion"):
				_pintar_tecla(t, t.get_meta("accion"))
		if cola_box.visible:
			_pintar_cola()


func _on_acierto(indice: int, _total: int) -> void:
	var k: float = clampf(float(indice) / float(maxi(1, pesca.stats.botones_intensidad_maxima)), 0.0, 1.0)
	_destello = lerpf(destello_acierto_min, destello_acierto_max, k)
	# En el carril (cañas rápida y tocha) el combo lo cuenta su propio panel.
	if pesca.estado == Pesca.Estado.RITMO:
		return
	combo.visible = indice >= 2
	combo.text = "x%d" % indice
	if not colores_racha.is_empty():
		combo.modulate = colores_racha[mini(pesca.stats.tramo_racha(indice), colores_racha.size() - 1)]
	combo.pivot_offset = combo.size * 0.5
	combo.scale = Vector2.ONE * (1.2 + k)
	create_tween().tween_property(combo, "scale", Vector2.ONE * (0.8 + 0.6 * k), 0.15)
	# Frases de acierto ("Genial", "¡Brutal!"...): quitadas por ahora, se retomarán más adelante.
	#var c: Color = color_numeros.lerp(color_perfecto, k)
	#_popup_en(_palabra(indice), c, prompt.position + teclas.position + teclas.size * 0.5 + Vector2(0, -120), 0.7 + 0.7 * k)


## Tramo de racha nuevo: destello y el contador pega un salto (sin textos).
func _on_racha(_tramo: int) -> void:
	_destello = maxf(_destello, destello_racha)
	combo.pivot_offset = combo.size * 0.5
	var k: float = pesca.intensidad()
	var tw := create_tween()
	tw.tween_property(combo, "scale", Vector2.ONE * (2.2 + k), 0.08)
	tw.tween_property(combo, "scale", Vector2.ONE * (0.8 + 0.6 * k), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _palabra(indice: int) -> String:
	var texto: String = palabras_acierto[0] if not palabras_acierto.is_empty() else ""
	for n in mini(palabras_acierto.size(), umbrales_palabras.size()):
		if indice >= umbrales_palabras[n]:
			texto = palabras_acierto[n]
	return texto

func _on_fallo() -> void:
	_equis()


func _on_machacar_progreso(golpes: int, _necesarios: int) -> void:
	barra_machacar.value = golpes
	_destello = maxf(_destello, destello_acierto_min)


func _on_machacar_fallido(escapa: bool) -> void:
	_equis(1.0 if escapa else 0.7)


func _on_capturado(c: Dictionary, pez: PezData) -> void:
	var col: Color = colores_rareza[mini(pez.rareza, colores_rareza.size() - 1)]
	# Nueva especie: es la primera que entra en la colección.
	var es_nuevo: bool = Juego.capturas_especie(pez.id) <= 1
	resultado.visible = true
	_t_carta = duracion_carta_nueva if es_nuevo else duracion_carta
	nuevo.visible = es_nuevo
	icono.texture = pez.icono
	nombre.text = pez.nombre
	nombre.modulate = col
	rareza.text = PezData.NOMBRES_RAREZA[pez.rareza]
	rareza.modulate = col
	detalle.text = "%s\n%s  ·  %s" % [Formato.calidad(c.calidad, c.perfecto), Formato.peso(c.peso), Formato.dinero(c.valor)]
	_destello = destello_perfecto if c.perfecto else destello_captura


## Caña rápida: un banco entero de la misma especie.
func _on_banco(pez: PezData, cantidad: int, valor: float) -> void:
	var col: Color = colores_rareza[mini(pez.rareza, colores_rareza.size() - 1)]
	var es_nuevo: bool = Juego.capturas_especie(pez.id) <= cantidad
	resultado.visible = true
	_t_carta = duracion_carta_nueva if es_nuevo else duracion_carta
	nuevo.visible = es_nuevo
	icono.texture = pez.icono
	nombre.text = "%s ×%d" % [pez.nombre, cantidad]
	nombre.modulate = col
	rareza.text = PezData.NOMBRES_RAREZA[pez.rareza]
	rareza.modulate = col
	detalle.text = "Un banco entero\n%s" % Formato.dinero(valor)
	_destello = destello_captura * 1.5


func _on_escapado(pez: PezData) -> void:
	_equis(1.4 if pez.rareza >= PezData.Rareza.RARO else 1.0)


## Texto rápido en pantalla (trucos, avisos).
func aviso_rapido(texto: String) -> void:
	_popup(texto, Color.WHITE, Vector2(0.5, 0.75), 0.8)


func _on_vendido(total: float) -> void:
	_popup_en("+" + Formato.dinero(total), color_perfecto, rublos.global_position + Vector2(rublos.size.x * 0.5, 80), 1.4)


func _equis(escala: float = 1.0) -> void:
	# Un fallo que hace escapar al pez lanza dos avisos seguidos: solo se ve una X.
	var ahora: int = Time.get_ticks_msec()
	if escena_x == null or ahora - _ultima_x < 300:
		return
	_ultima_x = ahora
	var x: Node = escena_x.instantiate()
	popups.add_child(x)
	x.mostrar(_sobre_la_cabeza(), escala * escala_x)


## Punto de pantalla (en coordenadas de Popups) encima de la cabeza del náufrago.
func _sobre_la_cabeza() -> Vector2:
	if camara == null:
		return popups.size * Vector2(0.5, 0.4)
	var p: Vector3
	if Juego.en_movimiento and jugador:
		p = jugador.global_position + Vector3.UP * altura_cabeza_andando
	elif cabeza:
		p = cabeza.global_position
	else:
		return popups.size * Vector2(0.5, 0.4)
	return popups.get_global_transform().affine_inverse() * camara.unproject_position(p)


## Popup en coordenadas relativas de pantalla (0..1).
func _popup(texto: String, color: Color, relativo: Vector2, escala: float) -> void:
	_popup_en(texto, color, popups.size * relativo, escala)


func _popup_en(texto: String, color: Color, centro: Vector2, escala: float) -> void:
	if escena_popup == null:
		return
	var p: Node = escena_popup.instantiate()
	popups.add_child(p)
	p.mostrar(texto, color, centro, escala)
