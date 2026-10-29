class_name ConexionArbol
extends Line2D
## Camino entre dos nodos del árbol. Se llena de agua cuando compras el nodo al que lleva.
## Se instancia sola desde conexion_arbol.tscn según los requisitos de cada nodo.

var hijo: NodoArbolData
var _material: ShaderMaterial
var _lleno: float = 0.0
var _tw: Tween


func _ready() -> void:
	_material = (material as ShaderMaterial).duplicate()
	material = _material


## Traza el camino en zigzag (sale por el eje de la rama y luego cruza).
func trazar(desde: Vector2, hasta: Vector2, vertical: bool, color: Color) -> void:
	var medio: Vector2 = (desde + hasta) * 0.5
	var pts: PackedVector2Array
	if vertical:
		pts = [desde, Vector2(desde.x, medio.y), Vector2(hasta.x, medio.y), hasta]
	else:
		pts = [desde, Vector2(medio.x, desde.y), Vector2(medio.x, hasta.y), hasta]
	points = pts
	var largo: float = 0.0
	for i in range(1, pts.size()):
		largo += pts[i].distance_to(pts[i - 1])
	_material.set_shader_parameter("largo", largo)
	_material.set_shader_parameter("color_agua", color)


func poner(lleno: bool, disponible: bool) -> void:
	if _tw and _tw.is_valid():
		_tw.kill()
	_lleno = 1.0 if lleno else 0.0
	_material.set_shader_parameter("lleno", _lleno)
	_material.set_shader_parameter("goteo", 1.0 if (disponible and not lleno) else 0.0)


## El agua corre por el camino. Devuelve el tween para esperar a que llegue.
func llenar(duracion: float = 0.45, retraso: float = 0.0) -> Tween:
	if _tw and _tw.is_valid():
		_tw.kill()
	_material.set_shader_parameter("goteo", 0.0)
	_material.set_shader_parameter("lleno", 0.0)
	_tw = create_tween()
	_tw.tween_interval(retraso)
	_tw.tween_method(func(k: float) -> void: _material.set_shader_parameter("lleno", k), 0.0, 1.0, duracion)
	return _tw
