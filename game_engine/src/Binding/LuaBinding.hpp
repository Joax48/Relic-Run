#ifndef LUA_BINDING_HPP
#define LUA_BINDING_HPP

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

//* Controles

bool IsActionActived(const std::string& action) {
    return Game::GetInstance().controllerManager->IsActionActived(action);
}

//* Components

// RigidBodyComponent

std::tuple<int,int> GetVelocity(Entity entity) {
    const auto& rigidBody = entity.GetComponent<RigidBodyComponent>();

    return {
        static_cast<int>(rigidBody.velocity.x),
        static_cast<int>(rigidBody.velocity.y)
    };
}

void SetVelocity(Entity entity, float x, float y) {
    auto& rigidBody = entity.GetComponent<RigidBodyComponent>();
    rigidBody.velocity.x = x;
    rigidBody.velocity.y = y;
}

// TagComponent
std::string GetTag(Entity entity) {
    return entity.GetComponent<TagComponent>().tag;
}

// TransformComponent
std::tuple<int,int> GetPosition(Entity entity) {
    const auto& transform = entity.GetComponent<TransformComponent>();

    return {
        static_cast<int>(transform.position.x),
        static_cast<int>(transform.position.y)
    };
}

void SetPosition(Entity entity, int x, int y) {
    auto& transform = entity.GetComponent<TransformComponent>();

    transform.position.x = x;
    transform.position.y = y;
}

std::tuple<int, int> GetSize(Entity entity) {
    if (entity.hasComponent<SpriteComponent>()) {
        const auto& transform = entity.GetComponent<TransformComponent>();
        const auto& sprite = entity.GetComponent<SpriteComponent>();
        return {
            static_cast<int>(sprite.width * transform.scale.x),
            static_cast<int>(sprite.height * transform.scale.y)
        };
    } else if (entity.hasComponent<BoxColliderComponent>()) {
        const auto& collider = entity.GetComponent<BoxColliderComponent>();
        return {collider.width, collider.height};
    }
    return {0, 0};
}



//* Scenes

void GoToScene(const std::string& sceneName) {
    Game::GetInstance().sceneManager->SetNextScene(sceneName);
    Game::GetInstance().sceneManager->StopScene();

}

//* Collisions

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

//* Entidades en runtime

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

Entity SpawnMelee(float x, float y, int w, int h) {
    auto& game = Game::GetInstance();
    Entity melee = game.registry->CreateEntity();
    melee.AddComponent<TransformComponent>(glm::vec2(x, y), glm::vec2(1.0f, 1.0f), 0.0);
    melee.AddComponent<BoxColliderComponent>(w, h, glm::vec2(0, 0));
    melee.AddComponent<TagComponent>("player_melee");
    return melee;
}

void KillEntity(Entity entity) {
    Game::GetInstance().registry->KillEntity(entity);
}

//* HUD

void SetText(Entity entity, const std::string& text) {
    entity.GetComponent<TextComponent>().text = text;
}

void SetSprite(Entity entity, const std::string& assetId) {
    entity.GetComponent<SpriteComponent>().textureId = assetId;
}

void SetSpriteSize(Entity entity, int w, int h) {
    auto& sprite = entity.GetComponent<SpriteComponent>();
    sprite.width     = w;
    sprite.height    = h;
    sprite.srcRect   = {0, 0, w, h};
}

void SetBoxCollider(Entity entity, int w, int h) {
    auto& col  = entity.GetComponent<BoxColliderComponent>();
    col.width  = w;
    col.height = h;
}

void SetHealth(Entity entity, int hp, int maxHp) {
    auto& hb = entity.GetComponent<HealthBarComponent>();
    hb.hp    = hp;
    hb.maxHp = maxHp;
}

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

void LoadMap(const std::string& tmxPath) {
    auto& game = Game::GetInstance();
    MapLoader loader;
    loader.LoadMap(tmxPath, game.registry, game.assetManager,
                   game.renderer, game.mapWidth, game.mapHeight);
}

void SetAlpha(Entity entity, int alpha) {
    entity.GetComponent<SpriteComponent>().alpha = static_cast<Uint8>(alpha);
}

void SetSpriteRow(Entity entity, int row) {
    auto& sprite = entity.GetComponent<SpriteComponent>();
    sprite.srcRect.y = row * sprite.height;
}

void SetSpriteWidth(Entity entity, int w) {
    auto& sprite   = entity.GetComponent<SpriteComponent>();
    sprite.width   = w;
    sprite.srcRect.w = w;
}

void SetVisible(Entity entity, bool visible) {
    if (entity.hasComponent<SpriteComponent>()) {
        entity.GetComponent<SpriteComponent>().alpha = visible ? 255 : 0;
    }
}

int GetTextWidth(Entity entity) {
    return entity.GetComponent<TextComponent>().width;
}

int GetWindowWidth() {
    return Game::GetInstance().windowWidth;
}

int GetWindowHeight() {
    return Game::GetInstance().windowHeight;
}

int GetCameraX() {
    return Game::GetInstance().camera.x;
}

int GetCameraY() {
    return Game::GetInstance().camera.y;
}

int GetMouseX() {
    int x, y;
    SDL_GetMouseState(&x, &y);
    return x;
}

int GetMouseY() {
    int x, y;
    SDL_GetMouseState(&x, &y);
    return y;
}

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

//* Audio

void PlayMusic(const std::string& path, bool loop) {
    Game::GetInstance().audioManager->PlayMusic(path, loop);
}

void StopMusic() {
    Game::GetInstance().audioManager->StopMusic();
}

void PlaySFX(const std::string& path) {
    Game::GetInstance().audioManager->PlaySFX(path);
}

//* SpawnGoblin

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

// Cambia sprite + reinicia animación (para cambiar entre idle/walk/attack)
void PlayAnimation(Entity entity, const std::string& assetId, int numFrames, int speedRate) {
    auto& sprite     = entity.GetComponent<SpriteComponent>();
    auto& animation  = entity.GetComponent<AnimationComponent>();
    sprite.textureId          = assetId;
    animation.numFrames       = numFrames;
    animation.frameSpeedRate  = speedRate;
    animation.startTime       = static_cast<int>(SDL_GetTicks());
    animation.currentFrame    = 0;
}

#endif // LUA_BINDING_HPP