extends Node3D
## El mundo que crece: vigila las condiciones de cada AparicionData y la trae con su animación.
## Lo que ya apareció se guarda en Juego.flags y se coloca directamente al cargar.

signal aparicion_empezada(datos: AparicionData)
## Momento de llegada (toca el agua o termina de atracar).
signal aparicion_llegada(datos: AparicionData)
signal aparicion_terminada(datos: AparicionData)

@export var apariciones: Array[AparicionData] = []
@export var pesca: Pesca
@export var camara: CamaraPesca
@export var celebracion: Node
## Sombra que crece en el agua antes de que algo caiga del cielo.
@export var sombra: MeshInstance3D
@export var sfx_mar: AudioStreamPlayer
@export var sfx_caida: AudioStreamPlayer
@export var sfx_impacto: AudioStreamPlayer
@export var tamano_celda: float = 2.0

@export_group("Llegada por mar")
@export var distancia_mar: float = 35.0
@export var duracion_mar: float = 4.5
@export var hundida_mar: float = 0.6
@export var balanceo_mar_grados: float = 5.0

@export_group("Caída del cielo")
@export var altura_cielo: float = 45.0
## Tiempo de sombra creciendo antes de que se vea caer.
@export var aviso_cielo: float = 1.6
@export var duracion_caida: float = 1.1
@export var giro_caida_grados: float = 200.0
@export var golpe_impacto: float = 0.9
@export var pausa_impacto: float = 0.12
@export var escala_sombra: float = 7.0
## Tiempo mirando la isla tras caer.
@export var reposo_cielo: float = 2.2

var _ocupado: bool = false


func _ready() -> void:
	if sombra:
		sombra.visible = false
	for a: AparicionData in apariciones:
		if ya_aparecio(a):
			var n: Node3D = _instanciar(a)
			if n.has_method("colocada"):
				n.colocada()


func _process(_delta: float) -> void:
	if _ocupado or (pesca and pesca.en_curso()) or (celebracion and celebracion.celebrando):
		return
	var pendientes: Array[AparicionData] = apariciones.filter(func(a: AparicionData) -> bool: return not ya_aparecio(a) and cumple(a))
	if pendientes.is_empty():
		return
	pendientes.sort_custom(func(a: AparicionData, b: AparicionData) -> bool: return a.orden < b.orden)
	traer(pendientes[0])


func ya_aparecio(a: AparicionData) -> bool:
	return Juego.flags.get("aparecido_" + String(a.id), false)


func cumple(a: AparicionData) -> bool:
	match a.condicion:
		AparicionData.Condicion.PECES_PESCADOS:
			return Juego.stats.peces_pescados >= a.valor
		AparicionData.Condicion.RUBLOS_TOTALES:
			return Juego.rublos_totales >= a.valor
	return false


func celda_a_mundo(c: Vector2i) -> Vector3:
	return Vector3(c.x * tamano_celda, 0.0, -c.y * tamano_celda)


func traer(a: AparicionData) -> void:
	_ocupado = true
	Juego.flags["aparecido_" + String(a.id)] = true
	Juego.guardar()
	var n: Node3D = _instanciar(a)
	aparicion_empezada.emit(a)
	match a.llegada:
		AparicionData.Llegada.MAR:
			await _por_mar(n, a)
		AparicionData.Llegada.CIELO:
			await _desde_cielo(n, a)
	aparicion_terminada.emit(a)
	_ocupado = false


func _instanciar(a: AparicionData) -> Node3D:
	var n: Node3D = a.escena.instantiate()
	n.name = String(a.id)
	add_child(n)
	n.position = celda_a_mundo(a.ancla)
	return n


func _por_mar(n: Node3D, a: AparicionData) -> void:
	var destino: Vector3 = n.position
	# Entra por su lado y desde el horizonte, nunca desde detrás de la cámara.
	var lado: float = signf(destino.x) if absf(destino.x) > 0.1 else 1.0
	var dir: Vector3 = Vector3(lado, 0.0, -0.8).normalized()
	n.position = destino + dir * distancia_mar + Vector3.DOWN * hundida_mar
	pesca.bloquear(duracion_mar + 1.0)
	camara.enfocar(destino, duracion_mar + 0.8, 3.0)
	if sfx_mar:
		sfx_mar.play()
	var tw := create_tween().set_parallel(true)
	tw.tween_property(n, "position:x", destino.x, duracion_mar).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(n, "position:z", destino.z, duracion_mar).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(n, "position:y", destino.y, duracion_mar * 0.6).set_delay(duracion_mar * 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_method(func(k: float) -> void:
		n.rotation_degrees.z = sin(k * TAU * 2.0) * balanceo_mar_grados * (1.0 - k), 0.0, 1.0, duracion_mar)
	await tw.finished
	n.rotation_degrees.z = 0.0
	camara.sacudir(0.15)
	if n.has_method("llegar"):
		n.llegar()
	aparicion_llegada.emit(a)


func _desde_cielo(n: Node3D, a: AparicionData) -> void:
	var destino: Vector3 = n.position
	var total: float = aviso_cielo + duracion_caida + reposo_cielo
	pesca.bloquear(total + 1.0)
	camara.enfocar(destino, total, 6.0)
	n.visible = false
	n.position = destino + Vector3.UP * altura_cielo
	if sombra:
		sombra.position = Vector3(destino.x, 0.18, destino.z)
		sombra.scale = Vector3.ONE * 0.2
		sombra.visible = true
		create_tween().tween_property(sombra, "scale", Vector3.ONE * escala_sombra, aviso_cielo + duracion_caida).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	if sfx_caida:
		sfx_caida.play()
	await get_tree().create_timer(aviso_cielo).timeout
	n.visible = true
	n.rotation_degrees.y = giro_caida_grados
	var tw := create_tween().set_parallel(true)
	tw.tween_property(n, "position:y", destino.y, duracion_caida).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(n, "rotation_degrees:y", 0.0, duracion_caida).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tw.finished
	# Impacto
	if sombra:
		sombra.visible = false
	if sfx_impacto:
		sfx_impacto.play()
	camara.sacudir(golpe_impacto)
	if n.has_method("llegar"):
		n.llegar()
	aparicion_llegada.emit(a)
	var rebote := create_tween()
	rebote.tween_property(n, "position:y", destino.y - 0.4, 0.12).set_ease(Tween.EASE_OUT)
	rebote.tween_property(n, "position:y", destino.y, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if pausa_impacto > 0.0:
		Engine.time_scale = 0.05
		await get_tree().create_timer(pausa_impacto, true, false, true).timeout
		Engine.time_scale = 1.0
	await get_tree().create_timer(reposo_cielo).timeout
