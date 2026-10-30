shader_type spatial;
// Reflejo de la luna: se dibuja solo sobre el agua. Usa la misma máscara de tierra que el mar, así que
// nunca pisa una isla aunque la estela sea larga.
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;

uniform sampler2D textura : source_color, filter_nearest;
uniform vec4 tinte : source_color = vec4(1.0);
uniform sampler2D mascara_tierra : filter_linear, repeat_disable;
uniform float radio_mascara = 24.0;
uniform float tamano_celda = 2.0;
// Cuánto antes de la orilla se apaga (0.5 = justo en el borde de la casilla de tierra).
uniform float margen_costa : hint_range(0.05, 0.5) = 0.2;

varying vec3 pos_mundo;

void vertex() {
	pos_mundo = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec4 c = texture(textura, UV) * tinte;
	float n = radio_mascara * 2.0 + 1.0;
	vec2 f = pos_mundo.xz / tamano_celda + radio_mascara + 0.5;
	float tierra = texture(mascara_tierra, f / n).r;
	c.a *= 1.0 - smoothstep(margen_costa, 0.5, tierra);
	ALBEDO = c.rgb;
	ALPHA = c.a;
}
