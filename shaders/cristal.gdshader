shader_type canvas_item;
// Panel de cristal: difumina lo que tiene detrás (lee la pantalla con desenfoque) y lo tiñe,
// con el borde y el brillo del dibujo del panel (art/ui/panel_cristal.png) por encima.
// Se pone como material de un PanelContainer con la variación de tema PanelCristal.

uniform sampler2D pantalla : hint_screen_texture, filter_linear_mipmap;
// Cuánto se difumina el fondo (nivel de mipmap: 0 nítido, 3-4 muy difuso).
uniform float desenfoque : hint_range(0.0, 6.0) = 3.0;
// Color del cristal y cuánto tapa el fondo.
uniform vec4 tinte : source_color = vec4(0.07, 0.15, 0.27, 1.0);
uniform float opacidad : hint_range(0.0, 1.0) = 0.62;
// Un poco de luz extra en el fondo difuminado (cristal claro).
uniform float claridad : hint_range(0.0, 1.0) = 0.12;

void fragment() {
	vec4 caja = texture(TEXTURE, UV) * COLOR;
	if (caja.a < 0.01) {
		COLOR = vec4(0.0);
	} else {
		vec3 fondo = textureLod(pantalla, SCREEN_UV, desenfoque).rgb;
		fondo = mix(fondo, vec3(1.0), claridad);
		vec3 c = mix(fondo, tinte.rgb, opacidad);
		// El dibujo del panel manda donde es opaco (borde, brillo); en el interior, casi transparente, deja ver el cristal.
		float dibujo = smoothstep(0.3, 0.95, caja.a);
		c = mix(c, caja.rgb, dibujo);
		COLOR = vec4(c, 1.0);
	}
}
