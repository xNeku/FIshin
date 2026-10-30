# GDD — Fishin (nombre provisional)

Marcas: [DECIDIDO] lo decidió el diseñador · [PROPUESTA] sugerencia de Claude sin confirmar (o ya implementada a falta de visto bueno) · [ABIERTO] sin decidir.

## 1. Concepto
- [DECIDIDO] Incremental de pesca con expansión de terreno al estilo Forager. Objetivo: dopamina y vitalidad.
- [DECIDIDO] Meta del protagonista: pescar todos los peces que existen y estar en paz. Una colección completa como objetivo final.
- [DECIDIDO] Fantasía: empiezas de náufrago flotando en un donut y acabas con una villa pesquera centrada en ti. Todo el mundo pesca, vende y compra para ti.
- [DECIDIDO] Referencias: Coal LLC (estilo y tono), Forager (expansión), Octopath Traveler (2.5D), Animal Well (interfaz).
- [DECIDIDO] Plataformas: Windows, Mac y Linux; lo que importa es PC (Steam, con logros). Android, quizá en el futuro si va bien en Steam. Que el diseñador trabaje en la tablet es por comodidad; no condiciona la salida. Móvil más adelante (la interfaz y el input se piensan táctiles desde el principio).
- [DECIDIDO] El náufrago no pesca solo (fuera el piloto automático); lo pasivo lo hacen trabajadores y negocios.
- [DECIDIDO] Lo pasivo nunca sustituye a pescar a mano: el dinero gordo sale de los combos buenos; lo pasivo sube poco a poco y solo se rompe en el endgame.
- [DECIDIDO] Tiene que dar para sus horas y poder dejarse abierto: primero se trabaja a mano y luego se disfruta viendo la ciudad automatizada, con combos de vez en cuando para pillar peces guapos en su época y hora.

## 2. Protagonista
- [DECIDIDO] Náufrago dejado, consumido por tabaco, alcohol y malos vicios, pero carismático y buen rollero. Está de puto chill porque es un máquina.
- [DECIDIDO] Inspirado en el personaje de Hotline Miami de la referencia: barba y melena de náufrago, sin gafas, pelo negro, más moreno de piel, sonrisa pícara.
- [DECIDIDO] No va en barca: pesca tumbado de chill en un donut flotador rosa (alto, que flote, no hundido), con la caña en la mano apuntando a la derecha y las piernas de frente, como tumbado mirando a cámara.
- [DECIDIDO] La celebración del pez gordo (brazos arriba con el pez) la hace tumbado. Con Q se pone de pie sobre el donut.
- [PROPUESTA] Implementado: el donut sube, baja y se inclina con la ola de verdad, con sombra y espuma en el agua. Al esperar lanza el corcho en arco (salpicadura y ondas lentas); al picar pasa a pose de tirar, el corcho se hunde y las ondas se aceleran; tiembla más con la intensidad.

## 3. Mundo y cuadrícula
- [DECIDIDO] El mapa es una cuadrícula/matriz. El donut está en (0,0).
- [DECIDIDO] Las 8 casillas alrededor del donut son agua permanente: el 3x3 es la zona de pesca.
- [DECIDIDO] Islotes, barcos y edificios (mercados, casinos, tiendas de anzuelos...) se pegan solos al superar hitos (dinero, logros). El jugador no elige dónde ni paga por todos.
- [DECIDIDO] Los hitos se cumplen en cuanto se supera el valor; no hace falta pasar justo por él.
- [DECIDIDO] Lo que manda es la condición: cada cosa llega cuando se cumple la suya. El "orden" de la carta solo desempata si dos se cumplen a la vez.
- [DECIDIDO] Todo lo que se pega al mundo llega con animación: por defecto navegando por el mar. Algunos especiales tienen mini cinemática; el diseñador lo indica en la carta.
- [DECIDIDO] Lo que llega por mar viene del lado donde está respecto al donut (lo del sur, del sur; lo del oeste, del oeste), en línea recta. Nunca desde un sitio cualquiera.
- [PROPUESTA] Implementado: llegadas MAR, CIELO (cae con sombra e impacto), CONSTRUIR (las tablas salen del agua una a una desde el donut hacia fuera) y EMERGER (sube del fondo).
- [ABIERTO] Lista ordenada de islas y cosas que van llegando. El diseñador la escribe en la **Carta de Fishin**: https://claude.ai/artifact/2oRoaePEyuUyDUYBJnK9oA (colección `elementos`).

### Lo que hay en el mapa ahora
- [DECIDIDO] **Barco comerciante** en la casilla (2,−1), llega tras 3 capturas.
- [DECIDIDO] **Primera isla** (3×1 en y −2, delante de la zona de pesca): bestiario a la izquierda y antorcha a la derecha. Llega por mar al ganar 200 ₽ en total.
- [DECIDIDO] **SkillTreeMan** (7 casillas en forma libre, x −4..−2): aparece al pescar 100 peces y cae del cielo. En (−4,0) hay un viejo senil de barba blanca meditando, entre palmeras, con una hoguera delante y bonsáis a los lados que crecerán con el árbol. Al interactuar con él se abre el árbol de habilidades. Vende la **Sabia caña** (caña nivel 3) por 2000 ₽.
- [DECIDIDO] **Camino de madera** (concepto permanente): conector entre islotes y edificios que irá creciendo; su forma es la estructura del juego y el diseñador la retoca en la carta. Primer tramo a los 20 min de juego: T desde el donut hacia arriba, de (0,2) a (0,6) y de (−2,6) a (2,6).
- [DECIDIDO] **Puerto pesquero** (5 casillas en (2..4, 0) y (3..4, −1)): aparece al hacer un combo x10. Pantalán de madera roto con un pescador en (4,−1), primo del mercader, que trabaja para ti.
- Nota: el combo x10 solo es posible con la Sabia caña (rota: hasta 5, decente: hasta 9). El puerto queda para después del viejo.
- [DECIDIDO] **Lonja** (3×3 en x −1..1, y 7..9, al final del camino): centro de venta conceptual. No se va a ella a vender: desde que aparece, todo lo que vendas (también al comerciante) vale ×1,3. Con el porteador, el comerciante le lleva el cubo navegando. Con los restaurantes será el centro neurálgico del pescado: se verá cómo lanza el pescado a cada destino. Emerge del fondo del mar. Casa blanca medio moruna con toldo azul y blanco, bandera con un pez pocho y flotadores rojos y blancos.
- [PROPUESTA] La lonja aparece cuando ya existe el camino y has ganado 1.500 ₽ en total. La fila de la casa (y = 9) no se pisa.
- [PROPUESTA] Cañas del early game: Rota (1), Decente (2), Sabia (3), **Fibra** (4, la vende el comerciante desde la lonja) y **Carbono** (5, desde la entrada de turistas). [DECIDIDO] El early game tiene como tope un combo de 25. Las cañas rápida y pesada son del mid game.
- [DECIDIDO] **Dos alturas**: la zona de la lonja, el camino 2 y los restaurantes es un puerto alto sobre pilotes de madera (1,2 m). El camino 1 tiene una escalera en (0,4). La entrada de turistas queda abajo, a la altura de pesca, con su escalera en (4,5) hasta el camino 2 (se añadió el rellano (4,4)). Solo se cambia de altura por las escaleras. Se pesca desde abajo.
- [DECIDIDO] De noche el náufrago fuma: sale humo y la brasa ilumina un poco.
- [DECIDIDO] **Camino 2** (32 casillas): anillo alrededor de la lonja con plaza arriba, ramal a la izquierda y ramal al restaurante. Llega al tener el tercer pescador. Con él el comerciante ya no llega navegando a la lonja: aparca y va andando.
- [DECIDIDO] **Restaurante O Mar** (parcela 5×5 en x 7..11, y 7..11): chiringuito de madera austero y con carisma en el centro (2×2), que se irá mejorando. Llega justo después del camino 2. La lonja le manda gratis una parte de lo que vendes (tú cobras lo mismo); con eso hace platos para la gente del pueblo y los turistas, y te paga lo que cobra. Ahí le das lo cosechado y le compras mejoras.
- [DECIDIDO] **Entrada de turistas** (11 casillas en x 4..7, y 3..6): plataforma cutre de tablones rotos con una escalera al camino. Llega tras 2 días enteros con el restaurante abierto.
- [DECIDIDO] **Cultivos** (anillo de 28 casillas en x −9..−6, y −4..4): pimientos de Padrón en las columnas de fuera y algas en los huecos de agua del medio. Llega cuando el restaurante ha servido a 50 personas.

## 4. Modos de juego
- [DECIDIDO] **Modo pesca** (en el donut). Es la única acción manual de pesca; todo lo demás lo automatizan fábricas y trabajadores.
- [DECIDIDO] **Modo movimiento**: un botón saca del modo pesca y el personaje anda como en cualquier juego. Del donut a una isla adyacente salta por encima del agua (y al revés).
- [DECIDIDO] Al principio no puedes moverte porque no hay suelo.
- [PROPUESTA] Implementado: WASD / stick para andar, Q (L1/LB) para bajar y volver, E (✕/A) para interactuar, Tab (Options/Menu) para el menú. Q solo baja si ya hay tierra y no estás en mitad de una pesca; para volver hay que estar en el donut. Se salta el agua si al empujar contra ella hay suelo a dos casillas, enfrente o en diagonal. Mientras andas no pica nada.
- [PROPUESTA] E con el viejo abre su tienda (Sabia caña) con frases suyas; el árbol aún no existe y lo dice él. E en el bestiario abre el libro (especies pescadas con su mejor calidad; las demás en silueta "???"). Las charlas son diálogos tipo Pokémon.

## 5. Pesca (núcleo)
- [DECIDIDO] En el donut el personaje espera a que pique. Cuando pica, sale un botón en pantalla.
- [DECIDIDO] Cadena de botones: cada acierto mejora la calidad del pez y cada botón da menos tiempo que el anterior.
- [DECIDIDO] La pesca acaba al fallar o al llegar al límite natural de la cadena. El límite sube con el árbol.
- [DECIDIDO] El largo de la cadena no es fijo: muchas veces solo 1 o 2 botones. El juego es lento y progresivo.
- [PROPUESTA] Cada caña define `cadena_min`, `cadena_max` y `sesgo_cadena`. Rota 1–5 (el 44 % de las picadas da 1 botón), decente 2–9, pro 3–15. La rama Destreza podría bajar el sesgo.
- [DECIDIDO] Sensación de adentrarse: zoom con shake hacia el jugador según el progreso.
- [DECIDIDO] El espectáculo se descubre poco a poco; al principio es suave. La escala es de juego entero: combos de ~50 botones al final, y ahí se nota la locura.
- [PROPUESTA] Implementado: la intensidad va por botones seguidos (máximo a los 50, `StatsPesca.botones_intensidad_maxima`): viñeta, aberración, latido desde ~10 botones, tono de acierto que sube, el botón salta por la pantalla y un congelado breve al capturar.
- [DECIDIDO] Futuro: modo infinito (zoom de ida y vuelta en bucle) y música con el beat cuadrado a las pulsaciones. Es para ver hasta dónde llegan los jugadores.
- [DECIDIDO] Futuro: modos de pesca según la caña (volumen y trofeo; ver `docs/PROGRESION.md`).
- [DECIDIDO] Las dobles tardan en salir. [PROPUESTA] Desde el 5º botón (`dobles_desde_boton`).
- [DECIDIDO] Pulsaciones dobles (tipo R2 + X). Teclado: números con la izquierda y flechas con la derecha; las dobles combinan una de cada.
- [DECIDIDO] Peces pesados o especiales tienen tramos de machacar un botón para llenar una barra. Si no la llenas, los legendarios y extraños se escapan y los normales salen peores.
- [DECIDIDO] Celebración al sacar algo muy tocho: el náufrago levanta el pez (tumbado), luz encima, primer plano y musiquilla estilo Zelda. [PROPUESTA] Se celebra lo extraño o legendario, o cualquier pez de 15 kg o más.
- [DECIDIDO] Si no pulsas el primer botón, el pez se escapa hasta que mejores la caña.
- [DECIDIDO] Auto: más adelante, si no pulsas, consigues el pez igualmente (mejora desbloqueable).
- [DECIDIDO] **Cañas**: mejor caña = mejores peces y más profundidad (más profundo = peces más complejos), mejores rates y puede dar pesca automática.
- [PROPUESTA] Implementado: cada caña (`data/canas/`) tiene profundidad, límite de cadena, tiempo de reacción, espera, probabilidad de raros y auto del primer botón. Cada pez tiene profundidad mínima.
- [PROPUESTA] Si la caña tiene menos límite que los pasos del pez, no llegas al perfect (gancho para mejorar la caña).
- [DECIDIDO] Habrá un catálogo grande de peces sacado de una enciclopedia, con sus rangos de peso. El diseñador lo pasará en un Excel.
- [DECIDIDO] Los peces se agrupan por momento del día (día / noche) y por estación.
- [DECIDIDO] El tiempo es un reloj propio del juego (día/noche y estaciones), con algún guiño a la hora real en logros secretos.
- [DECIDIDO] Un día dura 20 min reales: 12 de día (06:00-18:00) y 8 de noche (18:00-06:00). Cada estación dura 2 h (6 días); un año, 8 h.
- [DECIDIDO] Hecho: `data/reloj.tres` (RelojData), con noche oscura y reflejo de la luna en el mar. La luna tiene 8 fases, una por noche, y en luna nueva no se ve. Los peces solo pican en su estación y su horario.
- [DECIDIDO] En el midgame, cuando llega la calidad de vida, habrá un edificio reloj para adelantar el tiempo o hacer que pase más rápido (`Juego.velocidad_reloj`).
- [ABIERTO] Input táctil para móvil.

## 6. Economía
- [DECIDIDO] Una sola moneda que lo es todo: dinero, experiencia y economía. Rublos (₽).
- [DECIDIDO] Además hay materiales (algas, coral, bambú, perlas, marihuana) que se gastan en mejoras junto con los rublos, para que no se pueda pasar de ninguna línea. Detalle en `docs/PROGRESION.md`.
- [DECIDIDO] Al poco de empezar aparece un barco comerciante: le vendes peces y le compras cosas. Vende la siguiente caña y cebo.
- [PROPUESTA] Precios: caña decente 150 ₽, cebo 15 ₽, cajón 60 ₽ (×1.8 por compra, máximo 4).
- [DECIDIDO] El cebo da X probabilidad de X cosas (más probabilidad de cierto pez o rareza, pesca duplicada...) y su efecto dura un tiempo.
- [ABIERTO] Lista concreta de cebos, efectos y duración (pendiente del diseñador).
- Nota: el cebo actual (5 pescas, +30 % de tiempo de reacción) es provisional y hay que rehacerlo con duración en segundos y efectos de probabilidad.
- [DECIDIDO] La barca (lo que llevas encima) no tiene huecos ni límite (cambiado el 1 nov). Cada especie se apila con todas sus variantes y pesos; al pulsar la pila se despliegan.
- [DECIDIDO] Si la barca se llena, el juego avisa y no deja pescar hasta que vendas.
- [DECIDIDO] **Dinero y peces visuales y gustosos**: cuando alguien deposita dinero o peces, salen volando uno a uno en parábola hacia quien los recibe. Al vender, primero van tus peces y después vuelve el dinero. Puedes moverte mientras: las piezas te siguen.
- [PROPUESTA] El dinero vuela en monedas de 10; si es mucho, en billetes (100), fajos (1.000) o sacos (10.000), como mucho 25 piezas. El contador sube con cada pieza.
- [DECIDIDO] No hay progreso offline: solo avanza con el juego abierto.

## 7. Automatización y villa
- [DECIDIDO] Fábricas y trabajadores pescan y venden en automático.
- [DECIDIDO] Puerto: los trabajadores pescan solos y meten la pesca en un cubo en (2,0). Coges el cubo con E y lo llevas a cualquier mercader, que te paga con la misma animación. Con la mejora Porteador del árbol, los pescadores le dan el cubo al comerciante y este, de vez en cuando, hace un viaje rápido por el agua hasta la lonja a venderlo. El pantalán crecerá en tamaño, calidad y trabajadores.
- [DECIDIDO] El primer pescador está en la base, junto al cubo. Los demás se colocan al azar en bordes con agua delante, cerca de un compañero, y nunca obstruyen el paso (no tienen colisión). Algunos se sientan al borde de los tablones.
- [DECIDIDO] De primeras solo pescan el pez más barato. Cada uno coge 10, va andando al cubo y lo deja.
- [PROPUESTA] Tras venderlo, el cubo vuelve volando solo. Mientras lo llevas, los pescadores esperan junto a la base. Con el cubo en la mano no puedes volver a pescar.
- [DECIDIDO] Restaurantes: ingreso extra sin perder nada. La lonja les manda el pescado gratis; tú no cobras más por el pescado, ganas por lo que venden los restaurantes.
- [DECIDIDO] Cultivos: crecen solos. Con R2 cerca pegas un hozazo giratorio y lo cosechado vuela hacia ti (lo llevas encima). Se lo das al restaurante: los pimientos se venden como guarnición y las algas mejoran los platos. No habrá muchos cultivos ni mucho farmeo fuera de la pesca: pimientos de Padrón, algas, coral, perlas, marihuana y algo para hacer cerveza.
- [DECIDIDO] Turistas: no vienen todos los días, pero cuando vienen es en masa. Llegan en la segunda mitad del día y se quedan hasta la mitad de la noche. Cuanta más comida puede dar el restaurante, más vienen (más producto que vender = más turistas). Al principio son pocos.
- [DECIDIDO] Tipos de turista, acumulativos (al desbloquear uno, los que vienen se reparten entre todos los tipos):
  - Nivel 1: náufragos, pescadores, gente del pueblo; hombres y mujeres variados. Llegan en barca.
  - Nivel 2: gente normal de distintas nacionalidades (asiáticos, marroquíes...). Llegan en velero y en barcos turísticos pequeños (catamarán).
  - Nivel 3: yates con muchísima gente pija de distintas nacionalidades.
  - [DECIDIDO] Las nacionalidades tienen que ser graciosas y que se note de dónde son: se reconocen por la ropa y lo que llevan en la mano (sin caricaturizar caras).
  - [PROPUESTA] El nivel 3 se abre con 1.500 clientes servidos.
- [ABIERTO] Lista de edificios, qué hace cada uno y sus hitos.

## 8. Progresión: árbol de habilidades
- [DECIDIDO] Árbol pagado con dinero. Ramas de ejemplo: Carisma (mejores acuerdos y posibilidades), Suerte, Fuerza (peces más pesados), Destreza (más progresión de botones y más valor por acierto).
- [DECIDIDO] Se abre hablando con el viejo (SkillTreeMan), no desde el menú.
- [DECIDIDO] Ramas: Carisma, Suerte, Pesca y Chill. Más adelante, una rama de endgame acorde a tener una ciudad.
- [DECIDIDO] Extenso: el juego apunta a unas 20 h hasta acabarlo y entrar en el endgame.
- [DECIDIDO] Visual y con buen feel: estilo de árboles de los juegos de referencia, con nuestros colores; cada rama con su color e icono; una línea de agua recorre los caminos que vas desbloqueando.
- [PROPUESTA] Implementado: 60 nodos (ver `docs/PROGRESION.md`). Nodos, costes y efectos pendientes de revisión del diseñador. El diseñador lo escribe en el **Árbol de Fishin**: https://claude.ai/artifact/UtP4gNUbFFwpX9SPeTcTnu (colecciones `ramas` y `nodos`), con una imagen de referencia del flujo.

## 9. Menú (Tab / Options / atrás de Android)
- [DECIDIDO] Pestañas: **Barca** (inventario), **Stats** (pesca y dinero por segundo, tiempo jugado, peces pescados, legendarios...) y **Opciones**.
- [PROPUESTA] Implementado en Opciones: volver, filtro retro sí/no, borrar partida y guardar y salir.

## 10. Dirección de arte
- [DECIDIDO] Pixel art simple con personalidad. Placeholders de Claude (nada de bloques grises); el arte final es del diseñador y entra cambiando PNG, sin tocar código.
- [DECIDIDO] 2.5D con todo en sprites 2D muy simples (personajes con su caña en la mano, objetos, barcos...), estilo Octopath. Excepciones más trabajadas: paisaje (cielo, mar, clima), VFX, peces y menús.
- [DECIDIDO] Estilo B: el mundo se dibuja pixelado (a 1/4 de resolución, sin suavizar). Sin desenfoque (se probó en cinemáticas y se quitó).
- [DECIDIDO] Nada de modelos 3D en objetos: barcos, tablones, props y personajes en sprite o bloque con textura pixel. Solo son 3D los bloques del suelo, el mar y la cuadrícula de pesca.
- [DECIDIDO] La referencia es la demo B (hierba y arena con textura, tablones, palmeras, sprites), con el mar nuevo.
- [DECIDIDO] Mar con reflejos y clima que se nota (cielo, nubes, mar, lluvia, tormenta).
- [PROPUESTA] Implementado: ~24 px por metro en sprites y suelos. Los sprites del mundo reciben luz (se oscurecen con la tormenta, la hoguera los ilumina); la llama no. Climas por datos (soleado, nublado, lluvia, tormenta) al azar con peso y transición suave; F6 los cambia.
- [PROPUESTA] Guía de medidas para el arte (píxeles por casilla, alto de personaje, paleta, frames por animación) antes de que el diseñador dibuje.

## 11. Interfaz
- [DECIDIDO] Menús, diálogos, tienda, árbol y minijuego al estilo Animal Well: paneles negros con borde blanco de píxel, fuente pixel, lo seleccionado en amarillo, cabeceras en gris.
- [DECIDIDO] Filtro retro de tele de tubo por encima de todo (se quita en Opciones).
- [DECIDIDO] Menús y popups con animación de entrada suave pero retro.
- [DECIDIDO] El minijuego enseña el dibujo de la tecla o del botón del mando, no texto. Al menos mando de PlayStation; también Xbox. Iconos de un pack libre (Xelu, CC0), pixelados.
- [DECIDIDO] Sin frases en pantalla: ni al llegar islas o el comerciante, ni al picar, ni la calidad al capturar (ya va en el banner del pez, con su color). Fallo o escape: una X roja encima de la cabeza.
- [DECIDIDO] Nada de textos flotantes en el mundo (ni carteles ni contadores encima de pescadores o del cubo).
- [DECIDIDO] La indicación de acción va abajo a la derecha. En el donut siempre está la Q; si puedes hacer otra cosa a la vez, comparten la caja y se alternan cada 2 s.
- [DECIDIDO] Las frases de acierto del minijuego ("Genial", "¡Brutal!"...) se quitan por ahora; en el futuro se hará algo (el código está comentado).
- [PROPUESTA] Implementado: el tipo de mando se detecta por su nombre (si no se reconoce, PlayStation); al machacar, la tecla dibujada se aprieta sola.

## 12. Mid game (orden decidido el 2 nov)
- [DECIDIDO] **Ayuntamiento:** edificio que permite mejorar todo lo inmueble (pantalán, O Mar, lonja, entrada…) y construir una tienda para decorar al gusto. Toda decoración sube lo que pagan los turistas. Llega pre-midgame.
  - [PROPUESTA] Hacia el min 150-165 (300.000 ₽ ganados), en la plaza de arriba del camino 2. Un sistema común de nivel por edificio; la decoración, después. Lo que pagan los turistas sale de una sola cifra, el "atractivo" (nivel de turista × decoración × propinas).
  - [ABIERTO] Si las mejoras de O Mar (despensa, fogón, mesas) se mueven al ayuntamiento.
- [DECIDIDO] Después, en este orden: taladro de coral, sushi (segundo restaurante, con algas), cañas rápida y pesada, marihuana y decoración.
- [DECIDIDO] El yate (turistas de nivel 3) abre el mid game. Los turistas de más nivel pagan más.
