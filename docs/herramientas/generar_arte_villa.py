# Arte provisional (placeholder) de la villa: turistas, sus barcos, el restaurante, cultivos y la hoz.
# Se sustituye por el arte final del diseñador cambiando los PNG (mismos nombres) o las rutas en los datos.
# Uso: python3 docs/herramientas/generar_arte_villa.py   (desde la raíz del repo)
from PIL import Image, ImageDraw
import os

CONTORNO = (24, 16, 14, 255)
OJO = (24, 16, 14, 255)

PIELES = {
    "clara": (236, 196, 160), "rosada": (240, 176, 150), "morena": (198, 140, 96),
    "tostada": (170, 112, 70), "oscura": (110, 70, 46), "muy_oscura": (78, 50, 36),
}
PELOS = {
    "negro": (34, 28, 30), "castano": (96, 60, 36), "rubio": (230, 196, 100), "pelirrojo": (196, 92, 40),
    "canoso": (200, 200, 196), "gris": (130, 128, 124),
}


def contorno(im):
    """Pinta el contorno oscuro alrededor de todo lo dibujado (4 vecinos)."""
    w, h = im.size
    px = im.load()
    lleno = [[px[x, y][3] > 0 for y in range(h)] for x in range(w)]
    for x in range(w):
        for y in range(h):
            if lleno[x][y]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and lleno[nx][ny]:
                    px[x, y] = CONTORNO
                    break
    return im


def oscuro(c, f=0.75):
    return tuple(int(v * f) for v in c[:3]) + (255,)


def rect(d, x0, y0, x1, y1, c):
    d.rectangle([x0, y0, x1, y1], fill=c if len(c) == 4 else c + (255,))


def persona(piel, pelo="castano", peinado="corto", camisa=(60, 96, 150), estampado=None, pantalon=(58, 78, 122),
            falda=False, zapatos=(70, 46, 30), sombrero=None, barba=False, gafas=False, camara=False,
            delantal=False, chaleco=None, panuelo=None, mochila=None, flor=None, calcetines=False):
    W, H = 18, 26
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    p = PIELES[piel] + (255,)
    hc = PELOS.get(pelo, (60, 40, 30)) + (255,)
    cam = camisa + (255,)
    # Mochila por detrás (asoma por los lados).
    if mochila:
        rect(d, 3, 10, 14, 16, mochila)
    # Pelo largo por detrás de la cabeza.
    if peinado in ("largo", "trenzas"):
        rect(d, 5, 3, 12, 12, hc)
    # Cabeza.
    rect(d, 6, 4, 11, 10, p)
    # Peinados por encima.
    if peinado == "corto":
        rect(d, 6, 3, 11, 4, hc); rect(d, 6, 5, 6, 6, hc); rect(d, 11, 5, 11, 6, hc)
    elif peinado == "largo":
        rect(d, 6, 3, 11, 4, hc)
    elif peinado == "rizado":
        rect(d, 5, 2, 12, 4, hc); rect(d, 5, 5, 5, 7, hc); rect(d, 12, 5, 12, 7, hc)
        for x in (5, 8, 11):
            im.putpixel((x, 1), hc)
    elif peinado == "mono":
        rect(d, 6, 3, 11, 4, hc); rect(d, 8, 1, 9, 2, hc)
    elif peinado == "trenzas":
        rect(d, 6, 3, 11, 4, hc)
        for y in range(11, 16, 2):
            im.putpixel((5, y), hc); im.putpixel((12, y), hc)
    elif peinado == "cresta":
        rect(d, 8, 1, 9, 4, hc)
    elif peinado == "calvo":
        pass
    if panuelo:
        # Pañuelo que cubre pelo y cuello; la cara queda libre.
        rect(d, 5, 3, 12, 11, panuelo)
        rect(d, 7, 5, 10, 10, p)
    # Barba.
    if barba:
        rect(d, 6, 8, 11, 11, hc)
        rect(d, 8, 9, 9, 9, p)
    # Ojos o gafas.
    if gafas:
        rect(d, 6, 6, 11, 6, (30, 30, 36))
        im.putpixel((7, 6), (90, 160, 210, 255)); im.putpixel((10, 6), (90, 160, 210, 255))
    else:
        im.putpixel((7, 6), OJO); im.putpixel((10, 6), OJO)
    # Sombreros.
    if sombrero == "paja":
        rect(d, 3, 4, 14, 4, (222, 190, 110)); rect(d, 6, 2, 11, 3, (222, 190, 110)); rect(d, 6, 3, 11, 3, (170, 60, 50))
    elif sombrero == "lana":
        rect(d, 6, 1, 11, 4, (230, 180, 40)); rect(d, 6, 4, 11, 4, (200, 150, 30))
    elif sombrero == "boina":
        rect(d, 5, 2, 12, 3, (40, 40, 48)); im.putpixel((9, 1), (40, 40, 48, 255))
    elif sombrero == "gorra":
        rect(d, 6, 2, 11, 3, (200, 60, 50)); rect(d, 11, 4, 13, 4, (200, 60, 50))
    elif sombrero == "pescador":
        rect(d, 4, 4, 13, 4, (230, 210, 70)); rect(d, 6, 1, 11, 3, (230, 210, 70))
    elif sombrero == "bob":
        rect(d, 5, 3, 12, 4, (110, 150, 120)); rect(d, 6, 1, 11, 2, (110, 150, 120))
    if flor:
        im.putpixel((11, 3), flor + (255,)); im.putpixel((12, 4), flor + (255,))
    # Torso y brazos.
    rect(d, 5, 11, 12, 17, cam)
    rect(d, 4, 12, 4, 15, cam); rect(d, 13, 12, 13, 15, cam)
    im.putpixel((4, 16), p); im.putpixel((13, 16), p)
    if estampado == "rayas":
        for y in (12, 14, 16):
            rect(d, 5, y, 12, y, (240, 240, 236))
    elif estampado == "flores":
        for (x, y) in ((6, 12), (10, 13), (7, 15), (11, 16), (8, 11)):
            im.putpixel((x, y), (250, 220, 80, 255))
    elif estampado == "roto":
        im.putpixel((7, 16), (0, 0, 0, 0)); im.putpixel((11, 15), (0, 0, 0, 0)); im.putpixel((12, 17), (0, 0, 0, 0))
    if chaleco:
        rect(d, 5, 11, 6, 17, chaleco); rect(d, 11, 11, 12, 17, chaleco)
    if delantal:
        rect(d, 7, 12, 10, 18, (240, 238, 228))
    if camara:
        rect(d, 8, 13, 9, 14, (40, 40, 44)); im.putpixel((9, 13), (150, 200, 230, 255))
        im.putpixel((7, 12), (40, 40, 44, 255)); im.putpixel((10, 12), (40, 40, 44, 255))
    # Piernas.
    if falda:
        rect(d, 5, 18, 12, 20, pantalon)
        rect(d, 6, 21, 7, 23, p); rect(d, 10, 21, 11, 23, p)
    else:
        rect(d, 6, 18, 11, 23, pantalon)
        rect(d, 8, 21, 9, 23, (0, 0, 0, 0))
        if calcetines:
            rect(d, 6, 22, 7, 23, (245, 245, 245)); rect(d, 10, 22, 11, 23, (245, 245, 245))
    rect(d, 5, 24, 7, 24, zapatos); rect(d, 10, 24, 12, 24, zapatos)
    return contorno(im)


def turistas_nivel_1():
    # Náufragos, pescadores y gente del pueblo: llegan en barca.
    return {
        "naufrago_barbudo": persona("morena", "negro", "largo", camisa=(220, 210, 180), estampado="roto", pantalon=(70, 90, 140), barba=True, zapatos=(186, 126, 84)),
        "naufraga": persona("clara", "rubio", "largo", camisa=(200, 80, 70), estampado="roto", pantalon=(200, 180, 140), falda=True, zapatos=(186, 126, 84)),
        "pescador_chubasquero": persona("rosada", "canoso", "corto", camisa=(230, 200, 40), pantalon=(40, 60, 90), sombrero="pescador", barba=True, zapatos=(40, 40, 40)),
        "pescadora": persona("oscura", "negro", "rizado", camisa=(60, 96, 150), estampado="rayas", pantalon=(40, 60, 90), sombrero="lana", zapatos=(40, 40, 40)),
        "pueblerino_boina": persona("tostada", "gris", "corto", camisa=(235, 235, 228), pantalon=(80, 70, 60), sombrero="boina", chaleco=(70, 50, 40), zapatos=(50, 36, 28)),
        "pueblerina_delantal": persona("rosada", "castano", "mono", camisa=(110, 60, 110), pantalon=(60, 50, 60), falda=True, delantal=True, zapatos=(50, 36, 28)),
        "marinero_joven": persona("muy_oscura", "negro", "corto", camisa=(40, 60, 110), estampado="rayas", pantalon=(235, 235, 228), zapatos=(240, 240, 240)),
        "aldeana_panuelo": persona("clara", "castano", "corto", camisa=(150, 50, 50), pantalon=(40, 40, 48), falda=True, panuelo=(40, 40, 48), zapatos=(40, 40, 40)),
        "abuelo_bastos": persona("clara", "canoso", "calvo", camisa=(120, 140, 110), pantalon=(90, 80, 70), gafas=False, barba=True, zapatos=(50, 36, 28)),
        "chica_pueblo": persona("morena", "pelirrojo", "trenzas", camisa=(80, 150, 100), pantalon=(58, 78, 122), zapatos=(186, 126, 84)),
    }


def turistas_nivel_2():
    # Turistas normales de todas partes: llegan en velero o en catamarán.
    return {
        "turista_camara": persona("clara", "negro", "corto", camisa=(240, 240, 236), pantalon=(150, 130, 100), sombrero="bob", camara=True, gafas=True, zapatos=(240, 240, 240)),
        "turista_mochila": persona("clara", "negro", "largo", camisa=(240, 150, 170), pantalon=(60, 90, 160), mochila=(220, 120, 50), sombrero="paja", zapatos=(240, 240, 240)),
        "guiri_quemado": persona("rosada", "rubio", "corto", camisa=(60, 170, 190), estampado="flores", pantalon=(230, 200, 140), calcetines=True, gafas=True, zapatos=(130, 90, 60)),
        "senora_panuelo": persona("morena", "negro", "corto", camisa=(70, 120, 90), pantalon=(70, 120, 90), falda=True, panuelo=(200, 140, 60), zapatos=(120, 70, 50)),
        "chico_gorra": persona("tostada", "negro", "rizado", camisa=(240, 240, 236), pantalon=(60, 60, 70), sombrero="gorra", camara=True, zapatos=(240, 240, 240)),
        "senora_trenzas": persona("muy_oscura", "negro", "trenzas", camisa=(240, 190, 40), estampado="flores", pantalon=(170, 60, 80), falda=True, flor=(240, 80, 120), zapatos=(186, 126, 84)),
        "senor_hawaiana": persona("tostada", "gris", "calvo", camisa=(200, 60, 60), estampado="flores", pantalon=(240, 240, 236), gafas=True, zapatos=(130, 90, 60)),
        "chica_turista": persona("morena", "castano", "largo", camisa=(120, 90, 200), pantalon=(60, 90, 160), sombrero="paja", gafas=True, zapatos=(240, 240, 240)),
        "mochilero": persona("rosada", "pelirrojo", "rizado", camisa=(90, 130, 70), pantalon=(150, 130, 100), mochila=(60, 90, 130), barba=True, zapatos=(100, 70, 40)),
        "abuela_crucero": persona("clara", "canoso", "mono", camisa=(150, 200, 230), pantalon=(150, 200, 230), falda=True, camara=True, gafas=True, zapatos=(240, 240, 240)),
    }


def barca():
    im = Image.new("RGBA", (40, 18), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    madera, madera2, interior = (150, 98, 58), (120, 74, 42), (186, 132, 84)
    d.polygon([(1, 6), (38, 6), (34, 15), (5, 15)], fill=madera + (255,))
    rect(d, 4, 6, 35, 8, interior)
    rect(d, 2, 10, 37, 10, madera2)
    rect(d, 5, 13, 34, 13, madera2)
    # Remos.
    d.line([(10, 4), (2, 15)], fill=(200, 170, 110, 255))
    d.line([(29, 4), (37, 15)], fill=(200, 170, 110, 255))
    return contorno(im)


def velero():
    im = Image.new("RGBA", (48, 60), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    rect(d, 23, 4, 24, 46, (120, 84, 52))
    d.polygon([(25, 6), (25, 44), (44, 44)], fill=(246, 244, 236, 255))
    d.polygon([(22, 10), (22, 44), (6, 44)], fill=(232, 228, 214, 255))
    rect(d, 25, 3, 31, 6, (200, 60, 50))
    d.polygon([(1, 46), (47, 46), (42, 57), (6, 57)], fill=(246, 244, 236, 255))
    rect(d, 2, 50, 45, 51, (52, 104, 190))
    return contorno(im)


def catamaran():
    im = Image.new("RGBA", (64, 44), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    # Toldo de colores encima de la cubierta.
    rect(d, 12, 8, 51, 12, (240, 120, 60))
    for x in range(14, 50, 6):
        rect(d, x, 8, x + 2, 12, (250, 220, 90))
    rect(d, 14, 13, 14, 28, (200, 200, 196)); rect(d, 49, 13, 49, 28, (200, 200, 196))
    rect(d, 6, 28, 57, 31, (230, 226, 214))
    # Dos cascos.
    d.polygon([(2, 32), (24, 32), (21, 41), (5, 41)], fill=(246, 244, 236, 255))
    d.polygon([(39, 32), (61, 32), (58, 41), (42, 41)], fill=(246, 244, 236, 255))
    rect(d, 3, 35, 23, 35, (52, 104, 190)); rect(d, 40, 35, 60, 35, (52, 104, 190))
    return contorno(im)


def restaurante():
    """Chiringuito de madera austero (2x2), con letrero O MAR."""
    im = Image.new("RGBA", (60, 56), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    tabla, tabla2, tabla3 = (150, 98, 58), (128, 82, 48), (176, 120, 74)
    # Paredes de tablas verticales.
    for i, x in enumerate(range(6, 54, 4)):
        rect(d, x, 22, x + 3, 53, (tabla, tabla2, tabla3)[i % 3])
    # Tejado de tablones con alero.
    d.polygon([(1, 22), (59, 22), (54, 12), (6, 12)], fill=(110, 70, 40, 255))
    for y in (14, 17, 20):
        rect(d, 4, y, 56, y, (90, 56, 32))
    # Ventana-barra con toldo a rayas.
    rect(d, 10, 28, 33, 38, (40, 28, 22))
    for x in range(9, 35, 4):
        rect(d, x, 25, x + 1, 27, (220, 70, 60)); rect(d, x + 2, 25, x + 3, 27, (246, 244, 236))
    rect(d, 8, 38, 35, 40, (200, 150, 90))
    # Puerta.
    rect(d, 39, 30, 49, 53, (90, 56, 32)); im.putpixel((47, 42), (240, 200, 60, 255))
    # Letrero "O MAR" en el tejado.
    rect(d, 14, 2, 46, 10, (246, 236, 200))
    letras = {
        "O": ["111", "101", "101", "101", "111"],
        "M": ["10001", "11011", "10101", "10001", "10001"],
        "A": ["111", "101", "111", "101", "101"],
        "R": ["110", "101", "110", "101", "101"],
    }
    x = 17
    for ch in "O MAR":
        if ch == " ":
            x += 3
            continue
        g = letras[ch]
        for yy, fila in enumerate(g):
            for xx, b in enumerate(fila):
                if b == "1":
                    im.putpixel((x + xx, 4 + yy), (40, 80, 150, 255))
        x += len(g[0]) + 1
    rect(d, 20, 10, 21, 12, (90, 56, 32)); rect(d, 39, 10, 40, 12, (90, 56, 32))
    return contorno(im)


def mesa():
    im = Image.new("RGBA", (20, 22), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    # Sombrilla.
    d.polygon([(1, 7), (18, 7), (14, 2), (5, 2)], fill=(230, 80, 70, 255))
    rect(d, 7, 2, 9, 7, (246, 244, 236))
    rect(d, 9, 8, 10, 15, (200, 200, 196))
    rect(d, 3, 15, 16, 16, (176, 120, 74))
    rect(d, 4, 17, 4, 20, (120, 74, 42)); rect(d, 15, 17, 15, 20, (120, 74, 42))
    return contorno(im)


def pimiento_fases():
    fases = []
    hoja, hoja2, pim = (60, 130, 52), (42, 100, 40), (150, 215, 70)
    for f in range(3):
        im = Image.new("RGBA", (14, 16), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        rect(d, 6, 9, 7, 14, hoja2)
        if f == 0:
            rect(d, 4, 10, 6, 11, hoja); rect(d, 7, 9, 9, 10, hoja)
        else:
            d.ellipse([1, 3, 12, 12], fill=hoja + (255,))
            rect(d, 3, 6, 4, 7, hoja2); rect(d, 9, 5, 10, 6, hoja2); rect(d, 6, 4, 7, 5, hoja2)
        fases.append(contorno(im))
        if f == 2:
            # Pimientos colgando, con su propio contorno para que se lean sobre las hojas.
            d = ImageDraw.Draw(fases[-1])
            for (x, y) in ((2, 8), (6, 10), (10, 7)):
                rect(d, x - 1, y - 1, x + 2, y + 4, CONTORNO)
                rect(d, x, y, x + 1, y + 3, pim)
                fases[-1].putpixel((x, y), (200, 240, 140, 255))
    return fases


def alga_fases():
    fases = []
    c1, c2, brillo = (60, 130, 80), (40, 100, 70), (150, 200, 110)
    for f in range(3):
        im = Image.new("RGBA", (14, 18), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        alto = (5, 10, 15)[f]
        for i, x in enumerate((3, 6, 9)):
            a = alto - (i % 2) * 2
            for y in range(17 - a, 17):
                off = 1 if (y // 3) % 2 else 0
                im.putpixel((x + off, y), (c1 if i % 2 else c2) + (255,))
                im.putpixel((x + off + 1, y), (c1 if i % 2 else c2) + (255,))
        if f == 2:
            for (x, y) in ((4, 5), (10, 6), (7, 3)):
                im.putpixel((x, y), brillo + (255,))
        fases.append(contorno(im))
    return fases


def icono_pimiento():
    im = Image.new("RGBA", (10, 10), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.polygon([(4, 2), (7, 3), (6, 8), (4, 9), (3, 6)], fill=(110, 185, 60, 255))
    im.putpixel((5, 1), (60, 100, 40, 255)); im.putpixel((4, 4), (180, 230, 120, 255))
    return contorno(im)


def icono_alga():
    im = Image.new("RGBA", (10, 10), (0, 0, 0, 0))
    for y in range(1, 9):
        x = 4 + (1 if (y // 2) % 2 else 0)
        im.putpixel((x, y), (60, 130, 80, 255)); im.putpixel((x + 1, y), (60, 130, 80, 255))
    im.putpixel((3, 6), (40, 100, 70, 255)); im.putpixel((6, 3), (150, 200, 110, 255))
    return contorno(im)


def hoz():
    im = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.arc([2, 1, 14, 13], start=190, end=360, fill=(220, 222, 230, 255), width=2)
    rect(d, 12, 7, 13, 14, (140, 90, 50))
    return contorno(im)


def escalera():
    im = Image.new("RGBA", (12, 20), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    rect(d, 1, 0, 2, 19, (150, 98, 58)); rect(d, 9, 0, 10, 19, (150, 98, 58))
    for y in (2, 6, 10, 14, 18):
        rect(d, 3, y, 8, y, (176, 120, 74))
    return contorno(im)


def guardar(im, ruta):
    os.makedirs(os.path.dirname(ruta), exist_ok=True)
    im.save(ruta)


if __name__ == "__main__":
    for nombre, im in turistas_nivel_1().items():
        guardar(im, f"art/personajes/turistas/n1_{nombre}.png")
    for nombre, im in turistas_nivel_2().items():
        guardar(im, f"art/personajes/turistas/n2_{nombre}.png")
    guardar(barca(), "art/mundo/barcos/barca.png")
    guardar(velero(), "art/mundo/barcos/velero.png")
    guardar(catamaran(), "art/mundo/barcos/catamaran.png")
    guardar(restaurante(), "art/mundo/restaurante.png")
    guardar(mesa(), "art/mundo/props/mesa_sombrilla.png")
    for i, im in enumerate(pimiento_fases()):
        guardar(im, f"art/cultivos/pimiento_{i}.png")
    for i, im in enumerate(alga_fases()):
        guardar(im, f"art/cultivos/alga_{i}.png")
    guardar(icono_pimiento(), "art/cultivos/icono_pimiento.png")
    guardar(icono_alga(), "art/cultivos/icono_alga.png")
    guardar(hoz(), "art/cultivos/hoz.png")
    guardar(escalera(), "art/mundo/props/escalera.png")
    print("hecho")
