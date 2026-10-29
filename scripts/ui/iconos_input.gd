class_name IconosInput
## Dibujos de teclas y botones según el último dispositivo tocado (teclado, mando de PlayStation o Xbox).
## Archivos: <carpeta>/<teclado|ps|xbox>_<accion>[_pulsada].png

const CARPETA := "res://art/ui/teclas"

static var dispositivo: String = "teclado"
## Dibujos para un mando que no se reconoce por su nombre.
static var mando_por_defecto: String = "ps"
static var _cache: Dictionary = {}


static func icono(accion: StringName, pulsada: bool = false) -> Texture2D:
	var ruta: String = "%s/%s_%s%s.png" % [CARPETA, dispositivo, accion, "_pulsada" if pulsada else ""]
	if not _cache.has(ruta):
		_cache[ruta] = load(ruta) if ResourceLoader.exists(ruta) else null
	return _cache[ruta]


## Mira el evento y cambia de dispositivo si toca. Devuelve true si ha cambiado.
static func detectar(event: InputEvent) -> bool:
	var nuevo: String = dispositivo
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf((event as InputEventJoypadMotion).axis_value) > 0.5):
		nuevo = tipo_mando(event.device)
	elif event is InputEventKey or event is InputEventMouseButton:
		nuevo = "teclado"
	if nuevo == dispositivo:
		return false
	dispositivo = nuevo
	return true


## Xbox o PlayStation según el nombre que da el mando; si no se sabe, mando_por_defecto.
static func tipo_mando(id: int) -> String:
	var nombre: String = Input.get_joy_name(id).to_lower()
	for clave: String in ["xbox", "xinput", "microsoft"]:
		if nombre.contains(clave):
			return "xbox"
	for clave: String in ["playstation", "dualsense", "dualshock", "sony", "ps3", "ps4", "ps5", "wireless controller"]:
		if nombre.contains(clave):
			return "ps"
	return mando_por_defecto
