# Simulador de la economía de Fishin (v5: pesca base automática; picada() queda para los spots). Copia la lógica de scripts/pesca/pesca.gd con los datos
# de data/ y un jugador "normal" (acierta según el tiempo que le da cada botón).
# Uso: python3 docs/herramientas/simular_economia.py
# Si cambias un .tres de peces, cañas o stats, cámbialo aquí también.
import random

random.seed(1)

# --- data/stats_pesca.tres ---
T0, FACT, TMIN = 1.5, .88, .4        # tiempo del 1er botón, factor por botón, mínimo
MULT_DOBLE, DOBLES_DESDE = 1.4, 5
ESPERA = (5.0, 15.0)                  # segundos hasta que pica (rango base)
CADENA_POR_ESPERA = 0.7               # cuanto más tarda en picar, menos sesgo a cadenas cortas
RESULTADO = 1.6                       # pausa tras el pez
PAUSA = 0.12                          # entre botones
CAL_MIN, PERFECTO, PEN_MACHACAR = 0.3, 2.0, 0.25
# Racha: desde el botón X, cada botón acertado vale R veces (tramos tipo Guitar Hero, pago tipo osu!).
RACHA_DESDE = [5, 10, 15, 20, 25, 35, 50, 75, 100, 150, 200]
RACHA_MULT = [1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 3.0, 3.5, 4.0, 5.0, 6.0]
# Maestría (bestiario, estilo hitos de AdVenture Capitalist): capturas de una especie -> ×valor de esa especie.
MAESTRIA_DESDE = [10, 50, 200, 1000]
MAESTRIA_MULT = [1.1, 1.25, 1.5, 2.0]

# --- data/peces/*.tres --- (se leen de la carpeta) id, rareza, prof, valor, pmin, pmax, prob, perfect, mult_t,
# machacar_cada, prob_doble. Rareza: 0 común, 1 poco común, 2 raro, 3 épico, 4 legendario, 5 mítico.
import glob, os
_RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
PESO_NIVEL_ARRIBA = 0.45   # StatsPesca.peso_por_nivel_arriba


def _leer_peces():
    r = []
    for f in sorted(glob.glob(os.path.join(_RAIZ, "data", "peces", "*.tres"))):
        d = {}
        for linea in open(f, encoding="utf-8"):
            if " = " in linea and not linea.startswith("["):
                k, v = linea.strip().split(" = ", 1)
                d[k] = v
        g = lambda k, x=0.0: float(d.get(k, x))
        r.append((d["id"].strip('&"'), int(g("rareza")), int(g("profundidad", 1)), g("valor_base", 5), g("peso_min", .5),
                  g("peso_max", 2), g("probabilidad", 1), int(g("pasos_perfect", 6)), g("mult_tiempo", 1),
                  int(g("machacar_cada")), g("prob_doble")))
    return r


PECES = _leer_peces()
# --- data/canas/*.tres ---
def _leer_tres(f):
    d = {}
    for linea in open(f, encoding="utf-8"):
        if " = " in linea and not linea.startswith("["):
            k, v = linea.strip().split(" = ", 1)
            d[k] = v.strip('&"')
    return d


def _leer_canas():
    r = {}
    for f in glob.glob(os.path.join(_RAIZ, "data", "canas", "*.tres")):
        d = _leer_tres(f)
        r[d["id"]] = dict(prof=int(d["profundidad"]), cmin=int(d.get("cadena_min", 1)), cmax=int(d.get("cadena_max", 5)),
                          sesgo=float(d.get("sesgo_cadena", 2)), mt=float(d.get("mult_tiempo", 1)),
                          me=float(d.get("mult_espera", 1)), mr=float(d.get("mult_rareza", 1)),
                          auto=d.get("auto_primer_boton") == "true", nombre=d["nombre"],
                          valor=float(d.get("valor_pez", 5)))
    return r


CANAS = _leer_canas()
# Orden en que se compran: (id de caña, precio del artículo, lo que tiene que haber llegado).
COMPRA_CANAS = [("cana_buena", 300, None), ("cana_pro", 6800, "viejo y árbol"),
                ("cana_fibra", None, "lonja"), ("cana_carbono", None, "entrada turistas"),
                ("cana_coral", None, "taladro"), ("cana_altura", None, "sushi")]
# --- scenes/mundo/trabajador.tscn ---
TRAB = dict(t_pez=14.0, capacidad=8, viaje=15.0, mult_valor=0.4)


def racha(i):
    """Multiplicador del botón i (1 = el primero)."""
    m = 1.0
    for desde, r in zip(RACHA_DESDE, RACHA_MULT):
        if i >= desde:
            m = r
    return m


def maestria(n):
    m = 1.0
    for desde, r in zip(MAESTRIA_DESDE, MAESTRIA_MULT):
        if n >= desde:
            m = r
    return m


def suma_racha(a):
    return sum(racha(i) for i in range(1, a + 1))


def p_acierto(t, doble=False, jugador=1.0):
    # jugador = rapidez de reflejos: 1 normal, 1,3 bueno, 0,8 flojo (como si tuviera ese múltiplo de tiempo).
    # Calibrado con la prueba del diseñador (1 h 20 hasta la lonja "apenas fallé combos"):
    # 0,8 s o más: casi seguro; 0,4 s: 94 %; por debajo cae rápido (el flow baja hasta 0,3 s).
    t *= jugador
    p = 0.995 if t >= 0.8 else 0.94 + (t - 0.4) / 0.4 * 0.055 if t >= 0.4 else max(0.4, 0.94 - (0.4 - t) * 2.5)
    return p * (0.95 if doble else 1.0)


def tirar(c, E=None):
    E = E or {}
    suerte = c["mr"] * (1 + E.get("raros", 0))
    ws = [(p, p[6] * PESO_NIVEL_ARRIBA ** (c["prof"] - p[2]) * (suerte if p[1] >= 2 else 1))
          for p in PECES if p[2] <= c["prof"]]
    r = random.random() * sum(w for _, w in ws)
    for p, w in ws:
        r -= w
        if r <= 0:
            return p
    return ws[-1][0]


def largo(c, quitar=0.0, extra=0):
    o = c["cmax"] + extra - c["cmin"] + 1
    sesgo = max(0.45, c["sesgo"] * (1 - min(0.85, quitar)))
    return c["cmin"] + min(o - 1, int(o * random.random() ** sesgo))


def mult_valor(aciertos, perfect, mach_fall, calidad=0.0):
    m = max(CAL_MIN, suma_racha(aciertos) / perfect + calidad)
    m *= max(.1, 1 - PEN_MACHACAR * mach_fall)
    if aciertos >= perfect:
        m *= PERFECTO
    return m


CAPTURADOS = {}
PUNTOS = [0.0]  # puntos de pesca: suma de racha de cada pez (×2 si perfecto). Premian pescar bien.


def picada(c, jugador=1.0, forzar=None, E=None):
    """Una picada. E = efectos del árbol (como Juego.efecto). Devuelve (valor, segundos, aciertos, pescado, n)."""
    E = E or {}
    p = forzar or tirar(c, E)
    k = random.random()
    n = p[7] if forzar else min(p[7], largo(c, E.get("sesgo_cadena", 0) + k * CADENA_POR_ESPERA, int(E.get("cadena_extra", 0))))
    t = (ESPERA[0] + (ESPERA[1] - ESPERA[0]) * k) * c["me"] / (1 + E.get("espera", 0))
    aciertos = mach_fall = 0
    auto = c["auto"] or E.get("auto_primer_boton", 0) > 0
    for i in range(n):
        tm = max(TMIN, T0 * FACT ** i) * p[8] * c["mt"] * (1 + E.get("tiempo_reaccion", 0))
        mach = p[9] > 0 and i > 0 and (i + 1) % p[9] == 0
        doble = (not mach) and i + 1 >= DOBLES_DESDE and random.random() < p[10]
        if doble:
            tm *= MULT_DOBLE
        t += tm * 0.6 + PAUSA
        if mach:
            if random.random() < 0.85:
                aciertos += 1
            elif p[1] >= 3:
                return 0.0, t + RESULTADO, aciertos, False, n
            else:
                mach_fall += 1
            continue
        if random.random() < p_acierto(tm, doble, jugador):
            aciertos += 1
        else:
            if aciertos == 0 and not auto:
                return 0.0, t + RESULTADO, 0, False, n
            break
    t += RESULTADO
    peso = random.uniform(p[4], p[5]) / ((p[4] + p[5]) / 2) * (1 + E.get("peso", 0))
    CAPTURADOS[p[0]] = CAPTURADOS.get(p[0], 0) + 1
    PUNTOS[0] += suma_racha(aciertos) * (PERFECTO if aciertos >= p[7] else 1.0)
    v = p[3] * peso * mult_valor(aciertos, p[7], mach_fall, E.get("calidad", 0)) * maestria(CAPTURADOS[p[0]])
    if random.random() < E.get("pesca_doble", 0):
        v *= 2
    return v, t, aciertos, True, n


# --- v5: pesca base (sentado pesca solo) --- data/peces_base/*.tres y Pesca (main.tscn, grupo Pesca base)
def _leer_peces_base():
    r = []
    for f in sorted(glob.glob(os.path.join(_RAIZ, "data", "peces_base", "*.tres"))):
        d = _leer_tres(f)
        r.append((d["id"], int(d.get("rareza", 0)), float(d["valor_base"]), float(d["probabilidad"])))
    return r


PECES_BASE = _leer_peces_base()
BASE = dict(ventana=1.3, retraso_auto=4.0, valor_auto=0.55, suerte_manual=1.4, resultado=0.4,
            lanzar=0.8, reaccion=0.45)


def picada_base(c, E=None, atencion=0.8):
    """Una pieza de la base. atencion = probabilidad de que el jugador pique a mano (0 = AFK).
    Devuelve (valor, segundos, pescado)."""
    E = E or {}
    k = random.random()
    t = (ESPERA[0] + (ESPERA[1] - ESPERA[0]) * k) * c["me"] / (1 + E.get("espera", 0)) + BASE["lanzar"] + BASE["resultado"]
    manual = random.random() < atencion
    auto = E.get("auto_pesca", 0) > 0
    if manual:
        t += BASE["reaccion"]
    elif auto:
        t += BASE["ventana"] + BASE["retraso_auto"] / (1 + E.get("auto_ritmo", 0))
    else:
        return 0.0, t + BASE["ventana"], False
    suerte = c["mr"] * (1 + E.get("raros", 0)) * (BASE["suerte_manual"] if manual else 1)
    ws = [(p, p[3] * (suerte if p[1] >= 2 else (1 / c["mr"] if p[1] == 0 else 1))) for p in PECES_BASE]
    r = random.random() * sum(w for _, w in ws)
    for p, w in ws:
        r -= w
        if r <= 0:
            break
    peso = random.uniform(0.8, 1.2) * (1 + E.get("peso", 0))
    v = c["valor"] * p[2] * peso * (1 + E.get("calidad", 0))
    if not manual:
        v *= min(1.0, BASE["valor_auto"] + E.get("auto_valor", 0))
    if random.random() < E.get("pesca_doble", 0):
        v *= 2
    return v, t, True


def ritmo_base(cana, atencion=0.8, E=None, n=20000):
    c = CANAS[cana]
    d = tt = p = 0.0
    for _ in range(n):
        v, t, ok = picada_base(c, E, atencion)
        d += v; tt += t; p += ok
    return d / tt * 60, p / tt * 60


def ritmo(cana, jugador=1.0, n=20000):
    c = CANAS[cana]
    dinero = tiempo = capt = 0.0
    for _ in range(n):
        CAPTURADOS.clear()  # ritmo sin maestría
        v, t, _, ok, _ = picada(c, jugador)
        dinero += v; tiempo += t; capt += ok
    return dinero / tiempo * 60, capt / tiempo * 60


def trabajador(E=None):
    """₽/min y peces/min de un pescador (el pez más barato)."""
    E = E or {}
    baratos = sorted((p for p in PECES if p[2] == 1 and p[1] == 0 and p[0] not in ("bota_vieja",)), key=lambda p: p[3])
    sard = baratos[min(int(E.get("pez_trabajadores", 0)), len(baratos) - 1)]
    v = sard[3] * TRAB["mult_valor"]
    cap = TRAB["capacidad"] + E.get("trabajador_capacidad", 0)
    ciclo = (cap * TRAB["t_pez"] + TRAB["viaje"]) / (1 + E.get("trabajador_velocidad", 0))
    return v * cap / ciclo * 60


if __name__ == "__main__":
    print("--- Ritmo por caña ---")
    for cana in CANAS:
        for j, nom in [(1.0, "normal"), (1.3, "bueno")]:
            r, cpm = ritmo(cana, j)
            print(f"{cana:13s} {nom:7s}: {r:7.1f} ₽/min  {cpm:4.1f} peces/min")
    print(f"\nUn pescador: {trabajador():.1f} ₽/min")

    print("\n--- Racha: lo que vale cada largo (pez perfecto, sin contar peso) ---")
    for a in [1, 5, 10, 20, 35, 50, 100, 200]:
        print(f"x{a:<4d} multiplicador medio {suma_racha(a) / a:4.2f}   suma {suma_racha(a):7.1f}")

    print("\n--- ¿Compensa una cadena larga frente a muchas cortas? (mismo valor por botón) ---")
    espera = sum(ESPERA) / 2
    for a in [5, 20, 50, 100, 200]:
        t = espera + RESULTADO + sum(max(TMIN, T0 * FACT ** i) * .6 + PAUSA for i in range(a))
        print(f"cadena x{a:<4d}: {suma_racha(a) * PERFECTO / t:5.2f} por segundo")


LONJA = 1.3   # Comercio.bonus_lonja: todas las ventas desde que llega la lonja
# Segundos sin pescar por cada venta (el comerciante se llama desde el donut; andar, menús).
ANDAR_ANTES_CAMINO = 8.0


def precio_pescador(comprados):
    """data/articulos/contratar_pescador.tres: 1.000, 5.000, 10.000 y luego ×1,5."""
    lista = [1000, 5000, 10000]
    return lista[comprados] if comprados < len(lista) else lista[-1] * 1.5 ** (comprados - len(lista) + 1)


# ======================================================================================================
# v4: partida completa del early game (cañas, pescadores, árbol, lonja, O Mar, turistas, cultivos).
# Lo que no se modela: andar exacto por el mapa (se cuenta como pausas), el cebo y la rama Chill.
# ======================================================================================================

def _leer_apariciones():
    r = {}
    for f in glob.glob(os.path.join(_RAIZ, "data", "apariciones", "*.tres")):
        d = _leer_tres(f)
        r[d["id"]] = dict(cond=int(d.get("condicion", 1)), valor=float(d.get("valor", 0)),
                          requiere=[x.strip(' &"') for x in d.get("requiere", "").split("[")[-1].strip("])").split(",") if x.strip(' &"')])
    return r


def _leer_arbol():
    r = {}
    for f in glob.glob(os.path.join(_RAIZ, "data", "arbol", "nodos", "*.tres")):
        txt = open(f, encoding="utf-8").read()
        d = _leer_tres(f)
        ext = dict((m[1], os.path.basename(m[0])[:-5]) for m in
                   __import__("re").findall(r'path="([^"]+)" id="([^"]+)"', txt))
        req = [ext[x] for x in __import__("re").findall(r'ExtResource\("(r\d+)"\)', d.get("requisitos", ""))]
        r[d["id"]] = dict(efecto=d.get("efecto", ""), v=float(d.get("valor_por_nivel", 0)), niveles=int(d.get("niveles", 1)),
                          coste=float(d["coste_base"]), crec=float(d.get("crecimiento", 1)), req=req,
                          flag=d.get("requiere_flag", ""))
    return r


def _leer_articulo(i):
    d = _leer_tres(os.path.join(_RAIZ, "data", "articulos", i + ".tres"))
    _EF_MEJORA[i] = d.get("efecto", "")
    return float(d.get("precio", 0)), float(d.get("crecimiento_precio", 1)), int(d.get("max_compras", 1)), float(d.get("valor_efecto", 0))


APARICIONES = _leer_apariciones()
ARBOL = _leer_arbol()
# Valores de las escenas (Restaurante, Turistas, cultivos.gd, planta) — cámbialos aquí si los tocas allí.
REST = dict(parte=0.3, capacidad=120, mult_plato=1.25, locales=0.6, locales_pesc=0.15)
TUR = dict(prob=0.5, max_sin=2, platos=2.0, min=3, max=16, ventana=(0.5, 0.5))
CULT = dict(pim_plantas=18, pim_n=3, pim_t=120, pim_valor=0.4, alga_plantas=8, alga_n=2, alga_t=180, alga_valor=0.5,
            pim_precio=15.0, alga_precio=30.0,
            cada_visita=360, andar=25, chaval=75)
RELOJ = dict(dia=720.0, noche=480.0, inicio=0.0)
NIVELES_TUR = [0, 120, 400]
GASTO_TUR = [1.0, 1.6, 3.0]   # NivelTuristasData.mult_gasto: los de más nivel pagan más por plato
# Lo que no se ve en los datos: el jugador pasa por el huerto cada ~6 min y por el viejo/tiendas al vender.
# Mejoras de edificios: se compran en el ayuntamiento (data/articulos/mejora_*.tres).
MEJORAS = ["mejora_despensa", "mejora_fogon", "mejora_mesas", "mejora_pantalan_cebo", "mejora_pantalan_redes",
           "mejora_lonja_hielo", "mejora_entrada_muelle", "mejora_cultivos_bancales",
           "mejora_taladro_motor", "mejora_omar_terraza", "mejora_entrada_faro"]
TALADRO = dict(por_minuto=3.0, tope=60.0)
SUSHI = dict(parte=0.2, capacidad=80, mult_plato=2.0, locales=0.3)
MEJORAS += ["mejora_sushi_barra", "mejora_sushi_cuchillos"]
_REQ_MEJORA = {"mejora_despensa": "restaurante", "mejora_fogon": "restaurante", "mejora_mesas": "restaurante",
               "mejora_pantalan_cebo": "puerto", "mejora_pantalan_redes": "puerto", "mejora_lonja_hielo": "lonja",
               "mejora_entrada_muelle": "entrada turistas", "mejora_cultivos_bancales": "cultivos",
               "mejora_taladro_motor": "taladro", "mejora_omar_terraza": "taladro", "mejora_entrada_faro": "taladro",
               "mejora_sushi_barra": "sushi", "mejora_sushi_cuchillos": "sushi"}


def _efectos(niv, mejoras):
    E = {}
    for i, n in niv.items():
        nd = ARBOL[i]
        E[nd["efecto"]] = E.get(nd["efecto"], 0) + nd["v"] * n
    for i, n in mejoras.items():
        v = _leer_articulo(i)[3]
        E[_EF_MEJORA[i]] = E.get(_EF_MEJORA[i], 0) + v * n
    return E


_EF_MEJORA = {}


def partida(jugador=1.0, semilla=1, horas=4.0, informe=False, atencion=None):
    """jugador: reflejos en los spots (no se usa en la base). atencion: % de picadas que pica a mano
    (por defecto 0,9 sin pesca automática y luego 0,6: anda haciendo otras cosas)."""
    random.seed(semilla)
    CAPTURADOS.clear()
    PUNTOS[0] = 0.0
    t = rublos = totales = pend = 0.0
    peces = 0
    cana = "cana_rota"
    hitos, niv, mejoras = {}, {}, {}
    trab = 0
    ultima_venta = ultima_huerto = 0.0
    E = {}
    # Restaurante
    raciones = valor_rac = 0.0
    pim = alga = cosecha_pim = cosecha_alga = 0
    clientes = 0
    resto_parte = 0.0
    locales_acum = 0.0
    dias_sin = TUR["max_sin"]
    dia_decidido = -1
    visita = None   # dict(fin, quedan, cada)
    plantas_t = 0.0
    chaval_t = 0.0
    fuentes = dict(pesca=0.0, pescadores=0.0, restaurante=0.0)
    combos = []
    serie = []
    prox_informe = 0.0

    def hito(n):
        if n not in hitos:
            hitos[n] = t / 60

    def cumple(i):
        a = APARICIONES[i]
        if any(r.replace("_", " ") not in hitos and r not in hitos for r in a["requiere"]):
            return False
        c, v = a["cond"], a["valor"]
        return {0: peces >= v, 1: totales >= v, 3: t >= v * 60, 4: PUNTOS[0] >= v, 5: trab >= v,
                6: clientes >= v, 7: "restaurante" in hitos and (t / 60 - hitos["restaurante"]) * 60 >= v * (RELOJ["dia"] + RELOJ["noche"])}.get(c, False)

    def vender(precio_pez_lista):
        nonlocal raciones, valor_rac, resto_parte
        if "restaurante" not in hitos or not precio_pez_lista:
            return
        cap = REST["capacidad"] + E.get("despensa", 0)
        x = len(precio_pez_lista) * REST["parte"] + resto_parte
        k = int(x)
        resto_parte = x - k
        k = min(k, int(cap - raciones))
        if k > 0:
            muestra = random.sample(precio_pez_lista, k)
            raciones += k
            valor_rac += sum(muestra)
        if "sushi" in hitos:
            ks = min(int(len(precio_pez_lista) * SUSHI["parte"]), int(SUSHI["capacidad"] + E.get("sushi_despensa", 0) - su["raciones"]))
            if ks > 0:
                m2 = random.sample(precio_pez_lista, min(ks, len(precio_pez_lista)))
                su["raciones"] += len(m2); su["valor"] += sum(m2)

    su = dict(raciones=0.0, valor=0.0, alga=0)

    def servir_sushi():
        nonlocal clientes
        if su["raciones"] < 1 or su["alga"] <= 0:
            return 0.0
        medio = su["valor"] / su["raciones"]
        su["raciones"] -= 1; su["valor"] -= medio; su["alga"] -= 1
        clientes += 1
        return medio * (SUSHI["mult_plato"] + E.get("sushi_precio_plato", 0))

    def servir():
        nonlocal raciones, valor_rac, pim, alga, clientes
        if "sushi" in hitos and su["raciones"] >= 1 and su["alga"] > 0 and random.random() < 0.5:
            return servir_sushi()
        if raciones < 1:
            return 0.0
        medio = valor_rac / raciones
        raciones -= 1; valor_rac -= medio
        precio = medio * (REST["mult_plato"] + E.get("precio_plato", 0))
        g, m = 0.0, 1.0
        vc = 1 + E.get("valor_cosecha", 0)
        if pim > 0:
            pim -= 1; g = medio * CULT["pim_valor"] * vc
        if alga > 0:
            alga -= 1; m = 1 + CULT["alga_valor"] * vc
        clientes += 1
        return (precio + g) * m

    vendidos = []
    coral = coral_taladro = ultima_coral = 0.0
    while t < 3600 * horas:
        E = _efectos(niv, mejoras)
        mv = (1 + E.get("precio_venta", 0) + (E.get("precio_lonja", 0) if "lonja" in hitos else 0)) * (LONJA if "lonja" in hitos else 1)
        at = atencion if atencion is not None else (0.6 if E.get("auto_pesca", 0) > 0 else 0.9)
        v, dt, ok = picada_base(CANAS[cana], E, at)
        combos.append((cana, 0))
        t += dt; peces += ok
        if ok:
            pend += v; vendidos.append(v)
        # Pescadores (y lo que mandan a la lonja: el pez más barato).
        tr_rpm = trabajador(E) * trab
        tr = tr_rpm / 60 * dt * mv
        rublos += tr; totales += tr; fuentes["pescadores"] += tr
        if trab and "restaurante" in hitos:
            sard_v = min(p[3] for p in PECES if p[2] == 1 and p[1] == 0) * TRAB["mult_valor"]
            vendidos.extend([sard_v] * int(random.random() < tr_rpm / 60 * dt / max(1e-6, sard_v)))
        # Restaurante: gente del pueblo + turistas.
        if "restaurante" in hitos:
            locales_acum += dt * (REST["locales"] + REST["locales_pesc"] * trab
                                  + (SUSHI["locales"] * (1 + E.get("sushi_clientes", 0)) if "sushi" in hitos else 0)) / 60
            while locales_acum >= 1:
                locales_acum -= 1
                g = servir() * 1.0
                rublos += g; totales += g; fuentes["restaurante"] += g
            ciclo = RELOJ["dia"] + RELOJ["noche"]
            dia = int(t // ciclo); m = t % ciclo
            if "entrada turistas" in hitos:
                if dia != dia_decidido:
                    dia_decidido = dia
                    vienen = dias_sin >= TUR["max_sin"] or random.random() < TUR["prob"]
                    dias_sin = 0 if vienen else dias_sin + 1
                    hoy = vienen
                    if vienen:
                        ini = RELOJ["dia"] * TUR["ventana"][0]; fin = RELOJ["dia"] + RELOJ["noche"] * TUR["ventana"][1]
                        tope = round((TUR["max"] + E.get("mesas", 0) + E.get("muelle", 0)) * (1 + E.get("turistas", 0)))
                        visita = dict(ini=dia * ciclo + ini, fin=dia * ciclo + fin, n=None, tope=tope, comidos=0.0)
                if visita and visita["ini"] <= t < visita["fin"]:
                    if visita["n"] is None:
                        visita["n"] = max(TUR["min"], min(visita["tope"], int(raciones / TUR["platos"])))
                        hito("primera visita")
                        if clientes >= NIVELES_TUR[1]: hito("turistas nivel 2")
                        if clientes >= NIVELES_TUR[2]: hito("turistas nivel 3")
                    ritmo_v = visita["n"] * TUR["platos"] / (visita["fin"] - visita["ini"])
                    visita["comidos"] += ritmo_v * dt
                    while visita["comidos"] >= 1:
                        visita["comidos"] -= 1
                        abiertos = [g for c, g in zip(NIVELES_TUR, GASTO_TUR) if clientes >= c]
                        g = servir() * (1 + E.get("propinas", 0)) * sum(abiertos) / len(abiertos) * (1 + E.get("atractivo", 0))
                        rublos += g; totales += g; fuentes["restaurante"] += g
        # Cultivos: el jugador pasa cada ~6 min (o el chaval, si lo tiene).
        if "cultivos" in hitos:
            plantas_t += dt
            if E.get("cosechador", 0) > 0:
                chaval_t += dt
                if chaval_t >= CULT["chaval"] * max(0.2, 1 - E.get("cosechador_ritmo", 0)):
                    listas_p = CULT["pim_plantas"] * min(1, chaval_t / (CULT["pim_t"] / (1 + E.get("cultivos", 0))))
                    listas_a = CULT["alga_plantas"] * min(1, chaval_t / (CULT["alga_t"] / (1 + E.get("cultivos", 0))))
                    pp = (CULT["pim_n"] + E.get("por_planta", 0)) * (1 + E.get("cosecha_doble", 0))
                    pa = (CULT["alga_n"] + E.get("por_planta", 0)) * (1 + E.get("cosecha_doble", 0))
                    np_, na_ = int(listas_p * pp), int(listas_a * pa)
                    g = (np_ * CULT["pim_precio"] + na_ * CULT["alga_precio"]) * (1 + E.get("valor_cosecha", 0)) * mv
                    rublos += g; totales += g; fuentes["restaurante"] += g
                    alga += na_
                    chaval_t = 0.0; plantas_t = 0.0
            elif t - ultima_huerto >= CULT["cada_visita"]:
                ultima_huerto = t
                pp = (CULT["pim_n"] + E.get("por_planta", 0)) * (1 + E.get("cosecha_doble", 0))
                pa = (CULT["alga_n"] + E.get("por_planta", 0)) * (1 + E.get("cosecha_doble", 0))
                listas_p = CULT["pim_plantas"] * min(1, plantas_t / (CULT["pim_t"] / (1 + E.get("cultivos", 0))))
                listas_a = CULT["alga_plantas"] * min(1, plantas_t / (CULT["alga_t"] / (1 + E.get("cultivos", 0))))
                np_, na_ = int(listas_p * pp), int(listas_a * pa)
                g = (np_ * CULT["pim_precio"] + na_ * CULT["alga_precio"]) * (1 + E.get("valor_cosecha", 0)) * mv
                rublos += g; totales += g; fuentes["restaurante"] += g
                if "sushi" in hitos:
                    su["alga"] += na_ // 2; na_ -= na_ // 2
                alga += na_
                plantas_t = 0.0
                t += CULT["andar"]
        if "taladro" in hitos:
            coral_taladro = min(TALADRO["tope"], coral_taladro + TALADRO["por_minuto"] * (1 + E.get("coral", 0) + E.get("taladro_ritmo", 0)) * dt / 60)
            if t - ultima_coral >= 360:
                coral += int(coral_taladro); coral_taladro -= int(coral_taladro); ultima_coral = t
        # Vender cada ~3 min (con la lonja da igual dónde: al comerciante desde el donut).
        if t - ultima_venta > 180 and pend > 0:
            g = pend * mv
            rublos += g; totales += g; fuentes["pesca"] += g
            vender(vendidos); vendidos = []
            pend = 0; t += ANDAR_ANTES_CAMINO; ultima_venta = t
        # Llegadas.
        if peces >= 3: hito("comerciante")
        for ap, nombre in [("primera_isla", "primera isla"), ("isla_skilltree", "viejo y árbol"), ("camino", "camino"),
                           ("puerto_pesquero", "puerto"), ("lonja", "lonja"), ("camino_2", "camino 2"),
                           ("restaurante", "restaurante"), ("entrada_turistas", "entrada turistas"), ("cultivos", "cultivos"),
                           ("ayuntamiento", "ayuntamiento"), ("taladro", "taladro"), ("sushi", "sushi")]:
            if nombre not in hitos and cumple(ap):
                hito(nombre)
                if nombre == "puerto":
                    trab = max(trab, 1)
        # Compras: caña siguiente > pescador > árbol > O Mar (gastando con cabeza).
        objetivo = None
        for cid, precio, req in COMPRA_CANAS:
            if CANAS[cid]["prof"] > CANAS[cana]["prof"]:
                if precio is None:
                    precio = _leer_articulo(cid)[0]
                if req is None or req in hitos:
                    objetivo = (cid, precio)
                break
        desc = max(0.3, 1 - E.get("descuento", 0))
        _art = os.path.join(_RAIZ, "data", "articulos", objetivo[0] + ".tres") if objetivo else ""
        coral_cana = float(_leer_tres(_art).get("coste_coral", 0)) if objetivo and os.path.exists(_art) else 0.0
        if objetivo and rublos >= objetivo[1] * desc and coral >= coral_cana:
            coral -= coral_cana
            rublos -= objetivo[1] * desc; cana = objetivo[0]; hito(CANAS[cana]["nombre"]); objetivo = None
        reserva = objetivo[1] * desc if objetivo else 0.0
        libre = rublos - reserva * 0.7
        if trab and trab < 20:
            precio = precio_pescador(trab - 1) * desc
            if libre >= precio and precio <= rublos * 0.6:
                rublos -= precio; libre -= precio; trab += 1; hito(f"pescador {trab}")
        if "viejo y árbol" in hitos:
            for _ in range(3):
                mejor = None
                for i, nd in ARBOL.items():
                    nv = niv.get(i, 0)
                    if nv >= nd["niveles"] or any(niv.get(r, 0) == 0 for r in nd["req"]):
                        continue
                    if nd["flag"] and nd["flag"].replace("aparecido_", "").replace("_", " ") not in hitos \
                            and not (nd["flag"] == "aparecido_puerto_pesquero" and "puerto" in hitos) \
                            and not (nd["flag"] == "aparecido_isla_skilltree"):
                        continue
                    if nd["efecto"] in ("mirador", "hierba", "casino", "sushi_velocidad", "sushi_clientes"):
                        continue
                    coste = nd["coste"] * nd["crec"] ** nv * desc
                    if mejor is None or coste < mejor[1]:
                        mejor = (i, coste)
                if mejor and mejor[1] <= libre * 0.5:
                    rublos -= mejor[1]; libre -= mejor[1]; niv[mejor[0]] = niv.get(mejor[0], 0) + 1
                    hito("árbol: " + mejor[0])
                else:
                    break
        if "ayuntamiento" in hitos:
            for i in MEJORAS:
                if _REQ_MEJORA[i] not in hitos:
                    continue
                pr, cr, mx, _ = _leer_articulo(i)
                nv = mejoras.get(i, 0)
                coste = pr * cr ** nv * desc
                cc = float(_leer_tres(os.path.join(_RAIZ, "data", "articulos", i + ".tres")).get("coste_coral", 0)) * cr ** nv
                if nv < mx and coste <= libre * 0.4 and coral >= cc:
                    rublos -= coste; libre -= coste; coral -= cc; mejoras[i] = nv + 1; hito(f"{i} {nv + 1}")
        if informe and t >= prox_informe:
            serie.append((t / 60, rublos, totales, dict(fuentes), cana, trab, clientes, int(raciones)))
            prox_informe += 600
    hitos["_fuentes"] = fuentes
    hitos["_combos"] = combos
    hitos["_serie"] = serie
    hitos["_totales"] = totales
    return hitos


if __name__ == "__main__":
    import statistics
    for jug, nom in [(1.0, "normal"), (1.3, "bueno"), (0.8, "flojo")]:
        todas = [partida(jugador=jug, semilla=s, informe=(s == 0)) for s in range(8)]
        print(f"\n=== Jugador {nom} (media de 8 partidas de 4 h) ===")
        claves = {}
        for p in todas:
            for k, v in p.items():
                if not k.startswith("_") and not k.startswith("árbol") and not k.startswith("mejora"):
                    claves.setdefault(k, []).append(v)
        for k in sorted(claves, key=lambda k: statistics.mean(claves[k])):
            print(f"{statistics.mean(claves[k]):6.1f} min  {k}  ({len(claves[k])}/8)")
        if nom == "normal":
            print("\n  min   ₽ en mano   ₽ totales   ₽/min(10 min)   pesca/pescadores/O Mar    caña  pesc  clientes raciones")
            prev = None
            for (m, r, tot, f, c, tr, cl, ra) in todas[0]["_serie"]:
                rpm = (tot - prev) / 10 if prev is not None else 0
                prev = tot
                print(f"  {m:4.0f} {r:10.0f} {tot:11.0f} {rpm:12.0f}     {f['pesca']:9.0f}/{f['pescadores']:8.0f}/{f['restaurante']:8.0f}  {c[5:]:8s} {tr:3d} {cl:6d} {ra:5d}")
            # Combos por caña
            from collections import defaultdict
            cb = defaultdict(list)
            for p in todas:
                for c, a in p["_combos"]:
                    cb[c].append(a)
            print("\n  Combos por caña: media, % ≥10, % ≥15, % ≥20, máximo")
            for c, xs in cb.items():
                print(f"  {c:13s} {statistics.mean(xs):5.1f}  {sum(x >= 10 for x in xs) / len(xs) * 100:5.1f}%  "
                      f"{sum(x >= 15 for x in xs) / len(xs) * 100:5.1f}%  {sum(x >= 20 for x in xs) / len(xs) * 100:5.1f}%  {max(xs)}")
            arbol = sorted(((v, k) for k, v in todas[0].items() if k.startswith("árbol") or k.startswith("mejora")))
            print("\n  Compras del árbol y O Mar (partida 0):", ", ".join(f"{k.split(': ')[-1]}@{v:.0f}" for v, k in arbol[:60]))
