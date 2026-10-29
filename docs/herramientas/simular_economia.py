# Simulador del arranque de Fishin con los datos reales (peces, cañas, stats). Modelo de jugador:
# probabilidad de acertar cada botón según el tiempo que da (un jugador normal, no un pro).
import random, statistics
random.seed(1)
PECES = [  # id, rareza, prof, valor, pmin, pmax, prob, perfect, mult_t, machacar_cada, prob_doble
    ("sardina", 0, 1, 4, .1, .3, 10, 5, 1.0, 0, 0.0),
    ("caballa", 0, 1, 7, .3, .8, 7, 6, 1.0, 0, 0.1),
    ("lubina", 1, 1, 18, 1, 4, 4, 8, .95, 0, .25),
    ("bota_vieja", 2, 1, 25, .5, 1, 1.2, 7, .9, 4, .4),
    ("atun", 1, 2, 45, 20, 60, 2, 10, .95, 5, .2),
    ("kraken", 3, 3, 400, 5, 15, .3, 14, .9, 5, .35),
]
CANAS = {
    "rota": dict(prof=1, cmin=1, cmax=5, sesgo=2.0, mt=1.0, me=1.0, mr=1.0, auto=False),
    "decente": dict(prof=2, cmin=2, cmax=9, sesgo=1.6, mt=1.05, me=.9, mr=1.3, auto=False),
    "sabia": dict(prof=3, cmin=3, cmax=15, sesgo=1.25, mt=1.1, me=.8, mr=1.6, auto=True),
}
T0, FACT, TMIN, BONUS = 1.5, .88, .4, .12


def p_acierto(t, doble=False, jugador=1.0):
    # 1 s o más: casi seguro; 0,4 s: 3 de cada 4; por debajo cae rápido.
    p = 0.99 if t >= 1.0 else 0.75 + (t - 0.4) / 0.6 * 0.24 if t >= 0.4 else max(0.3, 0.75 - (0.4 - t) * 2)
    p = min(0.995, p * jugador)
    return p * (0.9 if doble else 1.0)


def tirar(c):
    ws = []
    for p in PECES:
        if p[2] > c["prof"]:
            continue
        ws.append((p, p[6] * (1 if p[1] == 0 else c["mr"])))
    r = random.random() * sum(w for _, w in ws)
    for p, w in ws:
        r -= w
        if r <= 0:
            return p
    return ws[-1][0]


def largo(c):
    o = c["cmax"] - c["cmin"] + 1
    return c["cmin"] + min(o - 1, int(o * random.random() ** c["sesgo"]))


def picada(c, jugador=1.0):
    p = tirar(c)
    n = min(p[7], largo(c))
    t_total = random.uniform(1.5, 3.5) * c["me"]
    aciertos, mach_fall, combo = 0, 0, 0
    escapa = False
    for i in range(n):
        tm = max(TMIN, T0 * FACT ** i) * p[8] * c["mt"]
        mach = p[9] > 0 and i > 0 and (i + 1) % p[9] == 0
        doble = (not mach) and i + 1 >= 5 and random.random() < p[10]
        if doble:
            tm *= 1.4
        t_total += tm * 0.6 + 0.12
        if mach:
            if random.random() < 0.85:
                aciertos += 1
            elif p[1] >= 2:
                escapa = True
                break
            else:
                mach_fall += 1
            continue
        if random.random() < p_acierto(tm, doble, jugador):
            aciertos += 1
        else:
            if aciertos == 0 and not c["auto"]:
                escapa = True
            break
    t_total += 1.6
    combo = aciertos
    if escapa:
        return 0.0, t_total, combo, p[0], False
    ratio = aciertos / p[7]
    perf = aciertos >= p[7]
    peso = random.uniform(p[4], p[5])
    mult = (0.3 + 0.7 * ratio) * max(.1, 1 - .25 * mach_fall) * (2 if perf else 1) * (1 + BONUS * aciertos)
    return p[3] * (peso / ((p[4] + p[5]) / 2)) * mult, t_total, combo, p[0], True


def ritmo(cana, jugador=1.0, n=20000):
    c = CANAS[cana]
    dinero = tiempo = 0.0
    capt = 0
    combos = []
    for _ in range(n):
        v, t, cb, _, ok = picada(c, jugador)
        dinero += v; tiempo += t; capt += ok; combos.append(cb)
    return dinero / tiempo * 60, capt / tiempo * 60, sum(1 for x in combos if x >= 10) / n


for cana in CANAS:
    for j, nom in [(1.0, "normal"), (1.03, "bueno")]:
        r, cpm, p10 = ritmo(cana, j)
        print(f"{cana:8s} {nom:7s}: {r:7.1f} ₽/min  {cpm:5.1f} peces/min  combo>=10 en {p10*100:4.1f}% de picadas")

# Línea de tiempo del arranque con un jugador normal
print("\n--- Línea de tiempo (jugador normal, vende al llenar o cada 2 min) ---")
t = 0.0; rublos = 0.0; totales = 0.0; peces = 0; cana = "rota"; mejor_combo = 0
hitos = {}
def hito(n):
    if n not in hitos:
        hitos[n] = t
        print(f"{t/60:6.1f} min  {n}   (₽ {rublos:.0f}, totales {totales:.0f}, peces {peces})")
pend = 0.0
while t < 3600 * 2:
    v, dt, cb, _, ok = picada(CANAS[cana])
    t += dt; pend += v; peces += ok; mejor_combo = max(mejor_combo, cb)
    if peces >= 3: hito("comerciante")
    if t - hitos.get("_venta", 0) > 120 or pend > 0 and peces % 15 == 0:
        rublos += pend; totales += pend; pend = 0; hitos["_venta"] = t; t += 6
    if totales >= 200: hito("primera isla (200 ₽ totales)")
    if cana == "rota" and rublos >= 150:
        rublos -= 150; cana = "decente"; hito("compra caña decente (150)")
    if peces >= 100: hito("viejo / árbol (100 peces)")
    if t >= 1200: hito("camino (20 min)")
    if cana == "decente" and rublos >= 2000 and "viejo / árbol (100 peces)" in hitos:
        rublos -= 2000; cana = "sabia"; hito("compra Sabia caña (2000)")
    if mejor_combo >= 10: hito("puerto (combo x10)")
    if totales >= 1500 and "camino (20 min)" in hitos: hito("lonja (1.500 ₽ totales + camino)")
