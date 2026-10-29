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
- [x] Auto-pesca (nodo Pesca de memoria)
- [ ] Modos de pesca por caña: volumen y trofeo (midgame)
- [ ] Modo infinito con récords
- [ ] Rehacer el cebo (probabilidades + duración)
- [x] Mecánicas avanzadas de pesca: machacar y pulsación doble (adelantado)
- [x] Racha de combo por tramos (osu! + Guitar Hero), modo flow más rápido (Leer el agua)
- [x] Pesca tranquila: esperas de 8-20 s, picoteos, chill que deja pasar el pez
- [x] Puntos de pesca: el que pesca mejor desbloquea antes (camino y puerto)
- [ ] Racha entre peces (pendiente de decidir)


## Fase 5 — Villa e incremental
- [x] Primer trabajador automático: pescadores del puerto + cubo + venta animada
- [x] Lonja: venta rápida de todo lo que llevas
- [ ] Más edificios y trabajadores (mejoras del puerto...)
- [ ] Ingresos pasivos, stats por segundo
- [ ] Progreso offline (si se decide)
- [~] Balance de curvas: hecho hasta el puerto y la lonja (~70 min) con el simulador; falta el resto del T1 y el T2

## Fase 6 — Contenido
- [x] Catálogo de peces del Excel del diseñador: 201 especies (Galicia + mundo), 6 rarezas, iconos placeholder
- [x] Maestría por especie en el bestiario
- [ ] Bestiario con filtros por zona o fichas compactas (hay 201)
- [ ] Peces que desbloquean edificios (sushi...)
- [x] Tiempo del juego: día/noche (20 min) y estaciones (2 h), noche con luna, peces por estación y hora
- [ ] Más edificios, ramas e hitos

## Fase 7 — Pulido
- [x] Estilo pixelado (B), mar con olas y reflejos, clima
- [x] Prota en donut con caña, corcho y ondas; suelos con textura y props en sprite
- [x] Barco comerciante en sprite, donut que flota sobre la ola
- [x] Interfaz estilo Animal Well (fuente pixel, paneles, selección amarilla), filtro retro, animaciones de entrada
- [x] Teclas y botones dibujados (teclado, PlayStation, Xbox), sin frases en pantalla, X roja de fallo
- [x] Carta del pez abajo a la izquierda (¡NUEVO!), botón de interactuar sobre la cabeza
- [x] Agua que se calma en la costa (ya no pisa las islas con tormenta); opción de agua realista sin bandas
- [ ] Probar rendimiento en la tablet
- [ ] Guía de medidas del arte
- [ ] Partículas, música y SFX
- [ ] Arte final del diseñador

## Fase 8 — Export y release
- [ ] GitHub Actions: builds de Windows, Mac (y Android)
- [x] Mando (PlayStation y Xbox) con iconos según el mando
- [x] Menús, tienda y árbol navegables con mando (L1/R1 pestañas, Círculo atrás, Triángulo extra)
- [ ] Input táctil y UI móvil
- [ ] Release
