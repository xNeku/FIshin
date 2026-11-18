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
- **Hito:** pescar 5 minutos seguidos engancha. (Tras el reformateo esto es de los spots; falta la prueba larga del diseñador.)

## Fase 2 — Economía mínima
- [x] Inventario de la barca
- [x] Barco comerciante: tienda (caña, cebo, hueco) y vender todo
- [x] HUD de dinero
- [x] Primeras mejoras compradas (cañas, cebo; los huecos de la barca se quitaron)
- **Hito:** bucle pescar → vender → mejorar.

## Fase 3 — Mundo y expansión
- [x] Cuadrícula y colocación (apariciones por datos desde la carta)
- [x] Hitos que hacen aparecer cosas, con llegada por mar o caída del cielo
- [x] Modo movimiento (Q), salto barca ↔ isla
- [x] Interacción (E): tienda del viejo, bestiario y diálogo tipo Pokémon (pescador)
- [x] Camino de madera y puerto pesquero (aparecen construyéndose)
- **Hito:** se nota que el mundo crece.

## Fase 4 — Menú y progresión
- [x] Menú (Tab) con pestañas (barca con pilas por especie, stats, opciones)
- [x] Árbol de habilidades (datos + UI en el viejo): ~70 nodos en 5 ramas; Pesca partida en Base y Maña
- [x] Auto-pesca (nodo Pesca de memoria; desde el reformateo es la pesca automática de la base)
- [x] ~~Modos de pesca por caña: volumen y trofeo~~ → sustituido por los spots (reformateo, 10 nov)
- [ ] Modo infinito con récords
- [ ] Rehacer el cebo (probabilidades + duración)
- [x] Mecánicas avanzadas de pesca: machacar y pulsación doble (machacar es ahora el remate de los peces tochos en O Penedo)
- [x] Racha de combo por tramos (osu! + Guitar Hero), modo flow más rápido (Leer el agua, ahora en la Maña)
- [x] Pesca tranquila: esperas, picoteos, chill que deja pasar el pez
- [x] ~~Puntos de pesca~~ → el camino pide peces y el puerto rublos (reformateo)
- [x] Racha entre peces: descartada (el combo es de cada pez); más cadenas largas al principio


## Fase 5 — Villa e incremental
- [x] Primer trabajador automático: pescadores del puerto + cubo + venta animada
- [x] Lonja conceptual: ×1,3 a todas las ventas
- [x] Restaurante O Mar (despensa, mejoras, cosecha), turistas en 3 niveles, cultivos con hozazo y chaval, porteador
- [x] Dos alturas (puerto alto sobre pilotes y escaleras)
- [x] Balance del early game con el simulador v4 (cañas de fibra y carbono, combos hasta 25)
- [x] Ayuntamiento: mejora de edificios con un sistema común
- [ ] Tienda de decoración en el ayuntamiento (la decoración sube el atractivo para turistas)
- [x] Taladro de coral y restaurante de sushi
- [x] ~~Cañas rápida y pesada~~ → su carril pasa a Mar de Fóra
- [x] Reformateo: pesca base automática (picar a mano / automática, calidades en vez de especies, ₽/min)
- [x] Spots: O Penedo (mid, minijuego clásico + remate) y Mar de Fóra (late, gigantes en carril 3D tipo Guitar Hero); bordes del puerto, retrete y sofá, cualquier caña vale
- [x] Simulador v5 con la pesca base (llegadas a ±5 % de la v4)
- [ ] Objetivos de coleccionismo por spot (premios por completar)
- [ ] Posición final de los spots en el mapa (el diseñador decide)
- [ ] Plantación de marihuana (mid game)
- [x] Ritmo de pesca en el panel (peces/min y ₽/min)
- [ ] Más stats por segundo (villa entera)
- [ ] Progreso offline (si se decide)
- [x] Balance de curvas del early game y primer tramo del mid game (simulador v5, ~7 h)

## Fase 6 — Contenido
- [x] Catálogo de peces del Excel del diseñador: 201 especies (Galicia + mundo), 6 rarezas, iconos placeholder
- [x] Maestría por especie en el bestiario
- [ ] Bestiario con filtros por zona o fichas compactas (hay 201)
- [ ] Peces que desbloquean edificios (sushi...)
- [ ] Simulador: modelar la marihuana y la decoración antes de meterlas
- [x] Tiempo del juego: día/noche (20 min) y estaciones (2 h), noche con luna, peces por estación y hora
- [ ] Más edificios, ramas e hitos

## Fase 7 — Pulido
- [x] Capturas del juego en `docs/capturas/`
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
