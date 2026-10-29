# PROGRESIÓN — líneas del incremental

Documento de trabajo para ordenar todo lo que crece en el juego: qué aparece, cuándo, qué aporta y cómo se equilibra.
Marcas como en el GDD: [DECIDIDO] lo dijo el diseñador · [PROPUESTA] sugerencia de Claude · [ABIERTO] sin decidir.
Los números son [PROPUESTA] para empezar a probar; se ajustan jugando.

---

## Visión (lo que tiene que sentirse)
- [DECIDIDO] Un juego que da para sus horas y que a veces se deja abierto. Primero lo trabajas mucho a mano; luego puedes jugar de chill, haciendo otra cosa, solo mirando lo automatizada que está tu ciudad.
- [DECIDIDO] De vez en cuando te haces unos combos para sacar peces muy guapos, justo en su época y a su hora, y logros de Steam.
- [DECIDIDO] Lo que importa es PC. El móvil, si llega, después.
- [PROPUESTA] En números:
  - **15–25 h** para desbloquearlo todo.
  - Una cola larga de **40 h o más** para completar la colección: peces de época y hora, legendarios, perfectos.
  - Ratos de idle sin límite.

---

## 0. Cómo encaja todo

Hay **siete líneas** que crecen a la vez y se enganchan entre sí:

| # | Línea | Qué da | Ejemplo de enganche |
|---|-------|--------|---------------------|
| 1 | Edificios (lo físico) | Comprar más caro, generar dinero, transformar cosas | La lonja paga más que el comerciante |
| 1.2 | Trabajadores | Automatizar cada edificio | Pescadores llenan el cubo |
| 2 | Árbol de habilidades | Mejoras del náufrago y de todo lo demás | Carisma: los trabajadores van más rápido |
| 3 | Cañas y objetos | Peces más valiosos y más profundos | Mejor caña → peces que desbloquean el sushi |
| 4 | Variedad de peces | Qué puedes pescar y dónde | Pescar atún desbloquea el restaurante de sushi |
| 5 | Recursos secundarios | Materiales para mejorar edificios | Coral del taladro → ampliar la pecera |
| 6 | Pecera | Lucir peces especiales; atrae turistas | Un legendario expuesto sube las visitas |
| 7 | Turismo / villa | Ingreso pasivo que se dispara al final | Turistas comen en el sushi y pagan la pecera |

- [DECIDIDO] Al final el náufrago forma una villa a la que vienen turistas que compran, comen en restaurantes, etc.
- [DECIDIDO] El jugador puede acabar teniéndolo todo; la gracia está en **en qué orden** gasta.
- [PROPUESTA] Regla de oro: cada cosa nueva tiene que hacer una de estas dos cosas: **multiplicar lo que ganas** (×2 o más) o **abrir una mecánica nueva**. Si no hace ninguna, sobra.
- [DECIDIDO] El dinero (₽) es la única moneda. Los recursos (algas, coral, bambú, perlas...) son **materiales** que se gastan en mejoras además de los rublos. Así el jugador no puede saltarse ninguna línea.
- [PROPUESTA] Cada material tiene que ser obligatorio para algo que el jugador quiere de verdad. Por ejemplo: ampliar la pecera pide coral, el hotel pide bambú y las mejoras de lujo piden perlas. Si un material se puede ignorar, sobra.

---

## Tramos del juego (la columna vertebral)

[PROPUESTA] Dividimos la partida en tramos. Cada tramo multiplica el ingreso por 10 o más y trae su propia mecánica. Los tiempos son de jugar sin prisa.

| Tramo | Nombre | Duración aprox. | Ingreso objetivo | Mecánica nueva |
|-------|--------|-----------------|------------------|----------------|
| T0 | Náufrago | 0 – 15 min | 10 – 50 ₽/min | Pescar a mano, vender, primera caña |
| T1 | Puerto | 15 – 45 min | 100 – 500 ₽/min | Árbol, andar, pescadores automáticos, lonja |
| T2 | Aldea | 45 min – 2 h | 1K – 10K ₽/min | Cultivo (algas), sushi, taladro de coral |
| T3 | Pueblo turístico | 2 – 5 h | 20K – 300K ₽/min | Turistas, pecera, submarinistas y perlas, bambú |
| T4 | Ciudad loca | 5 h + | 1M ₽/min y más | Tercer cultivo, casino, legendarios, todo al máximo |

Lo que ya está hecho cubre **T0 y T1** (comerciante, primera isla, viejo, camino, puerto, lonja).

---

## 1. Edificios

[DECIDIDO] Edificios que compran más caro, edificios que generan dinero, y todos se pueden mejorar.
[PROPUESTA] Tres tipos, para que cada uno se sienta distinto:
- **Comprador**: te paga más por lo que llevas (comerciante, lonja).
- **Productor**: genera algo solo (puerto, taladro, cultivos, submarinistas).
- **Transformador**: convierte una cosa en otra que vale más (sushi: pescado + algas → platos).

| Orden | Edificio | Tipo | Tramo | Se desbloquea con | Qué hace | Se mejora en |
|-------|----------|------|-------|-------------------|----------|--------------|
| 1 | Barco comerciante | Comprador | T0 | 3 capturas [hecho] | Compra peces, vende cañas, cebo, huecos | Más artículos, mejores precios |
| 2 | Primera isla (bestiario) | — | T0 | 200 ₽ totales [hecho] | Colección de peces | — |
| 3 | Viejo (árbol) | — | T1 | 100 peces [hecho] | Árbol de habilidades, Sabia caña | Bonsáis crecen con el árbol |
| 4 | Camino de madera | — | T1 | 20 min [hecho] | Conecta todo; crece con cada edificio | — |
| 5 | Puerto pesquero | Productor | T1 | Combo x10 [hecho] | Pescadores → cubo | Pantalán (más puestos), cubo más grande, peces mejores |
| 6 | Lonja | Comprador | T1 | Camino + 1.500 ₽ [hecho] | Vende todo de golpe | % de precio, recibe el cubo sola (porteador) |
| 7 | Huerto de algas | Productor | T2 | [ABIERTO] | Algas (recolectar a mano, gracioso) | Más parcelas, recolector |
| 8 | Restaurante de sushi | Transformador | T2 | Pescar [ABIERTO: qué pez] + tener algas | Pescado + algas → platos (×2–×3 el valor del pez) | Cocina, mesas, menú |
| 9 | Taladro marino | Productor | T2 | [ABIERTO] | Coral automático (islote propio) | Velocidad, profundidad (coral raro) |
| 10 | Pecera | Atracción | T3 | [ABIERTO] | Expones peces; atrae turistas | Tamaño y decoración (coral) |
| 11 | Muelle de turistas | Atracción | T3 | [ABIERTO] | Llegan turistas y gastan en la villa | Barcos más grandes |
| 12 | Centro de buceo | Productor | T3 | [ABIERTO] | Submarinistas que sacan perlas | Equipos, profundidad |
| 13 | Bambuzal | Productor | T3 | [ABIERTO] | Bambú (construcción) | Parcelas |
| 14 | Cabañas / hotel de bambú | Atracción | T3 | Bambú | Los turistas se quedan más y gastan más | Plantas, lujo |
| 15 | Chiringuito / tienda de souvenirs | Transformador | T3 | [ABIERTO] | Coral y perlas → recuerdos para turistas | — |
| 16 | Plantación de marihuana | Productor | T3–T4 | [ABIERTO] | Ver punto 5 | Parcelas |
| 17 | Casino | Atracción | T4 | [ABIERTO] | Ver IDEAS | — |

[PROPUESTA] Cada edificio tiene **niveles** (1 → 5 o más). Subir de nivel cuesta mucho más y cambia cómo se ve el edificio (más grande, más bonito). Así se ve la villa crecer.

### 1.2 Trabajadores
- [DECIDIDO] Los edificios con trabajadores permiten contratar más, como los pescadores.
- [PROPUESTA] Cada edificio tiene un **máximo de trabajadores por nivel** (subir de nivel = más plazas).
- [PROPUESTA] Cada trabajador nuevo cuesta más que el anterior (×1,15 cada uno) y aporta lo mismo. Las mejoras de edificio y el árbol (Carisma) multiplican a todos.

| Trabajador | Edificio | Qué hace |
|------------|----------|----------|
| Pescador | Puerto | Pesca el pez más barato y lo lleva al cubo [hecho] |
| Porteador | Puerto / lonja | Lleva el cubo a vender solo [DECIDIDO, para cuando haya árbol] |
| Agricultor | Huertos | Recolecta solo |
| Cocinero / camarero | Sushi | Cocina más rápido / sirve a más turistas |
| Operario | Taladro | Más coral |
| Submarinista | Centro de buceo | Perlas |

---

## 2. Árbol de habilidades

- [DECIDIDO] Se paga con dinero y se abre en el viejo. Al final se puede tener todo; hay que elegir el orden.
- [DECIDIDO] Ramas que tiene claras el diseñador: **Carisma**, **Suerte** y **Pesca**.
- [DECIDIDO] Cuarta rama: **Chill**.
- [DECIDIDO] Habrá más adelante una rama de endgame que encaje con que ya tiene una ciudad y no solo pesca de chill. Se piensa más tarde (concepto de endgame).

[PROPUESTA] **Tamaño del árbol** (para 15–25 h):
- **4 ramas × 15 nodos = unos 60 nodos**, y luego la rama de endgame con 15 más.
- Unos **10 nodos clave**, que cambian cómo juegas: porteador, auto-pesca del primer botón, auto-pesca completa, pesca doble, turistas que gastan más...
- **El resto son mejoras de porcentaje con niveles** (1 a 5): dan sensación de compra constante sin llenar el árbol de cosas distintas.
- Contando niveles salen **150–200 compras** en toda la partida. Si sale una cada 5–10 minutos, cuadra con las horas.
- Cada rama tiene nodos de **todos los tramos**: el árbol nunca se acaba antes de tiempo y siempre hay algo en él que perseguir.

- [DECIDIDO] Árbol bien extenso; el juego apunta a unas 20 h para acabarlo y entrar en el endgame.
- [PROPUESTA] **Implementado**: 60 nodos en 4 ramas (16 Pesca, 15 Carisma, 15 Suerte, 14 Chill), 10 nodos clave, costes de 300 ₽ a 300M ₽. Los que dependen de cosas que aún no existen (sushi, turistas, taladro, buceo, huerto, plantación, casino) salen con candado y "Llega con...". Datos en `data/arbol/`, pantalla en `scenes/ui/arbol.tscn` (cada nodo se puede mover a mano). Lista de efectos al final de este documento.

[PROPUESTA] Ejemplos originales de nodos (ya pasados al árbol):

**Carisma** (dinero y gente)
- +10 % por venta (varios niveles)
- Mejores precios en tiendas
- Trabajadores más rápidos
- Trabajadores más eficientes (cogen más peces por viaje)
- Porteador: el cubo se vende solo
- Los turistas gastan más

**Suerte**
- Más probabilidad de raros, extraños y legendarios
- Pesca doble (a veces sale 2 de una)
- Perlas en peces normales (muy de vez en cuando)
- Menos escapes en el primer botón
- Más perfectos

**Pesca** (solo el minijuego)
- Más tiempo para reaccionar
- Cadenas más largas (sube el límite de la caña)
- Cadenas menos cortas (baja el sesgo a 1–2 botones)
- Machacar más fácil (cada golpe llena más)
- Peces más pesados (lo que el GDD llamaba Fuerza)
- Auto-pesca del primer botón y, al final, auto-pesca completa

**Chill** [DECIDIDO como rama] (muy del personaje: lo que gana el náufrago sin hacer nada). [PROPUESTA] Ejemplos:
- Ganar más mientras no pulsas.
- Edificios que producen más.
- Ventajas por clima (en tormenta salen más raros).
- Vista de "mirar la ciudad" con todo funcionando solo.

---

## 3. Cañas y objetos

- [DECIDIDO] Mejorar caña da peces mejores y más profundos, y tiene que subir el valor de lo que pescas.
- [DECIDIDO] Peces más pesados y, dentro de la misma rareza, peces más valiosos.

[PROPUESTA] Valor de un pez = **valor base de la especie × peso × calidad × multiplicadores** (árbol, edificios).
Las especies profundas tienen más valor base, aunque sean de la misma rareza. Así una caña mejor siempre se nota en el dinero.

- [ABIERTO] Número de cañas. El diseñador plantea 15.
- [PROPUESTA] **15 = 12 de progresión + 3 especiales hechas con materiales.**
  - Las **12 de progresión** van de dos o tres por tramo: rota, decente y sabia (hechas), y 9 más. Cada una abre profundidad nueva y multiplica el valor medio unas ×2,5. De la primera a la duodécima, unas ×10.000.
  - Las **3 especiales**: caña de bambú, de coral y de perla. No son "la siguiente"; cada una tiene un truco (por ejemplo, la de perla sube los perfectos) y piden materiales. Así los materiales también sirven a la pesca.
  - Riesgo: 15 cañas que solo cambien números se vuelven aburridas. Cada caña tiene que notarse: un pez nuevo que ya puedes pescar, cadenas más largas o un efecto.

| Caña | Tramo | Profundidad | Valor medio por pez |
|------|-------|-------------|---------------------|
| 1 Rota | T0 | 1 | ×1 [hecho] |
| 2 Decente | T0 | 2 | ×3 [hecho] |
| 3 Sabia | T1 | 3 | ×10 [hecho] |
| 4–5 | T1–T2 | 4–5 | ×25 – ×60 |
| 6–8 | T2–T3 | 6–8 | ×150 – ×1.000 |
| 9–11 | T3–T4 | 9–11 | ×2.500 – ×15.000 |
| 12 | T4 | 12 | ×40.000 |
| Bambú, coral, perla | T2–T4 | — | Truco propio, pide materiales |

[PROPUESTA] Otros objetos, cada uno tocando una sola cosa para que se entienda:
- **Anzuelos**: peces más pesados.
- **Carrete**: machacar más fácil.
- **Sedal**: menos escapes.
- **Cebos**: efectos temporales de probabilidad (pendiente de la lista del diseñador).
- **Cajones**: más huecos en la barca [hecho].

---

## 4. Variedad de lo que pescas

- [DECIDIDO] Según avanzas, cambia la variedad de lo que pescas.
- [DECIDIDO] Habrá edificios que se desbloquean porque has pescado algo relacionado (por ejemplo, el sushi).
- [DECIDIDO] Catálogo grande sacado de una enciclopedia (Excel del diseñador), agrupado por día/noche y estación.

[PROPUESTA] La variedad sale de cuatro cosas, para que siempre haya algo nuevo que perseguir:
1. **Profundidad** (la caña).
2. **Zona**: cerca del taladro salen peces de arrecife; cerca del centro de buceo, ostras.
3. **Hora y estación** ([ABIERTO] cómo pasa el tiempo).
4. **Cebo**.

[PROPUESTA] Peces que desbloquean cosas:

| Pez | Desbloquea |
|-----|-----------|
| Atún o salmón | Restaurante de sushi |
| Pez de arrecife | Taladro de coral |
| Primer pez extraño | Pecera |
| Ostra | Centro de buceo |
| Primer legendario | [ABIERTO] |

[PROPUESTA] Unas 8 especies por tramo más legendarios: entre 40 y 50 peces en total.

---

## 5. Recursos secundarios

- [DECIDIDO] Hacen falta otros recursos además de la pesca, para mejorar edificios y otras cosas.
- [DECIDIDO] Cultivos: pocos tipos, cada uno en su zona, que se van desbloqueando. Recolectar tiene que ser gracioso (el náufrago se levanta y lo hace él).
- [DECIDIDO] Taladro marino automático en un islote propio que da coral.
- [DECIDIDO] Submarinistas que sacan perlas.
- [DECIDIDO] Tres cultivos: algas, bambú y marihuana. La marihuana va adelante; su uso concreto se verá más tarde.

| Recurso | Tramo | De dónde sale | Para qué sirve [PROPUESTA] |
|---------|-------|---------------|---------------------------|
| Algas | T2 | Huerto de algas | Sushi (alga nori + pescado), primeras mejoras |
| Coral | T2 | Taladro marino | Decorar y ampliar la pecera, mejoras de edificios |
| Bambú | T3 | Bambuzal | Construir (cabañas, hotel, ampliaciones del pantalán) |
| Perlas | T3 | Centro de buceo | Mejoras de lujo, souvenirs caros |
| Marihuana | T3–T4 | Zona propia | [ABIERTO] (se verá; por el tono, algo de "chill") |

[PROPUESTA] Cada recurso se recoge **a mano al principio** (gracioso y con animación) y **solo después**, cuando contratas a su trabajador.

Nota: en tiendas de móvil la marihuana sube la clasificación por edad. Se acepta, porque la prioridad es PC.

---

## 6. Pecera

- [DECIDIDO] Islote pecera que se amplía (tamaño y decoración). Del inventario eliges peces para echarlos dentro y lucir los especiales con brillos.
- [PROPUESTA] Cada pez expuesto suma **atractivo** según su rareza y calidad (un legendario perfecto vale muchísimo). El atractivo trae turistas (ver 7).
- [PROPUESTA] Los peces que echas a la pecera **ya no se venden**: es una decisión entre dinero ahora o turistas siempre.
- [PROPUESTA] La pecera se amplía con coral y dinero. Más tamaño = más peces; decoración = multiplicador de atractivo.
- [PROPUESTA] Es también la vitrina de la meta del juego (pescarlos todos).

---

## 7. Turismo y villa (la capa final)

- [DECIDIDO] La villa recibe turistas que compran, comen en restaurantes, etc. El dinero sigue subiendo y todo se vuelve loco.
- [PROPUESTA] Una sola cifra que lo resume: **Atractivo** = suma de edificios, niveles, pecera y decoración.
- [PROPUESTA] El atractivo decide cuántos turistas llegan por minuto. Cada turista gasta en los negocios que haya (sushi, souvenirs, hotel, casino).
- [PROPUESTA] Es el ingreso pasivo grande del final: a partir de T3 los turistas tienen que ganar más que tu caña.
- [PROPUESTA] Los turistas se ven paseando por el camino (sprites sencillos). Es la prueba visual de que la villa vive.

---

## 7.5 Logros (Steam)
- [DECIDIDO] Habrá logros de Steam.
- [PROPUESTA] Unos **50–60 logros** repartidos en:
  - **Pesca**: combos x10, x25 y x50, primer perfecto, primer machacar.
  - **Colección**: especies de cada tramo, todos los legendarios, peces de cada época.
  - **Villa**: cada edificio, X trabajadores, atractivo máximo.
  - **Dinero**: 1K, 1M, 1B...
  - **Secretos**: la bota vieja en tormenta, pescar a las 3 de la mañana...
- [PROPUESTA] Se montan ya **dentro del juego, por datos** (`.tres` con id, condición y dibujo) y con su pantalla propia. Steam se conecta al exportar.
- Aviso técnico: Steam en Godot necesita GodotSteam, un addon compilado, y nuestra regla es no usar addons compilados (por el editor de Android). Solución: los logros funcionan dentro del juego desde ya, y GodotSteam solo entra en la build de PC al final.

---

## 8. Equilibrio

- [DECIDIDO] **Lo pasivo nunca mata la pesca.** El dinero gordo siempre sale de una pesca loca a mano: un combo de la hostia tras varios intentos para sacar un buen pez. Lo pasivo (trabajadores, negocios, piloto) crece poco a poco, de la mano de la economía, y solo se rompe al llegar al endgame. Para avanzar del todo siempre hace falta trabajo manual.
- [DECIDIDO] El náufrago no pesca solo: ya lo hacen los trabajadores y los negocios. Fuera el piloto automático.
- [PROPUESTA] Implementado: cada botón acertado suma un +12 % al valor del pez (`StatsPesca.bonus_por_boton`): un combo de 10 vale ×2,2 y uno de 50, ×7.
- [PROPUESTA] En su lugar, la rama Chill premia volver a pescar tras un rato de chill: **Meditación** (clave: la siguiente picada trae más raros) y **Ron de coco** (más tiempo por botón en esa picada).
- [PROPUESTA] Objetivo de equilibrio: hasta el endgame, lo pasivo da como mucho un tercio de lo que gana alguien pescando bien a mano en el mismo tramo.

[PROPUESTA] Reglas para que la curva funcione:
1. **Tiempo hasta la siguiente cosa**: lo próximo tiene que poder comprarse en **2 a 5 minutos** de ingreso al principio y **10 a 20 minutos** al final. Nunca más de 30.
2. **Precios**:
   - Edificios y trabajadores: ×1,15 por cada compra.
   - Niveles de edificio: ×3 a ×5 por nivel.
   - Nodos del árbol: ×2 a ×3 por nivel.
3. **Cada tramo** multiplica el ingreso ×10 a ×30. Las cosas del tramo nuevo cuestan unos 5 minutos de su ingreso.
4. **Impacto**: cada desbloqueo da al menos ×2 a algo o abre una mecánica. Lo apuntamos en las tablas para verlo de un vistazo.
5. **Números grandes**: a partir de T3 los números crecen deprisa, y eso es lo divertido. El formato ya está (K, M…).

[PROPUESTA] Para equilibrar con datos y no a ojo: una **hoja de cálculo de curvas** con el ingreso por minuto de cada tramo, el precio de cada cosa y el tiempo que tarda en llegar. Los números de los `.tres` salen de ahí.

---

## Negocios y suministro
- [DECIDIDO] Los materiales impulsan los negocios.
- [DECIDIDO] Los negocios dependen de lo que les llevas: si no pescas lo suficiente, el sushi genera menos porque atiende a menos clientes. Lo mismo con las algas y con la tienda de marihuana.
- [PROPUESTA] Cada negocio tiene un **almacén** de lo que consume (pescado, algas...). Cada cliente gasta una ración: sin almacén no hay venta. Así la pesca (a mano o de los trabajadores) nunca deja de importar.

## Cañas (decidido)
- [DECIDIDO] Cañas diferentes; algunas tendrán funciones propias más adelante.
- [DECIDIDO] **Modos de pesca según la caña** (para el futuro, de midgame):
  - **Caña de volumen**: cada tecla acertada es un pez, en cadena; cuando hay que pulsar más rápido, cada pulsación es un pez. Peores de calidad, pero no mucho. Sirve para nutrir los negocios.
  - **Caña de trofeo**: pesca muy poco y solo está atenta a peces de más de X valor (o de X peso). Tarda en picar, no siempre sale algo gordo (para eso está la Suerte) y pide un combo larguísimo.
- [DECIDIDO] Todo encadenado: lo que vendes en la lonja (cuánto y de qué calidad) alimenta a los negocios. Cuanto más y mejor vendas, mejores platos y más producción sacan.
- [DECIDIDO] Las cañas especiales son más difíciles de conseguir y van bien metidas en el flujo del juego (no se compran sin más).
- [PROPUESTA] Las cañas con modo propio son las especiales del 12 + 3. La de volumen encaja con el bambú (material barato) y la de trofeo, con la perla o el coral.

## Modo flow
- [DECIDIDO] Un poco antes del midgame, a partir de 15 aciertos, los combos se ven como en Guitar Hero: ves cuál es el siguiente botón, todo más rápido. Así es más fácil para el jugador, y va ligado al árbol en el momento justo en que se abren los combos largos (+20, casi inhumanos sin esa habilidad).
- [PROPUESTA] Implementado: nodo clave **Leer el agua** (rama Pesca, 40K ₽, 3 niveles = ves 1, 2 o 3 botones por delante). Desde el botón 15 (`StatsPesca.cola_desde_boton`), los siguientes entran deslizándose por la derecha y cada botón da un 15 % menos de tiempo (`mult_tiempo_cola`). En modo flow el botón deja de saltar por la pantalla.

## Tamaño de los combos
- [DECIDIDO] En algún momento habrá un modo infinito para ver hasta dónde llegan los jugadores. El número se va regulando.
- [PROPUESTA] Escalones:
  - Arranque: 1–5 botones.
  - Midgame: perfectos de 10–25.
  - Final: legendarios y caña de trofeo de 30–60. A los 50 se nota la locura máxima.
  - Modo infinito (endgame): sin límite, con tabla de récords de Steam y fuera de la economía (o con el bonus de dinero topado).
- [PROPUESTA] Para que no sea solo reflejos: un respiro corto cada 10 botones y un tiempo mínimo por botón que nunca baje de ~0,4 s.
- [ABIERTO] Hasta dónde quiere el diseñador que llegue un combo "normal" de final de juego.
- [DECIDIDO] El modo infinito, equilibrado: los números grandes son por orgullo y estadísticas, no por dinero.
- [DECIDIDO] Logros de combos enormes (por ejemplo, x200) y peces que solo salen con combos larguísimos.

---

## Efectos del árbol (lo que lee el juego)
| Efecto | Qué hace | Dónde |
|--------|----------|-------|
| tiempo_reaccion | + tiempo por botón | Pesca |
| espera | − espera hasta que pica | Pesca |
| cadena_extra | + largo máximo de cadena | Pesca / caña |
| sesgo_cadena | menos cadenas de 1–2 | Pesca / caña |
| machacar | menos golpes para llenar la barra | Pesca |
| peso | + peso (y valor) | Pesca |
| calidad | + calidad | Pesca |
| dobles_tarde | las dobles salen más tarde | Pesca |
| auto_primer_boton | fallar el primero no lo espanta | Pesca |
| auto_pesca | si se acaba el tiempo, te lo quedas | Pesca |
| profundidad | la caña llega más hondo | Pesca |
| raros / legendarios / raros_tormenta | más no comunes / legendarios / en tormenta | Pesca |
| segunda_oportunidad | a veces no se escapa al fallar el primero | Pesca |
| pesca_doble | a veces sale otro igual | Pesca |
| precio_venta / precio_lonja | se vende más caro (todo / en la lonja) | Comercio |
| venta_doble | un pez se cobra doble | Comercio |
| descuento | tiendas más baratas | Juego.precio |
| trabajador_velocidad / trabajador_capacidad | trabajadores más rápidos / más peces por viaje | Trabajador |
| porteador | el cubo se vende solo al llenarse | Puerto |
| espera_chill / trabajadores_chill | sin tocar nada: pican antes / trabajadores más rápidos | Pesca / Trabajador |
| umbral_chill | antes cuentas como de chill | Juego |
| trabajadores_lluvia | con lluvia, trabajadores más rápidos | Trabajador |
| raros_tras_chill / tiempo_tras_chill | la picada que llega tras un rato de chill: más raros / más tiempo por botón | Pesca |
| sushi_velocidad, sushi_clientes, turistas, propinas, perla_peces, coral_doble, cultivos, hierba, casino, mirador | futuros (nodos con candado) | — |

---

## Línea hasta el midgame (borrador v1, a trabajar juntos)

### Cómo está ahora (simulado con los datos reales)
Simulador: `docs/herramientas/simular_economia.py`. Juega con los peces, cañas y tiempos de verdad y con un jugador normal (acierta casi siempre con 1 s por botón y 3 de cada 4 a 0,4 s).

| Caña | ₽/min | Peces/min | Combos ≥10 |
|------|-------|-----------|------------|
| Rota | ~60 | ~10 | 0 % |
| Decente | ~135 | ~8 | 0 % |
| Sabia | ~250 | ~7 | 2 % |

| Minuto | Qué llega |
|--------|-----------|
| 0,3 | Comerciante (3 peces) |
| 4,6 | Primera isla (200 ₽ totales) y compra de la caña decente |
| 12 | El viejo y su árbol (100 peces) |
| 20 | Camino (20 min) y lonja (1.500 ₽ totales), **a la vez** |
| 20,5 | Sabia caña (2.000 ₽) |
| 26,5 | Puerto (combo x10) |

**Problemas que se ven:**
1. Todo lo que hay se acaba en ~27 min. Después solo queda el árbol, que a 250 ₽/min se hace eterno (un nodo de 25K = 100 min).
2. El camino y la lonja llegan a la vez y se pisan.
3. Solo hay 6 peces y 3 cañas: la pesca no cambia en todo el tramo.
4. No se pueden contratar pescadores (solo el primero, gratis): el puerto no crece.
5. Lo pasivo es pequeño (~27 ₽/min por pescador, un 10 % de lo que ganas a mano). Bien según la regla, pero no hay forma de subirlo.

### Propuesta de orden hasta el midgame (~2 h)
[PROPUESTA] Objetivo: algo nuevo cada 3–8 minutos. Lo de la carta del diseñador manda; esto es un orden de partida para discutir.

**T0 Náufrago (0–15 min): 60 → 150 ₽/min**
| Min | Qué | Condición / coste |
|-----|-----|-------------------|
| 0,5 | Comerciante | 3 peces [hecho] |
| 3 | Caña decente | 150 ₽ [hecho] |
| 5 | Primera isla (bestiario) | 200 ₽ totales [hecho] |
| 6–14 | Cajones extra | 60 ₽ ×1,8 [hecho] |
| 12 | Viejo y árbol | 100 peces [hecho] |

**T1 Puerto (15–45 min): 250 → 1.000 ₽/min**
| Min | Qué | Condición / coste |
|-----|-----|-------------------|
| 18 | Sabia caña | 2.000 ₽ [hecho] |
| 20 | Camino | 20 min [hecho] |
| 25 | Puerto pesquero | Combo x10 [hecho] |
| 27 | **Contratar pescadores** (hablando con el primero) | 400 ₽, ×1,5 cada uno; máximo 3 con el pantalán de nivel 1 |
| 30 | Lonja | Camino + **3.000 ₽ totales** (para que no se pise con el camino) |
| 35 | **Caña 4** (más hondo: peces nuevos, ×2,5 de valor) | 12K ₽ |
| 40 | **Pantalán nivel 2** (+3 plazas de pescador; pescan el 2º pez más barato) | 15K ₽ |
| 15–45 | Primeros nodos del árbol | 300 – 20K ₽ |

**T2 Aldea (45 min – 2 h): 1K → 10K ₽/min**
| Min | Qué | Condición / coste |
|-----|-----|-------------------|
| 45 | **Huerto de algas** (recolectar a mano, gracioso) | 10K ₽ totales [ABIERTO] |
| 55 | **Restaurante de sushi** (pescado de la lonja + algas → platos) | Pescar un salmón (pez nuevo de la caña 4) + 25K ₽ + 30 algas |
| 65 | Contratar cocineros y camareros | Como los pescadores |
| 70 | **Taladro marino** (coral automático) | Pescar un pez de arrecife (caña 5) + 60K ₽ |
| 75 | **Caña 5** | 50K ₽ + 20 coral |
| 80 | **Leer el agua** (modo flow) | 40K ₽, árbol [hecho] |
| 90 | Mejoras del sushi (nivel 2–3: más platos, mejor precio) | ₽ + algas + coral |
| 100 | **Caña de volumen** (especial) | Sushi nivel 2 + 100 algas + 40 coral + 150K ₽ |
| 110 | Pantalán nivel 3 | ₽ + coral |
| 120 | Fin del midgame: llega el primer aviso de turistas (T3) | — |

**Suministro (decidido):** el sushi compra parte de lo que vendes en la lonja. Sin pescado o sin algas atiende a menos clientes. Más cantidad y calidad = más platos y mejores.

## 9. Cómo lo llevamos

1. El diseñador revisa este documento y marca lo que es [DECIDIDO], lo que cambia y lo que sobra.
2. Pasamos el orden de edificios a la **Carta de Fishin** (qué, dónde y con qué condición) y el árbol al **Árbol de Fishin**.
3. Claude monta la hoja de curvas a partir de las tablas.
4. Se implementa **por tramos**: primero T2 completo (algas, sushi, taladro) jugable y equilibrado; luego T3. No se pasa al siguiente hasta que el actual divierta (regla del proyecto).

## Preguntas abiertas (de una en una)
1. Duración del día y de las estaciones del reloj propio.
2. ¿Qué pez desbloquea el sushi y con qué condición llegan el huerto de algas y el taladro?
3. Número final de cañas (propuesta: 12 + 3 especiales).
4. Uso de la marihuana.
5. Rama de endgame (más adelante).

Resueltas: el tiempo es un reloj propio del juego, con guiños a la hora real en logros secretos (decidido); los recursos son materiales que se gastan (decidido); cuarta rama Chill (decidido); cultivos algas, bambú y marihuana (decidido).
