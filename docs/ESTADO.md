# ESTADO (traspaso entre sesiones)

## Dónde estamos
Fase 3 empezada: el mundo crece. Apariciones por datos (primera isla por mar a 200 ₽ totales, SkillTreeMan cae del cielo a 100 peces). Falta moverse e interactuar (árbol, bestiario, tienda del viejo).
Fase 2 hecha: bucle pescar → vender → mejorar. Cañas por profundidad, cebo, huecos de barca apilados por especie, tienda del comerciante (E) y menú (Tab) (Barca, Stats, Árbol vacío, Opciones). Save v2. Falta que el diseñador lo pruebe a mano.

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
- `scripts/pesca/celebracion.gd` (nodo Celebracion en main): levantar pez, luz, brillos, fanfarria y primer plano de la cámara. Los nodos visuales están en barca.tscn (PezLevantado, LuzTrofeo, Brillos).
- `scripts/mundo/mundo.gd` (nodo Mundo en main): lista de AparicionData (`data/apariciones/*.tres`), vigila condiciones, instancia la escena en su casilla ancla y la trae por MAR o desde el CIELO (sombra, caída, impacto). Guarda `aparecido_<id>` en Juego.flags. Bloquea la pesca (Pesca.bloquear) y mueve la cámara (CamaraPesca.enfocar / sacudir).
- Islas: `scenes/mundo/islas/*.tscn` con raíz `isla.gd` (salpicadura + al_llegar_activar). Fuego reutilizable: `scenes/mundo/fuego.tscn` (fuego.gd, activar()).
- Casilla de la carta → mundo: (x, y) → Vector3(x*2, 0, -y*2).
- `scenes/main.tscn`: lo monta todo.
- Peces: `data/peces/*.tres` (PezData). Arte placeholder en `art/` (generado por script, sustituible).

## Herramientas de diseño (artefactos)
- Carta de Fishin (mapa): https://claude.ai/artifact/2oRoaePEyuUyDUYBJnK9oA. Colección `elementos` con {nombre, tipo, estado, x, y, w, h (caja), celdas [[x,y]...] (forma real; si falta, es el rectángulo de la caja), orden, condicion, descripcion}. Coordenadas: barca en (0,0), x a la derecha, y hacia arriba (en Godot, y+ = -Z). 1 casilla = 2 m.
- Árbol de Fishin: https://claude.ai/artifact/UtP4gNUbFFwpX9SPeTcTnu. Colecciones `ramas` {nombre, descripcion, orden, color} y `nodos` {nombre, rama (id), nivel, coste, estado, efecto, descripcion, requisitos[]}.
- Se leen con ArtifactData (list). El código fuente está en `docs/herramientas/`.

## Siguiente paso
1. Modo movimiento (Q): andar por las islas, salto barca ↔ isla, interactuar con E (viejo → árbol + tienda de la Sabia caña; bestiario).
2. Árbol de habilidades: pasar el artefacto a datos cuando el diseñador lo rellene.
3. Rehacer el cebo: probabilidades + duración en segundos.

## Decisiones recientes
- 2.5D, Forward+, juego de PC. Moneda: rublos (₽). Fuente DejaVu Sans Bold (tiene ₽ y flechas).
- La intensidad visual va por botones seguidos (no por % del pez); el máximo llega con combos de 50 (final de juego). Las dobles salen desde el 5º botón.
- Largo de cadena aleatorio por picada (CanaData.tirar_largo_cadena), sesgado a corto.
- Machacar fallido: los extraños y legendarios se escapan, los demás pierden valor.
- Niebla desactivada (en Compatibility lo dejaba todo gris).

## Pendiente de preguntar (en orden)
0. Primera isla: ¿"200" son ₽ ganados en total? ¿Orden real por condición cumplida?
1. Qué cebos hay y qué sube cada uno.
2. Barca llena: ¿soltar, elegir qué tirar, o que no piquen especies nuevas?
3. Progreso offline.
4. Lista ordenada de islas y edificios (la escribirá el diseñador).
