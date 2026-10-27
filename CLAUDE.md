# CLAUDE.md — Fishin

Reglas del proyecto. Al empezar sesión lee SOLO esto y `docs/ESTADO.md`. El resto (`docs/GDD.md`, `docs/ROADMAP.md`, código) solo cuando la tarea lo necesite.

## Qué es
Incremental de pesca con expansión de terreno tipo Forager. Náufrago carismático en una barca que acaba teniendo una villa pesquera que trabaja para él. Diseño en `docs/GDD.md` (fuente de verdad).

## Roles
- El humano es game designer: decide, diseña y hará el arte final.
- Claude programa y hace placeholders con personalidad (formas por código, shaders, pixel art simple generado por script). El arte final entra cambiando rutas en los datos, sin tocar código.
- El humano trabaja casi siempre desde una tablet Android (Godot Android + Termux con git). En casa tiene un Mac M4 Pro.

## Stack
- Godot **4.7.2**. No uses APIs más nuevas.
- Solo GDScript **tipado**. Sin addons compilados.
- Escenas y Resources en texto (`.tscn` / `.tres`).
- Renderer: Forward+. El juego se hace para PC; la tablet (Lenovo Legion Y300) lo mueve sin problema.
- Objetivo: Windows y Mac. Móvil después: la UI y el input se piensan táctiles desde el principio.
- Nombres de propiedades y señales de Godot 4 exactos. Si dudas, compruébalo en headless.
- Los `Control` dentro de escenas de juego llevan `mouse_filter = 2` (Ignore) salvo los que tengan que recibir clics.
- En `.tscn` a mano, las propiedades que apuntan a nodos llevan `node_paths=PackedStringArray(...)` en la cabecera.

## Estructura
- `docs/ESTADO.md`: traspaso entre sesiones (dónde estamos, siguiente paso, decisiones recientes). Se actualiza al cerrar cada tarea o sesión.
- `docs/GDD.md`: diseño con marcas [DECIDIDO] / [PROPUESTA] / [ABIERTO]. Lo [ABIERTO] se pregunta, no se decide.
- `docs/ROADMAP.md`: fases con checklist.
- `docs/IDEAS.md`: ideas nuevas que no son del tramo actual. No van al código todavía.
- `scripts/` por áreas (`pesca/`, `economia/`, `mundo/`, `jugador/`, `ui/`, `datos/`).
- `scenes/`, `data/` (contenido como `.tres` con ID: peces, mejoras, edificios, hitos), `art/`.
- `tmp_tests/`: pruebas temporales; se borran antes del commit.

## REGLA CLAVE: escenas siempre en el editor
- **NUNCA generes escenas ni montes nodos por código** salvo que sea imprescindible, y en ese caso **pregunta antes** al humano.
- Todo se monta en `.tscn` accesibles y escalables, con todos sus nodos visibles y tratables, para que el humano lo retoque desde el engine.
- Lo dinámico (peces que aparecen, popups, piezas que se colocan en la cuadrícula) se instancia desde una escena `.tscn` hecha a mano, nunca se construye nodo a nodo en código.
- Excepción: los scripts de prueba en `tmp_tests/`.

## Principios de código
- Lógica separada de lo visual.
- Input solo por acciones del Input Map (teclado, mando y táctil).
- Valores de feel y de balance como `@export` o en Resources, para que el humano los ajuste en el inspector.
- Contenido por datos con ID. Nunca código por ítem.
- Lo que el humano vaya a retocar (mapa, personaje, UI, edificios) va en escenas `.tscn` editables con nodos claros.
- Dinero: usar `float` mientras quepa (hasta 1e308). Formatear siempre con una función común.
- Guardado desde el día 1, versionado (campo `version` en el save).

## Git
- Rama de trabajo: `claude/incremental-game-godot-5zd4o2`. Un commit por tarea.
- El humano: pull en Termux, prueba, ajusta en el inspector y hace push. Antes de continuar, haz pull y respeta sus cambios.
- Avisa siempre de qué `.tscn` tocas. No reescribas una escena entera sin necesidad.
- Los comandos para el humano van SIEMPRE en bloque de código.
- Al acabar cada cosa, da SIEMPRE una única línea lista para copiar y pegar en Termux que lo actualice todo. NUNCA incluyas `cd`: el humano ya está en la carpeta del repo (`~/storage/shared/Godot/FIshin`). Normalmente basta `git pull`.
- Si el humano tiene que tocar nodos en el editor, dale la jerarquía completa en un bloque.

## Cada tarea
1. Una frase de lo que vas a hacer y empiezas.
2. Valida: `godot --headless --path . --import` y `godot --headless --path . --quit-after 60` sin errores.
3. Prueba en ejecución con escenas scripteadas en `tmp_tests/`. Compilar no basta.
4. Commit, push y actualizar `docs/ESTADO.md`.
5. Informe corto: qué hay, comandos de pull, qué se puede ajustar y dónde, y qué queda sin probar.

## Tono
Español, directo, sin relleno. Crítico: avisa de riesgos y contradicciones. Las preguntas de diseño, de una en una. "¿Qué opinas?" significa opinar y no tocar nada.

## Sesiones
"inicio": leer CLAUDE.md + ESTADO.md y decir el siguiente paso. "fin sesión": actualizar ESTADO.md, hacer commit y push.
