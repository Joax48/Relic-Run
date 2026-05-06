#ifndef BOXCOLLISIONSYSTEM_HPP
#define BOXCOLLISIONSYSTEM_HPP

#include <iostream>
#include <glm/glm.hpp>
#include <memory>

#include <sol/sol.hpp>
#include <SDL2/SDL.h>

#include "../ECS/ECS.hpp"
#include "../Components/BoxColliderComponent.hpp"
#include "../Components/TransformComponent.hpp"
#include "../Components/ScriptComponent.hpp"
#include "../EventManager/EventManager.hpp"
#include "../Events/CollisionEvent.hpp"


class BoxCollisionSystem : public System {
    private:
        bool CheckAABBCollision(float aX, float aY, float aWidth, float aHeight
            , float bX, float bY, float bWidth, float bHeight) {
            return (aX < bX + bWidth &&
                    aX + aWidth > bX &&
                    aY < bY + bHeight &&
                    aY + aHeight > bY);

        }
    public:
        BoxCollisionSystem() {
            RequireComponent<BoxColliderComponent>();
            RequireComponent<TransformComponent>();
        }

        void Update(sol::state& lua, const std::unique_ptr<EventManager>& eventManager) {
            auto entities = GetSystemEntities();
            for (auto i = entities.begin(); i != entities.end(); i++) {
                Entity a = *i;

                const auto& aCollider = a.GetComponent<BoxColliderComponent>();
                const auto& aTransform = a.GetComponent<TransformComponent>();

                for (auto j = i; j != entities.end(); j++) {
                    Entity b = *j;

                    if (a == b) {
                        continue;
                    }

                    const auto& bCollider = b.GetComponent<BoxColliderComponent>();
                    const auto& bTransform = b.GetComponent<TransformComponent>();

                    bool collision = CheckAABBCollision(
                        aTransform.position.x
                        , aTransform.position.y 
                        , static_cast<float>(aCollider.width)
                        , static_cast<float>(aCollider.height)
                        , bTransform.position.x
                        , bTransform.position.y
                        , static_cast<float>(bCollider.width)
                        , static_cast<float>(bCollider.height));

                    
                    if (collision) {
                        eventManager->EmitEvent<CollisionEvent>(a, b);

                        if (a.hasComponent<ScriptComponent>()) {
                            const auto& script = a.GetComponent<ScriptComponent>();
                            if (script.on_collision != sol::lua_nil) {
                                lua["this"] = a;
                                script.on_collision(b);

                            }
                        }
                        if (b.hasComponent<ScriptComponent>()) {
                            const auto& script = b.GetComponent<ScriptComponent>();
                            if (script.on_collision != sol::lua_nil) {
                                lua["this"] = b;
                                script.on_collision(a);
                            }
                        }

                    }
                }
            }
        }
};

#endif // BOXCOLLISIONSYSTEM_HPP