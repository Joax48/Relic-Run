#ifndef PHYSICSSYSTEM_HPP
#define PHYSICSSYSTEM_HPP

#include "../Components/RigidBodyComponent.hpp"
#include "../ECS/ECS.hpp"

class PhysicsSystem : public System {
    public:
        PhysicsSystem(){
            RequireComponent<RigidBodyComponent>();
        }
        void Update() {
            for (auto entity : GetSystemEntities()) {
                auto& rigidBody = entity.GetComponent<RigidBodyComponent>();
                // Top-down game — no gravity
                rigidBody.sumForces = glm::vec2(0.0f);
            }
        }
};

#endif // PHYSICSSYSTEM_HPP