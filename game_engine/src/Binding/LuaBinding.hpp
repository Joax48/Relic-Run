#ifndef LUA_BINDING_HPP
#define LUA_BINDING_HPP

/**
 * @file LuaBinding.hpp
 * @brief Funciones C++ expuestas a Lua a través de Sol2.
 *
 * Cada función free-standing definida aquí se registra en ScriptSystem::CreateLuaBinding()
 * como una función global accesible desde cualquier script Lua del juego.
 *
 * Las funciones están organizadas en las siguientes categorías:
 * - @ref input      — Estado del teclado y ratón
 * - @ref components — Lectura/escritura de componentes ECS
 * - @ref scenes     — Transición entre escenas
 * - @ref collisions — Helpers de dirección de colisión
 * - @ref spawn      — Creación de entidades en runtime
 * - @ref hud        — Actualización de UI/HUD
 * - @ref audio      — Reproducción de música y efectos
 * - @ref window     — Consultas de ventana y cámara
 */

#include <string>
#include <tuple>

#include "../Components/AnimationComponent.hpp"
#include "../Components/BoxColliderComponent.hpp"
#include "../Components/HealthBarComponent.hpp"
#include "../MapLoader/MapLoader.hpp"
#include "../Components/ScriptComponent.hpp"
#include "../Components/TagComponent.hpp"
#include "../Components/TextComponent.hpp"
#include "../Components/RigidBodyComponent.hpp"
#include "../Components/SpriteComponent.hpp"
#include "../Components/TransformComponent.hpp"
#include "../ECS/ECS.hpp"
#include "../AudioManager/AudioManager.hpp"
#include "../Game/Game.hpp"

// ── Input ─────────────────────────────────────────────────────────────────────

/**
 * @defgroup input Controles
 * @{
 */

/** @brief true si la acción registrada está siendo mantenida este frame. */
bool IsActionActived(const std::string& action) {
    return Game::GetInstance().controllerManager->IsActionActived(action);
}

/** @brief true solo en el primer frame en que la acción fue presionada. */
bool IsActionJustPressed(const std::string& action) {
    return Game::GetInstance().controllerManager->IsActionJustPressed(action);
}

/** @brief true si cualquier tecla fue presionada este frame (para pantallas "press any key"). */
bool IsAnyKeyJustPressed() {
    return Game::GetInstance().controllerManager->IsAnyKeyJustPressed();
}

/** @} */

// ── Componentes ───────────────────────────────────────────────────────────────

/**
 * @defgroup components Componentes ECS
 * @{
 */

/** @brief Devuelve la velocidad de la entidad como (vx, vy). */
std::tuple<int,int> GetVelocity(Entity entity) {
    const auto& rigidBody = entity.GetComponent<RigidBodyComponent>();
    return {
        static_cast<int>(rigidBody.velocity.x),
        static_cast<int>(rigidBody.velocity.y)
    };
}

/** @brief Establece la velocidad de la entidad. */
void SetVelocity(Entity entity, float x, float y) {
    auto& rigidBody = entity.GetComponent<RigidBodyComponent>();
    rigidBody.velocity.x = x;
    rigidBody.velocity.y = y;
}

/** @brief Devuelve el tag de la entidad (p. ej. "player", "goblin"). */
std::string GetTag(Entity entity) {
    return entity.GetComponent<TagComponent>().tag;
}

/** @brief Devuelve la posición de la entidad como (x, y) en píxeles de mundo. */
std::tuple<int,int> GetPosition(Entity entity) {
    const auto& transform = entity.GetComponent<TransformComponent>();
    return {
        static_cast<int>(transform.position.x),
        static_cast<int>(transform.position.y)
    };
}

/** @brief Teletransporta la entidad a (x, y) en píxeles de mundo. */
void SetPosition(Entity entity, int x, int y) {
    auto& transform = entity.GetComponent<TransformComponent>();
    transform.position.x = x;
    transform.position.y = y;
}

/**
 * @brief Devuelve el tamaño efectivo (ancho, alto) en píxeles de pantalla.
 *
 * Si la entidad tiene SpriteComponent: width×scaleX, height×scaleY.
 * Si solo tiene BoxColliderComponent: collider.width, collider.height.
 * Si no tiene ninguno: (0, 0).
 */
std::tuple<int, int> GetSize(Entity entity) {
    if (entity.hasComponent<SpriteComponent>()) {
        const auto& transform = entity.GetComponent<TransformComponent>();
        const auto& sprite    = entity.GetComponent<SpriteComponent>();
        return {
            static_cast<int>(sprite.width  * transform.scale.x),
            static_cast<int>(sprite.height * transform.scale.y)
        };
    } else if (entity.hasComponent<BoxColliderComponent>()) {
        const auto& collider = entity.GetComponent<BoxColliderComponent>();
        return {collider.width, collider.height};
    }
    return {0, 0};
}

/** @} */

// ── Escenas ───────────────────────────────────────────────────────────────────

/**
 * @defgroup scenes Escenas
 * @{
 */

/**
 * @brief Inicia la transición a la escena indicada.
 *
 * Registra la próxima escena en SceneManager y detiene el bucle actual;
 * el cambio efectivo ocurre al inicio del siguiente ciclo de RunScene().
 *
 * @param sceneName Nombre registrado en @c scenes.lua (p. ej. "level_02").
 */
void GoToScene(const std::string& sceneName) {
    Game::GetInstance().sceneManager->SetNextScene(sceneName);
    Game::GetInstance().sceneManager->StopScene();
}

/** @} */

// ── Colisiones direccionales ──────────────────────────────────────────────────

/**
 * @defgroup collisions Colisiones
 * @brief Determinan la dirección relativa de una colisión usando previousPosition.
 * @{
 */

/** @brief true si @c other estaba a la izquierda de @c e en el frame anterior. */
bool LeftCollision(Entity e, Entity other) {
    const auto& eCollider = e.GetComponent<BoxColliderComponent>();
    const auto& eTrans    = e.GetComponent<TransformComponent>();
    const auto& oCollider = other.GetComponent<BoxColliderComponent>();
    const auto& oTrans    = other.GetComponent<TransformComponent>();

    float eX = eTrans.previousPosition.x + eCollider.offset.x;
    float eY = eTrans.previousPosition.y + eCollider.offset.y;
    float eH = static_cast<float>(eCollider.height);
    float oX = oTrans.previousPosition.x + oCollider.offset.x;
    float oY = oTrans.previousPosition.y + oCollider.offset.y;
    float oH = static_cast<float>(oCollider.height);

    return (oY < eY + eH && oY + oH > eY && oX < eX);
}

/** @brief true si @c other estaba arriba de @c e en el frame anterior. */
bool UpCollision(Entity e, Entity other) {
    const auto& eCollider = e.GetComponent<BoxColliderComponent>();
    const auto& eTrans    = e.GetComponent<TransformComponent>();
    const auto& oCollider = other.GetComponent<BoxColliderComponent>();
    const auto& oTrans    = other.GetComponent<TransformComponent>();

    float eX = eTrans.previousPosition.x + eCollider.offset.x;
    float eY = eTrans.previousPosition.y + eCollider.offset.y;
    float eW = static_cast<float>(eCollider.width);
    float oX = oTrans.previousPosition.x + oCollider.offset.x;
    float oY = oTrans.previousPosition.y + oCollider.offset.y;
    float oW = static_cast<float>(oCollider.width);

    return (oX < eX + eW && oX + oW > eX && oY < eY);
}

/** @brief true si @c other estaba abajo de @c e en el frame anterior. */
bool DownCollision(Entity e, Entity other) {
    const auto& eCollider = e.GetComponent<BoxColliderComponent>();
    const auto& eTrans    = e.GetComponent<TransformComponent>();
    const auto& oCollider = other.GetComponent<BoxColliderComponent>();
    const auto& oTrans    = other.GetComponent<TransformComponent>();

    float eX = eTrans.previousPosition.x + eCollider.offset.x;
    float eY = eTrans.previousPosition.y + eCollider.offset.y;
    float eW = static_cast<float>(eCollider.width);
    float oX = oTrans.previousPosition.x + oCollider.offset.x;
    float oY = oTrans.previousPosition.y + oCollider.offset.y;
    float oW = static_cast<float>(oCollider.width);

    return (oX < eX + eW && oX + oW > eX && oY > eY);
}

/** @brief true si @c other estaba a la derecha de @c e en el frame anterior. */
bool RightCollision(Entity e, Entity other) {
    const auto& eCollider = e.GetComponent<BoxColliderComponent>();
    const auto& eTrans    = e.GetComponent<TransformComponent>();
    const auto& oCollider = other.GetComponent<BoxColliderComponent>();
    const auto& oTrans    = other.GetComponent<TransformComponent>();

    float eX = eTrans.previousPosition.x + eCollider.offset.x;
    float eY = eTrans.previousPosition.y + eCollider.offset.y;
    float eH = static_cast<float>(eCollider.height);
    float oX = oTrans.previousPosition.x + oCollider.offset.x;
    float oY = oTrans.previousPosition.y + oCollider.offset.y;
    float oH = static_cast<float>(oCollider.height);

    return (oY < eY + eH && oY + oH > eY && oX > eX);
}

/** @} */

// ── Spawn ─────────────────────────────────────────────────────────────────────

/**
 * @defgroup spawn Creación de entidades en runtime
 * @{
 */

/**
 * @brief Crea un proyectil del jugador en (x, y) con velocidad (vx, vy).
 *
 * El proyectil carga @c ./assets/scripts/projectile.lua automáticamente.
 * Guarda y restaura @c lua["this"] para no romper el script del invocador.
 * Se destruye al colisionar con cualquier entidad que no sea @c "player",
 * @c "projectile" o @c "player_melee".
 *
 * @return La entidad proyectil creada.
 */
Entity SpawnProjectile(float x, float y, float vx, float vy) {
    auto& game = Game::GetInstance();
    sol::object saved_this = game.lua["this"];

    Entity proj = game.registry->CreateEntity();
    proj.AddComponent<TransformComponent>(glm::vec2(x, y), glm::vec2(1.0f, 1.0f), 0.0);
    proj.AddComponent<SpriteComponent>("projectile", 16, 16, 0, 0);
    proj.AddComponent<AnimationComponent>(4, 12, true);
    proj.AddComponent<RigidBodyComponent>(false, false, 1.0f);
    proj.GetComponent<RigidBodyComponent>().velocity = glm::vec2(vx, vy);
    proj.AddComponent<BoxColliderComponent>(16, 16, glm::vec2(0, 0));
    proj.AddComponent<TagComponent>("projectile");

    game.lua["on_awake"] = sol::nil;
    game.lua["update"] = sol::nil;
    game.lua["on_click"] = sol::nil;
    game.lua["on_collision"] = sol::nil;
    game.lua.script_file("./assets/scripts/projectile.lua");

    sol::function update_fn = sol::lua_nil;
    sol::function on_collision_fn = sol::lua_nil;

    sol::optional<sol::function> has_update = game.lua["update"];
    if (has_update != sol::nullopt) update_fn = has_update.value();

    sol::optional<sol::function> has_collision = game.lua["on_collision"];
    if (has_collision != sol::nullopt) on_collision_fn = has_collision.value();

    proj.AddComponent<ScriptComponent>(update_fn, sol::lua_nil, on_collision_fn);

    game.lua["this"] = saved_this;
    return proj;
}

/**
 * @brief Crea un proyectil enemigo en (x, y) con velocidad (vx, vy).
 *
 * Igual que SpawnProjectile pero con tag @c "enemy_projectile" y script
 * @c ./assets/scripts/enemy_projectile.lua. El jugador recibe daño al
 * colisionar con este proyectil.
 *
 * @return La entidad proyectil enemigo creada.
 */
Entity SpawnEnemyProjectile(float x, float y, float vx, float vy) {
    auto& game = Game::GetInstance();
    sol::object saved_this = game.lua["this"];

    Entity proj = game.registry->CreateEntity();
    proj.AddComponent<TransformComponent>(glm::vec2(x, y), glm::vec2(1.0f, 1.0f), 0.0);
    proj.AddComponent<SpriteComponent>("projectile", 16, 16, 0, 0);
    proj.AddComponent<AnimationComponent>(4, 12, true);
    proj.AddComponent<RigidBodyComponent>(false, false, 1.0f);
    proj.GetComponent<RigidBodyComponent>().velocity = glm::vec2(vx, vy);
    proj.AddComponent<BoxColliderComponent>(16, 16, glm::vec2(0, 0));
    proj.AddComponent<TagComponent>("enemy_projectile");

    game.lua["on_awake"] = sol::nil;
    game.lua["update"] = sol::nil;
    game.lua["on_click"] = sol::nil;
    game.lua["on_collision"] = sol::nil;
    game.lua.script_file("./assets/scripts/enemy_projectile.lua");

    sol::function update_fn = sol::lua_nil;
    sol::function on_collision_fn = sol::lua_nil;

    sol::optional<sol::function> has_update = game.lua["update"];
    if (has_update != sol::nullopt) update_fn = has_update.value();

    sol::optional<sol::function> has_collision = game.lua["on_collision"];
    if (has_collision != sol::nullopt) on_collision_fn = has_collision.value();

    proj.AddComponent<ScriptComponent>(update_fn, sol::lua_nil, on_collision_fn);

    game.lua["this"] = saved_this;
    return proj;
}

/**
 * @brief Crea una hitbox de melee invisible en (x, y) con tamaño (w × h).
 *
 * La hitbox tiene tag @c "player_melee", sin sprite y sin script.
 * El script del atacante es responsable de destruirla con @c kill_entity()
 * después de la duración del ataque.
 *
 * @return La entidad hitbox creada.
 */
Entity SpawnMelee(float x, float y, int w, int h) {
    auto& game = Game::GetInstance();
    Entity melee = game.registry->CreateEntity();
    melee.AddComponent<TransformComponent>(glm::vec2(x, y), glm::vec2(1.0f, 1.0f), 0.0);
    melee.AddComponent<BoxColliderComponent>(w, h, glm::vec2(0, 0));
    melee.AddComponent<TagComponent>("player_melee");
    return melee;
}

/** @brief Marca la entidad para destrucción en el próximo ciclo de Update(). */
void KillEntity(Entity entity) {
    Game::GetInstance().registry->KillEntity(entity);
}

/**
 * @brief Crea un orc en (x, y) y carga @c enemy_orc.lua.
 * @return La entidad orc creada.
 */
Entity SpawnOrc(float x, float y) {
    auto& game = Game::GetInstance();
    sol::object saved_this = game.lua["this"];

    Entity orc = game.registry->CreateEntity();
    orc.AddComponent<TransformComponent>(glm::vec2(x, y), glm::vec2(1.2f, 1.2f), 0.0);
    orc.AddComponent<SpriteComponent>("orc1-idle", 64, 64, 0, 0);
    orc.AddComponent<RigidBodyComponent>(false, false, 1.0f);
    orc.AddComponent<BoxColliderComponent>(40, 55, glm::vec2(21.0f, 13.0f));
    orc.AddComponent<TagComponent>("orc");
    orc.AddComponent<AnimationComponent>(4, 6, true);
    orc.AddComponent<HealthBarComponent>(3, 3);

    game.lua["on_awake"] = sol::nil;
    game.lua["update"] = sol::nil;
    game.lua["on_click"] = sol::nil;
    game.lua["on_collision"] = sol::nil;
    game.lua.script_file("./assets/scripts/enemy_orc.lua");

    sol::function update_fn = sol::lua_nil;
    sol::function on_collision_fn = sol::lua_nil;

    sol::optional<sol::function> has_update = game.lua["update"];
    if (has_update != sol::nullopt) update_fn = has_update.value();

    sol::optional<sol::function> has_collision = game.lua["on_collision"];
    if (has_collision != sol::nullopt) on_collision_fn = has_collision.value();

    orc.AddComponent<ScriptComponent>(update_fn, sol::lua_nil, on_collision_fn);

    game.lua["this"] = saved_this;
    return orc;
}

/**
 * @brief Crea un goblin en (x, y) y carga @c enemy_goblin.lua.
 * @return La entidad goblin creada.
 */
Entity SpawnGoblin(float x, float y) {
    auto& game = Game::GetInstance();
    sol::object saved_this = game.lua["this"];

    Entity goblin = game.registry->CreateEntity();
    goblin.AddComponent<TransformComponent>(glm::vec2(x, y), glm::vec2(1.2f, 1.2f), 0.0);
    goblin.AddComponent<SpriteComponent>("goblin1-idle", 64, 64, 0, 0);
    goblin.AddComponent<RigidBodyComponent>(false, false, 1.0f);
    goblin.AddComponent<BoxColliderComponent>(40, 55, glm::vec2(21.0f, 13.0f));
    goblin.AddComponent<TagComponent>("orc");
    goblin.AddComponent<AnimationComponent>(4, 6, true);
    goblin.AddComponent<HealthBarComponent>(3, 3);

    game.lua["on_awake"] = sol::nil;
    game.lua["update"] = sol::nil;
    game.lua["on_click"] = sol::nil;
    game.lua["on_collision"] = sol::nil;
    game.lua.script_file("./assets/scripts/enemy_goblin.lua");

    sol::function update_fn = sol::lua_nil;
    sol::function on_collision_fn = sol::lua_nil;

    sol::optional<sol::function> has_update = game.lua["update"];
    if (has_update != sol::nullopt) update_fn = has_update.value();

    sol::optional<sol::function> has_collision = game.lua["on_collision"];
    if (has_collision != sol::nullopt) on_collision_fn = has_collision.value();

    goblin.AddComponent<ScriptComponent>(update_fn, sol::lua_nil, on_collision_fn);

    game.lua["this"] = saved_this;
    return goblin;
}

/**
 * @brief Crea un vampiro en (x, y) y carga @c enemy_vampire.lua.
 * @return La entidad vampiro creada.
 */
Entity SpawnVampireEnemy(float x, float y) {
    auto& game = Game::GetInstance();
    sol::object saved_this = game.lua["this"];

    Entity vamp = game.registry->CreateEntity();
    vamp.AddComponent<TransformComponent>(glm::vec2(x, y), glm::vec2(1.5f, 1.5f), 0.0);
    vamp.AddComponent<SpriteComponent>("vampire-idle", 64, 64, 0, 0);
    vamp.AddComponent<RigidBodyComponent>(false, false, 1.0f);
    vamp.AddComponent<BoxColliderComponent>(38, 54, glm::vec2(13.0f, 10.0f));
    vamp.AddComponent<TagComponent>("vampire");
    vamp.AddComponent<AnimationComponent>(4, 6, true);
    vamp.AddComponent<HealthBarComponent>(2, 2);

    game.lua["on_awake"] = sol::nil;
    game.lua["update"] = sol::nil;
    game.lua["on_click"] = sol::nil;
    game.lua["on_collision"] = sol::nil;
    game.lua.script_file("./assets/scripts/enemy_vampire.lua");

    sol::function update_fn = sol::lua_nil;
    sol::function on_collision_fn = sol::lua_nil;

    sol::optional<sol::function> has_update = game.lua["update"];
    if (has_update != sol::nullopt) update_fn = has_update.value();

    sol::optional<sol::function> has_collision = game.lua["on_collision"];
    if (has_collision != sol::nullopt) on_collision_fn = has_collision.value();

    vamp.AddComponent<ScriptComponent>(update_fn, sol::lua_nil, on_collision_fn);

    game.lua["this"] = saved_this;
    return vamp;
}

/** @} */

// ── Mapa ──────────────────────────────────────────────────────────────────────

/**
 * @brief Carga un mapa Tiled (.tmx) y crea sus entidades tile en el registro ECS.
 *
 * Delega en MapLoader::LoadMap() y actualiza @c Game::mapWidth / @c Game::mapHeight.
 * Llamado desde Lua con @c load_map("./assets/maps/level_01.tmx").
 *
 * @param tmxPath Ruta relativa al archivo .tmx (p. ej. "./assets/maps/level_01.tmx").
 */
void LoadMap(const std::string& tmxPath) {
    auto& game = Game::GetInstance();
    MapLoader loader;
    loader.LoadMap(tmxPath, game.registry, game.assetManager,
                   game.renderer, game.mapWidth, game.mapHeight);
}

// ── HUD ───────────────────────────────────────────────────────────────────────

/**
 * @defgroup hud HUD y UI
 * @{
 */

/** @brief Actualiza el texto de un TextComponent en runtime. */
void SetText(Entity entity, const std::string& text) {
    entity.GetComponent<TextComponent>().text = text;
}

/** @brief Cambia la textura de un SpriteComponent por assetId. */
void SetSprite(Entity entity, const std::string& assetId) {
    entity.GetComponent<SpriteComponent>().textureId = assetId;
}

/** @brief Redimensiona el sprite y reinicia el srcRect a (0, 0, w, h). */
void SetSpriteSize(Entity entity, int w, int h) {
    auto& sprite     = entity.GetComponent<SpriteComponent>();
    sprite.width     = w;
    sprite.height    = h;
    sprite.srcRect   = {0, 0, w, h};
}

/** @brief Redimensiona la hitbox del BoxCollider sin cambiar su offset. */
void SetBoxCollider(Entity entity, int w, int h) {
    auto& col  = entity.GetComponent<BoxColliderComponent>();
    col.width  = w;
    col.height = h;
}

/** @brief Actualiza HP y maxHP del HealthBarComponent. */
void SetHealth(Entity entity, int hp, int maxHp) {
    auto& hb = entity.GetComponent<HealthBarComponent>();
    hb.hp    = hp;
    hb.maxHp = maxHp;
}

/** @brief Establece la transparencia del sprite (0=invisible, 255=opaco). */
void SetAlpha(Entity entity, int alpha) {
    entity.GetComponent<SpriteComponent>().alpha = static_cast<Uint8>(alpha);
}

/** @brief Cambia la fila activa del spritesheet (selecciona la animación). */
void SetSpriteRow(Entity entity, int row) {
    auto& sprite = entity.GetComponent<SpriteComponent>();
    sprite.srcRect.y = row * sprite.height;
}

/** @brief Cambia el ancho del sprite y su srcRect (usado para barras de progreso). */
void SetSpriteWidth(Entity entity, int w) {
    auto& sprite     = entity.GetComponent<SpriteComponent>();
    sprite.width     = w;
    sprite.srcRect.w = w;
}

/** @brief Muestra u oculta una entidad ajustando su alpha (255 u 0). */
void SetVisible(Entity entity, bool visible) {
    if (entity.hasComponent<SpriteComponent>()) {
        entity.GetComponent<SpriteComponent>().alpha = visible ? 255 : 0;
    }
}

/** @brief Devuelve el ancho en píxeles del texto renderizado del TextComponent. */
int GetTextWidth(Entity entity) {
    return entity.GetComponent<TextComponent>().width;
}

/**
 * @brief Cambia la textura activa y reinicia la animación.
 *
 * Equivalente a cambiar de animación (idle → walk → attack) actualizando
 * el assetId del sprite y los parámetros de AnimationComponent.
 *
 * @param assetId    Identificador de la nueva textura en AssetManager.
 * @param numFrames  Número de frames de la nueva animación.
 * @param speedRate  Velocidad de la nueva animación (frames/segundo aprox.).
 */
void PlayAnimation(Entity entity, const std::string& assetId,
                   int numFrames, int speedRate) {
    auto& sprite          = entity.GetComponent<SpriteComponent>();
    auto& animation       = entity.GetComponent<AnimationComponent>();
    sprite.textureId      = assetId;
    animation.numFrames   = numFrames;
    animation.frameSpeedRate = speedRate;
    animation.startTime   = static_cast<int>(SDL_GetTicks());
    animation.currentFrame = 0;
}

/** @} */

// ── Ventana / Cámara ──────────────────────────────────────────────────────────

/**
 * @defgroup window Ventana y cámara
 * @{
 */

/** @brief Ancho de la ventana SDL en píxeles. */
int GetWindowWidth() { return Game::GetInstance().windowWidth; }

/** @brief Alto de la ventana SDL en píxeles. */
int GetWindowHeight() { return Game::GetInstance().windowHeight; }

/** @brief Coordenada X de la esquina superior izquierda de la cámara en el mundo. */
int GetCameraX() { return Game::GetInstance().camera.x; }

/** @brief Coordenada Y de la esquina superior izquierda de la cámara en el mundo. */
int GetCameraY() { return Game::GetInstance().camera.y; }

/** @brief Posición X del cursor en coordenadas de pantalla. */
int GetMouseX() { int x, y; SDL_GetMouseState(&x, &y); return x; }

/** @brief Posición Y del cursor en coordenadas de pantalla. */
int GetMouseY() { int x, y; SDL_GetMouseState(&x, &y); return y; }

/** @} */

// ── Audio ─────────────────────────────────────────────────────────────────────

/**
 * @defgroup audio Audio
 * @{
 */

/**
 * @brief Reproduce una pista de música.
 * @param path Ruta relativa al archivo de audio (p. ej. "./assets/audio/level01.ogg").
 * @param loop true para repetir indefinidamente.
 */
void PlayMusic(const std::string& path, bool loop) {
    Game::GetInstance().audioManager->PlayMusic(path, loop);
}

/** @brief Detiene la música en reproducción. */
void StopMusic() {
    Game::GetInstance().audioManager->StopMusic();
}

/**
 * @brief Reproduce un efecto de sonido (one-shot).
 * @param path Ruta relativa al archivo de audio.
 */
void PlaySFX(const std::string& path) {
    Game::GetInstance().audioManager->PlaySFX(path);
}

/** @} */

#endif // LUA_BINDING_HPP
