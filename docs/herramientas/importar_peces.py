# Genera data/peces/*.tres y art/peces/*.png desde docs/datos/peces_fuente.csv (la lista del diseñador).
# Uso (desde la raíz del repo): python3 docs/herramientas/importar_peces.py [K] [G]
#   K = escala de valor (se calibra con simular_economia.py para que el ₽/min cuadre con los tramos).
# Después: godot --headless --path . --import
#
# Fórmulas (ver docs/INCREMENTAL.md y la tabla del ciclo en docs/PROGRESION.md):
#   profundidad: Galicia 1-6 (T0-T2), Mundo 7-12 (T2-T4). Dentro de cada categoría, de ligero a pesado.
#                Legendarios y míticos cierran tramo.
#   perfect:     rango de la profundidad (tabla del ciclo), más alto cuanto más raro.
#   valor:       K × G^(prof-1) × TIER_V × tamaño × (espera + 0,6·perfect)/(espera + 3) × (perfect/5)^0,3
#   probabilidad: por categoría (TIER_P). Los % del Excel no se usan: ponían el legendario por encima del épico.
#   dificultad:  mult_tiempo baja con la profundidad y la rareza (mín. 0,85); dobles y machaques suben.
import csv, hashlib, math, os, re, sys, unicodedata, colorsys
from PIL import Image

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
FUENTE = os.path.join(RAIZ, "docs", "datos", "peces_fuente.csv")
K = float(sys.argv[1]) if len(sys.argv) > 1 else 12.0
G = float(sys.argv[2]) if len(sys.argv) > 2 else 1.8   # cuánto vale más cada nivel de profundidad
ESPERA = 14.0

CATS = ["Común", "Poco Común", "Raro", "Épico", "Legendario", "Mítico"]
TIER_V = [1.0, 2.0, 5.0, 12.0, 40.0, 120.0]
TIER_P = [10.0, 5.0, 2.0, 0.7, 0.2, 0.06]
TIER_FRAC = [0.0, 0.25, 0.5, 0.8, 1.0, 1.0]
TIER_EXTRA = [1.0, 1.0, 1.0, 1.0, 1.3, 2.0]   # perfect de legendarios y míticos por encima del rango
TIER_DIF = [0.0, 0.0, 0.02, 0.04, 0.06, 0.08]
PERFECT = {1: (5, 7), 2: (6, 9), 3: (8, 10), 4: (9, 12), 5: (10, 14), 6: (12, 18), 7: (14, 22), 8: (16, 25),
           9: (20, 30), 10: (25, 38), 11: (30, 45), 12: (40, 80)}
ZONAS = {"Galicia": (1, 6), "Mundo": (7, 12)}
# Dónde cae cada legendario/mítico (por orden de peso).
LEGENDARIOS = {"Galicia": [2, 4, 5, 6], "Mundo": [9, 10, 11, 12]}
MITICO = {"Galicia": 6, "Mundo": 12}
# Los de siempre: mantienen su id (partidas guardadas) y salen en la primera profundidad.
FIJOS = {"Sardina": ("sardina", 1), "Xarda (Caballa)": ("caballa", 1), "Lubina (Robaliza)": ("lubina", 1),
         "Bota de Agua Vieja": ("bota_vieja", 1), "Atún Rojo (Cachón)": ("atun", None)}
TIPOS = {"Pez": 0, "Crustáceo": 1, "Cefalópodo": 2, "Equinodermo": 3, "Escualo": 4, "Mamífero": 5,
         "Objeto": 6, "Objeto/Flora": 7}
HORARIO = {"Ambos": 0, "Día": 1, "Noche": 2, "Ocaso": 3}
ESTACION = {"Primavera": 1, "Verano": 2, "Otoño": 4, "Invierno": 8}


def slug(nombre):
    s = re.sub(r"\(.*?\)", "", nombre).strip().lower()
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "_", s).strip("_")


def pesos(txt):
    a, b = [float(x) for x in re.findall(r"[\d.]+", txt)[:2]]
    return a, b


def leer():
    with open(FUENTE, encoding="utf-8") as f:
        filas = list(csv.DictReader(f))
    for r in filas:
        r["tier"] = CATS.index(r["categoria"])
        r["pmin"], r["pmax"] = pesos(r["peso"])
        r["media"] = (r["pmin"] + r["pmax"]) / 2
    return filas


def repartir(filas):
    """Pone la profundidad a cada especie."""
    for zona, (lo, hi) in ZONAS.items():
        z = [r for r in filas if r["zona"] == zona]
        niveles = hi - lo + 1
        for tier in range(6):
            grupo = sorted([r for r in z if r["tier"] == tier], key=lambda r: r["media"])
            if tier == 4:
                for r, p in zip(grupo, LEGENDARIOS[zona]):
                    r["prof"] = p
                continue
            if tier == 5:
                for r in grupo:
                    r["prof"] = MITICO[zona]
                continue
            # Los épicos no salen en la primera profundidad de la zona.
            base = lo + (1 if tier == 3 else 0)
            n_niv = hi - base + 1
            libres = [r for r in grupo if not (zona == "Galicia" and r["nombre"] in FIJOS and FIJOS[r["nombre"]][1])]
            for i, r in enumerate(libres):
                r["prof"] = base + min(n_niv - 1, i * n_niv // max(1, len(libres)))
            for r in grupo:
                if zona == "Galicia" and r["nombre"] in FIJOS and FIJOS[r["nombre"]][1]:
                    r["prof"] = FIJOS[r["nombre"]][1]


def juego(r):
    tier, prof = r["tier"], r["prof"]
    lo, hi = PERFECT[prof]
    perfect = max(3, round((lo + (hi - lo) * TIER_FRAC[tier]) * TIER_EXTRA[tier]))
    tam = min(1.8, max(0.7, r["media"] ** 0.15))
    t = (ESPERA + 0.6 * perfect) / (ESPERA + 3.0) * (perfect / 5) ** 0.3
    valor = K * G ** (prof - 1) * TIER_V[tier] * tam * t
    grande = r["media"] >= 3 or r["tipo"] in ("Escualo", "Mamífero") or tier >= 3
    return dict(
        perfect=perfect,
        valor=round(valor, 1) if valor < 100 else round(valor),
        prob=TIER_P[tier],
        mult_tiempo=round(max(0.85, 1.0 - 0.012 * (prof - 1) - TIER_DIF[tier]), 3),
        prob_doble=round(0.0 if (prof == 1 and tier == 0) else min(0.5, 0.04 * (prof - 1) + 0.05 * tier), 2),
        machacar_cada=max(4, 7 - prof // 3) if grande else 0,
        pulsaciones=8 + prof + 2 * tier,
        t_machacar=round(1.8 + 0.1 * tier + 0.05 * prof, 2),
    )


# --- Iconos 16x10: plantillas por forma. o contorno, b cuerpo, s sombra, e ojo, a detalle ---
P = {
"normal": ["................", "......oooo......", "....oobbbboo..oo", "..oobbbbbbbboobo", ".oeobbbbbbbbbbbo",
           ".ooobbbbbbbbbbo.", "..oossssssssooso", "....oossssoo..oo", "......oooo......", "................"],
"largo":  ["................", "................", "................", "..oooooooooooo.o", ".oeobbbbbbbbbbob",
           ".oobbbbbbbbbbbbo", "..oossssssssssoo", "...oooooooooooo.", "................", "................"],
"plano":  ["................", ".....oooooo.....", "...oobbbbbboo...", "..obbebbbbbbbo.o", ".obbbbbaabbbbbob",
           ".obbbbbbbbbbbbbo", "..obbbbbbbbbboso", "...oobbbbbboo...", ".....oooooo.....", "................"],
"alto":   [".....oooo.......", "...oobbbboo...oo", "..obbbbbbbboobbo", ".oeobbbbbbbbbbbo", ".ooobbabbabbbbbo",
           "..obbbbbbbbbboo.", "..oossssssssoobo", "...oossssssoo.oo", ".....oooooo.....", "................"],
"atun":   ["................", ".......oo.......", "....oooboooo..oo", "..oobbbbbbbboobo", ".oeobbbbbbbbbbbo",
           ".oooaaaaaaaaaao.", "..oossssssssoobo", "....ooossooo..oo", ".......oo.......", "................"],
"espada": ["................", "........oo......", ".......obbo.....", ".....oobbbboo.oo", "oooooobbbbbbboob",
           ".oeobbbbbbbbbbbo", "..oossssssssoobo", "....oossssoo..oo", "......oooo......", "................"],
"raya":   ["................", ".......oo.......", ".....oobboo.....", "...oobbbbbboo...", ".oobbbebbebbboo.",
           "oobbbbbbbbbbbboo", "..oobbbbbbbboo..", "....ooobbooo....", ".......oo.......", ".......o........"],
"tiburon": [".......o........", "......obo.......", "....oobbboooo.oo", "..oobbbbbbbbbobo", ".oeobbbbbbbbbbbo",
            "oooobbbbbbbbbbo.", "..oossssssssoobo", "....oo.oo.oo..oo", "................", "................"],
"caballito": [".....ooo........", "....obbbo.......", "...oebbo........", ".ooobbbo........", ".....obbo.......",
              ".....obbbo......", "......obbo......", ".....obbo.......", ".....obo.ooo....", "......oooo......"],
"cangrejo": ["................", ".oo..........oo.", "obbo........obbo", ".obo.oooooo.obo.", "..oobbebbebboo..",
             "..obbbbbbbbbbo..", "..oobbbbbbbboo..", ".o.oossssssoo.o.", "o.o.o.o..o.o.o.o", "................"],
"gamba":  ["................", "oo..............", "..o..ooooooo....", ".oeoobbbbbbboo..", ".obbbbbbbbbbbboo",
           "..oossssssssbbbo", "...o.o.o.o.oobbo", "............oooo", "................", "................"],
"pulpo":  [".....oooooo.....", "....obbbbbbo....", "...obebbbbebo...", "...obbbbbbbbo...", "....obbbbbbo....",
           "...obobobobobo..", "..obo.obobo.obo.", "..oo.obo.obo.oo.", ".....oo...oo....", "................"],
"calamar": ["................", "................", "o.o.o.ooooooo...", ".ooooobbbbbbboo.", "oooobbbbbbbebbbo",
            ".ooooobbbbbbboo.", "o.o.o.ooooooo...", "................", "................", "................"],
"estrella": [".......oo.......", "......obbo......", ".oooooobbooooo..", ".obbbbbbbbbbbo..", "..oobbbbbbbbo...",
             "...obbbbbbbo....", "...obboobbo.....", "..obo....obo....", "..oo......oo....", "................"],
"erizo":  ["....o..o..o.....", ".o..o..o..o..o..", "..o.oooooooo.o..", "...obbbbbbbbo...", ".ooobbbbbbbbooo.",
           "...obbbbbbbbo...", "..o.oooooooo.o..", ".o..o..o..o..o..", "....o..o..o.....", "................"],
"pepino": ["................", "................", "...oooooooooo...", "..obabbbabbbbo..", ".obbbbbbbbbbbbo.",
           ".obbbabbbbabbbo.", "..oossssssssoo..", "...oooooooooo...", "................", "................"],
"bota":   [".....oooooo.....", ".....obbbbo.....", ".....obbbbo.....", ".....obbbbo.....", ".....obbbbo.....",
           ".....obbbbooooo.", ".....obbbbbbbbbo", ".....ossssssssso", ".....oooooooooo.", "................"],
"lata":   ["................", ".....oooooo.....", "....oaaaaaao....", "....obbbbbbo....", "....oaaaaaao....",
           "....obbbbbbo....", "....obbbbbbo....", "....oaaaaaao....", ".....oooooo.....", "................"],
"botella": ["................", "................", "...oooooooo.....", "..obbbbbbbbooooo", "..obbaaaabbbbbao",
            "..obbbbbbbbooooo", "...oooooooo.....", "................", "................", "................"],
"rama":   ["................", ".........o.o....", "..........o.....", "oooooooooooooo..", "obbbbbbbbbbbbbo.",
           ".oooooooobbooo..", ".........oo.....", "................", "................", "................"],
"neumatico": ["....oooooooo....", "...obbbbbbbbo...", "..obbooooobbbo..", "..obo......obo..", "..obo......obo..",
              "..obbooooobbbo..", "...obbbbbbbbo...", "....oooooooo....", "................", "................"],
"alga":   ["...o.....o......", "..obo...obo..o..", "..obo..obo..obo.", "...obo.obo..obo.", "...obo..obo.obo.",
           "..obo...obo.obo.", "..obo..obo..obo.", "...obo.obo.obo..", "...obo.obo.obo..", "..oooooooooooo.."],
"ballena": ["................", "..oooooooooo....", ".obbbbbbbbbboo.o", "obebbbbbbbbbbbob", "obbbbbbbbbbbbboo",
            ".ossssssssssoo.o", "..oooooooooo....", "................", "................", "................"],
}
CLAVES = [
    ("espada", ["espada", "marlín", "vela"]),
    ("raya", ["raya", "manta"]),
    ("caballito", ["caballito", "dragón"]),
    ("plano", ["lenguado", "rodaballo", "platija", "solla", "halibut", "fletán", "acedía", "rémol"]),
    ("largo", ["congrio", "anguila", "morena", "aguja", "pipa", "trompet", "barracuda", "remo", "sierra", "lisa",
               "pejerrey", "espadín", "boquerón", "anchoa", "dardo", "víbora", "gobio", "blenio"]),
    ("atun", ["atún", "bonito", "melva", "bacoreta", "wahoo", "jurel", "chicharro", "llampuga", "dorado",
              "serviola", "limón", "caballa", "xarda", "sábalo", "esturión", "bacalao", "abadejo", "carbonero",
              "merluza", "maruca", "salmón", "corvina", "róbalo", "lubina", "pescadilla"]),
    ("alto", ["dorada", "sargo", "pargo", "besugo", "ángel", "mariposa", "cirujano", "payaso", "luna", "castañuela",
              "oblada", "chopa", "breca", "pagel", "dentón", "cofre", "globo", "erizo", "ballesta", "loro",
              "sargazo", "murciélago", "herrerita", "salpa", "urrta", "san martiño", "mero", "pinto", "maragota"]),
]
COLORES = [  # palabra -> tono (h, s, v)
    (["roj", "colorad", "pargo", "rubio", "cabracho", "escórpora", "salmón", "centolla", "bogavante", "langosta",
      "cangrejo rey", "nécora", "santiaguiño", "camarón", "gamba", "quisquilla", "pinta", "pez león"], (0.01, 0.65, 0.85)),
    (["dorad", "limón", "amarill", "oro", "ballesta", "payaso", "mariposa"], (0.12, 0.75, 0.95)),
    (["azul", "cirujano", "atún", "bonito", "melva", "marlín", "mako", "caballa", "xarda"], (0.6, 0.55, 0.85)),
    (["verde", "alga", "pepino", "loro", "maragota", "dragón"], (0.33, 0.55, 0.7)),
    (["negr", "morena", "congrio", "carbonero", "sapo", "rape", "víbora", "abisal", "groenlandia", "erizo"], (0.75, 0.25, 0.4)),
    (["pulpo", "calamar", "sepia", "chopo", "lura", "potarro", "nautilus", "pez ángel", "mandarín"], (0.88, 0.45, 0.8)),
    (["bota", "rama", "neumático", "estrella", "ermitaño", "cocoteros", "buey"], (0.07, 0.6, 0.55)),
]


def forma(r):
    n = r["nombre"].lower()
    t = r["tipo"]
    if t == "Escualo":
        return "tiburon"
    if t == "Mamífero":
        return "ballena"
    if t == "Crustáceo":
        return "gamba" if any(k in n for k in ["langosta", "bogavante", "santiaguiño", "camarón", "quisquilla"]) else "cangrejo"
    if t == "Cefalópodo":
        return "pulpo" if "pulpo" in n else "calamar"
    if t == "Equinodermo":
        return "estrella" if "estrella" in n else "erizo" if "erizo" in n else "pepino"
    if t in ("Objeto", "Objeto/Flora"):
        for k, f in [("bota", "bota"), ("lata", "lata"), ("botella", "botella"), ("mensaje", "botella"),
                     ("rama", "rama"), ("neumático", "neumatico")]:
            if k in n:
                return f
        return "alga"
    for f, ks in CLAVES:
        if any(k in n for k in ks):
            return f
    return "normal"


def color(r):
    n = r["nombre"].lower()
    h8 = hashlib.md5(r["id"].encode()).digest()
    jit = (h8[0] / 255 - 0.5) * 0.06
    for ks, (h, s, v) in COLORES:
        if any(k in n for k in ks):
            return colorsys.hsv_to_rgb((h + jit) % 1, s, v)
    # Plateados variados por defecto.
    return colorsys.hsv_to_rgb(0.55 + (h8[1] / 255 - 0.5) * 0.25, 0.12 + h8[2] / 255 * 0.25, 0.72 + h8[3] / 255 * 0.15)


def icono(r, ruta):
    c = color(r)
    rgb = lambda t: tuple(int(max(0, min(1, x)) * 255) for x in t) + (255,)
    pal = {"o": (24, 16, 14, 255), "b": rgb(c), "s": rgb(tuple(x * 0.65 for x in c)), "e": (250, 250, 250, 255),
           "a": rgb(tuple(min(1, x * 1.25 + 0.1) for x in c))}
    if r["tier"] >= 4:  # legendarios y míticos con detalle dorado
        pal["a"] = (255, 210, 80, 255)
    im = Image.new("RGBA", (16, 10), (0, 0, 0, 0))
    for y, fila in enumerate(P[forma(r)]):
        assert len(fila) == 16, (forma(r), y)
        for x, ch in enumerate(fila):
            if ch != ".":
                im.putpixel((x, y), pal[ch])
    im.save(ruta)


TRES = """[gd_resource type="Resource" script_class="PezData" format=3]

[ext_resource type="Script" path="res://scripts/datos/pez_data.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://art/peces/{id}.png" id="2_icono"]

[resource]
script = ExtResource("1_script")
id = &"{id}"
nombre = "{nombre}"
rareza = {tier}
icono = ExtResource("2_icono")
profundidad = {prof}
tipo = {tipo}
zona = {zona}
ubicacion = "{ubicacion}"
estaciones = {estaciones}
horario = {horario}
valor_base = {valor}
peso_min = {pmin}
peso_max = {pmax}
probabilidad = {prob}
pasos_perfect = {perfect}
mult_tiempo = {mult_tiempo}
prob_doble = {prob_doble}
machacar_cada = {machacar_cada}
pulsaciones_machacar = {pulsaciones}
tiempo_machacar = {t_machacar}
"""


def main():
    filas = leer()
    usados = set()
    for r in filas:
        if r["zona"] == "Galicia" and r["nombre"] in FIJOS:
            r["id"] = FIJOS[r["nombre"]][0]
        else:
            s = slug(r["nombre"])
            r["id"] = s if s not in usados else s + "_" + slug(r["zona"])
        usados.add(r["id"])
    repartir(filas)
    # El kraken bebé no está en la lista: es nuestro legendario de la Sabia caña.
    filas.append(dict(zona="Galicia", nombre="Kraken bebé", tipo="Cefalópodo", ubicacion="", peso="5 - 15 kg",
                      estaciones="Primavera, Verano, Otoño, Invierno", horario="Noche", tier=4, pmin=5.0, pmax=15.0,
                      media=10.0, id="kraken_bebe", prof=3))
    carp_d = os.path.join(RAIZ, "data", "peces")
    carp_a = os.path.join(RAIZ, "art", "peces")
    for f in os.listdir(carp_d):
        if f.endswith(".tres"):
            os.remove(os.path.join(carp_d, f))
    for r in filas:
        j = juego(r)
        est = sum(ESTACION[e.strip()] for e in r["estaciones"].split(",") if e.strip() in ESTACION) or 15
        with open(os.path.join(carp_d, r["id"] + ".tres"), "w", encoding="utf-8") as f:
            f.write(TRES.format(id=r["id"], nombre=r["nombre"].replace('"', "'"), tier=r["tier"], prof=r["prof"],
                                tipo=TIPOS[r["tipo"]], zona=0 if r["zona"] == "Galicia" else 1,
                                ubicacion=r.get("ubicacion", ""), estaciones=est, horario=HORARIO.get(r["horario"], 0),
                                pmin=r["pmin"], pmax=r["pmax"], **j))
        icono(r, os.path.join(carp_a, r["id"] + ".png"))
    # Resumen por profundidad.
    print(f"{len(filas)} especies (K = {K})")
    for p in range(1, 13):
        g = [r for r in filas if r["prof"] == p]
        print(f"prof {p:2d}: {len(g):3d} especies  " + ", ".join(f"{CATS[t][:4]} {sum(1 for r in g if r['tier'] == t)}"
                                                         for t in range(6)))


if __name__ == "__main__":
    main()
