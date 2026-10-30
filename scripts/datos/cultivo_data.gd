class_name CultivoData
extends Resource
## Algo que se cultiva y se cosecha a hozazos (pimientos, algas...). Cada .tres en data/cultivos/ es uno.
## Lo cosechado va contigo y se lo das al restaurante, que lo usa en sus platos.

## GUARNICION: el plato lleva además una ración de esto, que paga `valor` × lo que vale la ración de pescado
## (pimientos de Padrón).
## MEJORA_PLATO: el plato vale `valor` más (×(1 + valor)) si lleva uno (algas).
enum Uso { GUARNICION, MEJORA_PLATO }

@export var id: StringName
@export var nombre: String = ""
@export var icono: Texture2D
## Dibujos de la planta de brote a lista para cosechar (la última es "lista").
@export var fases: Array[Texture2D] = []
## Segundos de brote a lista.
@export var segundos_crecer: float = 90.0
## Lo que se cosecha de cada planta.
@export var por_planta: int = 3
@export var uso: Uso = Uso.GUARNICION
@export var valor: float = 10.0
