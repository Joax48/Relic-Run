#ifndef DAMAGESYSTEM_HPP
#define DAMAGESYSTEM_HPP

#include <iostream>
#include <memory>

#include "../ECS/ECS.hpp"
#include "../Components/CircleColliderComponent.hpp"
#include "../EventManager/EventManager.hpp"
#include "../Events/CollisionEvent.hpp"

class DamageSystem : public System {
public:
    DamageSystem() {
        RequireComponent<CircleColliderComponent>();
        // Requerir componentes necesarios para el sistema de daño
        // Ejemplo: RequireComponent<HealthComponent>();
    }

    void SubscribeToCollisionEvent(std::unique_ptr<EventManager>& eventManager) {
        eventManager->SubscribeToEvent<CollisionEvent, DamageSystem>(this
            , &DamageSystem::OnCollision);
    }

    void OnCollision(CollisionEvent& e) {
        std::cout << "[DAMAGESYSTEM] Colisión detectada entre las entidades "
            << e.a.GetId() << " y " << e.b.GetId() << std::endl;

            e.a.Kill();
            e.b.Kill();
        // Lógica para aplicar daño a las entidades involucradas en la colisión
        // Ejemplo: Reducir la salud de las entidades o destruirlas si la salud llega a cero
    }
};

#endif // DAMAGESYSTEM_HPP