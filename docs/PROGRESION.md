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

- [DECIDIDO] **Experiencia corta, unas 10 h**, y después un endgame tocho y largo para los fanáticos: mucha gente no aguanta más de 10 h en un juego así. Antes eran 15-20 h.
- [DECIDIDO] Todo más ágil:
  - Espera de 5-15 s; cuanto más tarda en picar, más probable que la cadena sea larga.
  - Llegadas más juntas y pescadores antes.
  - La lonja paga más.
- [PROPUESTA] Tiempos v3: midgame hacia las 3,5 h.

| Tramo | Nombre | Cuándo | Novedad cada | Mecánica nueva |
|-------|--------|--------|--------------|----------------|
| T0 | Náufrago | 0 – 25 min | 3-6 min | Pescar a mano, comerciante, primeras cañas, árbol |
| T1 | Puerto | 25 min – 1,5 h | 6-10 min | Pescadores (comprables), lonja, Sabia, pantalán |
| T2 | Aldea (midgame hacia las 3,5 h) | 1,5 – 4 h | 10-20 min | Algas, sushi con suministro, taladro, modo flow, edificio reloj |
| T3 | Pueblo turístico | 4 – 7 h | 15-25 min | Turistas, pecera, buceo y perlas, bambú; peces del mundo |
| T4 | Ciudad loca | 7 – 10 h | 20-30 min | Casino, legendarios del mundo, cañas especiales |
| — | Endgame | 10 h + | — | Largo para los fanáticos: modo infinito, récords, maestrías, todo al máximo |

## El ciclo: todo va de la mano

Regla: cada tramo sube a la vez la caña (cadena más larga), los peces (perfect más largo y más valor), lo que puedes encadenar (tramos de racha) y lo que cuestan las cosas. Si una de estas cosas se adelanta a las otras, el ciclo se rompe:
- Si la caña da cadenas de 30 pero no hay peces de perfect 30, no sirve de nada.
- Si los precios suben más rápido que los peces, el juego se para.

| Tramo | Cañas | Cadena de la caña | Perfect de los peces | Combo típico / récord | Racha que se alcanza | Lo pasivo (% de lo tuyo) | Rato sin pescar |
|-------|-------|-------------------|----------------------|------------------------|----------------------|--------------------------|-----------------|
| T0 | Rota, Decente | 1-5 → 2-9 | 5-8 | 3-5 / 9 | ×1,25 (desde 5) | 0 % | 5-10 % |
| T1 | Sabia, 4, 5 | 3-15 → 4-18 | 8-14 | 6-10 / 15 | ×1,5 (desde 10) | 5-15 % | 15-20 % |
| T2 | 6, 7, 8 + flow | 5-25 | 12-25 | 10-18 / 30 | ×2 (desde 20) | 15-25 % | 20-25 % |
| T3 | 9, 10, 11 | 8-40 | 20-45 | 18-30 / 60 | ×2,5-3 (35-50) | 25-33 % | 25 % |
| T4 | 12 + 3 especiales | 10-60 (trofeo 100+) | 40-80 (legendarios 100-200) | 30-50 / 200 | ×3,5-6 (75-200) | 33 % → endgame | 25-30 % |

- **El reto del minijuego no se regala.**
  - El tiempo mínimo por botón se queda en 0,4 s en todo el juego (límite humano).
  - Cada tramo pide más: cadenas largas, más dobles y machaques, peces con `mult_tiempo` de 0,85-0,9.
- **Lo que hace los combos más lentos (más fáciles) es muy poco**:
  - Árbol: como mucho +15 % (Muñeca suelta 3 × 3 %, Pulso de cirujano 2 × 3 %).
  - Ron de coco: +15 %, solo el primer pez tras un rato de chill.
  - Cañas: ya no dan tiempo (`mult_tiempo` 1,0); dan profundidad, cadena y suerte.
  - Lo demás son **cebos opcionales**, que se usan o no según quieras.
- **Cebos para ir con calma** (se compran, se gastan; como el Star Power de Guitar Hero, pero al revés):
  - T0 **Cebo de gusano** [hecho]: +20 % de tiempo durante 10 pescas, 25 ₽.
  - T2 **Cebo de mejillón**: +30 % durante 15 pescas, caro. Pensado para atacar un pez de perfect alto.
  - T3-T4 **Cebo de calma chicha**: +40 % durante 5 pescas, muy caro. Para el pez de tus récords.
- **Maestría** [hecho]: cada especie vale ×1,1 / ×1,25 / ×1,5 / ×2 al pescar 10 / 50 / 200 / 1.000 ejemplares. Se ve en el bestiario. Da objetivos largos y premia volver a pescar lo de siempre; es la idea de los hitos de AdVenture Capitalist.

-------|--------|-----------------|------------------|----------------|
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
- [DECIDIDO] Los pescadores se contratan **hablando con el primero**, que siempre está fijo en su puesto. Hay un **límite** de cuántos puedes tener, que sube con nodos del árbol y con mejoras del pantalán.
- [DECIDIDO] Hecho: desde que llega el puerto se compran más hablando con el primer pescador. Cuestan 1.000, 5.000 y 10.000 ₽, y después cada uno ×1,5 (`data/articulos/contratar_pescador.tres`). Máximo 20.
- Rendimiento: un pez barato cada 14 s y 8 por viaje, al 40 % de su valor: unos 23 ₽/min cada uno. Con 5 pescadores, lo pasivo es ~1/4 de lo que haces a mano.
- [PROPUESTA] Cada edificio tiene un **máximo de trabajadores por nivel** (subir de nivel = más plazas).
- [PROPUESTA] Cada trabajador nuevo cuesta más que el anterior (×1,15 cada uno) y aporta lo mismo. Las mejoras de edificio y el árbol (Carisma) multiplican a todos.

| Trabajador | Edificio | Qué hace |
|------------|----------|----------|
| Pescador | Puerto | Pesca el pez más barato y lo lleva al cubo [hecho] |
| Porteador | Puerto / lonja | Los pescadores le dan el cubo al comerciante, que navega a la lonja a venderlo [hecho] |
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
3. **Hora y estación**: día de 20 min (12 de día y 8 de noche), estaciones de 2 h. Hecho.
4. **Cebo**.

[PROPUESTA] Peces que desbloquean cosas:

| Pez | Desbloquea |
|-----|-----------|
| Atún rojo o salmón rosado | Restaurante de sushi |
| Pez de arrecife | Taladro de coral |
| Primer pez extraño | Pecera |
| Ostra | Centro de buceo |
| Primer legendario | [ABIERTO] |

### Catálogo (hecho): 201 especies
El diseñador pasó dos listas: **100 de Galicia y 100 del mundo** (`docs/datos/peces_fuente.csv`, sacado de su Excel). Se convierten en datos del juego con `python3 docs/herramientas/importar_peces.py 22 1.35`. Hay que volver a ejecutarlo si cambia la lista o las fórmulas, y luego `godot --headless --path . --import`.

- **Rareza en 6 categorías**, como en el Excel: Común, Poco común, Raro, Épico, Legendario y Mítico.
  - Probabilidad por categoría: 10 / 5 / 2 / 0,7 / 0,2 / 0,06.
  - Los % del Excel no se usan, porque ponían el legendario (0,4 %) por encima del épico (0,3 %) y el mítico igual que el legendario.
  - Desde Raro, la suerte de la caña y del árbol los sube. Desde Épico, se escapan si fallas el machaque.
- **Profundidad**: Galicia en la 1-6 (T0-T2, cañas 1-6) y el mundo en la 7-12 (T2-T4), unas 17 especies por nivel.
  - Dentro de cada categoría, de ligero a pesado.
  - Los legendarios cierran tramo:
    - Galicia: San Martiño en la 2, kraken bebé en la 3, Peixe Sapo en la 4, Morena en la 5, Fletán en la 6, y la Pinta Roja mítica en la 6.
    - Mundo: Calamar gigante en la 9 ... Cachalote en la 12, y el Tiburón de Groenlandia mítico.
  - Sardina, caballa (xarda), lubina (robaliza) y bota vieja se quedan en la 1 con su id de siempre. El atún pasa a ser el Atún Rojo (Cachón).
- **Cuanto más hondo, menos salen los de arriba**: cada nivel por encima de tu caña pesa ×0,45 (`StatsPesca.peso_por_nivel_arriba`). Cada caña nueva trae de verdad peces nuevos.
- **Valores por fórmula** (ver la cabecera del importador):
  - `valor = 22 × 1,35^(prof−1) × rareza (1/2/5/12/40/120) × tamaño × lo que cuesta pescarlo`.
  - El perfect sale de la tabla del ciclo.
  - La dificultad (menos tiempo por botón, dobles, machaques) sube con la profundidad y la rareza.
- **Estaciones y horario**: vienen del Excel y se guardan en cada pez, pero aún no filtran nada. Esperan al reloj del juego ([ABIERTO] duración del día y las estaciones).
- **Iconos**: placeholders 16×10 por forma (pez normal, alargado, plano, alto, atún, espada, raya, tiburón, caballito, cangrejo, gamba, pulpo, calamar, estrella, erizo, pepino, bota, lata, botella, rama, neumático, alga, ballena), con color por especie. Los legendarios llevan un detalle dorado.
- **Ojo con el Excel**:
  - Hay mamíferos (narval, beluga, cachalote). Pescarlos con caña puede chirriar; se podrían pasar a "avistamientos". [ABIERTO]
  - Hay especies repetidas en las dos listas (sargo picudo, caballito, pez ballesta, pepino de mar, pez limón): las del mundo llevan `_mundo` en el id.
  - "Pinta roja" sale como tiburón mítico de 1-3 kg, pero en Galicia es un pez común.

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
- [PROPUESTA] Implementado: nodo clave **Leer el agua** (rama Pesca, 40K ₽, 3 niveles = ves 1, 2 o 3 botones por delante). Desde el botón 15 (`StatsPesca.cola_desde_boton`), los siguientes entran deslizándose por la derecha y cada botón da un **30 % menos de tiempo** (`mult_tiempo_cola` 0,7), pudiendo bajar hasta 0,3 s (`tiempo_minimo_cola`; fuera del flow el mínimo es 0,4 s). [DECIDIDO] En modo flow la velocidad de reacción tiene que ser superior: como ves lo que viene, el reto pasa a ser la velocidad. En modo flow el botón deja de saltar por la pantalla.

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
- [DECIDIDO] El diseñador deja la curva en manos de Claude: que dé bastante y dé dopamina, y que un combo largo compense más que pescar muchos cortos seguidos.
- Hecho: **racha** (ver `docs/INCREMENTAL.md` §6). Cada botón paga una parte del pez, y en racha paga más: ×1,25 desde el 5.º, ×1,5 desde el 10.º, ×2 desde el 20.º... hasta ×6 desde el 200.º. Al cambiar de tramo suenan un arpegio y un destello. Valores en `data/stats_pesca.tres`.
- Pendiente: la cadena sigue cortándose en el `perfect` del pez; los combos largos llegan con peces de perfect alto.

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

**Chill** (lo regula Claude, por decisión del diseñador: la pesca es tranquila, con momentos de calma mientras lo pasivo genera por detrás):
- Esperas de 6-14 s con picoteos del corcho y un aviso antes de picar.
- De chill tras 8 s sin tocar nada (la Hamaca lo baja 1 s por nivel, hasta 4 s). Así Brisa marina y Ronquido funcionan dentro de casi cada espera.
- De chill, si pica un pez y no lo tocas, se va sin castigo. Puedes quedarte tumbado mientras trabajan los demás. Ver `docs/INCREMENTAL.md` §6.5.
| umbral_chill | antes cuentas como de chill | Juego |
| trabajadores_lluvia | con lluvia, trabajadores más rápidos | Trabajador |
| raros_tras_chill / tiempo_tras_chill | la picada que llega tras un rato de chill: más raros / más tiempo por botón | Pesca |
| sushi_velocidad, sushi_clientes, turistas, propinas, perla_peces, coral_doble, cultivos, hierba, casino, mirador | futuros (nodos con candado) | — |

---

## Línea de tiempo (a trabajar juntos)

### Cómo estaba antes del balance (histórico, simulador v1)
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

### Orientación v3 (espera de 8-20 s, andar para vender, maestría)
[PROPUESTA] Guía de ritmo: manda la carta. Simulado con un jugador normal (media de 20 partidas, `docs/herramientas/simular_economia.py`). Cuenta el rato que se pierde andando para vender: 8 s por venta en el donut y 35 s cuando ya hay camino.

**T0 y principio del T1 (lo que ya está hecho), v4**

Simulado con un jugador normal, espera de 5-15 s y lonja ×1,3. El bueno llega unos 2-3 min antes y el flojo unos 5 después.

| Min | Llega | Condición | Qué aporta |
|-----|-------|-----------|------------|
| 1 | Comerciante | 3 peces | Vender, tienda |
| 5 | Caña decente | 300 ₽ | ×2,5 (~250 ₽/min) |
| 6 | Primera isla (bestiario) | 400 ₽ totales | Suelo, colección |
| 15 | Viejo y árbol | **58 peces** | Árbol, tienda del viejo |
| 20 | Camino | **600 puntos de pesca** | Andar |
| 26 | Puerto (primer pescador) | Camino + **800 puntos de pesca** | 1 pescador (~23 ₽/min) |
| 35 | Sabia caña | **6.800 ₽** | ×2 (~490 ₽/min) |
| 38-90 | Pescadores 2 a 5 | Hablando con el primero: 1.000, 5.000, 10.000, 15.000 ₽ (luego ×1,5; máximo 20) | +23 ₽/min cada uno |
| 45 | Lonja | Camino + **11.000 ₽ totales** | Todas las ventas ×1,3, vendas donde vendas (no hace falta ir) |

**Premiar al que pesca bien** [DECIDIDO: hay que premiarlo, que acabe antes]:
- **Puntos de pesca** (`Juego.stats.puntos_pesca`): cada pez suma la racha de su cadena, ×2 si es perfecto. El camino y el puerto llegan por puntos, no por minutos ni por un solo combo.
- Con eso (simulado, con el catálogo):
  - Bueno: camino 38, puerto 52, lonja 62.
  - Normal: camino 40, puerto 55, lonja 66.
  - Flojo: camino 44, puerto 60, lonja 71.
- **Hoy la diferencia es pequeña en el T0-T1.** La caña decide al azar lo larga que es la cadena, y casi todas son cortas y lentas (más de 0,9 s por botón), así que todos las aciertan.
  - La habilidad empieza a notarse con cadenas de 10 o más (botones de 0,4 s) y en el flow (0,3 s).
  - Para que se note antes hay dos palancas.
    - [DECIDIDO] No hay racha entre peces: el combo es de cada pez.
    - [DECIDIDO] Lo que se busca es que al jugador le salgan cadenas largas más a menudo desde el principio. Hecho: cañas con cadenas más largas y menos sesgadas, y las esperas largas dan cadenas más largas (`cadena_por_espera`). Pendiente de que el diseñador lo pruebe.

**T1 Puerto (lo siguiente por hacer)**
| Min | Llega | Condición orientativa | Qué aporta | ₽/min |
|-----|-------|-----------------------|------------|-------|
| 75-100 | Contratar 2-3 pescadores | 150 ₽ × 1,6ⁿ | +8 ₽/min cada uno | ~300 |
| 90 | Caña 4 (peces nuevos, perfect 10-12) | ~6.000 ₽ | ×1,8 | ~550 |
| 110 | Pantalán nivel 2 | ~10.000 ₽ | +3 plazas; pescan el 2.º más barato | ~600 |
| 125 | Caña 5 | ~18.000 ₽ | ×1,6 | ~950 |
| 140 | Isla nueva (pista del T2) | ~30.000 ₽ totales desde el puerto | Objetivo a la vista | ~1.000 |
| 150 | Fin del T1 | — | Árbol de Pesca/Carisma a medias: ×1,5 | ~1.500 |

**T2 Aldea, hasta el midgame (5-6 h), a grandes rasgos**
| Hora | Llega | Qué aporta |
|------|-------|------------|
| 2,5-3 | Huerto de algas | Material, a mano al principio |
| 3-3,5 | Sushi (salmón + algas) | ×1,4, limitado por lo que pescas |
| 3,5 | Caña 6 + **Leer el agua** (flow, desde el botón 15) | Combos de 20+: entra la racha ×2 |
| 4-4,5 | Taladro marino (coral) | Material para cañas 7-8 |
| 4,5-5 | Caña 7, sushi nivel 2, cocineros | ×1,5 |
| 5-6 | **Midgame**: caña 8, pantalán 3 | ~20.000 ₽/min |

(La propuesta v1 "midgame a las 2 h" queda descartada: era demasiado rápida.)

---

## 9. Cómo lo llevamos

1. El diseñador revisa este documento y marca lo que es [DECIDIDO], lo que cambia y lo que sobra.
2. Pasamos el orden de edificios a la **Carta de Fishin** (qué, dónde y con qué condición) y el árbol al **Árbol de Fishin**.
3. Claude monta la hoja de curvas a partir de las tablas.
4. Se implementa **por tramos**: primero T2 completo (algas, sushi, taladro) jugable y equilibrado; luego T3. No se pasa al siguiente hasta que el actual divierta (regla del proyecto).

## Preguntas abiertas (de una en una)
2. ¿Qué pez desbloquea el sushi y con qué condición llegan el huerto de algas y el taladro?
3. Número final de cañas (propuesta: 12 + 3 especiales).
4. Uso de la marihuana.
5. Rama de endgame (más adelante).

6. ¿Se deja que la cadena pase del perfect (necesario para el flow y para los combos de x200), o los combos largos llegan solo con peces de perfect alto?

Resueltas: contratar hablando con el primer pescador, con límite por árbol + pantalán (decidido); el tiempo es un reloj propio del juego, con guiños a la hora real en logros secretos (decidido); los recursos son materiales que se gastan (decidido); cuarta rama Chill (decidido); cultivos algas, bambú y marihuana (decidido).
