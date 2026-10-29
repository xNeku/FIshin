extends Sprite3D
## Reflejo de la luna en el mar por la noche: se queda arriba de la vista y cambia con la fase
## (una por noche; en luna nueva no se ve). Dibujos en art/mundo/luna/luna_<fase>.png.

@export var camara: Camera3D
@export var agua: Agua
## Dónde se pone respecto al punto del mar que mira la cámara (x a la derecha, z hacia el fondo).
@export var desplazamiento: Vector3 = Vector3(3.5, 0.0, -5.5)
## Un dibujo por fase (0 nueva ... 4 llena ... 7 menguante).
@export var fases: Array[Texture2D] = []
## Temblor del reflejo con las olas.
@export var temblor: float = 0.08

var _t: float = 0.0


func _process(delta: float) -> void:
	var rd: RelojData = Juego.reloj_data
	if rd == null or camara == null:
		visible = false
		return
	var brillo: float = rd.brillo_luna(Juego.reloj) * rd.factor_noche(Juego.reloj)
	visible = brillo > 0.01
	if not visible:
		return
	_t += delta
	var f: int = rd.fase_luna(Juego.reloj)
	if f < fases.size():
		texture = fases[f]
	modulate.a = clampf(0.35 + brillo * 0.65, 0.0, 1.0) * (1.0 - temblor + temblor * sin(_t * 3.1))
	# Punto del mar al que mira la cámara, y desde ahí hacia el fondo de la vista.
	var o: Vector3 = camara.global_position
	var dir: Vector3 = -camara.global_transform.basis.z
	var suelo: Vector3 = o + dir * (-o.y / minf(-0.01, dir.y))
	var p: Vector3 = suelo + desplazamiento
	if agua:
		agua.pegar(self, p, 0.04)
	else:
		global_position = Vector3(p.x, 0.04, p.z)
		rotation_degrees.x = -90.0
