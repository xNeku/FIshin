// Mástil del carril en perspectiva (tipo Guitar Hero / Rocksmith). Se aplica a un TextureRect que enseña
// el carril plano (SubViewport): lo inclina hacia el fondo con perspectiva real y lo desvanece a lo lejos.
shader_type canvas_item;

// Ancho del borde lejano respecto al cercano (1 = sin perspectiva).
uniform float ancho_lejos : hint_range(0.1, 1.0) = 0.42;
// Parte lejana que se funde con el fondo (0..0.5 del largo).
uniform float desvanecer : hint_range(0.0, 0.6) = 0.22;
// Transparencia general del mástil.
uniform float opacidad : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	float w = mix(ancho_lejos, 1.0, UV.y);
	float u = 0.5 + (UV.x - 0.5) / w;
	// Lo de arriba de la pantalla está más lejos: el carril se comprime con 1/z.
	float v = (1.0 / ancho_lejos - 1.0 / w) / (1.0 / ancho_lejos - 1.0);
	if (u < 0.0 || u > 1.0) {
		COLOR = vec4(0.0);
	} else {
		vec4 c = texture(TEXTURE, vec2(u, v));
		c.a *= smoothstep(0.0, desvanecer, v) * opacidad;
		COLOR = c;
	}
}
