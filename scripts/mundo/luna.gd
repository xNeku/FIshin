extends Sprite3D
## Reflejo de la luna en el mar por la noche. Cruza la vista de izquierda a derecha según avanza
## la noche, titila con las olas y cambia con la fase (una por noche; en luna nueva no se ve).
## Dibujos: <carpeta>/luna_<fase>_<fotograma>.png (fase 0 nueva ... 4 llena ... 7 menguante).

@export var camara: Camera3D
@export var agua: Agua
@export_dir var carpeta: String = "res://art/mundo/luna"
@export var fotogramas: int = 3
## Cada cuánto cambia el brillo de la estela (segundos).
@export var ritmo_brillo: float = 0.35
## Recorrido en x a lo largo de la noche, respecto al punto del mar que mira la cámara.
@export var x_salida: float = -9.0
@export var x_puesta: float = 9.0
## Distancia hacia el fondo de la vista: al salir y a medianoche (más lejos, como más alta).
@export var z_horizonte: float = -4.5
@export var z_medianoche: float = -6.5

var _t: float = 0.0
var _texturas: Dictionary = {}


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
	var fase: int = rd.fase_luna(Juego.reloj)
	texture = _textura(fase, int(_t / maxf(0.05, ritmo_brillo)) % maxi(1, fotogramas))
	modulate.a = clampf(0.4 + brillo * 0.6, 0.0, 1.0)
	# Avance de la noche: 0 al anochecer, 1 al amanecer.
	var p: float = clampf((rd.momento(Juego.reloj) - rd.duracion_dia) / rd.duracion_noche, 0.0, 1.0)
	var o: Vector3 = camara.global_position
	var dir: Vector3 = -camara.global_transform.basis.z
	var suelo: Vector3 = o + dir * (-o.y / minf(-0.01, dir.y))
	var punto: Vector3 = suelo + Vector3(lerpf(x_salida, x_puesta, p), 0.0, lerpf(z_horizonte, z_medianoche, sin(p * PI)))
	# Plano, sin inclinarse con la ola: una estela tan larga inclinada levantaba las puntas por encima
	# de islas y casas. El material la recorta para que solo se vea sobre el agua.
	var y: float = agua.altura(punto) if agua else 0.0
	global_transform = Transform3D(Basis(Vector3.RIGHT, -PI * 0.5) * Basis.from_scale(scale), Vector3(punto.x, y + 0.04, punto.z))
	var m: ShaderMaterial = material_override as ShaderMaterial
	if m:
		m.set_shader_parameter("textura", texture)
		m.set_shader_parameter("tinte", modulate)
		if agua and agua.textura_tierra:
			m.set_shader_parameter("mascara_tierra", agua.textura_tierra)
			m.set_shader_parameter("radio_mascara", float(agua.radio_mascara))


func _textura(fase: int, fotograma: int) -> Texture2D:
	var ruta: String = "%s/luna_%d_%d.png" % [carpeta, fase, fotograma]
	if not _texturas.has(ruta):
		_texturas[ruta] = load(ruta) if ResourceLoader.exists(ruta) else null
	return _texturas[ruta]
