class_name PezData
extends Resource
## Un tipo de pez. Cada .tres en data/peces/ es un pez (la Pesca los carga todos de la carpeta).
## Los de la lista del diseñador salen de docs/datos/peces_fuente.csv con docs/herramientas/importar_peces.py.

enum Rareza { COMUN, POCO_COMUN, RARO, EPICO, LEGENDARIO, MITICO }
enum Tipo { PEZ, CRUSTACEO, CEFALOPODO, EQUINODERMO, ESCUALO, MAMIFERO, OBJETO, FLORA }
enum Zona { GALICIA, MUNDO }

const NOMBRES_RAREZA: Array[String] = ["Común", "Poco común", "Raro", "Épico", "Legendario", "Mítico"]

@export var id: StringName
@export var nombre: String = ""
@export var rareza: Rareza = Rareza.COMUN
@export var icono: Texture2D
## Profundidad mínima de caña para que pueda picar.
@export var profundidad: int = 1
## false = pez de la pesca base (calidades de data/peces_base): no cuenta para el bestiario ni sale en los spots.
@export var bestiario: bool = true

@export_group("Ficha")
@export var tipo: Tipo = Tipo.PEZ
@export var zona: Zona = Zona.GALICIA
## Dónde vive (para el bestiario; sobre todo los del mundo).
@export var ubicacion: String = ""
## Cuándo sale. Aún no se usa al pescar: espera al reloj del juego (día/noche y estaciones).
@export_flags("Primavera", "Verano", "Otoño", "Invierno") var estaciones: int = 15
@export_enum("Siempre", "Día", "Noche", "Ocaso") var horario: int = 0

@export_group("Economía")
@export var valor_base: float = 5.0
@export var peso_min: float = 0.5
@export var peso_max: float = 2.0
## Peso relativo en la tirada de qué pez pica.
@export var probabilidad: float = 1.0

@export_group("Minijuego")
## Pulsaciones necesarias para el perfect.
@export var pasos_perfect: int = 6
## Multiplica el tiempo de reacción de cada botón (>1 = más fácil).
@export var mult_tiempo: float = 1.0
## Probabilidad de que un paso sea doble (número + flecha).
@export_range(0.0, 1.0) var prob_doble: float = 0.0
## > 0 = pez tocho: si completas la cadena, el remate es machacar el botón principal (X / 1). 0 = sin remate.
@export var machacar_cada: int = 0
@export var pulsaciones_machacar: int = 10
@export var tiempo_machacar: float = 2.0


## Los raros de verdad se escapan si no llenas la barra; los normales salen peores.
func escapa_si_falla_machacar() -> bool:
	return rareza >= Rareza.EPICO
