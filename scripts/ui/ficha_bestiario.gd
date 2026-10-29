extends PanelContainer
## Una especie en el bestiario. Sin pescar: silueta y "???".

@onready var icono: TextureRect = $Margen/Contenido/Icono
@onready var nombre: Label = $Margen/Contenido/Nombre
@onready var detalle: Label = $Margen/Contenido/Detalle


## mejor_calidad < 0 = nunca pescado.
func mostrar(pez: PezData, mejor_calidad: float) -> void:
	icono.texture = pez.icono
	if mejor_calidad < 0.0:
		icono.modulate = Color(0.2, 0.22, 0.32, 1)
		nombre.text = "???"
		detalle.text = "Sin descubrir"
	else:
		icono.modulate = Color.WHITE
		nombre.text = pez.nombre
		detalle.text = "%s\n%s\n%s" % [PezData.NOMBRES_RAREZA[pez.rareza], Formato.calidad(mejor_calidad, mejor_calidad >= 1.0), _maestria(pez)]


## "Maestría 2" y debajo "63/200" (o el multiplicador al tope).
func _maestria(pez: PezData) -> String:
	var st: StatsPesca = Juego.stats_pesca
	var n: int = Juego.capturas_especie(pez.id)
	var nivel: int = st.nivel_maestria(n)
	if nivel >= st.maestria_desde.size():
		return "Maestría máx.\n×%s" % str(st.mult_maestria(n))
	return "Maestría %d\n%d/%d" % [nivel, n, st.maestria_desde[nivel]]
