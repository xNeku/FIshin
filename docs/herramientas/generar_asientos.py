# Asientos de los spots (placeholder hasta el arte del diseñador): retrete (O Penedo) y sofá (Mar de Fóra).
# Mismo lienzo y capas que el donut (64×58): <id>.png va detrás del náufrago y <id>_frente.png delante
# (las piernas van encima de todo). Uso: python3 docs/herramientas/generar_asientos.py
from PIL import Image

W, H = 64, 58
TINTA = (34, 26, 32, 255)


def lienzo():
    return Image.new("RGBA", (W, H), (0, 0, 0, 0))


def rect(im, x0, y0, x1, y1, c, borde=True):
    """Rectángulo relleno (incluye x1, y1) con contorno de tinta."""
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            en_borde = x in (x0, x1) or y in (y0, y1)
            im.putpixel((x, y), TINTA if borde and en_borde else c + (255,))


def ovalo(im, cx, cy, rx, ry, c, borde=True):
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            d = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
            if d <= 1.0:
                im.putpixel((x, y), TINTA if borde and d > 0.72 else c + (255,))


def linea_h(im, x0, x1, y, c):
    for x in range(x0, x1 + 1):
        im.putpixel((x, y), c + (255,) if len(c) == 3 else c)


def retrete():
    blanco, sombra, brillo, agua = (236, 238, 240), (196, 204, 214), (255, 255, 255), (120, 190, 230)
    atras = lienzo()
    # Cisterna detrás de la espalda, con su tapa y el tirador.
    rect(atras, 14, 17, 50, 37, blanco)
    rect(atras, 12, 13, 52, 18, sombra)
    linea_h(atras, 16, 48, 19, brillo)
    rect(atras, 45, 21, 49, 24, (170, 172, 184))
    for y in range(20, 36):
        atras.putpixel((15, y), sombra + (255,))
    # Taza: base y cuerpo (se ve por los lados y entre las piernas).
    ovalo(atras, 32, 44, 15, 6, blanco)
    ovalo(atras, 32, 44, 10, 3, agua, borde=False)
    rect(atras, 24, 46, 40, 55, blanco)
    for y in range(47, 55):
        atras.putpixel((25, y), sombra + (255,))
    rect(atras, 21, 54, 43, 57, sombra)
    frente = lienzo()
    # Borde delantero de la tapa y el pie, por delante de los muslos.
    for x in range(20, 45):
        frente.putpixel((x, 47), TINTA)
        frente.putpixel((x, 48), blanco + (255,))
    frente.putpixel((19, 47), TINTA); frente.putpixel((45, 47), TINTA)
    rect(frente, 21, 54, 43, 57, sombra)
    return atras, frente


def sofa():
    tela, oscura, clara, pata = (196, 104, 52), (150, 72, 38), (226, 140, 80), (92, 58, 36)
    atras = lienzo()
    # Respaldo ancho con dos cojines.
    rect(atras, 6, 22, 57, 40, tela)
    rect(atras, 9, 25, 31, 39, clara)
    rect(atras, 32, 25, 54, 39, clara)
    # Asiento y faldón.
    rect(atras, 6, 40, 57, 46, oscura)
    rect(atras, 6, 46, 57, 53, tela)
    # Patas.
    for x in (8, 54):
        rect(atras, x, 53, x + 2, 57, pata)
    frente = lienzo()
    # Brazos del sofá por delante (tapan los lados del asiento).
    rect(frente, 2, 34, 12, 53, tela)
    linea_h(frente, 3, 11, 35, clara)
    rect(frente, 51, 34, 61, 53, tela)
    linea_h(frente, 52, 60, 35, clara)
    # Borde del cojín delantero.
    for x in range(12, 52):
        frente.putpixel((x, 46), TINTA)
    return atras, frente


if __name__ == "__main__":
    for nombre, (a, f) in (("retrete", retrete()), ("sofa", sofa())):
        a.save(f"art/personajes/{nombre}.png")
        f.save(f"art/personajes/{nombre}_frente.png")
    print("hecho")
