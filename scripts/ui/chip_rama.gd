extends PanelContainer
## Etiqueta de una rama arriba del árbol: icono, nombre y cuántos nodos llevas.

@export var rama: RamaArbolData

@onready var icono: TextureRect = $Fila/Icono
@onready var nombre: Label = $Fila/Nombre
@onready var progreso: Label = $Fila/Progreso


func _ready() -> void:
	if rama:
		icono.texture = rama.icono
		icono.modulate = rama.color
		nombre.text = rama.nombre
		nombre.modulate = rama.color


func refrescar() -> void:
	if rama == null or Juego.arbol == null:
		return
	var total: int = 0
	var hechos: int = 0
	for n: NodoArbolData in Juego.arbol.nodos:
		if n.rama == rama:
			total += n.niveles
			hechos += Juego.nivel_habilidad(n)
	progreso.text = "%d/%d" % [hechos, total]
