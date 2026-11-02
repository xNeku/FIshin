# Calibra las cañas de carril (rápida = banco, tocha = pelea) contra la caña normal de la misma época.
# Copia la lógica de scripts/pesca/ritmo.gd y Pesca.terminar_ritmo. Uso: python3 docs/herramientas/simular_carril.py
import random, sys, os
sys.path.insert(0, os.path.dirname(__file__))
import simular_economia as S

# --- scenes/ui/ritmo.tscn (exports de Ritmo) ---
ANTELACION = 1.8
BPM_BANCO, ACELERA, CORCHEAS_DESDE, SEP_MIN = 120.0, 0.012, 5, 0.18
BPM_PELEA, PROB_LARGA, PROB_ACORDE, DANO, CURA = 96.0, 0.22, 0.15, 0.14, 0.025
# --- Pesca (main.tscn) ---
MULT_VOLUMEN, MULT_TROFEO = float(os.environ.get("MV", 0.18)), float(os.environ.get("MT", 0.7))


def p_nota(sep, jugador=1.0, larga=False, acorde=False):
    """Acierto de una nota según el hueco con la anterior (s). 0,5 s: 96 %; 0,25 s: 85 %; 0,18 s: 75 %."""
    s = sep * jugador
    p = 0.97 if s >= 0.6 else 0.85 + (s - 0.25) / 0.35 * 0.12 if s >= 0.25 else max(0.5, 0.85 - (0.25 - s) * 1.4)
    return p * (0.93 if larga else 1.0) * (0.85 if acorde else 1.0)


def pez_de(hondo, modo, mr):
    ws = []
    for p in S.PECES:
        if p[2] > hondo or (modo == "banco" and p[1] > 1) or (modo == "pelea" and p[1] < 2):
            continue
        w = p[6] * S.PESO_NIVEL_ARRIBA ** (hondo - p[2]) * (mr if p[1] >= 2 else 1)
        ws.append((p, w))
    r = random.random() * sum(w for _, w in ws)
    for p, w in ws:
        r -= w
        if r <= 0:
            return p
    return ws[-1][0]


def banco(c, jugador=1.0):
    p = pez_de(c["prof"], "banco", c["mr"])
    k = random.random()
    t = (S.ESPERA[0] + (S.ESPERA[1] - S.ESPERA[0]) * k) * c["me"] + ANTELACION + 0.4
    n = random.randint(c["cmin"], c["cmax"])
    pulso, combo, v, aciertos = 60 / BPM_BANCO, 0, 0.0, 0
    for i in range(n):
        sep = pulso * (0.5 if i >= CORCHEAS_DESDE and random.random() < 0.3 else 1.0)
        sep = max(SEP_MIN, sep)
        if random.random() < p_nota(sep, jugador):
            combo += 1; aciertos += 1
            v += p[3] * MULT_VOLUMEN * S.racha(combo)
        else:
            combo = 0
        t += sep
        pulso *= 1 - ACELERA
    return v, t + S.RESULTADO + 0.3, aciertos


def pelea(c, jugador=1.0):
    p = pez_de(c["prof"], "pelea", c["mr"])
    k = random.random()
    t = (S.ESPERA[0] + (S.ESPERA[1] - S.ESPERA[0]) * k) * c["me"] + ANTELACION + 0.4
    n = max(20, min(60, p[7] * 2))
    pulso = 60 / BPM_PELEA
    vida, combo, suma, aciertos, i, total = 1.0, 0, 0.0, 0, 0, 0
    while i < n:
        larga = i > 2 and random.random() < PROB_LARGA
        acorde = (not larga) and p[1] >= 3 and random.random() < PROB_ACORDE
        notas = 2 if acorde else 1
        for _ in range(notas):
            total += 1
            if random.random() < p_nota(pulso, jugador, larga, acorde):
                combo += 1; aciertos += 1; suma += S.racha(combo); vida = min(1, vida + CURA)
            else:
                combo = 0; vida -= DANO
        i += notas
        if vida <= 0:
            return 0.0, t + S.RESULTADO, 0
        dur = pulso * random.randint(1, 3) if larga else 0
        t += dur + pulso * (0.5 if random.random() < 0.2 else 1.0)
    m = max(S.CAL_MIN, suma / total) * (S.PERFECTO if aciertos >= total else 1)
    return p[3] * MULT_TROFEO * m, t + S.RESULTADO + 0.3, aciertos


def media(f, c, jugador, n=6000):
    d = tt = 0.0
    for _ in range(n):
        v, t, _ = f(c, jugador)
        d += v; tt += t
    return d / tt * 60


if __name__ == "__main__":
    random.seed(3)
    rapida = dict(prof=5, cmin=12, cmax=30, me=0.6, mr=1.0)
    tocha = dict(prof=6, cmin=0, cmax=0, me=1.6, mr=3.0)
    for j, nom in [(1.0, "normal"), (1.3, "bueno"), (0.8, "flojo")]:
        ref5 = S.ritmo("cana_carbono", j, 6000)[0]
        ref6 = S.ritmo("cana_coral", j, 6000)[0]; ref7 = S.ritmo("cana_altura", j, 6000)[0]
        b = media(banco, rapida, j)
        b6 = media(banco, dict(rapida, prof=6), j)
        pe = media(pelea, tocha, j)
        pe7 = media(pelea, dict(tocha, prof=7), j)
        print(f"{nom:7s} carbono {ref5:7.0f}  coral {ref6:7.0f} | rápida p5 {b:7.0f} ({b / ref5:4.2f}× carbono) p6 {b6:7.0f}"
              f" ({b6 / ref6:4.2f}× coral) | tocha p6 {pe:7.0f} ({pe / ref6:4.2f}× coral) p7 {pe7:7.0f} ({pe7 / ref7:4.2f}× altura)")
