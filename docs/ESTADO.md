# ESTADO (traspaso entre sesiones)

## Dónde estamos
Parada para valorar rumbo (29 oct). Hay un tramo jugable de principio a fin de lo diseñado:
- **Pesca**: minijuego completo (cadena de largo variable, dobles desde el 5º botón, machacar, intensidad que crece hasta 50 botones, celebración del pez gordo) con teclas y botones dibujados (teclado, PlayStation, Xbox).
- **Economía**: barca con 6 huecos apilados, comerciante (caña, cebo, huecos, vender todo), dinero y peces que vuelan, bestiario.
- **Mundo**: llegan por datos de la carta el comerciante, la primera isla, el viejo, el camino, el puerto con pescadores automáticos y cubo, y la lonja. Se anda, se salta y se interactúa.
- **Arte**: estilo B pixelado, mar con olas, reflejos y 4 climas; prota en donut que flota sobre la ola; todo en sprite; interfaz estilo Animal Well con filtro retro y animaciones de entrada.
- **Falta**: el árbol de habilidades (espera al diseñador), contenido (solo 6 peces y 3 cañas), rehacer el cebo, balance, música y probar en la tablet el rendimiento de la pasada de arte.

## Mapa rápido del código
- `scripts/pesca/pesca.gd` (Pesca): lógica del minijuego, solo señales. Las stats van en `data/stats_pesca.tres`.
- `scripts/pesca/camara_pesca.gd`: zoom, shake y congelado. `sonido_pesca.gd`: sfx y latido.
- `scripts/economia/juego.gd` (autoload Juego): rublos, capturas, stats, colección, flags, save `user://partida.json`.
- `scripts/ui/hud.gd` + `scenes/ui/hud.tscn`: panel de dinero (Info), teclas del minijuego (Prompt), banner del pez (Resultado), caja de acciones (Accion), aviso de barca llena (Estado). Popups desde `popup_texto.tscn` (solo "+X ₽" y trucos) y la X roja desde `popup_icono.tscn`.
- `scenes/mundo/barca.tscn` (barca.gd), `scenes/mundo/barco_comerciante.tscn`.
- `scripts/ui/menu.gd` + `scenes/ui/menu.tscn` (huecos desde `hueco_barca.tscn`, variantes desde `fila_variante.tscn`).
- `scripts/ui/tienda.gd` + `scenes/ui/tienda.tscn` (filas desde `fila_tienda.tscn`). Los artículos del comerciante se asignan en `barco_comerciante.tscn`.
- Datos: `data/canas/*.tres` (CanaData, se carga por id), `data/articulos/*.tres` (ArticuloData: CANA, CEBO, HUECO).
- Menú y tienda pausan el árbol (`process_mode = Always` en ellos).
- `scripts/pesca/celebracion.gd` (nodo Celebracion en main): levantar pez, luz, brillos, fanfarria y primer plano de la cámara. Los nodos visuales están en barca.tscn (PezLevantado, LuzTrofeo, Brillos).
- `scripts/mundo/mundo.gd` (nodo Mundo en main): lista de AparicionData (`data/apariciones/*.tres`), vigila condiciones, instancia la escena en su casilla ancla y la trae por MAR o desde el CIELO (sombra, caída, impacto). Guarda `aparecido_<id>` en Juego.flags. Bloquea la pesca (Pesca.bloquear) y mueve la cámara (CamaraPesca.enfocar / sacudir).
- Islas: `scenes/mundo/islas/*.tscn` con raíz `isla.gd` (salpicadura + al_llegar_activar). Fuego reutilizable: `scenes/mundo/fuego.tscn` (fuego.gd, activar()).
- AparicionData admite `pieza_por_celda` (tablón por casilla, girado según la forma) y llegada CONSTRUIR. Condiciones: PECES_PESCADOS, RUBLOS_TOTALES, COMBO_MAXIMO (Juego.stats.mejor_combo), MINUTOS_JUGADOS, PUNTOS_PESCA (Juego.stats.puntos_pesca: suma de la racha de cada pez, ×2 si perfecto; premia pescar bien). `requiere` (ids que deben haber llegado antes), `celdas_bloqueadas` (ocupadas pero no pisables). Llegadas: MAR, CIELO, CONSTRUIR, EMERGER.
- Sincronizar la carta: leer `elementos` y copiar las celdas a `data/apariciones/<id>.tres` (camino, puerto...).
- Casilla de la carta → mundo: (x, y) → Vector3(x*2, 0, -y*2).
- `scripts/jugador/jugador.gd` + `scenes/jugador/jugador.tscn` (nodo Jugador en main): modo andar, casillas pisables (Mundo.celdas_pisables), salto, interacción con el grupo "interactuables". Juego.en_movimiento = true mientras anda.
- `scripts/mundo/interactuable.gd` (Interactuable): nodos en las islas con accion TIENDA (nombre, articulos, compra_peces, saludos) o BESTIARIO. La Tienda acepta cualquier vendedor con esos campos.
- `scripts/ui/bestiario.gd` + `scenes/ui/bestiario.tscn` (fichas desde `ficha_bestiario.tscn`).
- `scripts/economia/trucos.gd` (nodo Trucos en main): F1 +100 ₽, F2 +50 peces, F3 +5 min, F4 +5 de mejor combo y +200 puntos de pesca, F5 +1 pescador. Solo en builds de depuración.
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
- Interfaz pixel: todo sale del tema `art/tema.tres` (fuente `art/fuentes/FishinPixel.ttf`, piezas 9-slice en `art/ui/`). Variaciones: Titulo (gris), Pequeno, Grande, Dinero (amarillo), PanelSeleccion, BarraNaranja. Tamaños de letra en múltiplos de 10 (1 píxel de fuente = tamaño/10). La fuente sale de Pixelify Sans (OFL, licencia en `art/fuentes/FishinPixel-OFL.txt`) ajustada a rejilla; el 2 y el 5 están redibujados.
- Iconos de teclas: pack CC0 de Xelu (vía addon Controller Icons), pixelados a 24 px con contorno blanco y versión _pulsada, en `art/ui/teclas/<teclado|xbox|ps>_<accion>[_pulsada].png` (créditos en CREDITOS.txt). El HUD elige según el último dispositivo tocado; el tipo de mando sale de su nombre (Input.get_joy_name) y, si no se reconoce, `HUD.mando_por_defecto` (ps).
- Animación de entrada: `scenes/ui/animacion_entrada.tscn` como hija de una ventana o popup; se lanza sola al aparecer. Estilos LINEA (raya que se abre a saltos), CAIDA, PARPADEO, FUNDIDO; duración, pasos y sonido (`art/sfx/abrir.wav`) por instancia. Puesta en menú, tienda, bestiario, diálogo, banner del pez, caja de acciones y aviso de barca llena.
- Caja de acciones (abajo a la derecha, nodo Accion del HUD): junta `Jugador.acciones()` y hablar con el comerciante; si hay varias, alterna cada `HUD.cambio_acciones` (2 s). En el donut siempre está la Q en cuanto hay tierra.
- Filtro CRT: `scenes/efectos/crt.tscn` (capa 100, valores en el material de Filtro). Se guarda en las opciones (`Juego.opcion` / `poner_opcion`, `user://opciones.cfg`, aparte del save para que borrar partida no lo toque); botón en Opciones.
- Guardado: se escribe a `partida.json.tmp` y se cambia por el bueno; el anterior queda en `partida.anterior.json` y se carga si el principal está roto. El dinero que va volando en una venta (`Juego.dinero_en_camino`) se guarda como si hubiera llegado.
- Llegada por mar: `Mundo._lado_de_llegada` (punto cardinal del centro de la isla vista desde la barca).
- Árbol de habilidades: datos en `data/arbol/` (`arbol.tres` con ramas y nodos; RamaArbolData, NodoArbolData). Juego guarda `habilidades` (id → nivel, save v4) y da `Juego.efecto(nombre)`, `mejorar_habilidad`, `motivo_no_mejorar`, `mult_venta`, `mult_trabajadores`, `de_chill` (segundos sin tocar nada). Pantalla: `scenes/ui/arbol.tscn` (arbol.gd), con cada nodo como instancia de `nodo_arbol.tscn` colocada a mano en Lienzo/Nodos; los caminos (`conexion_arbol.tscn`, shader `agua_camino`) se trazan solos por los requisitos. Se abre con el viejo (Interactuable accion ARBOL), que tiene botón a su tienda. Iconos 12×12 en `art/ui/arbol/iconos/` (blancos, se tiñen con el color de la rama).
- `scripts/ui/iconos_input.gd` (IconosInput): dibujos de teclas según el dispositivo; lo usan HUD, árbol y las pistas de los menús (`scenes/ui/pista_accion.tscn`).
- Mando: Cruz/A aceptar e interactuar, Círculo/B cancelar, L1/R1 pestañas o ramas (L1 en juego = bajar/subir al donut), Triángulo/Y acción extra (vender todo, tienda del viejo), Start menú.
- Peces: `data/peces/*.tres` (PezData, 201 especies), generados desde `docs/datos/peces_fuente.csv` con `docs/herramientas/importar_peces.py`. Iconos placeholder en `art/peces/` (generados por forma, sustituibles). La Pesca carga la carpeta entera (`Pesca.carpeta_peces`).

## Herramientas de diseño (artefactos)
- Carta de Fishin (mapa): https://claude.ai/artifact/2oRoaePEyuUyDUYBJnK9oA. Colección `elementos` con {nombre, tipo, estado, x, y, w, h (caja), celdas [[x,y]...] (forma real; si falta, es el rectángulo de la caja), orden, condicion, descripcion}. Coordenadas: barca en (0,0), x a la derecha, y hacia arriba (en Godot, y+ = -Z). 1 casilla = 2 m.
- Árbol de Fishin: https://claude.ai/artifact/UtP4gNUbFFwpX9SPeTcTnu. Colecciones `ramas` {nombre, descripcion, orden, color} y `nodos` {nombre, rama (id), nivel, coste, estado, efecto, descripcion, requisitos[]}.
- Se leen con ArtifactData (list). El código fuente está en `docs/herramientas/`.

## Última sesión (29 oct, tarde)
- Limpieza: fuera assets y exports sin uso; bugs arreglados (bucle infinito del puerto sin bordes libres, dinero perdido al cerrar a mitad de venta, filtro CRT que se reseteaba al borrar partida; guardado atómico con copia).
- Rendimiento: caché de casillas pisables, nodos del árbol parados con el árbol cerrado, efecto de pantalla del HUD apagado si no hace nada. El coste de los scripts por fotograma es bajo (~1,5 ms en headless con todo el mundo); lo que pesa es la GPU (Forward+, pixelado, CRT).
- Gráficos: atril del bestiario redibujado, iconos hamaca y brazo, rejilla de pesca más suave (`zona_pesca.gdshader`: `linea_tenue`, `largo_cruce`).
- Estudio: `docs/INCREMENTAL.md` con fórmulas de incremental aplicadas a Fishin. Hallazgo: la curva de combo lineal no premia los combos largos, y la cadena no pasa del perfect.

## Sesión 29 oct (noche)
- Balance de combo, ritmo, chill y pescadores por fórmula, con el simulador v2 (`docs/herramientas/simular_economia.py`) y lo aprendido de osu!, Guitar Hero, AdVenture Capitalist, Cookie Clicker y Cast n Chill (`docs/INCREMENTAL.md`).

## Sesión 30 oct
- Juego de 15-20 h: tramos nuevos (midgame a las 5-6 h), tabla del ciclo (caña, peces, combos, racha y pasivo suben juntos) y orientación v3 en `PROGRESION.md`.
- Datos: espera 8-20 s; cañas sin bonus de tiempo; árbol de tiempo recortado (como mucho +15 %); cebo de gusano +20 % durante 10 pescas; caña decente 300, Sabia 4.500; isla a 400 ₽ totales, camino a 40 min, lonja a 6.500, viejo a 75 peces.
- Maestría por especie (`Juego.capturados`, save v5) en el bestiario.

## Sesión 30 oct (tarde)
- Modo flow: un 30 % menos de tiempo por botón, mínimo 0,3 s. El sushi no caduca (decidido).
- Puntos de pesca (`Juego.stats.puntos_pesca`, condición PUNTOS_PESCA): camino a 700 y puerto a 1.000. El que pesca mejor llega antes.
- Catálogo de 201 especies desde el Excel del diseñador (`docs/datos/peces_fuente.csv`, `docs/herramientas/importar_peces.py 22 1.35`). Rareza en 6 categorías, peso por nivel de profundidad, iconos por forma.
  - La Pesca carga la carpeta `data/peces`; main.tscn ya no lleva la lista.
  - Sabia a 6.000 ₽ y lonja a 10.000 ₽ totales.
- El simulador lee los .tres directamente.

## Sesión 30 oct (noche): mando
- Causa de fondo: en Godot 4.7, `ui_accept` y `ui_cancel` de serie no traen botones de mando. Ahora están en el Input Map: aceptar = Cruz/A, Enter, Espacio; cancelar = Círculo/B, Esc.
- Acciones nuevas: `pestana_anterior` (L1/LB, Q), `pestana_siguiente` (R1/RB, E) y `accion_extra` (Triángulo/Y, T).
- Tienda: foco al abrir y tras comprar; Círculo/Tab cierra (la E solo con teclado); Triángulo vende todo. Esto arregla el bloqueo de no poder vender con mando.
- Menú de pausa: L1/R1 cambian de pestaña; el foco cae en la pestaña; Círculo vuelve.
- Árbol: navegación propia con cruceta y stick (`_navegar_mando`: nodo más cercano en esa dirección, con repetición al mantener); L1/R1 saltan de rama; Triángulo abre la tienda del viejo; Círculo sale (ya no L1).
- Bestiario: Círculo cierra; el stick o la cruceta desplazan la lista. Diálogo: Círculo cierra.
- Pistas con el dibujo del botón: `scenes/ui/pista_accion.tscn` (PistaAccion: acción + texto, detecta el mando también en pausa). Puestas en la tienda, el menú, el bestiario y el árbol.
- Iconos nuevos en `art/ui/teclas/` (ui_accept, ui_cancel, pestana_*, accion_extra); L1/R1/LB/RB redibujados para que se lean.

## Sesión 31 oct
- Prueba del diseñador: 29 min, 93 peces y 3,36K ₽. El simulador daba ~99 peces y ~3,5K a esa altura, así que cuadra.
- Interactuar: el botón sale encima de la cabeza (`HUD._icono_interactuar`, nodo `Popups/IconoInteractuar`; altura en `Interactuable.altura_icono` y `BarcoComerciante.altura_icono`). La caja de abajo a la derecha solo enseña la Q.
- Carta del pez abajo a la izquierda, con ¡NUEVO! la primera vez. Dura 4 s si es nueva y 2,5 s si no (`HUD.duracion_carta_nueva` / `duracion_carta`).
- El viejo y sus cosas, en la fila del fondo de su isla (`isla_skilltree.tscn`).
- Agua:
  - Máscara de tierra (`Agua.actualizar_tierra`, `mascara_tierra` en el shader): pegado a la costa se calma. Antes, con lluvia o tormenta, las olas (0,29-0,57 m) pasaban del suelo de las islas (0,25 m).
  - Opción "Agua: con bandas / realista" (`estilo_bandas`, `Juego.opcion("agua_bandas")`).
- Viejo a los 75 peces (~min 23).

## Nitidez (31 oct)
- Filtro CRT nítido: lee la imagen píxel a píxel (`filter_nearest`); sin curvatura ni aberración; resplandor 0,2. Los valores siguen en el material de `crt.tscn`.
- Píxeles del mundo: opción en Opciones (grandes 4 / medianos 3 / finos 2; `Pixelador.poner_encogimiento`, `Juego.opcion("pixel_mundo")`). Por defecto, medianos. Con 4, cada píxel del dibujo de los personajes ocupaba ~1,3 píxeles del mundo y se veían emborronados.
- No hay ciclo de día y noche: lo oscuro era el clima de tormenta. El reloj (día/noche, estaciones) está pendiente de que el diseñador decida duraciones.

## Siguiente paso
Sesión de progresión con el diseñador hasta el midgame (economía y orden de desbloqueos), partiendo de `docs/PROGRESION.md` (borrador v1) y `docs/INCREMENTAL.md`.

Ahora: el diseñador prueba el árbol de habilidades (60 nodos de propuesta) y revisa nodos, costes y efectos. Siguiente gran bloque: T2 (huerto de algas, sushi con suministro, taladro de coral) según `docs/PROGRESION.md`.

Por decidir con el diseñador en la charla de rumbo. Candidatos:
1. Probar en la tablet (rendimiento de pixelado + SSR + lluvia + CRT) y una partida larga de principio a fin para ajustar el ritmo de los primeros 30 min.
2. Árbol de habilidades (datos + interfaz del viejo) cuando el diseñador lo rellene.
3. Contenido: Excel de peces (día/noche, estación) y decidir cómo pasa el tiempo.
4. Rehacer el cebo (probabilidades + duración en segundos).
5. Música y sonido de verdad.

## Decisiones recientes
- 2.5D, Forward+, juego de PC. Moneda: rublos (₽). Fuente pixel propia Fishin Pixel (tiene ₽ y flechas).
- La intensidad visual va por botones seguidos (no por % del pez); el máximo llega con combos de 50 (final de juego). Las dobles salen desde el 5º botón.
- Largo de cadena aleatorio por picada (CanaData.tirar_largo_cadena), sesgado a corto.
- Barca llena (todos los huecos): no pica nada hasta vender. Sin progreso offline.
- Machacar fallido: los extraños y legendarios se escapan, los demás pierden valor.
- Niebla del clima activa (Forward+); en Compatibility lo dejaba todo gris.
- Sin frases en el HUD: fuera llegadas, ¡PICA!, calidad y estado de arriba (solo queda "¡Barca llena! Ve a vender"). Fallo/escape = X roja (`scenes/ui/popup_icono.tscn`, `art/ui/x_roja.png`). `AparicionData.texto_llegada` ya no se usa.
- Nada de textos flotantes en el mundo (ni carteles, ni contadores encima de pescadores o cubo). Las frases de acierto del minijuego están comentadas en hud.gd (_on_acierto) para retomarlas más adelante.
- Interfaz estilo Animal Well (paneles negros, borde blanco, selección amarilla) con filtro retro de tubo y animaciones de entrada. Teclas dibujadas del pack CC0 de Xelu; mando PlayStation por defecto, también Xbox. Acción posible abajo a la derecha, alternando cada 2 s si hay varias.
- El náufrago no pesca solo (fuera el piloto). Lo pasivo nunca sustituye a pescar a mano.
- Racha: cada botón acertado paga una parte del pez, y en racha paga más (×1,25 desde el 5.º ... ×6 desde el 200.º; `StatsPesca.racha_desde` / `racha_mult`). Al subir de tramo suenan un arpegio y un destello y el contador cambia de color. Ver `docs/INCREMENTAL.md` §6.
- Pesca tranquila: esperas de 8-20 s con picoteos del corcho y aviso antes de picar. De chill (8 s sin tocar nada), el pez que no tocas se va sin castigo (`Pesca.pez_se_va`). Peces ×2,5 de valor para mantener el ₽/min. Pescadores rebajados a ~8,3 ₽/min. La rejilla de la zona de pesca está oculta (ZonaPesca, visible = false en main.tscn).
- Estilo B pixelado, sin desenfoque. Nada de modelos 3D en objetos. Prota en donut rosa (no hay barca), piernas de frente, caña a la derecha. Viejo entre palmeras con hoguera delante.

## Pendiente del diseñador
1. Excel de peces (enciclopedia, pesos, día/noche, estación).
2. Imagen de referencia del flow del árbol + rellenar el Árbol de Fishin.
3. Lista de cebos y efectos (duplicar pesca, más probabilidad de X...).
4. Seguir rellenando la carta (siguientes islas y edificios).
5. Decidir cómo pasa el tiempo (día/noche, estaciones) para los peces del Excel.
6. Probar en la tablet y decir si va fluido.
