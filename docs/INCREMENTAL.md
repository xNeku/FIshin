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

En Fishin, la espera usa `maxf(0.3, 1 − espera)`, que es un tope duro. Si un día se pasa de 0,7 en total, los niveles extra no harán nada. Cambiarlo a `1 / (1 + espera)` es una línea, pero mueve todos los números de la rama, así que **queda para la sesión de balance**. Pasa lo mismo con `segunda_oportunidad`, `pesca_doble` y `venta_doble`: hoy son probabilidades sumadas tal cual.

## 6. Lo que cuesta el combo (ojo, choque con el diseño)

Decidido: **el dinero gordo viene de los combos largos hechos a mano**. Con la fórmula actual eso no pasa:

```
valor del pez ∝ 1 + 0,12 · aciertos         (lineal)
tiempo de la picada ≈ 4,5 s + 0,5 s · aciertos   (también lineal)
```

Valor por segundo según el largo del combo (salen del simulador):

| Fórmula | x3 | x5 | x10 | x20 | x50 | x100 | x200 | Multiplicador a x200 |
|---|---|---|---|---|---|---|---|---|
| lineal 0,12 (la de ahora) | 0,23 | 0,23 | 0,23 | 0,23 | 0,24 | 0,24 | 0,24 | ×25 |
| cuadrática suave `1 + 0,12a + 0,004a²` | 0,23 | 0,24 | 0,27 | 0,35 | 0,58 | 0,97 | 1,77 | ×185 |
| potencia `1 + 0,05·a^1,5` | 0,21 | 0,22 | 0,27 | 0,38 | 0,63 | 0,94 | 1,36 | ×142 |
| tramos: lineal × 1,5 cada 25 | 0,23 | 0,23 | 0,23 | 0,23 | 0,53 | 1,21 | 6,13 | ×641 |

- Con la lineal, **un combo de 100 rinde por segundo lo mismo que uno de 5**: pescar largo no compensa, solo luce más.
- Además, hoy la cadena se corta en `pasos_perfect` del pez (de 5 a 14), así que de momento no existen combos de 20 o más.
- El modo flow (desde el botón 15) y el modo infinito necesitan que la cadena pueda pasar del perfect.

**[ABIERTO] Qué curva quieres para el combo.** Mi opinión:

- La **cuadrática suave** es la más honesta: cada botón vale un poco más que el anterior, sin saltos raros.
- La **de tramos** da momentos de "¡x1,5!" al cruzar 25, 50, 75..., muy de feel. Pega con el flow y con logros como "combo 200".
- Se pueden combinar: cuadrática suave de base, y tramos solo como celebración visual, sin tocar el dinero.

## 7. Activo frente a pasivo

Decidido: lo pasivo nunca sustituye a pescar a mano, hasta que se rompe en el endgame. En fórmula:

```
ingreso pasivo total ≤ ingreso manual del jugador medio / 3     (hasta el endgame)
```

Formas de garantizarlo sin poner un tope feo:

1. **Lo pasivo pesca lo barato.** Ya lo hace: los pescadores sacan siempre el pez más barato, con calidad 0,3 y sin combo. Su valor escala con el pez base, no con tus multiplicadores de combo.
2. **Los multiplicadores grandes solo afectan a lo manual** (combo, perfecto, flow). Los de Carisma afectan a todo, pero son aditivos.
3. **Los negocios dependen de tu suministro** (decidido): sin tus peces buenos, el sushi va a medio gas.

Cifras de ahora: un pescador saca unos **21 ₽/min** (sardina, 10 por viaje, unos 57 s por ciclo). El manual va de 60 ₽/min (caña Rota) a 250 ₽/min (Sabia). Con la regla 1:3, en la Sabia caben 3 o 4 pescadores antes de que lo pasivo pese demasiado. Esa es una buena cifra para el límite inicial de contratación.

## 8. Contratar pescadores (decidido: se habla con el primero; el límite viene del árbol y del pantalán)

Propuesta de números para discutir:

```
coste del pescador n = 150 · 1,6^n      →  150, 240, 384, 614, 983, 1.573, 2.517, 4.027...
límite = 2 (base) + nodos del árbol + nivel del pantalán × 2
```

- Payback del primero: 150 / 21 ≈ 7 min; el quinto, unos 47 min.
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
- Anatomía de un incremental (Kongregate, post "The Math of Idle Games", partes I-III). Es la lectura clásica sobre costes, pagos y prestigio.

---

### Lo que ya está y lo que falta en el código

| Concepto | Estado |
|---|---|
| Costes geométricos (árbol, tienda) | Hecho |
| Efectos por cubos (`Juego.efecto`) | Hecho |
| Topes de probabilidad / reducción | Topes duros; pasar a hiperbólicos en el balance |
| Curva de combo con peso | Falta; la lineal no premia los combos largos |
| Cadena más allá del perfect (flow, infinito) | Falta |
| Contratación con límite | Falta (decidido cómo; faltan los números) |
| Suministro de negocios `min(clientes, raciones)` | Falta (T2) |
| Mala racha | No está |
| Offline / prestigio | Sin decidir |
