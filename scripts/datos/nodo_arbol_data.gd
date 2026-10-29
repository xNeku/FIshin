class_name NodoArbolData
extends Resource
## Una habilidad del árbol. Un .tres en data/arbol/nodos/. Dónde sale en pantalla se decide en
## scenes/ui/arbol.tscn (cada nodo es una instancia que se puede mover a mano).

enum TipoValor { PORCENTAJE, NUMERO, SEGUNDOS, SIN_VALOR }

@export var id: StringName
@export var nombre: String = ""
## Texto de lo que hace. {v} = lo que da cada nivel, {total} = lo que da con los niveles comprados.
@export_multiline var descripcion: String = ""
@export var rama: RamaArbolData
@export var icono: Texture2D
## Nodo clave: cambia cómo se juega. Sale más grande.
@export var clave: bool = false

@export_group("Niveles y precio")
@export_range(1, 50) var niveles: int = 1
@export var coste_base: float = 100.0
## Cada nivel cuesta esto veces más que el anterior.
@export var crecimiento: float = 2.0

@export_group("Efecto")
## Qué toca (lo lee el juego con Juego.efecto(nombre)). Ver la lista en docs/PROGRESION.md.
@export var efecto: StringName
@export var valor_por_nivel: float = 0.05
@export var formato: TipoValor = TipoValor.PORCENTAJE

@export_group("Requisitos")
## Hay que tener al menos un nivel de cada uno (NodoArbolData). Vacío = sale del viejo.
@export var requisitos: Array[Resource] = []
## Flag de Juego.flags que tiene que existir (ej. "aparecido_puerto_pesquero"). Vacío = ninguno.
@export var requiere_flag: String = ""
## Lo que se enseña mientras falta el flag (ej. "Llega con el puerto").
@export var texto_bloqueo: String = ""


func coste(nivel_actual: int) -> float:
	return coste_base * pow(crecimiento, nivel_actual)


func texto_valor(v: float) -> String:
	match formato:
		TipoValor.PORCENTAJE:
			return "%s%%" % _num(v * 100.0)
		TipoValor.NUMERO:
			return _num(v)
		TipoValor.SEGUNDOS:
			return "%s s" % _num(v)
	return ""


func texto_descripcion(nivel: int) -> String:
	return descripcion.format({"v": texto_valor(valor_por_nivel), "total": texto_valor(valor_por_nivel * nivel)})


static func _num(v: float) -> String:
	return str(int(round(v))) if absf(v - round(v)) < 0.01 else "%.1f" % v
