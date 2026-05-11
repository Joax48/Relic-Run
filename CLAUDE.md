# Relic Run — Game Engine Context

## Qué es este proyecto

Motor de videojuegos 2D escrito en **C++ con SDL2**, con scripting en **Lua via Sol2**.
El juego que corre sobre este motor se llama **Relic Run**: un ladrón de reliquias mágicas
en un mapa top-down abierto, inspirado en Adventure (Atari, 1980).

Arquitectura **ECS (Entity-Component-System)** con patrón **Publicador-Subscriptor**
para eventos (via EventManager).

---

## Cómo compilar y correr

```bash
cd Creacion_Videojuegos/game_engine
make
```

Corre en **Linux**. SDL2 instalado via apt. No sugerir Windows ni WSL.

---

## Estructura real del proyecto

```
Creacion_Videojuegos/
├── game_engine/               ← PROYECTO PRINCIPAL
│   ├── makefile
│   ├── assets/
│   │   ├── fonts/PressStart.ttf
│   │   ├── images/
│   │   │   ├── slime/             ← sprites del slime (CraftPix) ✅
│   │   │   ├── vampire/           ← sprites del vampiro (CraftPix) ✅
│   │   │   ├── orc_warrior.png    ← sprite del orc (CraftPix) ✅
│   │   │   ├── player.png         ← jugador PixelLab 272×272 ✅
│   │   │   ├── background.png, barrier_gem.png  ← prueba
│   │   │   ├── frog_*.png         ← prueba (ignorar)
│   │   │   ├── Enemy_Alan.png, Player_Ship.png  ← prueba (ignorar)
│   │   │   └── [goblin/, golem/]  ← pendiente de agregar
│   │   └── scripts/
│   │       ├── scenes.lua             ← registro de escenas
│   │       ├── scene_menu.lua         ← menú principal
│   │       ├── scene_level_01.lua     ← nivel 1 (mazmorra) ✅
│   │       ├── scene_01.lua           ← prueba (ignorar)
│   │       ├── scene_02.lua           ← prueba (ignorar)
│   │       ├── player_level01.lua     ← jugador activo ✅
│   │       ├── player.lua             ← prueba (ignorar)
│   │       ├── player_frog.lua        ← prueba (ignorar)
│   │       ├── projectile.lua         ← proyectil del jugador ✅
│   │       ├── relic.lua              ← reliquia recolectable ✅
│   │       ├── portal.lua             ← portal de salida ✅
│   │       ├── hud.lua                ← score y HUD en pantalla ✅
│   │       ├── powerup_cloak.lua      ← power-up invisibilidad ✅
│   │       ├── powerup_decoy.lua      ← power-up señuelo ✅
│   │       ├── powerup_timeslow.lua   ← power-up tiempo lento ✅
│   │       ├── enemy_alan.lua         ← prueba (ignorar)
│   │       ├── enemy_dragon.lua       ← dragón boss ✅
│   │       ├── enemy_mimic.lua        ← mimic (cofre falso) ✅
│   │       ├── enemy_skeleton_base.lua ← skeleton base ✅
│   │       ├── enemy_skeleton_mage.lua ← skeleton mage ✅
│   │       ├── menu_button01.lua      ← botón menú
│   │       └── menu_button02.lua      ← botón menú
│   ├── libs/
│   │   ├── glm/               ← matemáticas header-only
│   │   ├── lua/               ← lua.h, lauxlib.h, etc.
│   │   └── sol/               ← sol.hpp (bindings Lua)
│   └── src/
│       ├── main.cpp
│       ├── AssetManager/      ← AssetManager.hpp + .cpp
│       ├── Binding/
│       │   └── LuaBinding.hpp ← ARCHIVO CLAVE: funciones C++ expuestas a Lua
│       ├── Components/        ← todos header-only
│       ├── ControllerManager/ ← ControllerManager.hpp + .cpp
│       ├── ECS/               ← ECS.hpp + ECS.cpp
│       ├── EventManager/      ← Event.hpp + EventManager.hpp
│       ├── Events/            ← ClickEvent.hpp + CollisionEvent.hpp
│       ├── Game/              ← Game.hpp + Game.cpp
│       ├── SceneManager/      ← SceneLoader.hpp/.cpp + SceneManager.hpp/.cpp
│       ├── Systems/           ← todos header-only
│       └── Utils/Pool.hpp
├── lua_test/                  ← ignorar
└── sdl_intro/                 ← ignorar
```

---

## Cómo funciona el ScriptSystem — LEER CON ATENCIÓN

Las funciones Lua que el motor llama son: `on_awake`, `update`, `on_click`, `on_collision`.
**NO son `OnStart`, `OnUpdate`, etc. — son minúsculas con underscore.**

Cada entidad con `ScriptComponent` tiene su propio archivo `.lua`.
El motor carga el archivo, llama `on_awake()` inmediatamente al crear la entidad,
y guarda `update`, `on_click`, `on_collision` en el `ScriptComponent` para llamarlos después.

```lua
-- Estructura obligatoria de un script de entidad
function on_awake()
    -- se llama UNA VEZ al crear la entidad
    -- aquí se puede inicializar estado local
end

function update(dt)
    -- se llama CADA FRAME
    -- dt está disponible como parámetro
end

function on_collision(other)
    -- other es la Entity con la que colisionó
    -- usar get_tag(other) para identificarla
end

function on_click()
    -- se llama cuando se hace click (solo para entidades clickables)
end
```

**Importante:** `this` es una variable global Lua que apunta a la entidad dueña del script.
Se setea antes de llamar `on_awake`. En `update` y `on_collision` también está disponible.

---

## Cómo se define una escena Lua — estructura EXACTA

Las escenas son tablas Lua con esta estructura (ver scene_01.lua como referencia):

```lua
scene = {
    sprites = {
        [0] = {assetId = "my-texture", filePath = "./assets/images/file.png"},
        {assetId = "other", filePath = "./assets/images/other.png"},
        -- índice base 0, continúa sin índice explícito
    },
    fonts = {
        [0] = {fontId = "press_start_24", filePath = "./assets/fonts/PressStart.ttf", fontSize = 24},
    },
    keys = {
        [0] = {name = "UP",    key = 119},  -- SDLK_w
                {name = "LEFT",  key = 97},   -- SDLK_a
                {name = "DOWN",  key = 115},  -- SDLK_s
                {name = "RIGHT", key = 100},  -- SDLK_d
    },
    buttons = {
        [0] = {name = "SHOOT", button = 1},  -- SDL_BUTTON_LEFT
    },
    entities = {
        [0] = {
            components = {
                transform = {
                    position = {x = 400.0, y = 300.0},
                    scale    = {x = 2.0,   y = 2.0},
                    rotation = 0.0,
                },
                sprite = {
                    assetId  = "my-texture",
                    width    = 16,
                    height   = 16,
                    src_rect = {x = 0, y = 0},  -- offset en el spritesheet
                },
                rigid_body = {
                    is_dynamic = false,
                    is_solid   = false,
                    mass       = 1,
                },
                box_collider = {
                    width  = 32,
                    height = 32,
                    offset = {x = 0, y = 0},
                },
                animation = {
                    num_frames = 4,
                    speed_rate = 10,
                    is_loop    = true,
                },
                tag = {tag = "player"},
                camera_follow = {},     -- sin parámetros
                clickable     = {},     -- sin parámetros
                script = {
                    path = "./assets/scripts/player.lua",
                },
                text = {
                    text   = "Score: 0",
                    fontId = "press_start_24",
                    r = 255, g = 255, b = 255, a = 255,
                },
            }
        },
    }
}
```

**Notas críticas del SceneLoader:**
- Los arrays en Lua empiezan en `[0]` (no `[1]`) — el loader itera con índice 0 en adelante
- `src_rect` en sprite = offset en píxeles dentro del spritesheet (fila/columna × tamaño)
- `rigid_body` tiene `is_dynamic`, `is_solid`, `mass` — NO `velocity`
- Si un componente no es necesario, simplemente no se incluye en la tabla

---

## Bindings Lua disponibles — los REALES (LuaBinding.hpp)

Estas son TODAS las funciones C++ expuestas a Lua actualmente:

```lua
-- Input
is_action_activated("ACTION")  -- bool, nombre definido en keys[] de la escena

-- RigidBodyComponent
local vx, vy = get_velocity(entity)
set_velocity(entity, vx, vy)

-- TagComponent
local tag = get_tag(entity)    -- string

-- TransformComponent
local x, y = get_position(entity)
set_position(entity, x, y)
local w, h = get_size(entity)
-- get_size: si tiene SpriteComponent → width*scaleX, height*scaleY
--           si solo tiene BoxCollider → collider.width, collider.height

-- Colisiones direccionales (usar en on_collision)
left_collision(entity, other)   -- bool: other está a la izquierda de entity
right_collision(entity, other)  -- bool: other está a la derecha de entity
up_collision(entity, other)     -- bool: other está arriba de entity
down_collision(entity, other)   -- bool: other está abajo de entity
-- Usan previousPosition para determinar dirección

-- Entidades en runtime
local proj = spawn_projectile(x, y, vx, vy)
-- Crea entidad con: Transform(x,y,scale=2), Sprite("projectile",8,8),
--                  RigidBody(vel=vx/vy), BoxCollider(16,16), Tag("projectile")
-- Carga automáticamente: ./assets/scripts/projectile.lua
-- Devuelve la entidad creada

local melee = spawn_melee(x, y, w, h)
-- Crea hitbox invisible: Transform(x,y), BoxCollider(w,h), Tag("player_melee")
-- SIN sprite, SIN script — solo colisión
-- Devuelve la entidad creada (para matarla después con kill_entity)

kill_entity(entity)
-- Destruye la entidad del registro en el próximo Update()

-- Escenas
go_to_scene("nombre_escena")   -- nombre registrado en scenes.lua
```

**Notas importantes del código real:**
- `spawn_projectile` guarda y restaura `lua["this"]` — seguro llamarlo desde cualquier script
- `spawn_melee` NO carga script — es solo una hitbox, su lógica se maneja desde el script que lo creó
- El proyectil se destruye solo al colisionar con cualquier tag que NO sea `"player"`, `"projectile"` o `"player_melee"` — ver `projectile.lua`
- Para agregar binding nuevo: función C++ en `LuaBinding.hpp` → registrar en `ScriptSystem::CreateLuaBinding()` → `make`

**Lo que NO existe como binding todavía:**
- Acceso o modificación de AnimationComponent desde Lua
- Cambiar sprite/src_rect desde Lua en runtime
- Cualquier cosa de audio (SDL_mixer pendiente)
- Crear entidades genéricas desde Lua (solo projectile y melee tienen spawn dedicado)

---

## Game loop — orden de ejecución

```
Game::Run()
  └─ SetUp()         — registra sistemas, carga scenes.lua, abre librerías Lua
  └─ loop:
       SceneManager::StartScene()   — carga la escena actual
       RunScene():
         └─ SceneManager::LoadScene()   — llama SceneLoader, crea entidades
         └─ loop mientras escena corra:
              ProcessInput()    — SDL events → ControllerManager
              Update():
                eventManager->Reset()
                OverlapSystem::SubscribeToCollisionEvent()
                UISystem::SubscribeToClickEvent()
                registry->Update()           — agrega/elimina entidades pendientes
                ScriptSystem::Update(lua)    — llama update(dt) de cada entidad
                PhysicsSystem::Update()
                MovementSystem::Update(dt)
                BoxCollisionSystem::Update()
                CircleCollisionSystem::Update()
                AnimationSystem::Update()
                CameraMovementSystem::Update()
              Render():
                RenderSystem::Update()
                RenderTextSystem::Update()
         └─ assetManager->ClearAssets()
         └─ registry->ClearAllEntities()
```

**Notas:**
- `DamageSystem` está comentado — no se usa
- `ScriptSystem` corre ANTES que Physics y Movement — tener en cuenta para velocidades
- Al cambiar escena: se limpian assets y entidades, luego se carga la nueva

---

## Componentes implementados

| Componente | Parámetros del constructor |
|---|---|
| `TransformComponent` | `glm::vec2 position, glm::vec2 scale, float rotation` |
| `RigidBodyComponent` | `bool is_dynamic, bool is_solid, float mass` |
| `SpriteComponent` | `string assetId, int w, int h, int srcX, int srcY` |
| `AnimationComponent` | `int numFrames, int speedRate, bool isLoop` |
| `BoxColliderComponent` | `int w, int h, glm::vec2 offset` |
| `CircleColliderComponent` | `int radius, int w, int h` |
| `ScriptComponent` | `sol::function update, on_click, on_collision` |
| `TagComponent` | `string tag` |
| `TextComponent` | `string text, string fontId, int r, g, b, a` |
| `ClickableComponent` | _(sin parámetros)_ |
| `CameraFollowComponent` | _(sin parámetros)_ |

---

## Sistemas implementados

| Sistema | Cuándo se llama |
|---|---|
| `ScriptSystem` | `Update(lua)` — llama `update(dt)` de cada entidad con script |
| `MovementSystem` | `Update(dt)` — aplica RigidBody.velocity a Transform.position |
| `PhysicsSystem` | `Update()` — física básica |
| `BoxCollisionSystem` | `Update(lua, eventManager)` — AABB + resolución + emite CollisionEvent |
| `CircleCollisionSystem` | `Update(eventManager)` |
| `OverlapSystem` | suscrito a CollisionEvent — overlap sin resolución |
| `AnimationSystem` | `Update()` — avanza frames |
| `RenderSystem` | `Update(renderer, camera, assetManager)` |
| `RenderTextSystem` | `Update(renderer, assetManager)` |
| `CameraMovementSystem` | `Update(camera)` |
| `UISystem` | suscrito a ClickEvent |
| `DamageSystem` | **comentado — no activo** |

---

## Pendiente de implementar

### 1. Carga de mapas con Tiled + TinyXML2
Diseñar mapas en Tiled, exportar como `.tmx`, cargar con TinyXML2 en C++.
Implementar de la forma que tenga más sentido integrándose con el SceneLoader existente.
Exponer a Lua si es necesario. Assets de mapas en `assets/maps/`.

### 2. AnimationManager con estados
`AnimationComponent` básico existe. Si manejar múltiples animaciones
(idle, walk, attack) desde Lua se vuelve complejo, implementar soporte
de estados en C++. Usar criterio propio.

### 3. Audio — SDL_mixer
Único módulo C++ nuevo requerido por el enunciado.
- Clase `AudioManager` siguiendo patrón de `AssetManager`
- Inicializar SDL_mixer en `Game::Init()`
- Bindings Lua: `play_music(file, loop)`, `stop_music()`, `play_sfx(file)`
- Assets en `assets/sounds/`

---

## El juego: Relic Run

### Concepto
Un aventurero atraviesa tres mundos malditos en busca de reliquias antiguas.
Cada mundo tiene sus propios guardianes — familias de enemigos con variantes
de distinta fuerza, velocidad y comportamiento. El jugador puede pelear o esquivar.
Inspirado en Adventure (1980, Warren Robinett): mapa abierto, reliquias para
recolectar, enemigos que podés evitar o enfrentar.

Las armas cambian entre niveles — cada mundo tiene armas temáticas propias.
Da progresión sin necesitar inventario complejo.

### Narrativa implícita
Nivel 1 (Mazmorra) → Nivel 2 (Bosque encantado) → Nivel 3 (Cementerio maldito).
Cada nivel escala en peligro y los enemigos se vuelven más variados.

### Niveles y assets

**Nivel 1 — Mazmorra oscura**
- Tileset: buscar tileset dungeon top-down gratis en `free-game-assets.itch.io`
- Enemigos normales: Slime + Goblin
- Mini-boss: **Goblin Jefe** — guarda la reliquia principal, más HP y más grande
- Objetivo: recolectar 5 reliquias normales + derrotar al Goblin Jefe → portal de salida
- Mecánica especial: ninguna — nivel de aprendizaje, el jugador aprende los controles
- Duración estimada: ~2 minutos

**Nivel 2 — Bosque oscuro**
- Tileset: buscar tileset forest/woods top-down gratis en `free-game-assets.itch.io`
- Enemigos normales: Goblin + Orc + Vampiro (dispara) + Mimic (disfrazado de reliquia)
- Mini-boss: **Golem** — guardián del bosque, lento pero devastador, ataque en área
- Objetivo: recolectar 4 reliquias reales (cuidado con los Mimics) + derrotar al Golem → portal
- Mecánica especial: Mimic aparece mezclado con reliquias reales — el jugador no sabe cuál es cuál
- Duración estimada: ~2.5 minutos

**Nivel 3 — Cementerio maldito**
- Tileset: `free-game-assets.itch.io/free-undead-tileset-top-down-pixel-art` (ya encontrado, gratis)
- Enemigos normales: Slime (versión rápida) + Orc + Vampiro + Mimic
- Boss final: **Dragón** — patrulla central, escupe fuego, ataque especial al 50% HP
- Objetivo: encontrar la reliquia del Dragón + derrotarlo → portal de escape + contrarreloj
- Mecánica especial: contrarreloj visible desde que se activa el portal — presión de tiempo
- Duración estimada: ~3 minutos

**Tilesets a buscar (todos gratis en free-game-assets.itch.io o similar):**
- Dungeon/mazmorra 16×16 top-down
- Forest/bosque oscuro 16×16 top-down  
- Undead/cementerio: ya tenés el link ✅

**Gemas/reliquias:** buscar "free pixel art gem icon" o similar — CC0 preferido

### Enemigos — comportamiento detallado

Todos los assets son de CraftPix (mismo estilo visual garantizado).
Cada enemigo tiene su script Lua con variables de HP, velocidad y daño.
La lógica de IA se implementa una vez por tipo y se reutiliza entre niveles.

---

**Slime** | Tag: `"slime"` | Asset: gratis CraftPix
- Se mueve en saltos aleatorios por el mapa — elige dirección random cada 1-2 segundos
- NO persigue al jugador activamente — solo rebota por el área
- Al colisionar con el jugador hace daño de contacto
- Es el enemigo más predecible — fácil de esquivar si lo observás
- Aparece en: Nivel 1, Nivel 3 (versión más rápida)
- HP: 1 | Velocidad: lento | Daño: bajo | Puntos: +10

---

**Goblin** | Tag: `"goblin"` | Asset: $0.70 CraftPix
- Patrulla una ruta fija de waypoints definida en la escena Lua
- Al detectar al jugador (rango configurable) abandona la ruta y persigue
- Ataca en melee cuando está adyacente al jugador
- Si el jugador se aleja suficiente, vuelve a su ruta
- Aparece en: Nivel 1, Nivel 2
- HP: 2 | Velocidad: medio | Daño: medio | Puntos: +20

**Goblin Jefe (Mini-boss Nivel 1)** | Tag: `"goblin_boss"`
- Mismo sprite que el Goblin pero más grande (scale 2x) y diferente color si es posible
- Más HP y más rápido que el Goblin normal
- Guarda la reliquia principal del nivel 1 — patrulla alrededor de ella
- Al morir: aparece la reliquia final y se activa el portal de salida
- HP: 6 | Velocidad: medio-rápido | Daño: alto | Puntos: +80

---

**Orc** | Tag: `"orc"` | Asset: gratis CraftPix
- Persigue al jugador activamente desde que lo detecta — no tiene ruta fija
- Más lento que el Goblin pero más resistente y hace más daño
- No dispara — es puramente melee agresivo
- Difícil de esquivar en espacios cerrados
- Aparece en: Nivel 2, Nivel 3
- HP: 3 | Velocidad: medio | Daño: alto | Puntos: +25

---

**Vampiro** | Tag: `"vampire"` | Asset: gratis CraftPix
- **ÚNICO ENEMIGO QUE DISPARA** — lanza proyectiles de energía oscura
- Mantiene distancia del jugador — huye si el jugador se acerca demasiado
- Dispara en la dirección del jugador cada N segundos (cooldown configurable)
- Sus proyectiles usan el mismo sistema que `spawn_projectile` pero con tag `"enemy_projectile"`
- El jugador debe esquivar activamente o usar power-up
- Aparece en: Nivel 2, Nivel 3
- HP: 2 | Velocidad: rápido | Daño proyectil: medio | Puntos: +35

---

**Mimic** | Tag: `"mimic"` | Asset: sprite de reliquia/cofre (sin costo extra)
- Se disfraza visualmente como una reliquia normal en el suelo
- Usa el mismo sprite que las reliquias reales — el jugador NO puede distinguirlo
- Implementado con OverlapSystem: cuando el jugador se acerca a cierto radio, "despierta"
- Al despertar: cambia el sprite al de Goblin o Vampiro y ataca inmediatamente
- La sorpresa es el arma principal — hace daño directo al activarse
- El jugador aprende a ser cauteloso con todas las reliquias
- Aparece en: Nivel 2 y Nivel 3 (nunca en nivel 1 para que el jugador aprenda primero)
- HP: 2 | Velocidad: rápido al activarse | Daño: alto (sorpresa) | Puntos: +50

---

**Golem** | Tag: `"golem"` | Asset: $0.70 CraftPix
- **Mini-boss Nivel 2** — ocupa el centro del mapa, guarda las reliquias principales
- Patrulla un área pequeña alrededor de su zona
- Muy lento pero con mucho HP y daño devastador en melee
- Tiene un ataque especial de golpe en área (shockwave) cada N segundos
  — el jugador debe alejarse al ver la animación de carga
- Al morir: aparece la reliquia final del nivel 2
- HP: 8 | Velocidad: muy lento | Daño: muy alto | Puntos: +100

---

**Dragón** | Tag: `"dragon"` | Asset: PixelLab (mismo estilo que el jugador)
- **Boss final Nivel 3** — el enemigo más poderoso del juego
- Patrulla la zona central del cementerio en un círculo grande
- Ataque 1: escupe fuego en línea recta en la dirección del jugador
  — proyectil lento pero que persiste en el mapa 2-3 segundos
- Ataque 2: gira y escupe en las 4 direcciones simultáneamente (ataque especial)
  — se activa cuando baja al 50% de HP
- Al detectar al jugador cerca: carga hacia él en sprint corto
- Al morir: aparece la reliquia final y se activa el portal de escape + contrarreloj
- HP: 12 | Velocidad: lento/sprint | Daño: muy alto | Puntos: +200

---

### Assets confirmados

| Enemigo | Asset | Costo |
|---|---|---|
| Slime | CraftPix freebie | $0 |
| Goblin + Goblin Boss | CraftPix | $0.70 |
| Orc | CraftPix freebie | $0 |
| Vampiro | CraftPix freebie | $0 |
| Mimic | Sprite de reliquia (reutilizado) | $0 |
| Golem | CraftPix | $0.70 |
| Dragón | PixelLab (~3 generaciones) | $0 |
| Jugador | PixelLab (ya generado) | $0 |

**Total: $1.40**

### Mecánica de proyectiles enemigos
El Vampiro usa `spawn_projectile` con tag `"enemy_projectile"`.
El proyectil del jugador ignora `"enemy_projectile"` — no se cancelan entre sí.
El jugador recibe daño al colisionar con `"enemy_projectile"`.
Agregar este tag a la lista de ignorados en `projectile.lua` del jugador.

### Patrón de implementación en Lua
```lua
-- goblin.lua — variables configurables por tipo
local HP = 2
local SPEED = 100
local DAMAGE = 1
local POINTS = 20
local DETECTION_RANGE = 150  -- píxeles para detectar al jugador
local ATTACK_RANGE = 32      -- píxeles para atacar en melee
local PATROL_WAYPOINTS = {}  -- definidos en on_awake desde la escena
```

### Power-ups
| Tag | Efecto | Duración |
|---|---|---|
| `"powerup_cloak"` | Invisibilidad total — enemigos no detectan al jugador | 5s |
| `"powerup_decoy"` | Señuelo — atrae todos los enemigos a un punto del mapa | 8s |
| `"powerup_time"` | Todo al 20% velocidad excepto el jugador | 5s |

### Scripts de juego existentes
- `player_level01.lua` — movimiento 8-dir, melee (ATTACK), disparo (SHOOT),
  colisión con paredes, facing direction ✅
- `projectile.lua` — se destruye al colisionar con cualquier tag que no sea
  `"player"`, `"projectile"` o `"player_melee"` ✅

### Easter egg
Trigger de 1×1 con sprite transparente en nivel 1 (OverlapSystem).
Al tocarlo: sala secreta con nombre del desarrollador.
Homenaje directo a Warren Robinett, Adventure (1980).

---

## Convenciones del proyecto

- **C++:** PascalCase (`BoxColliderComponent.hpp`, `SceneLoader.cpp`)
- **Lua scripts:** snake_case (`scene_01.lua`, `enemy_slime.lua`)
- **Asset IDs:** kebab-case string (`"player-idle"`, `"tileset-forest"`)
- **Tags de entidades:** snake_case (`"player"`, `"slime"`, `"relic"`, `"wall"`)
- **Funciones Lua binding:** snake_case (`set_velocity`, `go_to_scene`)
- **Funciones en scripts Lua:** snake_case (`on_awake`, `update`, `on_collision`)
- **Sistemas y Componentes:** siempre header-only
- **Toda lógica del juego en Lua** — C++ solo para SDL y motor

## NO hacer

- No hardcodear rutas absolutas — usar `./assets/...` relativo
- No crear lógica de juego en C++ — todo en Lua
- No tocar `lua_test/` ni `sdl_intro/`
- No agregar dependencias externas sin necesidad real

---

## Plan de implementación — orden de trabajo

El objetivo es llegar a un juego jugable lo antes posible.
**Compilar y probar después de cada tarea antes de avanzar.**
Si algo no compila, resolver antes de continuar.

---

### FASE 1 — Jugador y mundo base ✅ COMPLETADA

**Tarea 1** ✅ — `scene_level_01.lua` con mapa, jugador, cámara
**Tarea 2** ✅ — Melee + disparo, `spawn_melee`, `spawn_projectile`, `kill_entity`
  - `player_level01.lua`: movimiento 8-dir, facing direction, melee (ATTACK), disparo (SHOOT)
  - `projectile.lua`: se destruye con cualquier tag excepto player/projectile/player_melee

---

### FASE 2 — Enemigos ✅ COMPLETADA

**Tarea 3** ✅ — Score y HUD → `hud.lua`
**Tarea 4** ✅ — Slime → movimiento aleatorio por saltos
**Tarea 5** ✅ — Skeleton → `enemy_skeleton_base.lua` + `enemy_skeleton_mage.lua`
**Tarea 6** ✅ — Mimic → `enemy_mimic.lua` (disfrazado de reliquia, ataca al acercarse)
**Tarea 7** ✅ — Dragón → `enemy_dragon.lua` (patrulla, escupe fuego)

**Enemigos pendientes de script** (implementar cuando se agreguen los sprites):
- `enemy_goblin.lua` + `enemy_goblin_boss.lua` — sprites goblin/ pendiente
- `enemy_orc.lua` — sprite orc_warrior.png ✅ ya está
- `enemy_vampire.lua` — sprites vampire/ ✅ ya están
- `enemy_golem.lua` — sprites golem/ pendiente

---

### FASE 3 — Reliquias y victoria ✅ COMPLETADA

**Tarea 8** ✅ — `relic.lua` + `portal.lua` — recolección y condición de victoria
**Tarea 9** ✅ — Sistema de pausa

---

### FASE 4 — Power-ups ✅ COMPLETADA

**Tarea 10** ✅ — `powerup_cloak.lua` — invisibilidad 5s
**Tarea 11** ✅ — `powerup_decoy.lua` — señuelo 8s
**Tarea 12** ✅ — `powerup_timeslow.lua` — tiempo lento 5s

---

### FASE 5 — Niveles 2 y 3 🔄 EN PROGRESO

**Tarea 13 — Nivel 2: Bosque oscuro** 🔄 EN PROGRESO
- Crear `scene_level_02.lua`
- Enemigos: Goblin + Orc + Vampiro + Mimic
- Mini-boss: Golem (guarda la reliquia principal)
- Mecánica especial: Mimic mezclado con reliquias reales
- Tileset: buscar forest top-down gratis en free-game-assets.itch.io

**Tarea 14 — Nivel 3: Cementerio maldito** ⏳ PENDIENTE
- Crear `scene_level_03.lua`
- Enemigos: Slime rápido + Orc + Vampiro + Mimic
- Boss final: Dragón (dos fases — ataque especial al 50% HP)
- Mecánica especial: contrarreloj al activar portal
- Tileset: `free-game-assets.itch.io/free-undead-tileset-top-down-pixel-art`

---

### FASE 6 — Audio, menú y pulido

**Tarea 15 — AudioManager (SDL_mixer)**
- Crear `src/AudioManager/AudioManager.hpp` y `.cpp`
- Inicializar en `Game::Init()`
- Bindings: `play_music(file, loop)`, `stop_music()`, `play_sfx(file)`
- Agregar música de fondo por nivel y efectos: golpe, recolección, muerte

**Tarea 16 — Menú principal**
- `scene_menu.lua` ya existe — completarlo
- Botones: Nivel 1, Nivel 2, Nivel 3 (cualquier nivel accesible)
- Música del menú

**Tarea 17 — Tiled + TinyXML2**
- Implementar carga de mapas `.tmx` para reemplazar mapas hardcodeados en Lua
- Hacer esto al final cuando los niveles ya estén funcionando
- Rediseñar los mapas en Tiled con el tileset final

**Tarea 18 — Easter egg**
- Agregar trigger 1×1 invisible en nivel 1 (esquina de un árbol)
- OverlapSystem → carga sala secreta `scene_easter_egg.lua`
- Texto con nombre del desarrollador en estilo runa

---

### FASE 7 — Animaciones (si hay tiempo)

**Tarea 19 — AnimationManager**
- Evaluar si `AnimationComponent` básico es suficiente o se necesitan estados
- Si se implementa: estados nombrados (`"idle"`, `"walk"`, `"attack"`)
- Binding: `set_animation(entity, "walk")`

---

## Orden de prioridad si el tiempo se acaba

Si el tiempo es muy reducido, el juego mínimo aceptable para el enunciado es:

1. ✅ Tareas 1–4 — jugador + slime + score (jugable)
2. ✅ Tareas 5–8 — resto de enemigos + reliquias + victoria
3. ✅ Tarea 9 — pausa
4. ✅ Tareas 10–12 — power-ups
5. ✅ Tareas 13–14 — niveles 2 y 3
6. ✅ Tarea 15 — audio (requerido por enunciado)
7. ✅ Tarea 16 — menú
8. ⚡ Tareas 17–19 — Tiled, easter egg, animaciones (si hay tiempo)

---

## Cómo trabajar con Claude Code eficientemente

- **Una tarea a la vez.** Decile el número de tarea y qué hacer.
- **Compilar siempre antes de pedir la siguiente tarea.**
- **Si hay error de compilación:** pegar el error exacto y pedir que lo corrija.
- **Si falta un binding:** pedirle que lo agregue a `LuaBinding.hpp` primero.
- **Al inicio de cada sesión nueva:** decile "leé el CLAUDE.md" para que retome contexto.
- **Prompt recomendado para empezar:**
  > "Leé el CLAUDE.md. Vamos a implementar la Tarea 1: escena base del nivel 1.
  >  Leé también `src/Binding/LuaBinding.hpp` y `assets/scripts/scene_01.lua`
  >  antes de escribir cualquier código."
