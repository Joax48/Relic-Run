# Relic Run

Aventura top-down 2D inspirada en *Adventure* (Atari, 1980). Encarna a un ladrón de reliquias mágicas que atraviesa tres mundos malditos, evade o enfrenta guardianes, y escapa con el botín antes de que sea demasiado tarde.

---

## Características

| Característica | Detalle |
|---|---|
| Motor | C++17 + SDL2 (propio) |
| Scripting | Lua 5.3 vía Sol2 — toda la lógica de juego en Lua |
| Arquitectura | ECS (Entity-Component-System) + Publicador-Subscriptor |
| Niveles | 3 mundos completos con jefes y enemigos únicos |
| Power-ups | Señuelo · Tiempo lento · Capa de invisibilidad |
| Audio | Música por nivel + efectos de sonido (SDL_mixer) |
| Mapas | Cargados desde `.tmx` (Tiled) vía TinyXML2 |

### Niveles

| # | Mundo | Enemigos | Jefe |
|---|---|---|---|
| 1 | Mazmorra oscura | Slime, Goblin | Goblin Jefe |
| 2 | Bosque encantado | Goblin, Orc, Vampiro, Mimic | Vampiro Jefe |
| 3 | Islas flotantes | Orc, Vampiro | Orc Warlord (Orc3) |

### Enemigos

- **Slime** — se mueve en saltos aleatorios, daño por contacto.
- **Goblin** — patrulla waypoints, persigue al detectar al jugador.
- **Orc** — persecución directa y agresiva, melee de alto daño.
- **Vampiro** — mantiene distancia y dispara proyectiles.
- **Mimic** — se disfraza de reliquia; ataca al acercarse.
- **Jefe final (Orc3)** — carga telegráfica, golpe en área (fase 2), música de batalla.

### Power-ups

| Tecla | Power-up | Efecto | Duración |
|---|---|---|---|
| `1` | Señuelo | Atrae enemigos a un punto fijo del mapa | 8 s |
| `2` | Tiempo lento | Reduce la velocidad de todos los enemigos al 20 % | 5 s |
| `3` | Capa | Invisibilidad total; enemigos no detectan al jugador | 5 s |

---

## Controles

| Tecla | Acción |
|---|---|
| `W A S D` | Mover al personaje (8 direcciones) |
| `J` | Ataque melee |
| `K` | Disparo mágico |
| `1` | Activar Señuelo |
| `2` | Activar Tiempo lento |
| `3` | Activar Capa de invisibilidad |
| `ESC` | Pausar / Reanudar |

---

## Objetivo de cada nivel

1. Recolectar todas las **reliquias** del mapa.
2. Derrotar al **jefe** para liberar la llave dorada.
3. Recoger la **llave** y cruzar el **portal de salida**.

El puntaje se acumula entre niveles. Si el jugador muere, el puntaje retrocede al valor con que entró a ese nivel.

---

## Dependencias

```
libSDL2-dev
libSDL2-image-dev
libSDL2-ttf-dev
libSDL2-mixer-dev
liblua5.3-dev
```

Instalar en Ubuntu/Debian:

```bash
sudo apt install libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libsdl2-mixer-dev liblua5.3-dev
```

---

## Compilar y ejecutar

```bash
cd game_engine
make
./game_engine
```

El binario se genera en `game_engine/game_engine`. No requiere instalación.

---

## Generar documentación Doxygen

```bash
cd game_engine
doxygen Doxyfile
# Abrir docs/html/index.html en el navegador
```

---

## Estructura del proyecto

```
game_engine/
├── makefile
├── Doxyfile
├── assets/
│   ├── audio/          — música y efectos de sonido
│   ├── fonts/          — PressStart2P TTF
│   ├── images/         — sprites y tilesets
│   ├── maps/           — mapas .tmx (Tiled)
│   └── scripts/        — lógica del juego en Lua
├── libs/
│   ├── glm/            — matemáticas header-only
│   ├── lua/            — Lua 5.3
│   └── sol/            — Sol2 (bindings Lua/C++)
└── src/
    ├── AssetManager/   — carga y caché de texturas y fuentes
    ├── AudioManager/   — reproducción de música y SFX
    ├── Binding/        — funciones C++ expuestas a Lua
    ├── Components/     — componentes ECS (header-only)
    ├── ControllerManager/ — teclado y ratón
    ├── ECS/            — núcleo Entity-Component-System
    ├── EventManager/   — sistema de eventos Pub/Sub
    ├── Game/           — bucle principal del juego
    ├── MapLoader/      — carga de mapas .tmx (TinyXML2)
    ├── SceneManager/   — carga y transición de escenas Lua
    ├── Systems/        — sistemas ECS (header-only)
    └── Utils/          — Pool de memoria genérico
```

---

## Autor
Jorge Quiros Anderson - C26161

Desarrollado como proyecto del curso *Creación de Videojuegos* — 2025.

Homenaje a *Adventure* (Warren Robinett, Atari, 1980).
