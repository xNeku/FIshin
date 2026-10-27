class_name ArticuloData
extends Resource
## Algo que se compra en una tienda. Cada .tres en data/articulos/ es uno.

enum Tipo { CANA, CEBO, HUECO }

@export var id: StringName
@export var nombre: String = ""
@export_multiline var descripcion: String = ""
@export var icono: Texture2D
@export var tipo: Tipo = Tipo.CEBO
@export var precio: float = 10.0
## El precio se multiplica por esto tras cada compra.
@export var crecimiento_precio: float = 1.0
## Veces que se puede comprar. 0 = sin límite.
@export var max_compras: int = 1

@export_group("Caña")
@export var cana: CanaData

@export_group("Cebo")
## Cuántas pescas dura el cebo.
@export var cebo_pescas: int = 5
## Multiplica el tiempo de reacción mientras dura.
@export var cebo_mult_tiempo: float = 1.3
## Multiplica la espera hasta que pica mientras dura.
@export var cebo_mult_espera: float = 1.0

@export_group("Hueco")
@export var huecos: int = 1


func precio_actual(compras: int) -> float:
	return precio * pow(crecimiento_precio, compras)
