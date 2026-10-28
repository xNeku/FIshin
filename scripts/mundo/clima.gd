extends Node
## El tiempo: sortea climas (data/climas) y pasa de uno a otro poco a poco, moviendo cielo, luz,
## niebla, mar y lluvia. En tormenta hay relámpagos.

signal clima_cambiado(clima: ClimaData)

@export var climas: Array[ClimaData] = []
@export var clima_inicial: ClimaData
@export var entorno: WorldEnvironment
@export var sol: DirectionalLight3D
## El nodo del mar (su material es el del shader de agua).
@export var agua: MeshInstance3D
@export var lluvia: GPUParticles3D
@export var camara: Camera3D
@export var sfx_lluvia: AudioStreamPlayer
@export var sfx_trueno: AudioStreamPlayer
## Segundos que tarda en pasar de un clima a otro.
@export var transicion: float = 12.0

@export_group("Relámpagos")
@export var espera_relampago_min: float = 5.0
@export var espera_relampago_max: float = 14.0
@export var fuerza_relampago: float = 4.0

var actual: ClimaData
var _origen: Dictionary = {}
var _destino: Dictionary = {}
var _k: float = 1.0
var _t_restante: float = 0.0
var _t_relampago: float = 8.0
var _destello: float = 0.0
var _valores: Dictionary = {}


func _ready() -> void:
	var inicio: ClimaData = clima_inicial if clima_inicial else (climas[0] if not climas.is_empty() else null)
	if inicio == null:
		return
	actual = inicio
	_valores = _leer(inicio)
	_destino = _valores.duplicate()
	_aplicar(_valores)
	_t_restante = randf_range(inicio.duracion_min, inicio.duracion_max)


func _process(delta: float) -> void:
	if actual == null:
		return
	_t_restante -= delta
	if _t_restante <= 0.0:
		cambiar(_sortear())
	if _k < 1.0:
		_k = minf(1.0, _k + delta / maxf(0.1, transicion))
		var s: float = smoothstep(0.0, 1.0, _k)
		for clave: String in _destino:
			_valores[clave] = _mezclar(_origen[clave], _destino[clave], s)
		_aplicar(_valores)
	if lluvia and camara:
		lluvia.global_position = camara.global_position + Vector3(0, 6, -6)
	_relampagos(delta)


## Pasa a un clima concreto (también lo usa el truco F6).
func cambiar(c: ClimaData) -> void:
	if c == null:
		return
	actual = c
	_origen = _valores.duplicate()
	_destino = _leer(c)
	_k = 0.0
	_t_restante = randf_range(c.duracion_min, c.duracion_max)
	clima_cambiado.emit(c)


func siguiente() -> void:
	var i: int = climas.find(actual)
	cambiar(climas[(i + 1) % climas.size()])


func _sortear() -> ClimaData:
	var total: float = 0.0
	for c: ClimaData in climas:
		if c != actual:
			total += c.probabilidad
	var r: float = randf() * total
	for c: ClimaData in climas:
		if c == actual:
			continue
		r -= c.probabilidad
		if r <= 0.0:
			return c
	return actual


func _leer(c: ClimaData) -> Dictionary:
	return {
		"cielo_arriba": c.cielo_arriba, "cielo_horizonte": c.cielo_horizonte, "nubes": c.nubes, "color_nubes": c.color_nubes,
		"color_sol": c.color_sol, "energia_sol": c.energia_sol, "energia_ambiente": c.energia_ambiente,
		"niebla": c.niebla, "color_niebla": c.color_niebla,
		"agua_profundo": c.agua_profundo, "agua_claro": c.agua_claro, "altura_ola": c.altura_ola,
		"velocidad_ola": c.velocidad_ola, "rugosidad": c.rugosidad, "lluvia": c.lluvia,
	}


func _mezclar(a: Variant, b: Variant, s: float) -> Variant:
	if a is Color:
		return (a as Color).lerp(b, s)
	return lerpf(a, b, s)


func _aplicar(v: Dictionary) -> void:
	var env: Environment = entorno.environment
	var cielo := env.sky.sky_material as ProceduralSkyMaterial
	if cielo:
		var arriba: Color = v.cielo_arriba
		cielo.sky_top_color = arriba.lerp(Color.WHITE, _destello)
		cielo.sky_horizon_color = v.cielo_horizonte
		cielo.ground_horizon_color = v.cielo_horizonte
		var cn: Color = v.color_nubes
		cielo.sky_cover_modulate = Color(cn.r, cn.g, cn.b, v.nubes)
	env.ambient_light_energy = v.energia_ambiente
	env.fog_enabled = v.niebla > 0.001
	env.fog_density = v.niebla
	env.fog_light_color = v.color_niebla
	sol.light_color = v.color_sol
	sol.light_energy = v.energia_sol + _destello * fuerza_relampago
	var m := agua.mesh.surface_get_material(0) as ShaderMaterial
	if m:
		m.set_shader_parameter("color_profundo", v.agua_profundo)
		m.set_shader_parameter("color_claro", v.agua_claro)
		m.set_shader_parameter("altura_ola", v.altura_ola)
		m.set_shader_parameter("velocidad", v.velocidad_ola)
		m.set_shader_parameter("rugosidad", v.rugosidad)
		m.set_shader_parameter("lluvia", v.lluvia)
	if lluvia:
		lluvia.emitting = v.lluvia > 0.02
		lluvia.amount_ratio = clampf(v.lluvia, 0.0, 1.0)
	if sfx_lluvia:
		if v.lluvia > 0.02 and not sfx_lluvia.playing:
			sfx_lluvia.play()
		elif v.lluvia <= 0.02 and sfx_lluvia.playing:
			sfx_lluvia.stop()
		sfx_lluvia.volume_db = linear_to_db(maxf(0.001, v.lluvia)) - 4.0


func _relampagos(delta: float) -> void:
	if _destello > 0.0:
		_destello = maxf(0.0, _destello - delta * 5.0)
		_aplicar(_valores)
	if not actual.relampagos:
		return
	_t_relampago -= delta
	if _t_relampago > 0.0:
		return
	_t_relampago = randf_range(espera_relampago_min, espera_relampago_max)
	_destello = 1.0
	await get_tree().create_timer(0.12).timeout
	_destello = 0.7
	await get_tree().create_timer(randf_range(0.3, 1.2)).timeout
	if sfx_trueno:
		sfx_trueno.pitch_scale = randf_range(0.85, 1.1)
		sfx_trueno.play()
