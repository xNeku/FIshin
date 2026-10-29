extends Node
## Autoload "Vuelos": peces, dinero o cubos que vuelan en parábola de un sitio a otro, uno a uno.
## Origen y destino pueden moverse mientras tanto: cada pieza persigue a su destino.

@export var escena_pieza: PackedScene
@export_group("Dinero")
## Valor de cada tipo de pieza: moneda, billete, fajo, saco...
@export var denominaciones: Array[float] = [10.0, 100.0, 1000.0, 10000.0]
@export var texturas_dinero: Array[Texture2D] = []
## Nunca vuelan más piezas que esto: si hay mucho dinero, se usan piezas de más valor.
@export var max_piezas_dinero: int = 25
@export_group("Peces")
## Si hay más peces, cada pieza que vuela representa varios.
@export var max_piezas_peces: int = 30
@export_group("Vuelo")
@export var intervalo: float = 0.09
## Tope de tiempo para que salgan todas las piezas de una tanda.
@export var duracion_maxima: float = 2.2
@export var tiempo_vuelo: float = 0.55
@export var arco: float = 1.6
## Altura del punto de salida y llegada sobre los pies.
@export var altura: float = 1.1
@export var subida_tono: float = 0.02

@onready var sfx_moneda: AudioStreamPlayer = $SfxMoneda
@onready var sfx_pez: AudioStreamPlayer = $SfxPez


## Lanza una pieza por textura. al_llegar(i) se llama cuando aterriza la i-ésima. Se puede esperar con await.
func enviar(desde: Node3D, hacia: Node3D, texturas: Array[Texture2D], al_llegar: Callable = Callable(), sfx: AudioStreamPlayer = null, escala: float = 1.0) -> void:
	var n: int = texturas.size()
	if n == 0:
		return
	var paso: float = minf(intervalo, duracion_maxima / n)
	var pendientes: Array[int] = [n]
	var ultimo_origen: Vector3 = _punto(desde, Vector3.ZERO)
	for i in n:
		ultimo_origen = _punto(desde, ultimo_origen)
		_lanzar(ultimo_origen, hacia, texturas[i], i, n, al_llegar, sfx, pendientes, escala)
		if i < n - 1:
			await get_tree().create_timer(paso, false).timeout
	while pendientes[0] > 0:
		await get_tree().process_frame


## Dinero de 'desde' a 'hacia'. Si sumar, cada pieza suma su valor al llegar (el contador sube pieza a pieza).
func enviar_dinero(desde: Node3D, hacia: Node3D, cantidad: float, sumar: bool = true) -> void:
	var valores: Array[float] = repartir(cantidad)
	var texturas: Array[Texture2D] = []
	for v: float in valores:
		texturas.append(_textura_dinero(v))
	if sumar:
		for v: float in valores:
			Juego.dinero_en_camino += v
	await enviar(desde, hacia, texturas, func(i: int) -> void:
		if sumar:
			Juego.dinero_en_camino -= valores[i]
			Juego.sumar_rublos(valores[i]), sfx_moneda)


## Capturas de 'desde' a 'hacia'. al_llegar(grupo) recibe las capturas que representa cada pieza.
func enviar_peces(desde: Node3D, hacia: Node3D, capturas: Array[Dictionary], al_llegar: Callable = Callable()) -> void:
	var por_pieza: int = ceili(float(capturas.size()) / float(max_piezas_peces))
	var grupos: Array = []
	var texturas: Array[Texture2D] = []
	for i in range(0, capturas.size(), por_pieza):
		var g: Array[Dictionary] = capturas.slice(i, i + por_pieza)
		grupos.append(g)
		texturas.append(Juego.pez_data(g[0].id).icono)
	await enviar(desde, hacia, texturas, func(i: int) -> void:
		if al_llegar.is_valid():
			al_llegar.call(grupos[i]), sfx_pez, 1.3)


## Parte una cantidad en piezas de la denominación más pequeña que no pase de max_piezas_dinero.
func repartir(cantidad: float) -> Array[float]:
	var r: Array[float] = []
	if cantidad <= 0.0 or denominaciones.is_empty():
		return r
	var d: float = denominaciones.back()
	for den: float in denominaciones:
		if ceilf(cantidad / den) <= max_piezas_dinero:
			d = den
			break
	var n: int = maxi(1, ceili(cantidad / d))
	for i in n - 1:
		r.append(d)
	r.append(cantidad - d * (n - 1))
	return r


func _textura_dinero(valor: float) -> Texture2D:
	var t: Texture2D = texturas_dinero[0] if not texturas_dinero.is_empty() else null
	for i in mini(denominaciones.size(), texturas_dinero.size()):
		if valor >= denominaciones[i] * 0.999:
			t = texturas_dinero[i]
	return t


func _punto(n: Node3D, si_no: Vector3) -> Vector3:
	return n.global_position + Vector3.UP * altura if is_instance_valid(n) else si_no


func _lanzar(inicio: Vector3, hacia: Node3D, textura: Texture2D, i: int, n: int, al_llegar: Callable, sfx: AudioStreamPlayer, pendientes: Array[int], escala: float) -> void:
	var pieza: Sprite3D = escena_pieza.instantiate()
	pieza.texture = textura
	add_child(pieza)
	pieza.global_position = inicio
	var base: Vector3 = pieza.scale * escala
	var destino: Vector3 = _punto(hacia, inicio)
	var tw := create_tween()
	tw.tween_method(func(k: float) -> void:
		destino = _punto(hacia, destino)
		pieza.global_position = inicio.lerp(destino, k) + Vector3.UP * sin(k * PI) * arco
		pieza.scale = base * (0.7 + 0.5 * sin(k * PI)), 0.0, 1.0, tiempo_vuelo).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
	pieza.queue_free()
	if sfx:
		sfx.pitch_scale = 1.0 + subida_tono * float(i) * 20.0 / maxf(20.0, float(n))
		sfx.play()
	if al_llegar.is_valid():
		al_llegar.call(i)
	pendientes[0] -= 1
