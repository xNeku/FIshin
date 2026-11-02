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


class Lienzo:
    """Dibuja en un lienzo de 26x30 con el muñeco desplazado (sitio para sombreros y cosas en la mano)."""
    W, H, OX, OY = 26, 30, 4, 3

    def __init__(self):
        self.im = Image.new("RGBA", (self.W, self.H), (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.im)

    def r(self, x0, y0, x1, y1, c):
        rect(self.d, x0 + self.OX, y0 + self.OY, x1 + self.OX, y1 + self.OY, c)

    def p(self, x, y, c):
        if 0 <= x + self.OX < self.W and 0 <= y + self.OY < self.H:
            self.im.putpixel((x + self.OX, y + self.OY), c if len(c) == 4 else c + (255,))


def persona(piel, pelo="castano", peinado="corto", camisa=(60, 96, 150), estampado=None, pantalon=(58, 78, 122),
            falda=False, zapatos=(70, 46, 30), sombrero=None, barba=False, gafas=False, camara=False,
            delantal=False, chaleco=None, panuelo=None, mochila=None, flor=None, calcetines=False,
            bigote=False, extras=(), largo=False, jersey=None):
    L = Lienzo()
    p = PIELES[piel] + (255,)
    hc = PELOS.get(pelo, (60, 40, 30)) + (255,)
    cam = camisa + (255,)
    if mochila:
        L.r(3, 10, 14, 16, mochila)
    if peinado in ("largo", "trenzas"):
        L.r(5, 3, 12, 12, hc)
    L.r(6, 4, 11, 10, p)
    if peinado == "corto":
        L.r(6, 3, 11, 4, hc); L.r(6, 5, 6, 6, hc); L.r(11, 5, 11, 6, hc)
    elif peinado == "largo":
        L.r(6, 3, 11, 4, hc)
    elif peinado == "rizado":
        L.r(5, 2, 12, 4, hc); L.r(5, 5, 5, 7, hc); L.r(12, 5, 12, 7, hc)
        for x in (5, 8, 11):
            L.p(x, 1, hc)
    elif peinado == "mono":
        L.r(6, 3, 11, 4, hc); L.r(8, 1, 9, 2, hc)
    elif peinado == "trenzas":
        L.r(6, 3, 11, 4, hc)
        for y in range(11, 16, 2):
            L.p(5, y, hc); L.p(12, y, hc)
    elif peinado == "tupe":
        L.r(6, 3, 11, 4, hc); L.r(7, 1, 11, 2, hc); L.p(12, 2, hc)
    elif peinado == "cardado":
        L.r(4, 1, 13, 5, hc); L.r(4, 6, 5, 9, hc); L.r(12, 6, 13, 9, hc)
    if panuelo:
        L.r(5, 3, 12, 11, panuelo); L.r(7, 5, 10, 10, p)
    if barba:
        L.r(6, 8, 11, 11, hc); L.r(8, 9, 9, 9, p)
    if bigote:
        L.r(7, 8, 10, 8, hc if not barba else oscuro(hc))
    if gafas == "corazon":
        L.r(6, 6, 7, 6, (240, 60, 120)); L.r(10, 6, 11, 6, (240, 60, 120)); L.p(8, 6, (240, 60, 120)); L.p(9, 6, (240, 60, 120))
    elif gafas == "grandes":
        L.r(5, 5, 12, 7, (30, 30, 36)); L.p(6, 5, (120, 120, 130))
    elif gafas:
        L.r(6, 6, 11, 6, (30, 30, 36)); L.p(7, 6, (90, 160, 210)); L.p(10, 6, (90, 160, 210))
    else:
        L.p(7, 6, OJO); L.p(10, 6, OJO)
    # Sombreros.
    S = sombrero
    if S == "paja":
        L.r(3, 4, 14, 4, (222, 190, 110)); L.r(6, 2, 11, 3, (222, 190, 110)); L.r(6, 3, 11, 3, (170, 60, 50))
    elif S == "lana":
        L.r(6, 1, 11, 4, (230, 180, 40)); L.r(6, 4, 11, 4, (200, 150, 30))
    elif S == "boina":
        L.r(5, 2, 12, 3, (40, 40, 48)); L.p(9, 1, (40, 40, 48))
    elif S == "gorra":
        L.r(6, 2, 11, 3, (200, 60, 50)); L.r(11, 4, 13, 4, (200, 60, 50))
    elif S == "pescador":
        L.r(4, 4, 13, 4, (230, 210, 70)); L.r(6, 1, 11, 3, (230, 210, 70))
    elif S == "bob":
        L.r(5, 3, 12, 4, (110, 150, 120)); L.r(6, 1, 11, 2, (110, 150, 120))
    elif S == "tirolés":
        L.r(4, 4, 13, 4, (50, 90, 50)); L.r(6, 1, 11, 3, (50, 90, 50)); L.r(6, 3, 11, 3, (150, 40, 40))
        L.p(12, 0, (240, 240, 240)); L.p(13, -1, (240, 240, 240)); L.p(11, 1, (240, 240, 240))
    elif S == "charro":
        L.r(-1, 4, 18, 5, (210, 170, 70)); L.r(5, 0, 12, 3, (210, 170, 70)); L.r(5, 3, 12, 3, (170, 40, 40))
        L.p(-1, 3, (210, 170, 70)); L.p(18, 3, (210, 170, 70))
    elif S == "ushanka":
        L.r(5, 1, 12, 4, (110, 80, 60)); L.r(4, 4, 5, 9, (110, 80, 60)); L.r(12, 4, 13, 9, (110, 80, 60)); L.r(6, 3, 11, 3, (150, 120, 90))
    elif S == "corchos":
        L.r(3, 4, 14, 4, (170, 130, 80)); L.r(6, 1, 11, 3, (170, 130, 80))
        for x in (4, 7, 10, 13):
            L.p(x, 5, (180, 150, 110)); L.p(x, 6, (230, 210, 170))
    elif S == "bombin":
        L.r(4, 3, 13, 3, (30, 30, 34)); L.r(6, 0, 11, 2, (30, 30, 34))
    elif S == "vaquero":
        L.r(2, 4, 15, 4, (240, 236, 220)); L.r(6, 0, 11, 3, (240, 236, 220)); L.p(2, 3, (240, 236, 220)); L.p(15, 3, (240, 236, 220)); L.r(6, 3, 11, 3, (120, 80, 40))
    elif S == "capitan":
        L.r(5, 1, 12, 3, (245, 245, 245)); L.r(5, 4, 12, 4, (30, 40, 70)); L.p(8, 2, (230, 190, 60)); L.p(9, 2, (230, 190, 60))
    elif S == "pamela":
        L.r(0, 3, 17, 4, (240, 220, 180)); L.r(5, 1, 12, 2, (240, 220, 180)); L.r(5, 2, 12, 2, (200, 60, 90))
    elif S == "piel":
        L.r(5, 0, 12, 4, (90, 70, 60)); L.r(6, 0, 11, 0, (130, 110, 90))
    elif S == "tam":
        L.r(5, 2, 12, 3, (40, 70, 140)); L.p(8, 0, (200, 40, 40)); L.p(9, 0, (200, 40, 40)); L.r(8, 1, 9, 1, (200, 40, 40))
    if flor:
        L.p(11, 3, flor + (255,)); L.p(12, 4, flor + (255,))
    # Torso (o túnica larga hasta los pies).
    alto_torso = 22 if largo else 17
    L.r(5, 11, 12, alto_torso, cam)
    L.r(4, 12, 4, 15, cam); L.r(13, 12, 13, 15, cam)
    L.p(4, 16, p); L.p(13, 16, p)
    e = estampado
    if e == "rayas":
        for y in (12, 14, 16):
            L.r(5, y, 12, y, (240, 240, 236))
    elif e == "rayas_celeste":
        for x in (6, 8, 10, 12):
            L.r(x, 11, x, 17, (120, 190, 230))
    elif e == "flores":
        for (x, y) in ((6, 12), (10, 13), (7, 15), (11, 16), (8, 11)):
            L.p(x, y, (250, 220, 80))
    elif e == "roto":
        for (x, y) in ((7, 16), (11, 15), (12, 17)):
            L.p(x, y, (0, 0, 0, 0))
    elif e == "union":
        L.r(5, 11, 12, 17, (40, 50, 130)); L.r(8, 11, 9, 17, (240, 240, 240)); L.r(5, 14, 12, 14, (240, 240, 240)); L.r(8, 11, 8, 17, (200, 40, 40)); L.r(5, 14, 12, 14, (200, 40, 40))
    elif e == "brasil":
        L.r(5, 11, 12, 11, (40, 140, 70)); L.p(8, 14, (40, 140, 70)); L.p(9, 14, (40, 140, 70)); L.p(8, 13, (60, 90, 170))
    elif e == "poncho":
        L.r(3, 11, 14, 17, (200, 70, 50))
        for y, c in ((12, (240, 200, 60)), (14, (60, 140, 90)), (16, (240, 200, 60))):
            L.r(3, y, 14, y, c)
    elif e == "chilaba":
        for x in (6, 9, 12):
            L.r(x, 11, x, 22, oscuro(cam, 0.82))
        L.r(5, 10, 12, 10, cam)
    elif e == "traje":
        L.r(8, 11, 9, 16, (240, 240, 240)); L.r(8, 12, 8, 15, (180, 40, 40))
    elif e == "capitan":
        L.r(8, 12, 8, 17, (230, 190, 60)); L.p(7, 13, (230, 190, 60)); L.p(7, 15, (230, 190, 60))
    elif e == "polo":
        L.r(8, 11, 9, 12, (240, 240, 240))
    if chaleco:
        L.r(5, 11, 6, 17, chaleco); L.r(11, 11, 12, 17, chaleco)
    if jersey:
        L.r(4, 10, 13, 11, jersey); L.r(7, 12, 10, 13, jersey)
    if delantal:
        L.r(7, 12, 10, 18, (240, 238, 228))
    if camara:
        L.r(8, 13, 9, 14, (40, 40, 44)); L.p(9, 13, (150, 200, 230)); L.p(7, 12, (40, 40, 44)); L.p(10, 12, (40, 40, 44))
    # Piernas.
    if largo:
        L.r(6, 23, 7, 23, p); L.r(10, 23, 11, 23, p)
    elif falda:
        L.r(5, 18, 12, 20, pantalon); L.r(6, 21, 7, 23, p); L.r(10, 21, 11, 23, p)
    else:
        L.r(6, 18, 11, 23, pantalon); L.r(8, 21, 9, 23, (0, 0, 0, 0))
        if calcetines:
            L.r(6, 22, 7, 23, (245, 245, 245)); L.r(10, 22, 11, 23, (245, 245, 245))
    L.r(5, 24, 7, 24, zapatos); L.r(10, 24, 12, 24, zapatos)
    # Cosas en la mano o encima.
    for x in extras:
        if x == "baguette":
            L.r(13, 9, 14, 17, (220, 170, 90)); L.p(13, 10, (190, 140, 60)); L.p(14, 13, (190, 140, 60))
        elif x == "mate":
            L.r(14, 14, 16, 16, (130, 90, 50)); L.p(15, 12, (200, 200, 200)); L.p(15, 13, (200, 200, 200))
        elif x == "tirantes":
            L.r(6, 11, 6, 17, (90, 60, 30)); L.r(11, 11, 11, 17, (90, 60, 30)); L.r(6, 13, 11, 13, (90, 60, 30))
        elif x == "jarra":
            L.r(14, 12, 16, 16, (240, 200, 60)); L.r(14, 11, 16, 11, (250, 250, 240)); L.p(17, 13, (200, 200, 200))
        elif x == "refresco":
            L.r(14, 11, 16, 16, (200, 50, 50)); L.p(15, 9, (240, 240, 240)); L.p(15, 10, (240, 240, 240))
        elif x == "zuecos":
            L.r(4, 24, 7, 25, (240, 200, 60)); L.r(10, 24, 13, 25, (240, 200, 60))
        elif x == "babuchas":
            L.r(4, 24, 7, 24, (240, 200, 60)); L.r(10, 24, 13, 24, (240, 200, 60))
        elif x == "sombrilla":
            L.r(14, 4, 15, 16, (90, 60, 40)); L.r(10, 1, 20, 2, (240, 120, 160)); L.r(12, 0, 18, 0, (240, 120, 160))
        elif x == "palo_selfie":
            L.r(14, 2, 14, 15, (60, 60, 64)); L.r(13, 0, 15, 2, (30, 30, 34)); L.p(14, 1, (150, 200, 230))
        elif x == "puro":
            L.r(11, 9, 13, 9, (120, 80, 40)); L.p(14, 9, (255, 120, 30))
        elif x == "perrito":
            L.r(13, 20, 17, 22, (245, 245, 240)); L.r(16, 18, 18, 20, (245, 245, 240)); L.p(18, 19, OJO); L.r(13, 23, 13, 24, (245, 245, 240)); L.r(17, 23, 17, 24, (245, 245, 240))
        elif x == "monoculo":
            L.p(10, 6, (230, 190, 60)); L.p(11, 6, (230, 190, 60)); L.p(11, 7, (230, 190, 60)); L.p(11, 8, (230, 190, 60))
        elif x == "cadena":
            L.r(7, 12, 10, 12, (240, 200, 60)); L.p(8, 13, (240, 200, 60))
        elif x == "perlas":
            L.r(6, 11, 11, 11, (250, 250, 245)); L.p(7, 12, (250, 250, 245)); L.p(10, 12, (250, 250, 245))
        elif x == "abanico":
            L.r(13, 10, 17, 12, (200, 40, 60)); L.r(14, 9, 16, 9, (200, 40, 60)); L.p(14, 13, (120, 80, 40))
        elif x == "golf":
            L.r(1, 10, 3, 20, (60, 90, 60)); L.p(1, 8, (220, 220, 220)); L.p(2, 7, (220, 220, 220)); L.p(3, 9, (220, 220, 220))
        elif x == "movil":
            L.r(14, 11, 15, 13, (30, 30, 34)); L.p(14, 12, (150, 200, 230))
    return contorno(L.im)


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
    # Turistas de todas partes (en velero o catamarán): se reconoce de dónde vienen por la ropa.
    return {
        "ingles_quemado": persona("rosada", "rubio", "corto", camisa=(40, 50, 130), estampado="union", pantalon=(230, 200, 140), calcetines=True, zapatos=(130, 90, 60), extras=("jarra",)),
        "aleman_tirolés": persona("clara", "rubio", "corto", camisa=(240, 240, 236), pantalon=(110, 70, 40), sombrero="tirolés", bigote=True, zapatos=(70, 46, 30), extras=("tirantes", "jarra")),
        "frances_baguette": persona("clara", "negro", "corto", camisa=(30, 40, 90), estampado="rayas", pantalon=(40, 40, 48), sombrero="boina", bigote=True, extras=("baguette",)),
        "mexicano_charro": persona("morena", "negro", "corto", camisa=(240, 240, 236), estampado="poncho", pantalon=(60, 50, 40), sombrero="charro", bigote=True),
        "escoces_kilt": persona("rosada", "pelirrojo", "corto", camisa=(240, 240, 236), pantalon=(170, 40, 40), falda=True, sombrero="tam", barba=True, calcetines=False, zapatos=(40, 40, 40)),
        "ruso_ushanka": persona("clara", "castano", "corto", camisa=(240, 240, 236), estampado="rayas", pantalon=(60, 60, 70), sombrero="ushanka", zapatos=(40, 40, 40)),
        "holandesa_zuecos": persona("clara", "rubio", "trenzas", camisa=(250, 140, 40), pantalon=(60, 90, 160), falda=True, extras=("zuecos",)),
        "argentino_mate": persona("morena", "castano", "rizado", camisa=(240, 240, 236), estampado="rayas_celeste", pantalon=(40, 40, 48), extras=("mate",)),
        "brasileña": persona("tostada", "negro", "largo", camisa=(250, 210, 40), estampado="brasil", pantalon=(60, 90, 160), zapatos=(240, 240, 240)),
        "asiatica_sombrilla": persona("clara", "negro", "largo", camisa=(240, 240, 236), pantalon=(150, 200, 230), gafas=True, camara=True, extras=("sombrilla",), zapatos=(240, 240, 240)),
        "marroqui_chilaba": persona("tostada", "negro", "corto", camisa=(200, 170, 120), estampado="chilaba", largo=True, bigote=True, extras=("babuchas",)),
        "americano_refresco": persona("rosada", "castano", "corto", camisa=(240, 240, 236), pantalon=(60, 90, 160), sombrero="gorra", gafas=True, extras=("refresco",), zapatos=(240, 240, 240)),
        "australiano_corchos": persona("tostada", "rubio", "corto", camisa=(170, 150, 100), pantalon=(150, 130, 90), sombrero="corchos", zapatos=(100, 70, 40)),
    }


def turistas_nivel_3():
    # Gente pija de todas partes: llegan en yate.
    return {
        "pijo_espanol": persona("tostada", "castano", "tupe", camisa=(240, 150, 170), estampado="polo", pantalon=(230, 220, 190), jersey=(80, 120, 190), gafas=True, zapatos=(90, 60, 40)),
        "lord_ingles": persona("rosada", "gris", "corto", camisa=(40, 40, 48), estampado="traje", pantalon=(40, 40, 48), sombrero="bombin", bigote=True, extras=("monoculo",), zapatos=(20, 20, 20)),
        "magnate_ruso": persona("clara", "castano", "calvo", camisa=(110, 80, 60), pantalon=(40, 40, 48), sombrero="piel", gafas="grandes", extras=("cadena",), zapatos=(20, 20, 20)),
        "heredera_italiana": persona("tostada", "negro", "largo", camisa=(200, 30, 50), pantalon=(200, 30, 50), falda=True, sombrero="pamela", gafas="grandes", extras=("perrito",), zapatos=(200, 30, 50)),
        "petrolero_tejano": persona("rosada", "gris", "corto", camisa=(240, 236, 220), estampado="traje", pantalon=(240, 236, 220), sombrero="vaquero", bigote=True, extras=("puro",), zapatos=(120, 80, 40)),
        "influencer": persona("morena", "rubio", "largo", camisa=(250, 150, 200), pantalon=(240, 240, 240), gafas="corazon", extras=("palo_selfie",), zapatos=(250, 150, 200)),
        "francesa_chic": persona("clara", "castano", "mono", camisa=(240, 240, 236), estampado="rayas", pantalon=(30, 40, 90), falda=True, panuelo=None, flor=(200, 40, 60), extras=("perlas", "perrito"), zapatos=(30, 30, 34)),
        "ejecutivo_golf": persona("clara", "negro", "corto", camisa=(40, 40, 48), estampado="traje", pantalon=(40, 40, 48), gafas=True, extras=("golf",), zapatos=(20, 20, 20)),
        "capitan_yate": persona("tostada", "canoso", "corto", camisa=(30, 40, 80), estampado="capitan", pantalon=(240, 240, 240), sombrero="capitan", barba=True, zapatos=(240, 240, 240)),
        "senora_marbella": persona("rosada", "rubio", "cardado", camisa=(240, 200, 60), pantalon=(240, 200, 60), falda=True, gafas="grandes", extras=("perlas", "abanico"), zapatos=(240, 200, 60)),
        "jeque_del_movil": persona("morena", "negro", "corto", camisa=(250, 250, 245), largo=True, panuelo=(250, 250, 245), gafas=True, extras=("movil",), zapatos=(120, 80, 40)),
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


def yate():
    im = Image.new("RGBA", (84, 54), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    blanco, gris, azul, cristal = (246, 246, 242), (210, 212, 216), (40, 60, 110), (40, 50, 70)
    d.polygon([(2, 34), (83, 30), (74, 50), (12, 50)], fill=blanco + (255,))
    rect(d, 6, 40, 78, 41, azul)
    d.polygon([(14, 34), (66, 32), (60, 22), (22, 22)], fill=blanco + (255,))
    rect(d, 24, 25, 58, 28, cristal)
    d.polygon([(28, 22), (56, 22), (52, 14), (34, 14)], fill=gris + (255,))
    rect(d, 36, 16, 50, 18, cristal)
    rect(d, 43, 4, 44, 14, (150, 150, 160)); rect(d, 39, 6, 48, 7, (150, 150, 160))
    rect(d, 70, 26, 72, 31, (200, 40, 40))
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


def ayuntamiento():
    """Casa consistorial gallega: piedra, soportales, balcón, reloj y bandera."""
    im = Image.new("RGBA", (76, 72), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    piedra, piedra2, junta = (206, 200, 186), (188, 182, 168), (150, 144, 132)
    rect(d, 4, 22, 71, 69, piedra)
    for y in range(26, 69, 6):
        rect(d, 4, y, 71, y, junta)
        for x in range(4 + (y // 6 % 2) * 6, 71, 12):
            rect(d, x, y - 5, x, y, junta)
    # Tejado de teja.
    d.polygon([(0, 24), (75, 24), (68, 14), (7, 14)], fill=(176, 84, 60, 255))
    for x in range(8, 68, 5):
        rect(d, x, 15, x, 23, (150, 66, 48))
    # Torre del reloj.
    rect(d, 29, 2, 46, 16, piedra2)
    d.polygon([(27, 3), (48, 3), (43, -3), (32, -3)], fill=(176, 84, 60, 255))
    d.ellipse([32, 5, 43, 15], fill=(246, 240, 220, 255), outline=(60, 50, 40, 255))
    rect(d, 37, 7, 37, 10, (40, 30, 24)); rect(d, 38, 10, 40, 10, (40, 30, 24))
    # Bandera.
    rect(d, 52, 0, 52, 14, (120, 120, 128))
    rect(d, 53, 1, 63, 6, (240, 240, 236)); d.line([(53, 6), (63, 1)], fill=(60, 110, 200, 255))
    # Balcón con ventanas.
    for x in (10, 28, 46):
        rect(d, x, 28, x + 16, 38, (70, 110, 150)); rect(d, x + 7, 28, x + 8, 38, piedra2)
    rect(d, 6, 40, 69, 41, (80, 60, 44))
    for x in range(8, 69, 3):
        rect(d, x, 36, x, 40, (80, 60, 44))
    # Soportales (arcos) abajo.
    for x in (8, 26, 44, 60):
        d.rectangle([x, 50, x + 12, 69], fill=(70, 62, 56, 255))
        d.ellipse([x, 44, x + 12, 56], fill=(70, 62, 56, 255))
    # Escudo.
    rect(d, 35, 42, 40, 47, (220, 180, 70))
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
    for nombre, im in turistas_nivel_3().items():
        guardar(im, f"art/personajes/turistas/n3_{nombre}.png")
    guardar(yate(), "art/mundo/barcos/yate.png")
    guardar(barca(), "art/mundo/barcos/barca.png")
    guardar(velero(), "art/mundo/barcos/velero.png")
    guardar(catamaran(), "art/mundo/barcos/catamaran.png")
    guardar(restaurante(), "art/mundo/restaurante.png")
    guardar(ayuntamiento(), "art/mundo/ayuntamiento.png")
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
