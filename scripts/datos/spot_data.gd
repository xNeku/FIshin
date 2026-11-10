class_name SpotData
extends Resource
## Un spot de pesca activa (data/spots/<id>.tres). En la base el náufrago pesca solo; en un spot se juega
## el minijuego, salen especies de verdad (bestiario), carta y celebración.

## CLASICO: el minijuego de botones de siempre. BANCO: carril, cada nota es un pez. TROFEO: carril largo
## con notas mantenidas y tensión; solo raros o mejores.
enum Modo { CLASICO, BANCO, TROFEO }

@export var id: StringName
@export var nombre: String = ""
@export_multiline var descripcion: String = ""
@export var modo: Modo = Modo.CLASICO
## Orden al cambiar de spot con "accion_extra" (base → 1 → 2 → 3 → base).
@export var orden: int = 1
## Rarezas que pican aquí (PezData.Rareza, ambos incluidos).
@export_range(0, 5) var rareza_min: int = 0
@export_range(0, 5) var rareza_max: int = 5
## Profundidad de más sobre la de tu caña.
@export var profundidad_extra: int = 0
## Multiplica el valor de todo lo que sale aquí.
@export var mult_valor: float = 1.5
## Multiplica la probabilidad de raros o mejores.
@export var mult_rareza: float = 1.0
## Multiplica la espera hasta que pica.
@export var mult_espera: float = 1.0
@export_group("Carril (banco)")
## Notas del banco (cada una es un pez).
@export var notas_min: int = 12
@export var notas_max: int = 30
