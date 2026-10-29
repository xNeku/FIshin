# Simulador de la economía de Fishin (v2). Copia la lógica de scripts/pesca/pesca.gd con los datos
# de data/ y un jugador "normal" (acierta según el tiempo que le da cada botón).
# Uso: python3 docs/herramientas/simular_economia.py
# Si cambias un .tres de peces, cañas o stats, cámbialo aquí también.
import random

random.seed(1)

# --- data/stats_pesca.tres ---
T0, FACT, TMIN = 1.5, .88, .4        # tiempo del 1er botón, factor por botón, mínimo
MULT_DOBLE, DOBLES_DESDE = 1.4, 5
ESPERA = (6.0, 14.0)                  # segundos hasta que pica (rango base)
RESULTADO = 1.6                       # pausa tras el pez
PAUSA = 0.12                          # entre botones
CAL_MIN, PERFECTO, PEN_MACHACAR = 0.3, 2.0, 0.25
# Racha: desde el botón X, cada botón acertado vale R veces (tramos tipo Guitar Hero, pago tipo osu!).
RACHA_DESDE = [5, 10, 20, 35, 50, 75, 100, 150, 200]
RACHA_MULT = [1.25, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 5.0, 6.0]

# --- data/peces/*.tres ---  id, rareza, prof, valor, pmin, pmax, prob, perfect, mult_t, machacar_cada, prob_doble
PECES = [
    ("sardina", 0, 1, 14, .1, .3, 10, 5, 1.0, 0, 0.0),
    ("caballa", 0, 1, 25, .3, .8, 7, 6, 1.0, 0, 0.1),
    ("lubina", 1, 1, 60, 1, 4, 4, 8, .95, 0, .25),
    ("bota_vieja", 2, 1, 85, .5, 1, 1.2, 7, .9, 4, .4),
    ("atun", 1, 2, 130, 20, 60, 2, 10, .95, 5, .2),
    ("kraken", 3, 3, 1100, 5, 15, .3, 14, .9, 5, .35),
]
# --- data/canas/*.tres ---
CANAS = {
    "rota": dict(prof=1, cmin=1, cmax=5, sesgo=2.0, mt=1.0, me=1.0, mr=1.0, auto=False),
    "decente": dict(prof=2, cmin=2, cmax=9, sesgo=1.6, mt=1.05, me=.85, mr=1.3, auto=False),
    "sabia": dict(prof=3, cmin=3, cmax=15, sesgo=1.25, mt=1.1, me=.7, mr=1.6, auto=True),
}
# --- scenes/mundo/trabajador.tscn ---
TRAB = dict(t_pez=38.0, capacidad=6, viaje=15.0, mult_valor=0.4)


def racha(i):
    """Multiplicador del botón i (1 = el primero)."""
    m = 1.0
    for desde, r in zip(RACHA_DESDE, RACHA_MULT):
        if i >= desde:
            m = r
    return m


def suma_racha(a):
    return sum(racha(i) for i in range(1, a + 1))


def p_acierto(t, doble=False, jugador=1.0):
    # 1 s o más: casi seguro; 0,4 s: 3 de cada 4; por debajo cae rápido.
    p = 0.99 if t >= 1.0 else 0.75 + (t - 0.4) / 0.6 * 0.24 if t >= 0.4 else max(0.3, 0.75 - (0.4 - t) * 2)
    p = min(0.995, p * jugador)
    return p * (0.9 if doble else 1.0)


def tirar(c):
    ws = [(p, p[6] * (1 if p[1] == 0 else c["mr"])) for p in PECES if p[2] <= c["prof"]]
    r = random.random() * sum(w for _, w in ws)
    for p, w in ws:
        r -= w
        if r <= 0:
            return p
    return ws[-1][0]


def largo(c):
    o = c["cmax"] - c["cmin"] + 1
    return c["cmin"] + min(o - 1, int(o * random.random() ** c["sesgo"]))


def mult_valor(aciertos, perfect, mach_fall):
    m = max(CAL_MIN, suma_racha(aciertos) / perfect)
    m *= max(.1, 1 - PEN_MACHACAR * mach_fall)
    if aciertos >= perfect:
        m *= PERFECTO
    return m


def picada(c, jugador=1.0, forzar=None):
    p = forzar or tirar(c)
    n = p[7] if forzar else min(p[7], largo(c))
    t = random.uniform(*ESPERA) * c["me"]
    aciertos = mach_fall = 0
    for i in range(n):
        tm = max(TMIN, T0 * FACT ** i) * p[8] * c["mt"]
        mach = p[9] > 0 and i > 0 and (i + 1) % p[9] == 0
        doble = (not mach) and i + 1 >= DOBLES_DESDE and random.random() < p[10]
        if doble:
            tm *= MULT_DOBLE
        t += tm * 0.6 + PAUSA
        if mach:
            if random.random() < 0.85:
                aciertos += 1
            elif p[1] >= 2:
                return 0.0, t + RESULTADO, aciertos, False
            else:
                mach_fall += 1
            continue
        if random.random() < p_acierto(tm, doble, jugador):
            aciertos += 1
        else:
            if aciertos == 0 and not c["auto"]:
                return 0.0, t + RESULTADO, 0, False
            break
    t += RESULTADO
    peso = random.uniform(p[4], p[5]) / ((p[4] + p[5]) / 2)
    return p[3] * peso * mult_valor(aciertos, p[7], mach_fall), t, aciertos, True


def ritmo(cana, jugador=1.0, n=20000):
    c = CANAS[cana]
    dinero = tiempo = capt = 0.0
    for _ in range(n):
        v, t, _, ok = picada(c, jugador)
        dinero += v; tiempo += t; capt += ok
    return dinero / tiempo * 60, capt / tiempo * 60


def trabajador():
    sard = PECES[0]
    v = sard[3] * TRAB["mult_valor"]
    ciclo = TRAB["capacidad"] * TRAB["t_pez"] + TRAB["viaje"]
    return v * TRAB["capacidad"] / ciclo * 60


if __name__ == "__main__":
    print("--- Ritmo por caña ---")
    for cana in CANAS:
        for j, nom in [(1.0, "normal"), (1.03, "bueno")]:
            r, cpm = ritmo(cana, j)
            print(f"{cana:8s} {nom:7s}: {r:7.1f} ₽/min  {cpm:4.1f} peces/min")
    print(f"\nUn pescador: {trabajador():.1f} ₽/min")

    print("\n--- Racha: lo que vale cada largo (pez perfecto, sin contar peso) ---")
    for a in [1, 5, 10, 20, 35, 50, 100, 200]:
        print(f"x{a:<4d} multiplicador medio {suma_racha(a) / a:4.2f}   suma {suma_racha(a):7.1f}")

    print("\n--- ¿Compensa una cadena larga frente a muchas cortas? (mismo valor por botón) ---")
    espera = sum(ESPERA) / 2
    for a in [5, 20, 50, 100, 200]:
        t = espera + RESULTADO + sum(max(TMIN, T0 * FACT ** i) * .6 + PAUSA for i in range(a))
        print(f"cadena x{a:<4d}: {suma_racha(a) * PERFECTO / t:5.2f} por segundo")
