shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;
// Rejilla de la zona de pesca 3x3.

uniform vec4 color_linea : source_color = vec4(1.0, 1.0, 1.0, 0.22);
uniform float grosor : hint_range(0.0, 0.2) = 0.025;
uniform float celdas = 3.0;
uniform float pulso = 2.0;

void fragment() {
	vec2 g = fract(UV * celdas);
	float d = min(min(g.x, 1.0 - g.x), min(g.y, 1.0 - g.y));
	float a = 1.0 - smoothstep(grosor, grosor + 0.01, d);
	ALBEDO = color_linea.rgb;
	ALPHA = a * color_linea.a * (0.75 + 0.25 * sin(TIME * pulso));
}
