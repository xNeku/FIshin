shader_type canvas_item;
// Noche y atardecer sobre el mundo pixelado (va en el Contenedor del Pixelador; el HUD no se toca).
// Lo muy claro (fuego, antorchas, el reflejo de la luna) se salva para que brille en la oscuridad.

uniform float noche : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tinte_noche : source_color = vec4(0.26, 0.32, 0.58, 1.0);
uniform float ocaso : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tinte_ocaso : source_color = vec4(1.0, 0.78, 0.62, 1.0);
// Desde qué brillo un píxel cuenta como luz y no se oscurece.
uniform float umbral_luz : hint_range(0.0, 1.0) = 0.8;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float brillo = max(c.r, max(c.g, c.b));
	float luz = smoothstep(umbral_luz, 1.0, brillo);
	vec3 oscuro = c.rgb * tinte_noche.rgb;
	vec3 r = mix(c.rgb, mix(oscuro, c.rgb, luz), noche);
	r = mix(r, r * tinte_ocaso.rgb, ocaso);
	COLOR = vec4(r, c.a);
}
