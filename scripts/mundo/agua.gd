class_name Agua
extends MeshInstance3D
## El mar: lleva el tiempo de las olas del shader y dice a qué altura está el agua en cada punto,
## para que lo que flota (donut, corcho, sombras) vaya encima de la ola de verdad.
## Las olas son las mismas que en shaders/agua.gdshader (si cambias una, cambia la otra).

var tiempo: float = 0.0
var _material: ShaderMaterial


func _ready() -> void:
	_material = mesh.surface_get_material(0) as ShaderMaterial
	# Las olas siguen moviéndose con el menú abierto.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if _material == null:
		return
	tiempo += delta * _param("velocidad", 1.0)
	_material.set_shader_parameter("tiempo", tiempo)


## Altura del agua (en el mundo) en la posición x/z dada.
func altura(p: Vector3) -> float:
	return global_position.y + _olas(Vector2(p.x, p.z)).x * _param("altura_ola", 0.14)


## Inclinación del agua en x/z (derivadas de la altura).
func pendiente(p: Vector3) -> Vector2:
	var o: Vector3 = _olas(Vector2(p.x, p.z))
	var a: float = _param("altura_ola", 0.14)
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
