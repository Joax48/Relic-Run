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

                // Aplicar la fuerza de gravedad
                if (rigidBody.isDynamic) {
                    rigidBody.sumForces += glm::vec2(0.0f, 9.8 * rigidBody.mass * 64);
                }
            }
        }
};

#endif // PHYSICSSYSTEM_HPP