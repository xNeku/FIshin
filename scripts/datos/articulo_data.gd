class_name ArticuloData
extends Resource
## Algo que se compra en una tienda. Cada .tres en data/articulos/ es uno.

## TRABAJADOR: contrata un pescador más para el puerto (lo vende el primer pescador).
## HUECO ya no se usa (la barca no tiene huecos); se queda para no mover los números de los .tres.
enum Tipo { CANA, CEBO, HUECO, TRABAJADOR }

@export var id: StringName
@export var nombre: String = ""
@export_multiline var descripcion: String = ""
@export var icono: Texture2D
@export var tipo: Tipo = Tipo.CEBO
@export var precio: float = 10.0
## El precio se multiplica por esto tras cada compra.
@export var crecimiento_precio: float = 1.0
## Precios fijos de las primeras compras (si se rellena); después sigue el último × crecimiento_precio.
@export var precios: Array[float] = []
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


func precio_actual(compras: int) -> float:
	if not precios.is_empty():
		if compras < precios.size():
			return precios[compras]
		return precios.back() * pow(crecimiento_precio, compras - precios.size() + 1)
	return precio * pow(crecimiento_precio, compras)
