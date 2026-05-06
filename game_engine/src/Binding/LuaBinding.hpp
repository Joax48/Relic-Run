#ifndef LUA_BINDING_HPP
#define LUA_BINDING_HPP

#include <string>
#include <tuple>

#include "../Components/BoxColliderComponent.hpp"
#include "../Components/TagComponent.hpp"
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
    const auto& transform = entity.GetComponent<TransformComponent>();
    const auto& sprite = entity.GetComponent<SpriteComponent>();

    int width = sprite.width * transform.scale.x;
    int height = sprite.height * transform.scale.y;

    return {width, height};
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

#endif // LUA_BINDING_HPP