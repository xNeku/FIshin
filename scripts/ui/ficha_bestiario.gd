extends PanelContainer
## Una especie en el bestiario. Sin pescar: silueta y "???".

const NOMBRES_RAREZA: Array[String] = ["Común", "Raro", "Extraño", "Legendario"]

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
		detalle.text = "%s\n%s" % [NOMBRES_RAREZA[pez.rareza], Formato.calidad(mejor_calidad, mejor_calidad >= 1.0)]
