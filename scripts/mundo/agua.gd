class_name Agua
extends MeshInstance3D
## El mar: lleva el tiempo de las olas del shader y dice a qué altura está el agua en cada punto,
## para que lo que flota (donut, corcho, sombras) vaya encima de la ola de verdad.
## Las olas son las mismas que en shaders/agua.gdshader (si cambias una, cambia la otra).

## Para saber dónde hay tierra: pegado a la costa el agua se calma (si no, con tormenta se mete en las islas).
@export var mundo: Node
## Casillas a cada lado de la barca que cubre la máscara de tierra.
@export var radio_mascara: int = 24

var tiempo: float = 0.0
var _material: ShaderMaterial
var _mascara: Image
## La máscara como textura, para otros shaders que no deben pintar sobre tierra (reflejo de la luna).
var textura_tierra: ImageTexture


func _ready() -> void:
	_material = mesh.surface_get_material(0) as ShaderMaterial
	# Las olas siguen moviéndose con el menú abierto.
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("agua")
	poner_bandas(Juego.opcion("agua_bandas", true))
	if mundo:
		mundo.aparicion_llegada.connect(func(_d: AparicionData) -> void: actualizar_tierra())
		mundo.aparicion_terminada.connect(func(_d: AparicionData) -> void: actualizar_tierra())
	actualizar_tierra.call_deferred()


## Agua con bandas de color (estilo) o de un solo tono (realista). Se elige en Opciones.
func poner_bandas(si: bool) -> void:
	if _material:
		_material.set_shader_parameter("estilo_bandas", 1.0 if si else 0.0)


## Rehace la máscara de tierra con las casillas de todo lo que ya ha llegado.
func actualizar_tierra() -> void:
	if _material == null or mundo == null:
		return
	var n: int = radio_mascara * 2 + 1
	_mascara = Image.create(n, n, false, Image.FORMAT_R8)
	for a: AparicionData in mundo.apariciones:
		if not mundo.ya_aparecio(a):
			continue
		for c: Vector2i in a.celdas:
			var px: Vector2i = Vector2i(c.x + radio_mascara, -c.y + radio_mascara)
			if px.x >= 0 and px.y >= 0 and px.x < n and px.y < n:
				_mascara.set_pixelv(px, Color.WHITE)
	textura_tierra = ImageTexture.create_from_image(_mascara)
	_material.set_shader_parameter("mascara_tierra", textura_tierra)
	_material.set_shader_parameter("radio_mascara", float(radio_mascara))
	_material.set_shader_parameter("tamano_celda", float(mundo.tamano_celda))


## 1 en mar abierto, 0 en el borde de una isla (misma cuenta que el shader, con filtrado bilineal).
func atenuacion(p: Vector3) -> float:
	if _mascara == null or mundo == null:
		return 1.0
	var n: int = _mascara.get_width()
	var f: Vector2 = Vector2(p.x, p.z) / float(mundo.tamano_celda) + Vector2.ONE * float(radio_mascara)
	var i: Vector2i = Vector2i(floori(f.x), floori(f.y))
	var t: Vector2 = f - Vector2(i)
	var m: float = 0.0
	for d: Vector2i in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]:
		var q: Vector2i = i + d
		if q.x < 0 or q.y < 0 or q.x >= n or q.y >= n:
			continue
		var w: float = (t.x if d.x == 1 else 1.0 - t.x) * (t.y if d.y == 1 else 1.0 - t.y)
		m += _mascara.get_pixelv(q).r * w
	return 1.0 - smoothstep(0.0, 0.5, m) * _param("calma_costa", 1.0)


func _process(delta: float) -> void:
	if _material == null:
		return
	tiempo += delta * _param("velocidad", 1.0)
	_material.set_shader_parameter("tiempo", tiempo)


## Altura del agua (en el mundo) en la posición x/z dada.
func altura(p: Vector3) -> float:
	return global_position.y + _olas(Vector2(p.x, p.z)).x * _param("altura_ola", 0.14) * atenuacion(p)


## Inclinación del agua en x/z (derivadas de la altura).
func pendiente(p: Vector3) -> Vector2:
	var o: Vector3 = _olas(Vector2(p.x, p.z))
	var a: float = _param("altura_ola", 0.14) * atenuacion(p)
	return Vector2(o.y * a, o.z * a)


func _param(nombre: StringName, defecto: float) -> float:
	var v: Variant = _material.get_shader_parameter(nombre) if _material else null
	return float(v) if v != null else defecto


func _onda(p: Vector2, dir: Vector2, frec: float, amp: float, vel: float) -> Vector3:
	var fase: float = dir.dot(p) * frec + tiempo * vel
	return Vector3(sin(fase) * amp, cos(fase) * amp * frec * dir.x, cos(fase) * amp * frec * dir.y)


func _olas(p: Vector2) -> Vector3:
	var e: float = _param("escala_ola", 0.42)
	var r := Vector3.ZERO
	r += _onda(p, Vector2(1.0, 0.35).normalized(), e, 0.55, 1.0)
	r += _onda(p, Vector2(-0.4, 1.0).normalized(), e * 1.37, 0.3, 1.3)
	r += _onda(p, Vector2(0.7, -0.8).normalized(), e * 2.3, 0.12, 1.9)
	r += _onda(p, Vector2(-1.0, -0.2).normalized(), e * 3.1, 0.06, 2.6)
	return r


## Tumba un sprite plano sobre el agua en p (sombras, espuma, ondas), inclinado como la ola.
func pegar(nodo: Node3D, p: Vector3, alto: float) -> void:
	var pend: Vector2 = pendiente(p)
	var normal := Vector3(-pend.x, 1.0, -pend.y).normalized()
	var b := Basis(Quaternion(Vector3.UP, normal)) * Basis(Vector3.RIGHT, -PI * 0.5) * Basis.from_scale(nodo.scale)
	nodo.global_transform = Transform3D(b, Vector3(p.x, altura(p) + alto, p.z))
