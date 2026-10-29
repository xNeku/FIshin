# ROADMAP

Regla: no se pasa de fase hasta que la actual sea jugable y divertida. Cada tarea = un commit.

## Fase 0 — Setup
- [x] Proyecto Godot 4.7.2 (Forward+, carpetas, Input Map, resolución y escalado para PC y móvil)
- [x] Autoload de estado del juego + guardado y carga versionados
- [x] Formateo de números grandes

## Fase 1 — Núcleo: pescar es divertido
- [x] Escena barca + zona 3x3 + protagonista placeholder
- [x] Espera y picada
- [x] Minijuego: cadena de botones con tiempo decreciente, fallo y límite
- [x] Calidad del pez según la cadena
- [x] Datos de peces (`.tres`) y tirada de pez
- [x] Juice básico (sonido placeholder, screenshake, popups)
- **Hito:** pescar 5 minutos seguidos engancha. (Sin confirmar por el diseñador en partida larga.)

## Fase 2 — Economía mínima
- [x] Inventario de la barca
- [x] Barco comerciante: tienda (caña, cebo, hueco) y vender todo
- [x] HUD de dinero
- [x] Primeras mejoras compradas (cañas con profundidad, cebo, huecos)
- **Hito:** bucle pescar → vender → mejorar.

## Fase 3 — Mundo y expansión
- [x] Cuadrícula y colocación (apariciones por datos desde la carta)
- [x] Hitos que hacen aparecer cosas, con llegada por mar o caída del cielo
- [x] Modo movimiento (Q), salto barca ↔ isla
- [x] Interacción (E): tienda del viejo, bestiario y diálogo tipo Pokémon (pescador)
- [x] Camino de madera y puerto pesquero (aparecen construyéndose)
- **Hito:** se nota que el mundo crece.

## Fase 4 — Menú y progresión
- [x] Menú (Tab) con pestañas (barca con huecos apilados, stats, opciones)
- [x] Árbol de habilidades (datos + UI en el viejo): 60 nodos de propuesta, a revisar por el diseñador
- [x] Auto-pesca (nodo Pesca de memoria) y piloto automático de chill
- [ ] Rehacer el cebo (probabilidades + duración)
- [x] Mecánicas avanzadas de pesca: machacar y pulsación doble (adelantado)


## Fase 5 — Villa e incremental
- [x] Primer trabajador automático: pescadores del puerto + cubo + venta animada
- [x] Lonja: venta rápida de todo lo que llevas
- [ ] Más edificios y trabajadores (mejoras del puerto...)
- [ ] Ingresos pasivos, stats por segundo
- [ ] Progreso offline (si se decide)
- [ ] Balance de curvas

## Fase 6 — Contenido
- [ ] Catálogo de peces (Excel del diseñador), legendarios, colección (la meta)
- [ ] Tiempo del juego: día/noche y estaciones
- [ ] Más edificios, ramas e hitos

## Fase 7 — Pulido
- [x] Estilo pixelado (B), mar con olas y reflejos, clima
- [x] Prota en donut con caña, corcho y ondas; suelos con textura y props en sprite
- [x] Barco comerciante en sprite, donut que flota sobre la ola
- [x] Interfaz estilo Animal Well (fuente pixel, paneles, selección amarilla), filtro retro, animaciones de entrada
- [x] Teclas y botones dibujados (teclado, PlayStation, Xbox), sin frases en pantalla, X roja de fallo
- [ ] Probar rendimiento en la tablet
- [ ] Guía de medidas del arte
- [ ] Partículas, música y SFX
- [ ] Arte final del diseñador

## Fase 8 — Export y release
- [ ] GitHub Actions: builds de Windows, Mac (y Android)
- [x] Mando (PlayStation y Xbox) con iconos según el mando
- [ ] Input táctil y UI móvil
- [ ] Release
