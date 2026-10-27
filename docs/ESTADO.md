# ESTADO (traspaso entre sesiones)

## Dónde estamos
Fase 2 hecha: bucle pescar → vender → mejorar. Cañas por profundidad, cebo, huecos de barca apilados por especie, tienda del comerciante (E) y menú ESC (Barca, Stats, Árbol vacío, Opciones). Save v2. Falta que el diseñador lo pruebe a mano.

## Mapa rápido del código
- `scripts/pesca/pesca.gd` (Pesca): lógica del minijuego, solo señales. Las stats van en `data/stats_pesca.tres`.
- `scripts/pesca/camara_pesca.gd`: zoom, shake y congelado. `sonido_pesca.gd`: sfx y latido.
- `scripts/economia/juego.gd` (autoload Juego): rublos, capturas, stats, colección, flags, save `user://partida.json`.
- `scripts/ui/hud.gd` + `scenes/ui/hud.tscn`. Popups desde `scenes/ui/popup_texto.tscn`.
- `scenes/mundo/barca.tscn` (barca.gd), `scenes/mundo/barco_comerciante.tscn`.
- `scripts/ui/menu.gd` + `scenes/ui/menu.tscn` (huecos desde `hueco_barca.tscn`, variantes desde `fila_variante.tscn`).
- `scripts/ui/tienda.gd` + `scenes/ui/tienda.tscn` (filas desde `fila_tienda.tscn`). Los artículos del comerciante se asignan en `barco_comerciante.tscn`.
- Datos: `data/canas/*.tres` (CanaData, se carga por id), `data/articulos/*.tres` (ArticuloData: CANA, CEBO, HUECO).
- Menú y tienda pausan el árbol (`process_mode = Always` en ellos).
- `scenes/main.tscn`: lo monta todo.
- Peces: `data/peces/*.tres` (PezData). Arte placeholder en `art/` (generado por script, sustituible).

## Siguiente paso
1. Feedback del diseñador sobre el feel de la pesca y la tienda.
2. Fase 3: hito de 100 ₽ → islote 1x1, cuadrícula, modo movimiento (Q) y salto barca ↔ isla.

## Decisiones recientes
- 2.5D, Forward+, juego de PC. Moneda: rublos (₽). Fuente DejaVu Sans Bold (tiene ₽ y flechas).
- Machacar fallido: los extraños y legendarios se escapan, los demás pierden valor.
- Niebla desactivada (en Compatibility lo dejaba todo gris).

## Pendiente de preguntar (en orden)
1. Cebo: ¿más tiempo de reacción, que piquen antes, o ambas?
2. Barca llena: ¿soltar, elegir qué tirar, o que no piquen especies nuevas?
3. Progreso offline.
4. Lista ordenada de islas y edificios (la escribirá el diseñador).
