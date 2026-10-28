shader_type spatial;
render_mode specular_schlick_ggx, cull_back;
// Mar del juego: olas que mueven la superficie, detalle de oleaje, reflejos (SSR del entorno),
// color por bandas para casar con el pixelado y anillos de lluvia. El nodo Clima mueve los parámetros.

uniform vec4 color_profundo : source_color = vec4(0.04, 0.22, 0.38, 1.0);
uniform vec4 color_claro : source_color = vec4(0.14, 0.56, 0.68, 1.0);
uniform vec4 color_cresta : source_color = vec4(0.75, 0.92, 0.95, 1.0);
uniform float altura_ola = 0.14;
uniform float escala_ola = 0.42;
uniform float velocidad = 1.0;
// Tiempo de las olas: lo lleva agua.gd (así sabe a qué altura está el agua en cada punto).
uniform float tiempo = 0.0;
uniform float rugosidad : hint_range(0.0, 1.0) = 0.06;
uniform float bandas = 5.0;
uniform float umbral_cresta : hint_range(0.0, 1.0) = 0.86;
uniform sampler2D detalle_a : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D detalle_b : hint_normal, filter_linear_mipmap, repeat_enable;
uniform float escala_detalle = 0.07;
uniform float fuerza_detalle : hint_range(0.0, 2.0) = 0.45;
uniform float lluvia : hint_range(0.0, 1.0) = 0.0;
uniform float densidad_gotas = 0.7;
// Cuánto pesa la altura de la ola en el color (bajo = agua más uniforme).
uniform float peso_altura : hint_range(0.0, 1.0) = 0.55;

varying vec3 pos_mundo;
varying float altura;

// Suma de ondas: devuelve (altura, derivada x, derivada z).
vec3 onda(vec2 p, vec2 dir, float frec, float amp, float vel, float t) {
	float fase = dot(dir, p) * frec + t * vel;
	return vec3(sin(fase) * amp, cos(fase) * amp * frec * dir.x, cos(fase) * amp * frec * dir.y);
}

vec3 olas(vec2 p, float t) {
	vec3 r = vec3(0.0);
	r += onda(p, normalize(vec2(1.0, 0.35)), escala_ola, 0.55, 1.0, t);
	r += onda(p, normalize(vec2(-0.4, 1.0)), escala_ola * 1.37, 0.3, 1.3, t);
	r += onda(p, normalize(vec2(0.7, -0.8)), escala_ola * 2.3, 0.12, 1.9, t);
	r += onda(p, normalize(vec2(-1.0, -0.2)), escala_ola * 3.1, 0.06, 2.6, t);
	return r;
}

float azar(vec2 c) {
	return fract(sin(dot(c, vec2(127.1, 311.7))) * 43758.5453);
}

void vertex() {
	pos_mundo = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 o = olas(pos_mundo.xz, tiempo);
	altura = o.x;
	VERTEX.y += o.x * altura_ola;
	NORMAL = normalize(vec3(-o.y * altura_ola, 1.0, -o.z * altura_ola));
}

void fragment() {
	vec2 p = pos_mundo.xz;
	float t = tiempo;
	// Detalle: dos mapas de normales deslizándose en direcciones distintas.
	vec3 na = texture(detalle_a, p * escala_detalle + vec2(t * 0.02, t * 0.013)).rgb;
	vec3 nb = texture(detalle_b, p * escala_detalle * 1.7 - vec2(t * 0.017, -t * 0.021)).rgb;
	vec3 nm = normalize(na + nb - 1.0);

	// Anillos de lluvia: una gota por celda, cada una a su ritmo.
	float anillo = 0.0;
	if (lluvia > 0.01) {
		vec2 g = p * densidad_gotas;
		vec2 celda = floor(g);
		float r1 = azar(celda);
		float r2 = azar(celda + 17.3);
		vec2 centro = vec2(r1, r2) * 0.6 + 0.2;
		float fase = fract(TIME * 0.9 + r1 * 7.0);
		float d = length(fract(g) - centro);
		float radio = fase * 0.35;
		anillo = (1.0 - smoothstep(0.0, 0.06, abs(d - radio))) * (1.0 - fase) * step(r2, lluvia);
	}

	float k = clamp(altura * 0.5 + 0.5, 0.0, 1.0);
	k = floor(k * bandas) / bandas;
	vec3 c = mix(color_profundo.rgb, color_claro.rgb, k * peso_altura);
	c = mix(c, color_cresta.rgb, step(umbral_cresta, k + nm.x * 0.08) * 0.6);
	c = mix(c, color_cresta.rgb, step(0.5, anillo) * 0.7);
	ALBEDO = c;
	NORMAL_MAP = mix(nm, vec3(0.5, 0.5, 1.0), 1.0 - step(0.01, fuerza_detalle));
	NORMAL_MAP_DEPTH = fuerza_detalle + anillo * 0.8;
	ROUGHNESS = rugosidad;
	METALLIC = 0.0;
	SPECULAR = 0.6;
}
