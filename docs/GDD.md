# GDD — Fishin (nombre provisional)

Marcas: [DECIDIDO] lo decidió el diseñador · [PROPUESTA] sugerencia de Claude sin confirmar · [ABIERTO] sin decidir.

## 1. Concepto
- [DECIDIDO] Incremental de pesca con expansión de terreno al estilo Forager. Objetivo: dopamina y vitalidad.
- [DECIDIDO] Meta del protagonista: pescar todos los peces que existen y estar en paz. Una colección completa como objetivo final.
- [DECIDIDO] Fantasía: empiezas de náufrago en una barca reventada y acabas con una villa pesquera centrada en ti. Todo el mundo pesca, vende y compra para ti.
- [DECIDIDO] Referencias: Coal LLC (estilo y tono), Forager (expansión), Octopath Traveler (2.5D).

## 2. Estilo visual
- [DECIDIDO] Pixel art simple con personalidad. Placeholders hechos por Claude (nada de bloques grises), arte final del diseñador.
- [DECIDIDO] 2.5D: mundo 3D de casillas low-poly con personajes pixel art en sprites mirando a cámara (tipo HD-2D), con shaders y efectos. Renderer Forward+.
- [DECIDIDO] Plataformas: Windows y Mac. Móvil más adelante.

## 3. Protagonista
- [DECIDIDO] Náufrago dejado, consumido por tabaco, alcohol y malos vicios, pero carismático y buen rollero. Está de puto chill porque es un máquina.
- [DECIDIDO] Inspirado en el personaje de Hotline Miami de la referencia: barba y melena de náufrago, sin gafas, pelo negro, más moreno de piel, sonrisa pícara.

## 4. Mundo y cuadrícula
- [DECIDIDO] El mapa es una cuadrícula/matriz. La barca está en (0,0).
- [DECIDIDO] Las 8 casillas adyacentes a la barca son agua permanente: el área 3x3 es la zona de pesca.
- [DECIDIDO] Islotes, barcos y edificios (mercados, casinos, tiendas de anzuelos...) se pegan solos al superar hitos (dinero, logros). El jugador no elige dónde ni paga por todos.
- [DECIDIDO] Los hitos se cumplen en cuanto se supera el valor, no hace falta pasar justo por él.
- [ABIERTO] Regla de colocación automática: dónde aparece cada cosa nueva.

## 5. Modos de juego
- [DECIDIDO] **Modo pesca** (en la barca). Es la única acción manual de pesca; todo lo demás lo automatizan fábricas y trabajadores.
- [DECIDIDO] **Modo movimiento**: un botón saca del modo pesca y el personaje se mueve como en cualquier juego. Si anda desde la barca hacia una isla adyacente, salta por encima del agua (y al revés para volver).
- [DECIDIDO] Al principio no puedes moverte porque no hay suelo.
- [PROPUESTA] Teclas: WASD para moverse, Q para entrar y salir del modo pesca.
- [PROPUESTA] Implementado: Q solo baja a tierra si ya ha llegado alguna isla y no estás en mitad de una pesca; para volver a pescar hay que estar en la barca. Saltas el agua si al empujar contra ella hay suelo a dos casillas, enfrente o en la diagonal (la barca es 1×1). Mientras andas no pica nada.
- [PROPUESTA] E con el viejo abre su tienda (Sabia caña) con frases suyas; el árbol aún no existe y lo dice él. E en el bestiario abre el libro: especies pescadas con su mejor calidad y las demás en silueta "???".
- [PROPUESTA] Interactuar con la tecla E abre un diálogo tipo Pokémon.

## 6. Pesca (núcleo)
- [DECIDIDO] En la barca el personaje espera a que pique. Cuando pica, sale un botón en pantalla.
- [DECIDIDO] Cadena de botones: cada acierto mejora la calidad del pez y cada botón da menos tiempo para reaccionar que el anterior.
- [DECIDIDO] La pesca acaba al fallar o al llegar al límite natural de la cadena. El límite sube con el árbol de habilidades.
- [DECIDIDO] El largo de la cadena no es fijo: en cada picada sale uno distinto, muchas veces solo 1 o 2 botones. El juego es lento y progresivo.
- [PROPUESTA] Cada caña define `cadena_min`, `cadena_max` y `sesgo_cadena` (cuánto tira a corto). Caña rota 1–5 (el 44 % de las picadas da 1 botón), decente 2–9 y pro 3–15. La rama Destreza podría bajar el sesgo.
- [DECIDIDO] Sensación de adentrarse: zoom con shake hacia el jugador según el progreso. El juego sabe cuántas pulsaciones hacen falta para el perfect.
- [DECIDIDO] Futuro: modo infinito (zoom de ida y vuelta en bucle) y música con el beat cuadrado a las pulsaciones.
- [PROPUESTA] Implementado: viñeta, aberración cromática, latido que acelera, tono de acierto que sube, el botón salta por la pantalla cuanto más dentro estás, y un congelado breve al capturar.
- [PROPUESTA] Si la caña tiene menos límite que los pasos del pez, no llegas al perfect (gancho para mejorar la caña).
- [DECIDIDO] El espectáculo (shake, zoom, efectos, frases) se descubre poco a poco según avanzas; al principio es suave.
- [DECIDIDO] La escala es de juego entero: al final habrá combos de ~50 botones y ahí es donde se tiene que notar la locura. Al principio, muy ligero.
- [PROPUESTA] Va por botones seguidos: el máximo llega a los 50 (`StatsPesca.botones_intensidad_maxima`). Las frases suben en 1, 5, 10, 20, 35 y 50. El latido empieza hacia los 10 botones.
- [DECIDIDO] Las dobles tardan en salir. [PROPUESTA] Solo desde el 5º botón de la cadena (`dobles_desde_boton`).
- [DECIDIDO] Celebración al sacar algo muy tocho: el náufrago levanta el pez con las manos, luz encima, primer plano y musiquilla (estilo Zelda).
- [PROPUESTA] Se celebra lo extraño o legendario, o cualquier pez de 15 kg o más (nodo `Celebracion` en main.tscn).
- [DECIDIDO] Peces pesados o especiales tienen tramos de machacar un botón para llenar una barra. Si no la llenas, pierdes el pez o te lo quedas con peores stats.
- [DECIDIDO] Al no llenar la barra depende del pez: los legendarios y los extraños se escapan, y los normales salen peores.
- [DECIDIDO] También hay pulsaciones dobles (tipo R2 + X).
- [DECIDIDO] Teclado: números con la mano izquierda y flechas con la derecha. Las dobles combinan una de cada.
- [DECIDIDO] Auto: más adelante, si no pulsas, consigues el pez igualmente (mejora desbloqueable).
- [DECIDIDO] Si no pulsas el primer botón, el pez se escapa hasta que mejores la caña.
- [DECIDIDO] **Cañas**: mejorar la caña da acceso a mejores peces y llega más profundo (más profundo = peces más complejos). Además mejora los rates y puede dar pesca automática.
- [PROPUESTA] Implementado: cada caña (`data/canas/`) tiene profundidad, límite de cadena, tiempo de reacción, espera, probabilidad de raros y auto del primer botón. Cada pez tiene profundidad mínima.
- [ABIERTO] Input táctil para móvil.

- [DECIDIDO] Habrá un catálogo grande de peces sacado de una enciclopedia, con sus rangos de peso. El diseñador lo pasará en un Excel.
- [DECIDIDO] Los peces se agrupan por momento del día (día / noche) y por estación (invierno...). [ABIERTO] Cómo pasa el tiempo en el juego (ciclo día/noche, duración de las estaciones).

## 7. Economía
- [DECIDIDO] Una sola moneda que lo es todo: dinero, experiencia y economía.
- [DECIDIDO] Moneda: rublos. Símbolo ₽ (U+20BD); comprobar que la fuente lo tiene. El primer hito son 100 ₽.
- [DECIDIDO] Al poco de empezar a pescar aparece un barco comerciante: le vendes peces y le compras cosas.
- [PROPUESTA] El barco aparece tras 3 capturas (ajustable en el inspector: `BarcoComerciante.capturas_para_aparecer`).
- [DECIDIDO] El primer comerciante vende: la siguiente caña, cebo (boost de tiempo) y +1 hueco.
- [PROPUESTA] Precios: caña decente 150 ₽, cebo 15 ₽ (5 pescas, +30% de tiempo de reacción) y cajón 60 ₽ (×1.8 por compra, máximo 4). Con E se abre su tienda, que también compra todo lo de la barca.
- [DECIDIDO] El cebo da X probabilidad de X cosas (p. ej. más probabilidad de cierto pez o rareza) y su efecto dura un tiempo.
- [DECIDIDO] Ejemplos de efectos de cebo: pesca duplicada, más probabilidad de cierto pez...
- [ABIERTO] Lista concreta de cebos, efectos y duración (pendiente del diseñador).
- Nota: el código actual del cebo (5 pescas y +30% de tiempo de reacción) está mal y hay que rehacerlo con duración en segundos y efectos de probabilidad.
- [DECIDIDO] La barca tiene inventario (los peces que llevas encima).
- [DECIDIDO] Inventario por huecos: empiezas con 6. Cada especie ocupa un hueco y se apila ahí con todas sus variantes y pesos. Al pulsar el hueco se despliegan las variantes. Los huecos solo son para lo que pescas.
- [DECIDIDO] Si la barca se llena (todos los huecos ocupados), el juego te avisa y no te deja pescar más hasta que vendas.

## 8. Menú (Tab / Esc / atrás de Android)
- [DECIDIDO] Pestañas:
  - **Árbol de habilidades**, pagado con dinero. Ramas de ejemplo: Carisma (mejores acuerdos y posibilidades), Suerte, Fuerza (peces más pesados), Destreza (más progresión de botones y más valor por acierto).
  - **Barca**: inventario.
  - **Opciones**.
  - **Stats**: pesca por segundo, dinero por segundo, tiempo jugado, peces pescados, legendarios...

## 9. Automatización / villa
- [DECIDIDO] Fábricas y trabajadores pescan y venden en automático.
- [ABIERTO] Lista de edificios, qué hace cada uno y sus hitos.

## 10. Progreso offline
- [DECIDIDO] No hay progreso offline: solo avanza con el juego abierto.

## 11. Progresión del mundo
- [DECIDIDO] Todo lo que se pega al mundo llega con animación: por defecto viene navegando por el mar. Algunos especiales tienen mini cinemática épica; el diseñador lo indica en la descripción de la carta.
- [DECIDIDO] Barco comerciante en la casilla (2,−1), tras 3 capturas.
- [DECIDIDO] **SkillTreeMan** (forma libre de 7 casillas, x −4..−2): aparece al pescar 100 peces y **cae del cielo**. En (−4,0) hay un viejo senil de barba blanca meditando, tapado solo por un libro, con una hoguera delante y bonsáis a los lados que crecerán con el árbol. Al interactuar con él se abre el árbol de habilidades (ya no está en el menú Tab). Vende la **Sabia caña** (caña nivel 3) por 2000 ₽.
- [DECIDIDO] **Primera isla** (3×1 en y −2, delante de la zona de pesca): bestiario (libro con todos los peces) a la izquierda y antorcha a la derecha. Llega por mar.
- [DECIDIDO] La primera isla aparece al ganar 200 ₽ en total.
- [DECIDIDO] Lo que manda es la condición: cada cosa llega cuando se cumple la suya. El "orden" de la carta solo desempata si dos se cumplen a la vez.
- Nota: el antiguo "primer islote a 100 ₽" se ha sustituido por la primera isla.
- [ABIERTO] Lista ordenada de islas y cosas que van llegando según avances. El diseñador la escribe en la **Carta de Fishin**: https://claude.ai/artifact/2oRoaePEyuUyDUYBJnK9oA (colección `elementos`).
- Árbol de habilidades: el diseñador lo escribe en el **Árbol de Fishin**: https://claude.ai/artifact/UtP4gNUbFFwpX9SPeTcTnu (colecciones `ramas` y `nodos`).
