shader_type spatial;
// Agua estilizada: olas por vértice, caras planas (low poly) y color por bandas.

uniform vec4 color_profundo : source_color = vec4(0.06, 0.3, 0.5, 1.0);
uniform vec4 color_claro : source_color = vec4(0.2, 0.68, 0.78, 1.0);
uniform vec4 color_brillo : source_color = vec4(0.85, 0.97, 1.0, 1.0);
uniform float altura_ola = 0.12;
uniform float escala_ola = 0.55;
uniform float velocidad = 1.0;
uniform float bandas = 4.0;
uniform float umbral_brillo : hint_range(0.0, 1.0) = 0.9;

varying float altura;
varying vec3 pos_mundo;

float ola(vec2 p, float t) {
	return sin(p.x * escala_ola + t) * 0.5
		+ sin(p.y * escala_ola * 1.3 + t * 1.4) * 0.35
		+ sin((p.x + p.y) * escala_ola * 2.1 + t * 0.7) * 0.15;
}

void vertex() {
	pos_mundo = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	altura = ola(pos_mundo.xz, TIME * velocidad);
	VERTEX.y += altura * altura_ola;
}

void fragment() {
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	float k = clamp(altura * 0.5 + 0.5, 0.0, 1.0);
	k = floor(k * bandas) / bandas;
	vec3 c = mix(color_profundo.rgb, color_claro.rgb, k);
	float chispa = sin(pos_mundo.x * 6.0 + TIME * 2.0) * sin(pos_mundo.z * 6.0 - TIME * 1.7);
	c = mix(c, color_brillo.rgb, step(umbral_brillo, chispa) * 0.7);
	ALBEDO = c;
	ROUGHNESS = 0.2;
	SPECULAR = 0.6;
}
