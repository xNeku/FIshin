# Texturas provisionales de los suelos (placeholder hasta el arte del diseñador).
# Estilo propio: losetas de 32×32 con formas dibujadas (matojos, ondas de arena, vetas, tablones largos),
# no ruido de píxel suelto. Todas se repiten sin costura (lo que sale por un borde entra por el otro).
# Uso: python3 docs/herramientas/generar_suelos.py   (desde la raíz del repo)
import math
import random
from PIL import Image

N = 32


class Loseta:
    def __init__(self, base):
        self.im = Image.new("RGBA", (N, N), base + (255,))

    def p(self, x, y, c):
        self.im.putpixel((x % N, y % N), c + (255,) if len(c) == 3 else c)

    def mancha(self, cx, cy, r, c, rnd, irregular=0.35):
        """Mancha redondeada e irregular (repite por los bordes)."""
        for dy in range(-r - 1, r + 2):
            for dx in range(-r - 1, r + 2):
                d = math.hypot(dx, dy * 1.15)
                if d <= r * (1 - irregular * rnd.random() * 0.6):
                    self.p(cx + dx, cy + dy, c)


def hierba():
    rnd = random.Random(11)
    base, oscuro, claro, brizna = (86, 152, 64), (70, 130, 54), (108, 172, 74), (58, 112, 46)
    t = Loseta(base)
    # Manchas grandes y suaves de luz y sombra.
    for _ in range(5):
        t.mancha(rnd.randrange(N), rnd.randrange(N), rnd.randint(4, 6), oscuro, rnd)
    for _ in range(4):
        t.mancha(rnd.randrange(N), rnd.randrange(N), rnd.randint(3, 5), claro, rnd)
    # Matojos: una "V" de briznas con la punta clara.
    for _ in range(9):
        x, y = rnd.randrange(N), rnd.randrange(N)
        for dx, dy in ((0, 0), (-1, -1), (1, -1), (-2, -2), (2, -2)):
            t.p(x + dx, y + dy, brizna)
        t.p(x - 2, y - 3, claro); t.p(x + 2, y - 3, claro); t.p(x, y - 1, claro)
    # Florecillas sueltas.
    for c in ((246, 240, 214), (250, 214, 92), (246, 240, 214)):
        x, y = rnd.randrange(N), rnd.randrange(N)
        t.p(x, y, c); t.p(x + 1, y, c); t.p(x, y + 1, c); t.p(x + 1, y + 1, (200, 160, 60))
    return t.im


def arena():
    rnd = random.Random(23)
    base, onda, luz, concha = (232, 210, 160), (214, 188, 136), (244, 228, 188), (250, 236, 222)
    t = Loseta(base)
    # Ondas que deja el mar: curvas suaves en diagonal.
    for k in range(4):
        fase = k * N / 4
        for x in range(N):
            y = int(fase + 2.2 * math.sin(2 * math.pi * x / N) + x * 0.25) % N
            t.p(x, y, onda)
            t.p(x, y - 1, luz)
    # Conchitas y piedrecitas claras.
    for _ in range(3):
        x, y = rnd.randrange(N), rnd.randrange(N)
        t.p(x, y, concha); t.p(x + 1, y, concha); t.p(x, y + 1, (220, 170, 150))
    for _ in range(6):
        t.p(rnd.randrange(N), rnd.randrange(N), (200, 176, 128))
    return t.im


def tierra():
    rnd = random.Random(37)
    base, veta, oscuro, luz = (132, 92, 62), (114, 78, 52), (96, 64, 44), (150, 108, 74)
    t = Loseta(base)
    # Vetas horizontales onduladas (se leen como estratos en los lados y como surcos encima).
    for y0 in (3, 11, 19, 27):
        for x in range(N):
            y = y0 + int(round(1.2 * math.sin(2 * math.pi * (x + y0 * 3) / N)))
            t.p(x, y, veta)
            if rnd.random() < 0.5:
                t.p(x, y + 1, veta)
            t.p(x, y - 1, luz)
    # Grietas cortas.
    for _ in range(5):
        x, y = rnd.randrange(N), rnd.randrange(N)
        for k in range(rnd.randint(2, 4)):
            t.p(x + k, y + (k % 2), oscuro)
    # Terrones redondos del mismo color (no piedras grises).
    for _ in range(4):
        x, y = rnd.randrange(N), rnd.randrange(N)
        t.p(x, y, luz); t.p(x + 1, y, luz); t.p(x, y + 1, oscuro); t.p(x + 1, y + 1, oscuro)
    return t.im


def tablones(viejos=False):
    rnd = random.Random(53 if viejos else 41)
    if viejos:
        cols = [(150, 140, 126), (138, 128, 116), (162, 152, 136)]
        junta, veta, clavo = (70, 64, 58), (124, 116, 104), (90, 90, 96)
    else:
        cols = [(178, 124, 78), (166, 114, 70), (188, 134, 86)]
        junta, veta, clavo = (98, 64, 40), (150, 102, 62), (70, 66, 70)
    t = Loseta(cols[0])
    alto = 8   # tablones de 8 píxeles: largos y anchos, como un pantalán
    for fila in range(N // alto):
        y0 = fila * alto
        corte = (fila * 13 + 5) % N          # junta escalonada, una por tablón largo
        c = cols[fila % len(cols)]
        for y in range(y0, y0 + alto):
            for x in range(N):
                t.p(x, y, c)
        for x in range(N):
            t.p(x, y0, junta)                # separación entre tablones
        for y in range(y0, y0 + alto):
            t.p(corte, y, junta)             # fin de tablón
        # Veta: dos líneas largas que ondulan un poco.
        for k in (2, 5):
            for x in range(N):
                if (x + fila * 7) % 11 < 8:
                    t.p(x, y0 + k + (1 if math.sin((x + fila * 5) / 4.0) > 0.6 else 0), veta)
        # Clavos a los lados de la junta.
        for dx in (-2, 2):
            t.p(corte + dx, y0 + 2, clavo); t.p(corte + dx, y0 + alto - 2, clavo)
        if viejos:
            # Huecos y grietas: tablón roto aquí y allá.
            if rnd.random() < 0.6:
                x = rnd.randrange(N)
                for k in range(rnd.randint(4, 9)):
                    t.p(x + k, y0 + alto // 2, junta)
                    if k % 3 == 0:
                        t.p(x + k, y0 + alto // 2 + 1, junta)
    return t.im


if __name__ == "__main__":
    for nombre, im in (("hierba", hierba()), ("arena", arena()), ("tierra", tierra()),
                       ("tablones", tablones()), ("tablones_rotos", tablones(viejos=True))):
        im.save(f"art/mundo/suelo/{nombre}.png")
    print("hecho")
