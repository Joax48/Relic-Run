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
│   │   ├── images/            ← sprites de prueba (se reemplazarán)
│   │   └── scripts/           ← TODA la lógica del juego va aquí
│   │       ├── scenes.lua         ← registro de escenas (cargado al inicio)
│   │       ├── scene_menu.lua
│   │       ├── scene_01.lua
│   │       ├── scene_02.lua
│   │       ├── player.lua / player_frog.lua
│   │       ├── enemy_alan.lua
│   │       ├── menu_button01.lua / menu_button02.lua
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
- Tileset: Pack gratuito Anokolisa (`anokolisa.itch.io/dungeon-crawler-pixel-art-asset-pack`)
- Objetivo: recolectar 6 reliquias y llegar al portal de salida
- Enemigos: familia Skeleton + familia Orc
- Armas: armas base del pack gratuito

**Nivel 2 — Bosque encantado**
- Tileset: Pixel Crawler - Fairy Forest ($5) (`anokolisa.itch.io/pixel-crawler-ff`)
- Objetivo: conseguir 3 llaves élficas → robar reliquias → escapar
- Enemigos: familia Elf
- Armas: armas élficas (upgrade del nivel 1)

**Nivel 3 — Cementerio maldito**
- Tileset: Pixel Crawler - Cemetery ($7.50) (`anokolisa.itch.io/pixel-crawler-cemetery`)
- Objetivo: encontrar la reliquia del dragón + escapar (contrarreloj visible)
- Enemigos: familia Zombie + Dragón jefe
- Armas: armas malditas (upgrade del nivel 2)

Assets adicionales:
- **Dragón jefe** ($3): `xzany.itch.io/dragon-2d-pixel-art` — 6 animaciones, sprite 48×64px
- **Gemas/reliquias** (gratis CC0): greatdocbrown — Coins & Gems & Chests
- Gasto total estimado: ~$15.50

### Familias de enemigos — variantes y fuerza

Cada variante tiene distinto HP, velocidad y daño configurado en su script Lua.
La lógica de IA es compartida por familia — solo cambian las variables numéricas.

**Familia Skeleton — Nivel 1** | Animaciones: Death, Run, Idle
Comportamiento base: patrullan ruta fija, atacan melee al acercarse.

| Tag | Variante | HP | Velocidad | Comportamiento especial | Puntos |
|---|---|---|---|---|---|
| `"skeleton_base"` | Base | 1 | lento | ninguno | +10 |
| `"skeleton_mage"` | Mage | 1 | lento | dispara proyectil | +20 |
| `"skeleton_warrior"` | Warrior | 2 | medio | más daño melee | +25 |
| `"skeleton_rogue"` | Rogue | 1 | rápido | se acerca más rápido | +20 |

**Familia Orc — Nivel 1** | Animaciones: Death, Run, Idle
Comportamiento base: persiguen al jugador al detectarlo, más agresivos.

| Tag | Variante | HP | Velocidad | Comportamiento especial | Puntos |
|---|---|---|---|---|---|
| `"orc_base"` | Base | 2 | medio | ninguno | +15 |
| `"orc_mage"` | Mage | 1 | lento | dispara hechizo de área | +30 |
| `"orc_warrior"` | Warrior | 3 | lento | muy alto daño melee | +35 |
| `"orc_rogue"` | Rogue | 2 | muy rápido | persigue sin parar | +25 |

**Familia Elf — Nivel 2** | Animaciones: Death, Run, Idle, Hit
Comportamiento base: patrullan, atacan a distancia.

| Tag | Variante | HP | Velocidad | Comportamiento especial | Puntos |
|---|---|---|---|---|---|
| `"elf_base"` | Base | 1 | medio | melee corto | +15 |
| `"elf_ranger"` | Ranger | 2 | medio | proyectil rápido a distancia | +30 |
| `"elf_hunter"` | Hunter | 1 | rápido | proyectil + se mueve mientras dispara | +35 |
| `"elf_druid"` | Druid | 2 | lento | hechizo lento pero de área | +40 |

**Familia Zombie — Nivel 3** | Animaciones: Death, Run, Idle, Hit
Comportamiento base: lentos pero resistentes, se mueven en grupos.

| Tag | Variante | HP | Velocidad | Comportamiento especial | Puntos |
|---|---|---|---|---|---|
| `"zombie_base"` | Base | 2 | muy lento | ninguno | +15 |
| `"zombie_muscle"` | Muscle | 4 | lento | muy alto daño | +30 |
| `"zombie_deformed"` | Deformed | 3 | medio | errático, difícil de esquivar | +25 |
| `"zombie_banshee"` | Banshee | 1 | lento | grita atrayendo zombies cercanos | +20 |

**Dragón — Jefe final Nivel 3** | Animaciones: Idle, Run, Attack1, Attack2, Hurt, Death

| Tag | HP | Velocidad | Comportamiento | Puntos |
|---|---|---|---|---|
| `"dragon"` | 10 | lento | patrulla zona central, escupe fuego en línea recta | +150 |

Al morir el dragón aparece la reliquia final y se activa el portal de escape.

### Patrón de implementación en Lua para variantes

```lua
-- skeleton_warrior.lua — solo cambia variables, lógica igual que skeleton_base.lua
local HP = 2
local SPEED = 80
local DAMAGE = 2
local POINTS = 25
-- require o copiar lógica de patrulla/detección compartida
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

### FASE 1 — Jugador y mundo base (prioridad máxima)

**Tarea 1 — Escena base del nivel 1** ✅ COMPLETADA
- `scene_level_01.lua` con mapa, jugador, cámara

**Tarea 2 — Ataque del jugador** ✅ COMPLETADA
- Melee con `spawn_melee` + `kill_entity` (hitbox temporal, MELEE_DURATION=0.15s)
- Disparo con `spawn_projectile` (PROJ_SPEED=350, cooldown=0.35s)
- Bindings implementados: `spawn_projectile`, `spawn_melee`, `kill_entity`
- Scripts: `player_level01.lua`, `projectile.lua`
- Facing direction implementado (horizontal tiene prioridad sobre vertical)
- Teclas: ATTACK=melee, SHOOT=disparo

**Tarea 3 — Score y HUD**
- TextComponent en pantalla con score actual (fijo, no sigue cámara)
- Variable global Lua `score` accesible desde cualquier script
- Binding para actualizar el texto desde Lua: `set_text(entity, string)`

---

### FASE 2 — Enemigos (uno a la vez, en orden de complejidad)

**Tarea 4 — Slime**
- `assets/scripts/enemy_slime.lua`
- Movimiento: cada N segundos elige dirección aleatoria y salta
- Al recibir daño (colisión con proyectil o melee): reduce HP, muere si llega a 0
- Al morir: suma +10 al score, se destruye
- Binding necesario: `kill_entity(entity)` o usar el existente

**Tarea 5 — Arquero esqueleto**
- `assets/scripts/enemy_archer.lua`
- Patrulla ruta fija definida en el script (lista de waypoints)
- Si el jugador entra en rango de visión: dispara proyectil hacia él
- Al morir: +25 score

**Tarea 6 — Mimic**
- `assets/scripts/enemy_mimic.lua`
- Spawn con sprite de reliquia (disfrazado)
- Al solapar con jugador (OverlapSystem): cambia a sprite de enemigo y ataca
- Es el más sorpresivo — colocarlo cerca de reliquias reales
- Al morir: +50 score

**Tarea 7 — Dragón**
- `assets/scripts/enemy_dragon.lua`
- Patrulla zona central del nivel 3
- Cada N segundos escupe proyectil de fuego en línea recta
- Más HP que los demás
- Al morir: +100 score

---

### FASE 3 — Mecánica de reliquias y condición de victoria

**Tarea 8 — Reliquias y llave**
- Entidad "reliquia" con OverlapSystem — al tocarla el jugador la recoge
- Contador de reliquias en HUD
- Portal de salida: solo activo cuando se tienen todas las reliquias
- Al entrar al portal: `go_to_scene("level_02")` o pantalla de victoria

**Tarea 9 — Sistema de pausa**
- Tecla ESC pausa el juego (mostrar texto "PAUSA" en pantalla)
- El game loop no llama Update() mientras está pausado
- Esto requiere un flag en Game.cpp o manejarlo desde Lua

---

### FASE 4 — Power-ups

**Tarea 10 — Capa de invisibilidad**
- Entidad con sprite de power-up, OverlapSystem
- Al recogerlo: flag global `player_invisible = true` por 5 segundos
- Los enemigos chequean ese flag antes de detectar al jugador
- Efecto visual: reducir alpha del sprite del jugador

**Tarea 11 — Orbe señuelo**
- Al recogerlo: todos los enemigos cambian su target a una posición fija por 8s
- Los scripts de enemigos chequean `decoy_active` y `decoy_x, decoy_y`

**Tarea 12 — Pergamino temporal**
- Al recogerlo: flag `time_slow = true` por 5s
- En cada script de enemigo: multiplicar velocidad por 0.2 si `time_slow`
- Efecto visual: tinte azul en pantalla (si se puede con SDL)

---

### FASE 5 — Niveles 2 y 3

**Tarea 13 — Nivel 2: Castillo maldito**
- `scene_level_02.lua` con nuevo mapa y ambientación oscura
- Mecánica de llaves: 3 llaves que abren el portal de salida
- Mimic aparece por primera vez aquí
- Música diferente al nivel 1

**Tarea 14 — Nivel 3: Ruinas del dragón**
- `scene_level_03.lua` con contrarreloj visible en HUD
- Puertas que se cierran progresivamente (entidades que aparecen con timer)
- Dragón como enemigo principal
- Al morir el dragón: aparece la reliquia final

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
