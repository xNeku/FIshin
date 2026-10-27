extends HBoxContainer
## Una captura concreta dentro del detalle de una especie.

@onready var calidad: Label = $Calidad
@onready var peso: Label = $Peso
@onready var valor: Label = $Valor


func mostrar(c: Dictionary) -> void:
	calidad.text = Formato.calidad(c.calidad, c.perfecto)
	peso.text = Formato.peso(c.peso)
	valor.text = Formato.dinero(c.valor)
	if c.perfecto:
		calidad.modulate = Color("ffd84a")
