shader_type canvas_item;
// Fondo del árbol: azul muy oscuro, puntitos de rejilla y burbujas pixel que suben. Va en un ColorRect.

uniform vec4 color_arriba : source_color = vec4(0.015, 0.02, 0.05, 1.0);
uniform vec4 color_abajo : source_color = vec4(0.03, 0.06, 0.13, 1.0);
uniform vec4 color_burbuja : source_color = vec4(0.35, 0.6, 0.9, 0.5);
uniform float tam_pixel = 4.0;
// Columnas de burbujas (más = más burbujas).
uniform float densidad : hint_range(0.0, 1.0) = 0.35;
uniform float velocidad = 1.0;

float azar(float n) {
	return fract(sin(n * 127.1) * 43758.5453);
}

void fragment() {
	vec2 tam = 1.0 / SCREEN_PIXEL_SIZE / tam_pixel;
	vec2 celda = floor(UV * tam);
	vec3 c = mix(color_arriba.rgb, color_abajo.rgb, UV.y);
	// Rejilla de puntos muy tenue.
	if (mod(celda.x, 12.0) == 0.0 && mod(celda.y, 12.0) == 0.0) {
		c += vec3(0.06, 0.08, 0.12);
	}
	// Burbujas: cada columna ancha tiene (o no) una burbuja subiendo.
	float columna = floor(celda.x / 10.0);
	float h = azar(columna);
	if (h < densidad) {
		float vel = mix(0.03, 0.08, azar(columna + 3.3)) * velocidad;
		float altura = fract(h * 13.0 - TIME * vel) * (tam.y + 8.0) - 4.0;
		float bx = columna * 10.0 + 4.0 + floor(sin(TIME * 1.3 + h * 30.0) * 1.5);
		float radio = 1.0 + floor(azar(columna + 7.7) * 2.0);
		float d = distance(celda, vec2(bx, altura));
		if (d <= radio + 0.5 && d > radio - 0.5) {
			c = mix(c, color_burbuja.rgb, color_burbuja.a);
		}
		if (celda == vec2(bx - 1.0, altura - 1.0) && radio > 1.0) {
			c = mix(c, vec3(1.0), 0.4);
		}
	}
	COLOR = vec4(c, 1.0);
}
