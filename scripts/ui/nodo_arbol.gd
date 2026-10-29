class_name NodoArbol
extends Button
## Un nodo del árbol en pantalla. Se coloca a mano en scenes/ui/arbol.tscn (muévelo donde quieras)
## y se le asigna su NodoArbolData. Solo visual: el árbol (arbol.gd) decide qué pasa al pulsarlo.

signal elegido(nodo: NodoArbol)
signal accionado(nodo: NodoArbol)

enum Estado { OCULTO, BLOQUEADO, DISPONIBLE, COMPRADO, MAX }

@export var datos: NodoArbolData
@export var textura_clave: Texture2D
@export var icono_candado: Texture2D
@export_group("Colores")
@export var color_bloqueado: Color = Color(0.28, 0.29, 0.36)
@export var color_max: Color = Color(1.0, 0.89, 0.16)
@export_group("Animación")
## Latido de los que puedes comprar ya.
@export var latido: float = 0.25
@export var velocidad_latido: float = 4.0

@onready var marco: NinePatchRect = $Marco
@onready var icono_rect: TextureRect = $Icono
@onready var nivel: Label = $Nivel
@onready var seleccion: NinePatchRect = $Seleccion

var estado: Estado = Estado.BLOQUEADO
var _color: Color = Color.WHITE
var _asequible: bool = false
var _t: float = 0.0
var _tw: Tween


func _ready() -> void:
	pivot_offset = size * 0.5
	seleccion.visible = false
	if datos and datos.clave and textura_clave:
		marco.texture = textura_clave
		marco.patch_margin_left = 24
		marco.patch_margin_top = 24
		marco.patch_margin_right = 24
		marco.patch_margin_bottom = 24
	mouse_entered.connect(func() -> void: elegido.emit(self))
	focus_entered.connect(func() -> void:
		seleccion.visible = true
		elegido.emit(self))
	focus_exited.connect(func() -> void: seleccion.visible = false)
	pressed.connect(func() -> void: accionado.emit(self))
	refrescar()


func centro() -> Vector2:
	return position + size * 0.5


func refrescar() -> void:
	if datos == null:
		return
	var nv: int = Juego.nivel_habilidad(datos)
	var rama: Color = datos.rama.color if datos.rama else Color.WHITE
	var por_flag: bool = datos.requiere_flag != "" and not Juego.flags.get(datos.requiere_flag, false)
	if nv >= datos.niveles:
		estado = Estado.MAX
	elif nv > 0:
		estado = Estado.COMPRADO
	elif Juego.habilidad_disponible(datos):
		estado = Estado.DISPONIBLE
	else:
		estado = Estado.BLOQUEADO
	_asequible = estado != Estado.MAX and Juego.motivo_no_mejorar(datos) == ""
	icono_rect.texture = icono_candado if por_flag and nv == 0 else datos.icono
	match estado:
		Estado.BLOQUEADO:
			_color = color_bloqueado
			icono_rect.modulate = color_bloqueado.lerp(rama, 0.25)
		Estado.DISPONIBLE:
			_color = rama.darkened(0.25)
			icono_rect.modulate = rama
		Estado.COMPRADO:
			_color = rama
			icono_rect.modulate = rama.lightened(0.3)
		Estado.MAX:
			_color = color_max
			icono_rect.modulate = rama.lightened(0.4)
	marco.self_modulate = _color
	nivel.visible = datos.niveles > 1 and estado != Estado.BLOQUEADO
	nivel.text = "%d/%d" % [nv, datos.niveles]
	nivel.modulate = color_max if estado == Estado.MAX else Color.WHITE


func _process(delta: float) -> void:
	_t += delta
	if _asequible:
		# Lo que ya puedes pagar late suave.
		var k: float = 0.5 + 0.5 * sin(_t * velocidad_latido)
		marco.self_modulate = _color.lightened(latido * k)
	elif estado == Estado.MAX:
		marco.self_modulate = _color.lightened(0.15 * (0.5 + 0.5 * sin(_t * 2.0)))


## Salto al comprar.
func pop() -> void:
	_matar_tween()
	scale = Vector2.ONE * 1.35
	modulate = Color(2.0, 2.0, 2.0)
	_tw = create_tween().set_parallel(true)
	_tw.tween_property(self, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tw.tween_property(self, "modulate", Color.WHITE, 0.3)


## Temblor cuando no se puede comprar.
func sacudir() -> void:
	_matar_tween()
	var x0: float = position.x
	_tw = create_tween()
	_tw.tween_method(func(k: float) -> void: position.x = x0 + sin(k * 30.0) * 8.0 * (1.0 - k), 0.0, 1.0, 0.3)
	_tw.tween_callback(func() -> void: position.x = x0)


## Parpadeo cuando queda disponible.
func despertar(retraso: float = 0.0) -> void:
	_matar_tween()
	_tw = create_tween()
	_tw.tween_interval(retraso)
	for i in 3:
		_tw.tween_property(self, "modulate", Color(2.2, 2.2, 2.2), 0.06)
		_tw.tween_property(self, "modulate", Color.WHITE, 0.1)


func _matar_tween() -> void:
	if _tw and _tw.is_valid():
		_tw.kill()
	scale = Vector2.ONE
	modulate = Color.WHITE
