extends CanvasLayer
## HUD de pesca y dinero. Solo visual: lee la Pesca y el Juego.

@export var pesca: Pesca
@export var barco: BarcoComerciante
@export var celebracion: Node
@export var escena_popup: PackedScene
@export var velocidad_contador: float = 6.0
## Cuánto salta de sitio el botón al tope de intensidad (píxeles).
@export var salto_prompt_maximo: float = 220.0
@export var color_numeros: Color = Color("ff9a3c")
@export var color_flechas: Color = Color("4fd6ff")
@export var color_perfecto: Color = Color("ffd84a")
@export var color_fallo: Color = Color("ff4a4a")
@export var colores_rareza: Array[Color] = [Color("e8e8e8"), Color("4fa3ff"), Color("b56bff"), Color("ffb02e")]
## Frase de cada acierto según cuántos botones llevas: la palabra i sale desde el botón umbrales_palabras[i].
@export var palabras_acierto: Array[String] = ["Bien", "Genial", "¡Brutal!", "¡LOCURA!", "¡¡DIOS!!", "¡¡¡INHUMANO!!!"]
@export var umbrales_palabras: Array[int] = [1, 5, 10, 20, 35, 50]

@export_group("Destellos de pantalla (0..1)")
@export var destello_picada: float = 0.15
@export var destello_acierto_min: float = 0.05
@export var destello_acierto_max: float = 0.6
@export var destello_captura: float = 0.2
@export var destello_perfecto: float = 0.5

const TEXTO_TECLA: Dictionary = {
	&"pesca_1": "1", &"pesca_2": "2", &"pesca_3": "3", &"pesca_4": "4",
	&"pesca_arriba": "↑", &"pesca_abajo": "↓", &"pesca_izq": "←", &"pesca_der": "→",
}
const NOMBRES_RAREZA: Array[String] = ["Común", "Raro", "Extraño", "Legendario"]

@onready var efecto: ColorRect = $EfectoPantalla
@onready var rublos: Label = $Info/Rublos
@onready var barca: Label = $Info/Barca
@onready var cana: Label = $Info/Cana
@onready var cebo: Label = $Info/Cebo
@onready var estado: Label = $Estado
@onready var prompt: Control = $Prompt
@onready var teclas: Control = $Prompt/Teclas
@onready var tecla1: PanelContainer = $Prompt/Teclas/Tecla1
@onready var tecla2: PanelContainer = $Prompt/Teclas/Tecla2
@onready var mas: Label = $Prompt/Teclas/Mas
@onready var barra_tiempo: ProgressBar = $Prompt/BarraTiempo
@onready var machacar: Label = $Prompt/Machacar
@onready var barra_machacar: ProgressBar = $Prompt/BarraMachacar
@onready var combo: Label = $Combo
@onready var popups: Control = $Popups
@onready var resultado: PanelContainer = $Resultado
@onready var icono: TextureRect = $Resultado/Margen/Fila/Icono
@onready var nombre: Label = $Resultado/Margen/Fila/Textos/Nombre
@onready var detalle: Label = $Resultado/Margen/Fila/Textos/Detalle
@onready var aviso: Label = $Aviso

var _rublos_mostrados: float = 0.0
var _intensidad_objetivo: float = 0.0
var _intensidad: float = 0.0
var _destello: float = 0.0
var _pos_prompt: Vector2
var _mat: ShaderMaterial


func _ready() -> void:
	_mat = efecto.material as ShaderMaterial
	_rublos_mostrados = Juego.rublos
	_pos_prompt = prompt.position
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
		pesca.pez_escapado.connect(_on_escapado)
		pesca.barca_llena.connect(_on_barca_llena)
		pesca.intensidad_cambiada.connect(func(i: float) -> void: _intensidad_objetivo = i)
		_on_estado(pesca.estado)
	if celebracion:
		celebracion.empezada.connect(func(pez: PezData) -> void:
			estado.text = "¡%s!" % pez.nombre.to_upper()
			combo.visible = false
			_popup("¡%s!" % pez.nombre.to_upper(), colores_rareza[pez.rareza], Vector2(0.5, 0.18), 2.0))
	if barco:
		barco.vendido.connect(_on_vendido)
		barco.llegado.connect(func() -> void: _popup("¡Ha llegado un comerciante!", colores_rareza[1], Vector2(0.5, 0.3), 0.8))


func _process(delta: float) -> void:
	var dt: float = Juego.delta_real(delta)
	_rublos_mostrados = lerpf(_rublos_mostrados, Juego.rublos, 1.0 - exp(-velocidad_contador * dt))
	if absf(_rublos_mostrados - Juego.rublos) < 0.05:
		_rublos_mostrados = Juego.rublos
	rublos.text = Formato.dinero(_rublos_mostrados)
	barca.text = "Barca: %d/%d huecos · %d peces (%s)" % [Juego.huecos_usados(), Juego.huecos, Juego.capturas.size(), Formato.dinero(Juego.valor_inventario())]
	cana.text = Juego.cana().nombre
	cebo.visible = not Juego.cebo.is_empty()
	if cebo.visible:
		cebo.text = "Cebo: %d pescas" % int(Juego.cebo.pescas)
	aviso.visible = barco != null and barco.puede_hablar()
	if aviso.visible:
		aviso.text = "[E] Hablar con el comerciante"

	var p: Pesca.Paso = pesca.paso_actual() if pesca else null
	if p:
		barra_tiempo.value = pesca.tiempo_restante / p.tiempo * 100.0

	_intensidad = lerpf(_intensidad, _intensidad_objetivo, 1.0 - exp(-4.0 * dt))
	_destello = lerpf(_destello, 0.0, 1.0 - exp(-8.0 * dt))
	if _mat:
		_mat.set_shader_parameter("intensidad", _intensidad)
		_mat.set_shader_parameter("destello", _destello)


func _on_estado(e: Pesca.Estado) -> void:
	match e:
		Pesca.Estado.ESPERANDO:
			estado.text = "Esperando que piquen..."
			prompt.visible = false
			combo.visible = false
		Pesca.Estado.PASO:
			prompt.visible = true
		_:
			prompt.visible = false


func _on_pica(_pez: PezData) -> void:
	estado.text = "¡¡HA PICADO!!"
	resultado.visible = false
	_destello = destello_picada
	_popup("¡PICA!", Color.WHITE, Vector2(0.5, 0.35), 1.0)


func _on_paso(p: Pesca.Paso, _i: int) -> void:
	var doble: bool = p.tipo == Pesca.Tipo.DOBLE
	var mash: bool = p.tipo == Pesca.Tipo.MACHACAR
	_pintar_tecla(tecla1, p.acciones[0])
	tecla2.visible = doble
	mas.visible = doble
	if doble:
		_pintar_tecla(tecla2, p.acciones[1])
	machacar.visible = mash
	barra_machacar.visible = mash
	barra_tiempo.visible = true
	if mash:
		barra_machacar.max_value = p.pulsaciones
		barra_machacar.value = 0
		machacar.text = "¡MACHACA %s!" % TEXTO_TECLA.get(p.acciones[0], "?")
	# Cuanto más dentro, más loco salta el botón por la pantalla.
	var salto: float = salto_prompt_maximo * _intensidad_objetivo * _intensidad_objetivo
	prompt.position = _pos_prompt + Vector2(randf_range(-salto, salto), randf_range(-salto, salto) * 0.5)
	teclas.pivot_offset = teclas.size * 0.5
	teclas.scale = Vector2.ONE * 1.5
	create_tween().tween_property(teclas, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _pintar_tecla(panel: PanelContainer, accion: StringName) -> void:
	var texto: Label = panel.get_node("Texto")
	texto.text = TEXTO_TECLA.get(accion, "?")
	panel.self_modulate = color_flechas if accion in Pesca.FLECHAS else color_numeros


func _on_acierto(indice: int, _total: int) -> void:
	var k: float = clampf(float(indice) / float(maxi(1, pesca.stats.botones_intensidad_maxima)), 0.0, 1.0)
	_destello = lerpf(destello_acierto_min, destello_acierto_max, k)
	combo.visible = indice >= 2
	combo.text = "x%d" % indice
	combo.pivot_offset = combo.size * 0.5
	combo.scale = Vector2.ONE * (1.2 + k)
	create_tween().tween_property(combo, "scale", Vector2.ONE * (0.8 + 0.6 * k), 0.15)
	var c: Color = color_numeros.lerp(color_perfecto, k)
	_popup_en(_palabra(indice), c, prompt.position + teclas.position + teclas.size * 0.5 + Vector2(0, -120), 0.7 + 0.7 * k)


func _palabra(indice: int) -> String:
	var texto: String = palabras_acierto[0] if not palabras_acierto.is_empty() else ""
	for n in mini(palabras_acierto.size(), umbrales_palabras.size()):
		if indice >= umbrales_palabras[n]:
			texto = palabras_acierto[n]
	return texto

func _on_fallo() -> void:
	_popup_en("¡FALLO!", color_fallo, prompt.position + teclas.position + teclas.size * 0.5, 1.0)


func _on_machacar_progreso(golpes: int, _necesarios: int) -> void:
	barra_machacar.value = golpes
	_destello = maxf(_destello, destello_acierto_min)


func _on_machacar_fallido(escapa: bool) -> void:
	_popup("¡Se suelta!" if escapa else "Pierde fuerza...", color_fallo, Vector2(0.5, 0.45), 1.0)


func _on_capturado(c: Dictionary, pez: PezData) -> void:
	var col: Color = colores_rareza[pez.rareza]
	if not (celebracion and celebracion.celebrando):
		estado.text = "¡Capturado!"
	resultado.visible = true
	icono.texture = pez.icono
	nombre.text = "%s  ·  %s" % [pez.nombre, NOMBRES_RAREZA[pez.rareza]]
	nombre.modulate = col
	detalle.text = "%s  ·  %s  ·  %s" % [Formato.calidad(c.calidad, c.perfecto), Formato.peso(c.peso), Formato.dinero(c.valor)]
	_destello = destello_perfecto if c.perfecto else destello_captura
	if c.perfecto:
		_popup("¡¡PERFECTO!!", color_perfecto, Vector2(0.5, 0.4), 1.5)
	else:
		_popup(Formato.calidad(c.calidad, false), col, Vector2(0.5, 0.4), 1.0)


func _on_escapado(pez: PezData) -> void:
	estado.text = "Se ha escapado..."
	if pez.rareza >= PezData.Rareza.RARO:
		_popup("Era un %s..." % pez.nombre, colores_rareza[pez.rareza], Vector2(0.5, 0.4), 1.2)
	else:
		_popup("Se escapó", color_fallo, Vector2(0.5, 0.4), 1.0)


func _on_barca_llena(pez: PezData) -> void:
	estado.text = "¡Barca llena!"
	_popup("Sin hueco: sueltas el %s" % pez.nombre, color_fallo, Vector2(0.5, 0.4), 1.1)


func _on_vendido(total: float) -> void:
	_popup_en("+" + Formato.dinero(total), color_perfecto, rublos.global_position + Vector2(rublos.size.x * 0.5, 80), 1.4)


## Popup en coordenadas relativas de pantalla (0..1).
func _popup(texto: String, color: Color, relativo: Vector2, escala: float) -> void:
	_popup_en(texto, color, popups.size * relativo, escala)


func _popup_en(texto: String, color: Color, centro: Vector2, escala: float) -> void:
	if escena_popup == null:
		return
	var p: Node = escena_popup.instantiate()
	popups.add_child(p)
	p.mostrar(texto, color, centro, escala)
