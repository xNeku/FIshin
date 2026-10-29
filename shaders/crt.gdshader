shader_type canvas_item;
// Filtro retro de tele de tubo: líneas de barrido, máscara de fósforo, resplandor, aberración,
// viñeta y una curvatura muy suave. Va encima de todo (mundo, HUD y menús).

uniform sampler2D pantalla : hint_screen_texture, filter_linear_mipmap;
// Alto de cada línea de barrido en píxeles de pantalla (4 = una por píxel del juego a 1080p).
uniform float alto_linea = 4.0;
uniform float fuerza_lineas : hint_range(0.0, 1.0) = 0.35;
uniform float fuerza_mascara : hint_range(0.0, 1.0) = 0.12;
uniform float resplandor : hint_range(0.0, 2.0) = 0.35;
uniform float aberracion = 0.0012;
uniform float vineta : hint_range(0.0, 1.0) = 0.35;
uniform float curvatura : hint_range(0.0, 0.2) = 0.025;
uniform float parpadeo : hint_range(0.0, 0.1) = 0.012;
uniform float brillo = 1.12;

vec2 curvar(vec2 uv) {
	vec2 d = uv - 0.5;
	return uv + d * dot(d, d) * curvatura * 4.0;
}

void fragment() {
	vec2 uv = curvar(SCREEN_UV);
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		vec2 ab = (uv - 0.5) * aberracion * 2.0;
		vec3 c = vec3(texture(pantalla, uv + ab).r, texture(pantalla, uv).g, texture(pantalla, uv - ab).b);
		// Resplandor: lo claro se derrama un poco (mipmaps de la pantalla).
		vec3 halo = textureLod(pantalla, uv, 3.0).rgb * 0.6 + textureLod(pantalla, uv, 5.0).rgb * 0.4;
		c += max(halo - 0.35, 0.0) * resplandor;
		// Líneas de barrido y máscara de fósforo (columnas R, G, B).
		vec2 px = uv / SCREEN_PIXEL_SIZE;
		float linea = 0.5 + 0.5 * cos(px.y / alto_linea * 6.2831853);
		c *= 1.0 - fuerza_lineas * (1.0 - linea);
		int col = int(mod(px.x, 3.0));
		vec3 mascara = col == 0 ? vec3(1.0, 0.75, 0.75) : (col == 1 ? vec3(0.75, 1.0, 0.75) : vec3(0.75, 0.75, 1.0));
		c *= mix(vec3(1.0), mascara, fuerza_mascara);
		// Viñeta y parpadeo leve.
		vec2 d = uv - 0.5;
		c *= 1.0 - vineta * smoothstep(0.25, 0.75, length(d * vec2(1.0, 0.8)));
		c *= brillo * (1.0 - parpadeo * (0.5 + 0.5 * sin(TIME * 60.0)));
		COLOR = vec4(c, 1.0);
	}
}
