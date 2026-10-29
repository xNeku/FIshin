shader_type canvas_item;
// Camino del árbol de habilidades (va en un Line2D con textura estirada: UV.x recorre la línea).
// Vacío: raya oscura discontinua. Disponible: un hilillo de agua que avanza. Lleno: agua que corre
// con olas y brillos, y espuma en el frente mientras se está llenando. Todo a saltos de píxel.

uniform vec4 color_agua : source_color = vec4(0.35, 0.82, 1.0, 1.0);
uniform vec4 color_vacio : source_color = vec4(0.22, 0.24, 0.32, 1.0);
// 0..1: hasta dónde ha llegado el agua.
uniform float lleno : hint_range(0.0, 1.0) = 0.0;
// 1 = se puede comprar el nodo al que lleva: hilillo que avanza.
uniform float goteo : hint_range(0.0, 1.0) = 0.0;
// Largo de la línea en píxeles (lo pone el script) y tamaño del píxel del juego.
uniform float largo = 200.0;
uniform float tam_pixel = 4.0;
uniform float velocidad = 1.0;

void fragment() {
	float px = floor(UV.x * largo / tam_pixel) * tam_pixel;
	float x = px / max(largo, 1.0);
	float fila = floor(UV.y * 3.0);
	float t = TIME * velocidad;
	vec4 c = color_vacio;
	float raya = step(0.5, fract(px / (tam_pixel * 3.0)));
	c.a = mix(0.25, 0.6, raya);
	if (x <= lleno) {
		// Olas que corren hacia el nodo.
		float ola = 0.5 + 0.5 * sin(px / 14.0 - t * 6.0);
		vec3 agua = mix(color_agua.rgb * 0.55, color_agua.rgb, step(0.5, ola));
		// Brillos sueltos que viajan.
		float brillo = step(0.9, fract(px / 52.0 - t * 1.2));
		agua = mix(agua, vec3(1.0), brillo * 0.85);
		// Borde de arriba más claro, de abajo más oscuro.
		agua = mix(agua, vec3(1.0), step(fila, 0.0) * 0.3);
		agua *= mix(1.0, 0.7, step(2.0, fila));
		c = vec4(agua, 1.0);
		// Espuma en el frente mientras se llena.
		if (lleno < 0.999 && x > lleno - tam_pixel * 2.0 / max(largo, 1.0)) {
			c.rgb = vec3(1.0);
		}
	} else if (goteo > 0.0) {
		float gota = step(0.8, fract(px / 36.0 - t * 1.5));
		c = mix(c, vec4(color_agua.rgb, 0.9), gota * goteo);
	}
	COLOR = c;
}
