# Matemáticas de incremental (chuleta para equilibrar Fishin)

Notas de estudio para la sesión de progresión. Primero la teoría corta y luego qué significa para Fishin con sus números de ahora. Lo que toca decidir está marcado [ABIERTO] y es del diseñador.

---

## 1. El bucle básico: cuánto tardas en poder comprar

Todo incremental se resume en una fórmula:

```
tiempo hasta la siguiente compra = (coste − lo que tienes) / ingresos por segundo
```

El "ritmo" (pacing) es lo que sale de ahí. Se equilibra poniendo **el tiempo entre desbloqueos** que quieres y despejando el coste, no al revés:

```
coste = ingresos esperados en ese momento × minutos que quieres que tarde
```

Regla de los buenos incrementales: los primeros desbloqueos caen cada 30-90 s, luego cada 3-5 min, y en el midgame cada 10-20 min. Los intervalos crecen despacio (más o menos en progresión geométrica): `t_n ≈ t_0 · g^n`, con g entre 1,1 y 1,3.

## 2. Costes que crecen: geométricos

Lo estándar para cualquier cosa que se compra varias veces:

```
coste(n) = base · r^n          (n = cuántas llevas)
```

| r | Sensación | Ejemplo |
|---|---|---|
| 1,07 - 1,15 | compras muchas, cada una un poco más cara | edificios de Cookie Clicker (1,15), AdVenture Capitalist (1,07-1,15) |
| 1,5 - 2 | pocas compras con peso | niveles de nodo del árbol, contratar pescadores |
| 2,5 - 10 | saltos de tramo | cañas, ampliaciones del pantalán |

Las fórmulas útiles para la UI ("comprar ×10" y "comprar el máximo"):

```
coste de k seguidas desde n = base · r^n · (r^k − 1) / (r − 1)
máximo que puedes pagar     = floor( log_r( dinero · (r − 1) / (base · r^n) + 1 ) )
```

En Fishin ya está: `NodoArbolData.coste(nivel) = coste_base · crecimiento^nivel` y `ArticuloData.precio_actual(veces)`.

## 3. Retorno (payback): la cifra que de verdad equilibra

Para cualquier mejora que suba los ingresos:

```
payback = coste / ingresos extra que da (en segundos o minutos)
```

- El jugador, aunque no lo sepa, compra lo de mejor payback.
- Si todas las opciones de un tramo tienen paybacks parecidos (por ejemplo, de 3 a 8 min), cualquier decisión se siente bien y ninguna es la "obligatoria".
- Si una tiene payback de 30 s y las demás de 10 min, el resto sobra: hay que bajarle el retorno o subirle el coste.
- Las mejoras que no dan dinero directo (calidad de vida, más tiempo de reacción) se valoran por cuánto suben el ingreso del jugador medio. Para eso está el simulador.

Con costes geométricos y producción lineal, el payback de cada unidad nueva empeora: es lo que hace que una línea "se agote" y el jugador pase a otra. Eso es bueno.

## 4. Cómo se suman los bonus: cubos

Dos formas, y las dos son necesarias:

- **Aditivo** (`1 + a + b + c`): crece despacio y es fácil de controlar.
- **Multiplicativo** (`(1+a) · (1+b) · (1+c)`): explota rápido y es lo que da la sensación de "números que se disparan".

El truco de casi todos los incrementales grandes es **sumar dentro de un cubo y multiplicar entre cubos**:

```
valor = base_pez × (1 + Σ carisma) × (1 + Σ lonja) × mult_caña × mult_combo × mult_calidad
```

Así cada cubo crece en línea (controlable) y el total crece multiplicando (satisfactorio). En Fishin `Juego.efecto(nombre)` ya suma por efecto: cada `efecto` es un cubo. Ahora mismo `mult_venta` suma Carisma y lonja en el mismo cubo (`1 + precio_venta + precio_lonja`). Si se quiere que la lonja pegue más fuerte en el midgame, se separan en dos cubos.

## 5. Topes y rendimientos decrecientes (softcaps)

Las probabilidades y los porcentajes de reducción **no pueden sumar sin límite**: un 110 % de pesca doble o un −100 % de espera rompen el juego.

| Fórmula | Para qué | Comportamiento |
|---|---|---|
| `min(x, tope)` | tope duro | simple, pero el último nivel "no hace nada" |
| `x / (x + k)` | probabilidades | nunca llega a 1; con x = k da el 50 % |
| `1 / (1 + x)` | reducciones de tiempo | un +100 % de "velocidad" es la mitad de espera, nunca cero |
| `x^0,5` o `log(1+x)` pasado un umbral | softcap | sigue subiendo, pero cada vez menos |

En Fishin, la espera ya va en hiperbólica: `espera × 1 / (1 + efecto espera)` (Paciencia + Cigarrito al máximo = +90 % de ritmo, es decir, un 47 % menos de espera). Siguen sumadas tal cual `segunda_oportunidad`, `pesca_doble` y `venta_doble`: mientras el árbol no pase del 50 % en ninguna, no hace falta tocarlas.

## 6. El combo: la racha (hecho)

**Problema que había:** el valor del pez era `× (1 + 0,12 · aciertos)`. El valor y el tiempo crecían los dos en línea, así que un x100 rendía por segundo lo mismo que un x5. Además, entre picada y picada solo pasaban 1,5-3,5 s: pescar 20 sardinas seguidas costaba casi lo mismo que un pez largo.

**Lo que hacen otros:**
- **osu!**: cada golpe vale `valor × (1 + combo × dificultad / 25)`, así que lo que suma una cadena crece con el cuadrado de su largo.
- **Guitar Hero**: el multiplicador sube x2, x3, x4 cada 10 notas seguidas y se pierde al fallar. El tope (x4, x8 con Star Power) evita que se dispare.
- **Taiko**: el bonus es `combo / 10` con tope 10.

**Fórmula de Fishin:** pago por botón (osu!) con tramos (Guitar Hero) y un tope por tramo:

```
multiplicador del botón i = racha(i): 1 hasta el 4.º; ×1,25 desde el 5.º; ×1,5 desde el 10.º; ×2 desde el 20.º;
                            ×2,5 desde el 35.º; ×3 desde el 50.º; ×3,5 desde el 75.º; ×4 desde el 100.º;
                            ×5 desde el 150.º; ×6 desde el 200.º (el tope)
valor = base × peso × max(0,3, Σ racha(1..aciertos) / perfect) × (2 si perfecto) × penalización de machacar
```

| Cadena perfecta | x1 | x5 | x10 | x20 | x35 | x50 | x100 | x200 |
|---|---|---|---|---|---|---|---|---|
| Multiplicador medio de la racha | 1,00 | 1,05 | 1,18 | 1,36 | 1,65 | 1,92 | 2,59 | 3,56 |
| Rinde por segundo (con el mismo valor por botón) | — | 0,67 | — | 2,50 | — | 5,87 | 10,2 | 16,4 |

- Cada botón acertado paga una parte del pez, y en racha paga más.
- Al cambiar de tramo hay recompensa sin texto: sonido de arpegio (`art/sfx/racha.wav`), destello, el contador da un salto y cambia de color (`HUD.colores_racha`).
- Rinde más por segundo por dos motivos: la espera entre picadas (unos 10 s) se reparte entre más botones, y los tramos suben el pago.
- Por encima de 200 el multiplicador ya no sube: el modo infinito crece en línea y no rompe la economía.
- Todo está en `data/stats_pesca.tres` (`racha_desde`, `racha_mult`) para ajustarlo en el inspector.

**Guía para poner precio a un pez nuevo** (para que los peces largos compensen su tiempo):

```
base ≈ k_tramo × (espera media + 0,6 s × perfect) × perfect^0,3 × rareza
```

El `perfect^0,3` es la prima por dificultad. Comparado con un pez de x5, uno de x50 rinde unas 3,6 veces más por segundo y uno de x200, unas 11. Rinde más, pero no tanto como para que los cortos sobren.

**Pendiente:** la cadena sigue cortándose en el `perfect` del pez, así que los combos de 20 o más llegan con los peces de perfect alto (midgame 10-25, final 30-60). El modo infinito será aparte.

## 6.5 Ritmo de pesca y chill (hecho)

Referencia: **Cast n Chill** (Steam, 2025, "muy positivas"). Las reseñas destacan que el sedal en el agua sin que pique nada "a veces es lo mejor", y su modo idle.

- **Espera realista:** de 6 a 14 s (antes 1,5-3,5 s). Caña Decente ×0,85, Sabia ×0,7. Salen unos 4,4 peces/min, uno cada ~14 s.
- **Picoteos:** mientras esperas, el corcho tiembla de vez en cuando (picoteos falsos cada 2,5-6 s). Justo antes de picar (0,9 s) hay un aviso. Así el que está tranquilo ve venir el pez y no se asusta. Valores en `StatsPesca` (`picoteo_min`, `picoteo_max`, `aviso_picada`) y la fuerza en la Barca (`hundimiento_picoteo`, `hundimiento_aviso`).
- **Chill:**
  - Estás de chill tras **8 s sin tocar nada**. La Hamaca lo baja 1 s por nivel, hasta 4 s.
  - Con esperas de 6-14 s, en casi todas las picadas entras en chill a mitad de espera. Por eso Brisa marina y Ronquido (pican más rápido de chill) ya funcionan.
- **Dejar pasar:**
  - Si estás de chill y pica un pez que no tocas, se va solo: sin X, sin sonido de escape y sin contar como escapado.
  - Puedes quedarte tumbado en el donut todo lo que quieras mientras los pescadores (y la rama Chill: Siesta, Atardecer, Nirvana) generan por detrás, y volver a pescar cuando te apetezca.
  - De paso cierra un agujero: la caña Sabia y la Pesca de memoria pescaban solas si no tocabas nada.
- **Mismo ritmo de dinero:** los peces valen unas 2,5 veces más (sardina 14, caballa 25, lubina 60, bota 85, atún 130, kraken 1.100). Así el ₽/min se queda como estaba (Rota ~57, Decente ~138, Sabia ~275) y los precios, el árbol y las llegadas por dinero no se descuadran. El viejo pasa de 100 a 50 peces para seguir llegando hacia el minuto 12.

## 7. Activo frente a pasivo

Decidido: lo pasivo nunca sustituye a pescar a mano, hasta que se rompe en el endgame. En fórmula:

```
ingreso pasivo total ≤ ingreso manual del jugador medio / 3     (hasta el endgame)
```

Formas de garantizarlo sin poner un tope feo:

1. **Lo pasivo pesca lo barato.** Ya lo hace: los pescadores sacan siempre el pez más barato, con calidad 0,3 y sin combo. Su valor escala con el pez base, no con tus multiplicadores de combo.
2. **Los multiplicadores grandes solo afectan a lo manual** (combo, perfecto, flow). Los de Carisma afectan a todo, pero son aditivos.
3. **Los negocios dependen de tu suministro** (decidido): sin tus peces buenos, el sushi va a medio gas.

Cifras de ahora (rebajadas): un pescador saca unos **8,3 ₽/min**. Pesca una sardina cada 38 s, lleva 6 por viaje y les saca el 40 % del valor (`calidad` 0,15).

```
ingreso de un pescador = valor_sardina × lerp(0,3, 1, calidad) × capacidad / (capacidad × tiempo_por_pez + viaje)
                       = 14 × 0,405 × 6 / (6 × 38 + 15) × 60 ≈ 8,3 ₽/min
```

- Cuando llega el puerto (con la caña Sabia, ~275 ₽/min a mano), el primero es un 3 % de lo tuyo.
- Con la regla 1:3 caben unos 10 antes de que lo pasivo pese demasiado. Así queda sitio para que el árbol (Carisma y Chill) y el pantalán los hagan crecer sin romper nada.
- Bolsas extra (Carisma) pasa a +1 pez por nivel; antes era +2, que con 6 de capacidad era demasiado.

## 8. Contratar pescadores (decidido: se habla con el primero; el límite viene del árbol y del pantalán)

Propuesta de números para discutir:

```
coste del pescador n = 150 · 1,6^n      →  150, 240, 384, 614, 983, 1.573, 2.517, 4.027...
límite = 2 (base) + nodos del árbol + nivel del pantalán × 2
```

- Payback del primero: 150 / 8,3 ≈ 18 min; el quinto, unos 2 h. Es lento a propósito: el pescador es compañía y un empujón, no la forma de ganar. Si se quiere más alegre, se baja la base del coste, no se sube lo que pesca.
- Eso empuja a mejorar el pantalán o a subir Carisma (velocidad y capacidad del pescador) en vez de acumular gente.
- Mejorar al pescador (multiplicar sus 21 ₽/min) suele ser mejor palanca que contratar más, porque no ocupa bordes.
- Recuerda que el puerto tiene bordes físicos limitados: el límite de contratación nunca debería pasar de los bordes que hay, o el jugador paga por alguien que no cabe. El código ya avisa en vez de colgarse.

## 9. Cadenas de suministro (sushi, algas, lonja)

Modelo estándar (Factorio, Kittens Game):

```
platos servidos/min = min(clientes/min, raciones disponibles/min)
ingreso del sushi   = platos servidos · precio del plato · mult_calidad_media
```

- **Raciones** salen de los peces que vendes en la lonja: cada especie da X raciones, y la calidad media sube el precio del plato (decidido: "cuantos más vendas y de mejor calidad, mejores platos").
- **Clientes** salen de la villa y el turismo (atracción, ver abajo).
- Que el jugador vea el cuello de botella: "clientes 30/min, raciones 12/min" en el panel del negocio. Ese es el feel de "si no pescas, el restaurante no rinde".
- Para que no se acapare, el almacén tiene tope o las raciones caducan (se pierde un % por minuto). Sin eso, pescas una hora y el sushi va solo el resto del juego, que rompe lo decidido.

**Turismo** (más adelante): `atracción = Σ (edificios × su atractivo) × (1 + decoración)` y `clientes/min = atracción^0,8`. El exponente menor que 1 hace que cada punto extra de atracción cuente un poco menos.

## 10. Rareza, suerte y mala racha

- Los pesos actuales (`probabilidad × mult_rareza × suerte`) están bien. Cuidado: subir la suerte también sube la proporción de raros entre sí; si dos efectos de suerte se multiplican, los legendarios se disparan.
- **Protección contra la mala racha** (pity): cada picada sin raro sube un poco su peso, y se resetea al salir. Evita las rachas de 200 picadas sin nada, que son las que hacen dejar un juego. Son 5 líneas en `_tirar_pez`. **[ABIERTO]**, pero lo recomiendo para los peces de combo enorme.
- El valor esperado de una picada es `Σ prob_i · valor_i · E[mult]`. El simulador ya lo calcula; cada pez nuevo se mete ahí antes de ponerle el precio.

## 11. Ingreso sin el juego abierto (offline)

Casi todos los incrementales de Steam lo tienen: al volver, "mientras no estabas: +X". Lo habitual es un tope de 8-12 h al 25-50 % de eficiencia, y solo lo pasivo. Encaja con "un juego para tenerlo abierto", pero también puede quitar la gracia de dejarlo abierto. **[ABIERTO]**.

## 12. Prestigio

Reiniciar a cambio de una moneda permanente: `moneda = floor((total ganado / 1e6)^0,5)`. La raíz hace que doblar lo ganado no doble la moneda. El GDD no habla de prestigio, y con unas 20 h de juego y un endgame de ciudad puede que no haga falta. Si algún día hay rama endgame infinita, es la herramienta típica. **[ABIERTO]**, sin prisa.

## 13. Números grandes

- `float` aguanta hasta 1e308; sobra para el diseño actual (decidido).
- Formato: K, M, B, T y después aa, ab... o notación científica. Todo por `Formato.dinero()`.
- Orden de magnitud orientativo para unas 20 h: empezar en decenas de ₽/min, midgame en miles o decenas de miles, endgame en millones o miles de millones. Si a las 5 h ya hay millones, el resto se acelera demasiado.

## 14. Método para la sesión de balance

1. Fijar la **línea de tiempo objetivo**: minuto → qué se desbloquea (borrador en `PROGRESION.md`).
2. Para cada minuto, el **ingreso esperado** del jugador medio (simulador).
3. Despejar **costes**: `coste = ingreso × minutos objetivo`.
4. Comprobar los **paybacks** de todas las opciones abiertas en ese momento (que se parezcan).
5. Comprobar la regla **pasivo ≤ manual / 3**.
6. Pasarlo por el simulador (`docs/herramientas/simular_economia.py`), ajustar y repetir.
7. Probarlo jugando: la tabla dice si cuadra, el mando dice si divierte.

## 15. Referencias

- Cookie Clicker: costes ×1,15, mejoras multiplicativas por edificio, mejoras sinérgicas.
- AdVenture Capitalist: hitos de cantidad (×2 al tener 25, 50, 100...), managers como automatización.
- Kittens Game: recursos encadenados, almacenes con tope, el equilibrio como puzzle.
- Antimatter Dimensions: números enormes, varias capas de prestigio, ritmo muy medido.
- Forager: expansión de terreno que se paga y desbloquea más recursos (nuestra referencia directa).
- Anthony Pecorella (productor de AdVenture Capitalist), "The Math of Idle Games", partes I-III. Es la lectura clásica:
  - Parte I: crecimiento, costes, compra en bloque y máximo asequible.
  - Parte II: modelos de crecimiento por derivadas, al estilo Antimatter Dimensions.
  - Parte III: bucles de prestigio.
  - Enlaces: [I](https://www.gamedeveloper.com/design/the-math-of-idle-games-part-i), [II](https://www.gamedeveloper.com/disciplines/the-math-of-idle-games-part-ii), [III](https://www.gamedeveloper.com/design/the-math-of-idle-games-part-iii).
- Cookie Clicker: coste `base × 1,15^n`, que dobla el precio cada 5 edificios; la compra en bloque es una serie geométrica ([wiki](https://cookieclicker.wiki.gg/wiki/Building)).
- AdVenture Capitalist: hitos a 25, 50, 100, 200... unidades que reducen a la mitad el tiempo de ciclo ([wiki](https://adventure-capitalist.fandom.com/wiki/Businesses)).
- osu! (ScoreV1): el valor de cada golpe crece con el combo ([wiki](https://osu.ppy.sh/wiki/be/Gameplay/Score/ScoreV1/osu%21)).
- Guitar Hero: multiplicador x2, x3, x4 cada 10 notas, que se pierde al fallar ([wiki](https://guitarhero.fandom.com/wiki/Multiplier)).
- Cast n Chill: pesca idle tranquila con modo automático ([reseña de Shacknews](https://www.shacknews.com/article/144913/cast-n-chill-review-score)).
- Devlog "Active or idle?": bonus por no tocar y enfriamientos en los clics para equilibrar los dos estilos ([itch.io](https://fourda.itch.io/four-divine-abidings-full/devlog/981439/active-or-idle)). Es lo mismo que hacemos con la rama Chill.

---

### Lo que ya está y lo que falta en el código

| Concepto | Estado |
|---|---|
| Costes geométricos (árbol, tienda) | Hecho |
| Efectos por cubos (`Juego.efecto`) | Hecho |
| Topes de probabilidad / reducción | Espera en hiperbólica; las probabilidades siguen sumadas (bajo el 50 %) |
| Curva de combo con peso | Hecho: racha por tramos con tope ×6 |
| Esperas realistas, picoteos y chill que deja pasar | Hecho |
| Cadena más allá del perfect (flow, infinito) | Falta |
| Contratación con límite | Falta (decidido cómo; faltan los números) |
| Suministro de negocios `min(clientes, raciones)` | Falta (T2) |
| Mala racha | No está |
| Offline / prestigio | Sin decidir |
