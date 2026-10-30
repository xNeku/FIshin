shader_type canvas_item;
// Efecto de "adentrarse": viñeta, aberración cromática y saturación que crecen con la pesca.

uniform sampler2D pantalla : hint_screen_texture, filter_linear_mipmap;
uniform float intensidad : hint_range(0.0, 1.0) = 0.0;
uniform float destello : hint_range(0.0, 1.0) = 0.0;
// Color del destello (blanco; al picar un pez raro, el de su rareza).
uniform vec4 color_destello : source_color = vec4(1.0);
uniform vec4 color_vineta : source_color = vec4(0.06, 0.0, 0.12, 1.0);
uniform float aberracion_maxima = 0.012;
uniform float saturacion_extra = 0.7;
uniform float vineta_maxima = 0.65;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 d = uv - 0.5;
	float r = length(d);
	vec2 ab = d * aberracion_maxima * intensidad * 2.0;
	vec3 c;
	c.r = texture(pantalla, uv + ab).r;
	c.g = texture(pantalla, uv).g;
	c.b = texture(pantalla, uv - ab).b;
	float gris = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(vec3(gris), c, 1.0 + saturacion_extra * intensidad);
	float v = smoothstep(0.75 - vineta_maxima * intensidad * 0.6, 0.2, r);
	c = mix(color_vineta.rgb, c, mix(1.0, v, intensidad * vineta_maxima + 0.15));
	c += color_destello.rgb * destello * 0.18;
	COLOR = vec4(c, 1.0);
}
