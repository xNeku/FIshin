shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;
// Rejilla de la zona de pesca 3x3: líneas tenues y los cruces marcados (tipo mira).

uniform vec4 color_linea : source_color = vec4(1.0, 1.0, 1.0, 0.22);
uniform float grosor : hint_range(0.0, 0.2) = 0.025;
uniform float celdas = 3.0;
uniform float pulso = 2.0;
// Cuánto se ve la línea lejos de los cruces (0 = solo los cruces, 1 = línea entera).
uniform float linea_tenue : hint_range(0.0, 1.0) = 0.35;
// Largo de la marca de cada cruce, en fracción de casilla.
uniform float largo_cruce : hint_range(0.0, 0.5) = 0.14;

void fragment() {
	vec2 g = fract(UV * celdas);
	vec2 borde = min(g, 1.0 - g);
	float d = min(borde.x, borde.y);
	float a = 1.0 - smoothstep(grosor, grosor + 0.01, d);
	// Cerca de un cruce las dos distancias son pequeñas: ahí la línea sale entera.
	float cruce = 1.0 - smoothstep(largo_cruce, largo_cruce + 0.02, max(borde.x, borde.y));
	ALBEDO = color_linea.rgb;
	ALPHA = a * mix(linea_tenue, 1.0, cruce) * color_linea.a * (0.75 + 0.25 * sin(TIME * pulso));
}
