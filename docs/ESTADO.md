# ESTADO (traspaso entre sesiones)

## Dónde estamos
Fase 1 jugable: minijuego de pesca completo (simple, doble y machacar), zoom/shake/efectos, 6 peces en datos, inventario, barco comerciante que vende, guardado. Falta probarlo a mano y ajustar el feel.

## Mapa rápido del código
- `scripts/pesca/pesca.gd` (Pesca): lógica del minijuego, solo señales. Las stats van en `data/stats_pesca.tres`.
- `scripts/pesca/camara_pesca.gd`: zoom, shake y congelado. `sonido_pesca.gd`: sfx y latido.
- `scripts/economia/juego.gd` (autoload Juego): rublos, capturas, stats, colección, flags, save `user://partida.json`.
- `scripts/ui/hud.gd` + `scenes/ui/hud.tscn`. Popups desde `scenes/ui/popup_texto.tscn`.
- `scenes/mundo/barca.tscn` (barca.gd), `scenes/mundo/barco_comerciante.tscn`.
- `scenes/main.tscn`: lo monta todo.
- Peces: `data/peces/*.tres` (PezData). Arte placeholder en `art/` (generado por script, sustituible).

## Siguiente paso
1. Feedback del diseñador sobre el feel de la pesca.
2. Fase 2: comprar al comerciante (primera mejora de caña = límite de cadena) y menú ESC básico.
3. Fase 3: hito de 100 ₽ → islote 1x1 y modo movimiento.

## Decisiones recientes
- 2.5D, Forward+, juego de PC. Moneda: rublos (₽). Fuente DejaVu Sans Bold (tiene ₽ y flechas).
- Machacar fallido: los extraños y legendarios se escapan, los demás pierden valor.
- Niebla desactivada (en Compatibility lo dejaba todo gris).

## Pendiente de preguntar (en orden)
1. Qué vende el comerciante (¿caña, cebos?) y precios.
2. Capacidad del inventario de la barca.
3. Progreso offline.
4. Lista ordenada de islas y edificios (la escribirá el diseñador).
