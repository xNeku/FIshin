class_name ArticuloData
extends Resource
## Algo que se compra en una tienda. Cada .tres en data/articulos/ es uno.

## TRABAJADOR: contrata un pescador más para el puerto (lo vende el primer pescador).
## HUECO ya no se usa (la barca no tiene huecos); se queda para no mover los números de los .tres.
## MEJORA: cada compra suma `valor_efecto` al efecto `efecto` (Juego.efecto), igual que un nodo del árbol.
enum Tipo { CANA, CEBO, HUECO, TRABAJADOR, MEJORA }

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
## Solo sale en la tienda si existe este flag (ej. "aparecido_lonja": el comerciante trae género nuevo).
@export var requiere_flag: String = ""

@export_group("Caña")
@export var cana: CanaData

@export_group("Cebo")
## Cuántas pescas dura el cebo.
@export var cebo_pescas: int = 5
## Multiplica el tiempo de reacción mientras dura.
@export var cebo_mult_tiempo: float = 1.3
## Multiplica la espera hasta que pica mientras dura.
@export var cebo_mult_espera: float = 1.0


## Coral que cuesta además de los rublos (mid game). Crece igual que el precio.
@export var coste_coral: float = 0.0

@export_group("Mejora")
## Nombre del efecto que sube (ej. "despensa", "precio_plato", "mesas").
@export var efecto: StringName
@export var valor_efecto: float = 1.0


func coral_actual(compras: int) -> float:
	return coste_coral * pow(crecimiento_precio, compras) if coste_coral > 0.0 else 0.0


func a_la_venta() -> bool:
	return requiere_flag == "" or Juego.flags.get(requiere_flag, false)


func precio_actual(compras: int) -> float:
	if not precios.is_empty():
		if compras < precios.size():
			return precios[compras]
		return precios.back() * pow(crecimiento_precio, compras - precios.size() + 1)
	return precio * pow(crecimiento_precio, compras)
