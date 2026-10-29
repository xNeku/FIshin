class_name RamaArbolData
extends Resource
## Una rama del árbol de habilidades (Carisma, Suerte, Pesca, Chill...). Un .tres en data/arbol/ramas/.

@export var id: StringName
@export var nombre: String = ""
@export_multiline var descripcion: String = ""
## Color de la rama: marcos, iconos y agua de sus caminos.
@export var color: Color = Color.WHITE
@export var icono: Texture2D
