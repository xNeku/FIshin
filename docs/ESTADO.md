# ESTADO (traspaso entre sesiones)

## Dónde estamos
Pasada de arte hecha (estilo B, la demo que le gustó al diseñador): mundo pixelado a 1/4 con HUD nítido (sin desenfoque), mar nuevo con olas, reflejos y climas, prota tumbado en un donut rosa que flota sobre la ola con caña, corcho y ondas, suelos y tablones con textura pixel, barco del comerciante y props en sprite, y el viejo entre palmeras con la hoguera delante. Ya no quedan modelos 3D en objetos.
Fase 3 casi completa: el mundo crece (apariciones por datos) y ya se puede andar (Q), saltar entre barca e islas e interactuar (E) con el viejo (tienda) y el bestiario. Falta el árbol de habilidades (espera al diseñador). Puerto pesquero funcionando: pescadores automáticos que llenan el cubo; el náufrago lo coge y lo vende. Ventas animadas (peces y dinero volando). Lonja: emerge del mar y vende de golpe barca + cubo.
Fase 2 hecha: bucle pescar → vender → mejorar. Cañas por profundidad, cebo, huecos de barca apilados por especie, tienda del comerciante (E) y menú (Tab) (Barca, Stats, Opciones). Save v2. Falta que el diseñador lo pruebe a mano.

## Mapa rápido del código
- `scripts/pesca/pesca.gd` (Pesca): lógica del minijuego, solo señales. Las stats van en `data/stats_pesca.tres`.
- `scripts/pesca/camara_pesca.gd`: zoom, shake y congelado. `sonido_pesca.gd`: sfx y latido.
- `scripts/economia/juego.gd` (autoload Juego): rublos, capturas, stats, colección, flags, save `user://partida.json`.
- `scripts/ui/hud.gd` + `scenes/ui/hud.tscn`. Popups desde `scenes/ui/popup_texto.tscn`.
- `scenes/mundo/barca.tscn` (barca.gd), `scenes/mundo/barco_comerciante.tscn`.
- `scripts/ui/menu.gd` + `scenes/ui/menu.tscn` (huecos desde `hueco_barca.tscn`, variantes desde `fila_variante.tscn`).
- `scripts/ui/tienda.gd` + `scenes/ui/tienda.tscn` (filas desde `fila_tienda.tscn`). Los artículos del comerciante se asignan en `barco_comerciante.tscn`.
- Datos: `data/canas/*.tres` (CanaData, se carga por id), `data/articulos/*.tres` (ArticuloData: CANA, CEBO, HUECO).
- Menú y tienda pausan el árbol (`process_mode = Always` en ellos).
- `scripts/pesca/celebracion.gd` (nodo Celebracion en main): levantar pez, luz, brillos, fanfarria y primer plano de la cámara. Los nodos visuales están en barca.tscn (PezLevantado, LuzTrofeo, Brillos).
- `scripts/mundo/mundo.gd` (nodo Mundo en main): lista de AparicionData (`data/apariciones/*.tres`), vigila condiciones, instancia la escena en su casilla ancla y la trae por MAR o desde el CIELO (sombra, caída, impacto). Guarda `aparecido_<id>` en Juego.flags. Bloquea la pesca (Pesca.bloquear) y mueve la cámara (CamaraPesca.enfocar / sacudir).
- Islas: `scenes/mundo/islas/*.tscn` con raíz `isla.gd` (salpicadura + al_llegar_activar). Fuego reutilizable: `scenes/mundo/fuego.tscn` (fuego.gd, activar()).
- AparicionData admite `pieza_por_celda` (tablón por casilla, girado según la forma) y llegada CONSTRUIR. Condiciones: PECES_PESCADOS, RUBLOS_TOTALES, COMBO_MAXIMO (Juego.stats.mejor_combo), MINUTOS_JUGADOS. `requiere` (ids que deben haber llegado antes), `celdas_bloqueadas` (ocupadas pero no pisables). Llegadas: MAR, CIELO, CONSTRUIR, EMERGER.
- Sincronizar la carta: leer `elementos` y copiar las celdas a `data/apariciones/<id>.tres` (camino, puerto...).
- Casilla de la carta → mundo: (x, y) → Vector3(x*2, 0, -y*2).
- `scripts/jugador/jugador.gd` + `scenes/jugador/jugador.tscn` (nodo Jugador en main): modo andar, casillas pisables (Mundo.celdas_pisables), salto, interacción con el grupo "interactuables". Juego.en_movimiento = true mientras anda.
- `scripts/mundo/interactuable.gd` (Interactuable): nodos en las islas con accion TIENDA (nombre, articulos, compra_peces, saludos) o BESTIARIO. La Tienda acepta cualquier vendedor con esos campos.
- `scripts/ui/bestiario.gd` + `scenes/ui/bestiario.tscn` (fichas desde `ficha_bestiario.tscn`).
- `scripts/economia/trucos.gd` (nodo Trucos en main): F1 +100 ₽, F2 +50 peces, F3 +5 min, F4 +5 de mejor combo, F5 +1 pescador. Solo en builds de depuración.
- `scripts/ui/dialogo.gd` + `scenes/ui/dialogo.tscn`: diálogo tipo Pokémon (Interactuable accion DIALOGO, lineas).
- `scenes/efectos/vuelos.tscn` (autoload Vuelos): piezas que vuelan en parábola persiguiendo a quien recibe. `enviar`, `enviar_peces`, `enviar_dinero` (suma rublos al llegar cada pieza), `repartir` (monedas/billetes/fajos/sacos).
- `scripts/economia/comercio.gd` (nodo Comercio en main): `vender_barca(comprador)` y `vender_cubo(comprador)` con animación. La Tienda lo usa al pulsar "Vender todo".
- Puerto: `scripts/mundo/puerto.gd` (raíz de puerto_pesquero.tscn, hereda de Isla) contrata pescadores según Juego.trabajadores y elige puestos (Mundo.puestos_de_pesca, cerca de compañeros). `trabajador.gd` + `scenes/mundo/trabajador.tscn`: puesto → pescar el pez más barato → cubo (Mundo.ruta con saltos). `cubo.gd`. Juego guarda trabajadores, cubo_capturas y cubo_en_mano (save v3).
- Interactuable accion VENTA: Comercio.vender_todo (barca + cubo en mano), sin menú (la lonja).
- Interactuable tiene `prioridad` (cubo 2, comerciante 1, charla 0). El barco comerciante tiene su Interactuable para cuando vas andando.
- `scenes/main.tscn`: lo monta todo.
- Pixelado: `scripts/efectos/pixelador.gd` + `scenes/efectos/pixelador.tscn` (en main, grupo "pixelador"). Copia la cámara del juego a una SubViewport a 1/4 y la escala sin suavizar.
- Mar: `shaders/agua.gdshader` (4 olas, detalle con normal maps, anillos de lluvia) + `scripts/mundo/agua.gd` (Agua, en el nodo Agua de main): lleva el tiempo de las olas y da `altura(p)`, `pendiente(p)` y `pegar(sprite, p, alto)` para lo que flota. Si cambias las olas en el shader, cámbialas también en agua.gd. Clima: `scripts/mundo/clima.gd` (nodo Clima en main) con `data/climas/*.tres` (ClimaData): cielo, nubes, sol, niebla, colores del mar, olas, lluvia, relámpagos.
- Donut: `scenes/mundo/barca.tscn` (barca.gd): capas DonutAtras, Protagonista, DonutDelante, Piernas (mismo lienzo 64x58, offset para que la base quede en el origen); flota con Agua; Sombra y Espuma pegadas al agua; poses chill/tira (la punta de la caña va por píxel del sprite), corcho con lanzado, sedal, ondas y salpicadura. Trofeo tumbado en Celebracion.textura_trofeo. Foco (Marker3D) es el punto al que mira la cámara en el primer plano y de donde salen los peces que vuelan.
- Barco comerciante: capas Fondo, Comerciante, Delante (`art/mundo/barco_*.png`), flota con Agua.
- Arte del mundo: suelos en `art/mundo/suelo/` con materiales en `art/materiales/` (triplanar, se cambian ahí para todas las islas), props en `art/mundo/props/`. Los PNG nuevos llevan `detect_3d/compress_to=0` para que el editor no los reimporte solo.
- Peces: `data/peces/*.tres` (PezData). Arte placeholder en `art/` (generado por script, sustituible).

## Herramientas de diseño (artefactos)
- Carta de Fishin (mapa): https://claude.ai/artifact/2oRoaePEyuUyDUYBJnK9oA. Colección `elementos` con {nombre, tipo, estado, x, y, w, h (caja), celdas [[x,y]...] (forma real; si falta, es el rectángulo de la caja), orden, condicion, descripcion}. Coordenadas: barca en (0,0), x a la derecha, y hacia arriba (en Godot, y+ = -Z). 1 casilla = 2 m.
- Árbol de Fishin: https://claude.ai/artifact/UtP4gNUbFFwpX9SPeTcTnu. Colecciones `ramas` {nombre, descripcion, orden, color} y `nodos` {nombre, rama (id), nivel, coste, estado, efecto, descripcion, requisitos[]}.
- Se leen con ArtifactData (list). El código fuente está en `docs/herramientas/`.

## Siguiente paso
1. Que el diseñador pruebe la pasada de arte (donut flotando, mar, climas con F6, islas, barco).
2. Árbol de habilidades: pasar el artefacto a datos cuando el diseñador lo rellene.
3. Rehacer el cebo: probabilidades + duración en segundos.

## Decisiones recientes
- 2.5D, Forward+, juego de PC. Moneda: rublos (₽). Fuente DejaVu Sans Bold (tiene ₽ y flechas).
- La intensidad visual va por botones seguidos (no por % del pez); el máximo llega con combos de 50 (final de juego). Las dobles salen desde el 5º botón.
- Largo de cadena aleatorio por picada (CanaData.tirar_largo_cadena), sesgado a corto.
- Barca llena (todos los huecos): no pica nada hasta vender. Sin progreso offline.
- Machacar fallido: los extraños y legendarios se escapan, los demás pierden valor.
- Niebla del clima activa (Forward+); en Compatibility lo dejaba todo gris.
- Estilo B pixelado, sin desenfoque. Nada de modelos 3D en objetos. Prota en donut rosa (no hay barca), piernas de frente, caña a la derecha. Viejo entre palmeras con hoguera delante.

## Pendiente del diseñador
1. Excel de peces (enciclopedia, pesos, día/noche, estación).
2. Imagen de referencia del flow del árbol + rellenar el Árbol de Fishin.
3. Lista de cebos y efectos (duplicar pesca, más probabilidad de X...).
4. Seguir rellenando la carta.
