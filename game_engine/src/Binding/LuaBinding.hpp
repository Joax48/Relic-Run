#ifndef LUA_BINDING_HPP
#define LUA_BINDING_HPP

#include <string>
#include <tuple>

#include "../Components/BoxColliderComponent.hpp"
#include "../Components/ScriptComponent.hpp"
#include "../Components/TagComponent.hpp"
#include "../Components/TextComponent.hpp"
#include "../Components/RigidBodyComponent.hpp"
#include "../Components/SpriteComponent.hpp"
#include "../Components/TransformComponent.hpp"
#include "../ECS/ECS.hpp"
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
    const auto& eTrasnform = e.GetComponent<TransformComponent>();

    const auto& oCollider = other.GetComponent<BoxColliderComponent>();
    const auto& oTrasnform = other.GetComponent<TransformComponent>();
    
    float eX = eTrasnform.previousPosition.x;
    float eY = eTrasnform.previousPosition.y;
    float eH = static_cast<float>(eCollider.height);

    float oX = oTrasnform.previousPosition.x;
    float oY = oTrasnform.previousPosition.y;
    float oH = static_cast<float>(oCollider.height);

    // El lado izquierdo de e choca contra other

    return (
        oY < eY + eH &&
        oY + oH > eY &&
        oX < eX
    );
}

bool UpCollision(Entity e, Entity other) {
    const auto& eCollider = e.GetComponent<BoxColliderComponent>();
    const auto& eTransform = e.GetComponent<TransformComponent>();

    const auto& oCollider = other.GetComponent<BoxColliderComponent>();
    const auto& oTransform = other.GetComponent<TransformComponent>();

    float eX = eTransform.previousPosition.x;
    float eY = eTransform.previousPosition.y;
    float eW = static_cast<float>(eCollider.width);

    float oX = oTransform.previousPosition.x;
    float oY = oTransform.previousPosition.y;
    float oW = static_cast<float>(oCollider.width);

    return (
        oX < eX + eW &&
        oX + oW > eX &&
        oY < eY
    );
}

bool DownCollision(Entity e, Entity other) {
    const auto& eCollider = e.GetComponent<BoxColliderComponent>();
    const auto& eTransform = e.GetComponent<TransformComponent>();

    const auto& oCollider = other.GetComponent<BoxColliderComponent>();
    const auto& oTransform = other.GetComponent<TransformComponent>();

    float eX = eTransform.previousPosition.x;
    float eY = eTransform.previousPosition.y;
    float eW = static_cast<float>(eCollider.width);

    float oX = oTransform.previousPosition.x;
    float oY = oTransform.previousPosition.y;
    float oW = static_cast<float>(oCollider.width);

    return (
        oX < eX + eW &&
        oX + oW > eX &&
        oY > eY
    );
}

bool RightCollision(Entity e, Entity other) {
    const auto& eCollider = e.GetComponent<BoxColliderComponent>();
    const auto& eTrasnform = e.GetComponent<TransformComponent>();

    const auto& oCollider = other.GetComponent<BoxColliderComponent>();
    const auto& oTrasnform = other.GetComponent<TransformComponent>();
    
    float eX = eTrasnform.previousPosition.x;
    float eY = eTrasnform.previousPosition.y;
    float eH = static_cast<float>(eCollider.height);

    float oX = oTrasnform.previousPosition.x;
    float oY = oTrasnform.previousPosition.y;
    float oH = static_cast<float>(oCollider.height);

    // El lado derecho de e choca contra other

    return (
        oY < eY + eH &&
        oY + oH > eY &&
        oX > eX
    );

}

//* Entidades en runtime

Entity SpawnProjectile(float x, float y, float vx, float vy) {
    auto& game = Game::GetInstance();
    sol::object saved_this = game.lua["this"];

    Entity proj = game.registry->CreateEntity();
    proj.AddComponent<TransformComponent>(glm::vec2(x, y), glm::vec2(2.0f, 2.0f), 0.0);
    proj.AddComponent<SpriteComponent>("projectile", 8, 8, 0, 0);
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

#endif // LUA_BINDING_HPP