# PROGRESIÓN — líneas del incremental

Documento de trabajo para ordenar todo lo que crece en el juego: qué aparece, cuándo, qué aporta y cómo se equilibra.
Marcas como en el GDD: [DECIDIDO] lo dijo el diseñador · [PROPUESTA] sugerencia de Claude · [ABIERTO] sin decidir.
Los números son [PROPUESTA] para empezar a probar; se ajustan jugando.

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
- [PROPUESTA] El dinero (₽) sigue siendo lo único con lo que se paga. Algas, coral, bambú y perlas son **materiales** que además se piden en ciertas mejoras (ver punto 5 y la pregunta abierta).

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
| 16 | Tercer cultivo | Productor | T4 | [ABIERTO] | Ver punto 5 | Parcelas |
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
- [ABIERTO] Si hay más ramas.

[PROPUESTA] Ejemplos de nodos para empezar a discutir (5 a 8 por rama, con costes que se multiplican):

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

[PROPUESTA] Cuarta rama posible, **Chill** (muy del personaje): todo lo que gana el náufrago sin hacer nada. Por ejemplo, ganar más mientras no pulsas, que los edificios produzcan más, o que el clima dé ventajas (en tormenta salen más raros).

---

## 3. Cañas y objetos

- [DECIDIDO] Mejorar caña da peces mejores y más profundos, y tiene que subir el valor de lo que pescas.
- [DECIDIDO] Peces más pesados y, dentro de la misma rareza, peces más valiosos.

[PROPUESTA] Valor de un pez = **valor base de la especie × peso × calidad × multiplicadores** (árbol, edificios).
Las especies profundas tienen más valor base, aunque sean de la misma rareza. Así una caña mejor siempre se nota en el dinero.

| Caña | Tramo | Profundidad | Cadena | Valor medio por pez |
|------|-------|-------------|--------|---------------------|
| Rota | T0 | 1 | 1–5 | ×1 [hecho] |
| Decente | T0 | 2 | 2–9 | ×3 [hecho] |
| Sabia | T1 | 3 | 3–15 | ×10 [hecho] |
| 4 | T2 | 4 | — | ×30 |
| 5 | T3 | 5 | — | ×100 |
| 6 | T3 | 6 | — | ×300 |
| 7 | T4 | 7 | — | ×1.000 |
| Legendaria | T4 | 8 | — | ×3.000 |

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
- [ABIERTO] Qué tres cultivos. El diseñador propone algas, marihuana y bambú.

| Recurso | Tramo | De dónde sale | Para qué sirve [PROPUESTA] |
|---------|-------|---------------|---------------------------|
| Algas | T2 | Huerto de algas | Sushi (alga nori + pescado), primeras mejoras |
| Coral | T2 | Taladro marino | Decorar y ampliar la pecera, mejoras de edificios |
| Bambú | T3 | Bambuzal | Construir (cabañas, hotel, ampliaciones del pantalán) |
| Perlas | T3 | Centro de buceo | Mejoras de lujo, souvenirs caros |
| Tercer cultivo | T4 | Zona propia | [ABIERTO] |

[PROPUESTA] Cada recurso se recoge **a mano al principio** (gracioso y con animación) y **solo después**, cuando contratas a su trabajador.

Aviso sobre la marihuana: encaja con el personaje, pero en tiendas de móvil sube la clasificación por edad, y alguna plataforma pone pegas. En PC (Steam) no hay problema. Hay que tenerlo en cuenta si el móvil va en serio.

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

## 8. Equilibrio

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

## 9. Cómo lo llevamos

1. El diseñador revisa este documento y marca lo que es [DECIDIDO], lo que cambia y lo que sobra.
2. Pasamos el orden de edificios a la **Carta de Fishin** (qué, dónde y con qué condición) y el árbol al **Árbol de Fishin**.
3. Claude monta la hoja de curvas a partir de las tablas.
4. Se implementa **por tramos**: primero T2 completo (algas, sushi, taladro) jugable y equilibrado; luego T3. No se pasa al siguiente hasta que el actual divierta (regla del proyecto).

## Preguntas abiertas (de una en una)
1. ¿Los recursos (algas, coral, bambú, perlas) se **gastan como materiales** en mejoras, además de los rublos, o solo se **venden** por rublos? Choca con "una sola moneda que lo es todo" del GDD.
2. ¿Qué pez desbloquea el sushi y con qué condición llegan el huerto de algas y el taladro?
3. ¿Hay cuarta rama del árbol (por ejemplo Chill)?
4. ¿Cuál es el tercer cultivo definitivo?
5. Cómo pasa el tiempo en el juego (día/noche y estaciones), para los peces del Excel.
