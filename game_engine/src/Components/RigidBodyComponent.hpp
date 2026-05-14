#ifndef RIGIDBODYCOMPONENT_HPP
#define RIGIDBODYCOMPONENT_HPP

#include <glm/glm.hpp>

/**
 * @struct RigidBodyComponent
 * @brief Propiedades físicas de una entidad: velocidad, fuerzas y masa.
 *
 * MovementSystem lee @c velocity cada frame y la aplica a @c TransformComponent::position.
 * PhysicsSystem acumula fuerzas en @c sumForces y las convierte en aceleración.
 *
 * En la mayoría de los scripts Lua la velocidad se controla directamente con
 * @c set_velocity(entity, vx, vy) en vez de aplicar fuerzas, lo que da un
 * control preciso y predecible al estilo de un juego de acción top-down.
 *
 * @c isDynamic controla si el sistema de física aplica gravedad o fuerzas externas.
 * @c isSolid controla si BoxCollisionSystem resuelve colisiones con otras entidades sólidas.
 */
struct RigidBodyComponent {
    glm::vec2 velocity     = glm::vec2(0); ///< Velocidad actual en píxeles/segundo.
    glm::vec2 sumForces    = glm::vec2(0); ///< Suma de fuerzas acumuladas para este frame.
    glm::vec2 acceleration = glm::vec2(0); ///< Aceleración resultante (sumForces / mass).

    float mass;    ///< Masa de la entidad en kg (arbitrario).
    float invMass; ///< Inverso de la masa, precalculado para evitar divisiones.

    bool isDynamic; ///< Si es true, PhysicsSystem aplica aceleración y fuerzas.
    bool isSolid;   ///< Si es true, BoxCollisionSystem resuelve penetraciones.

    /**
     * @param isDynamic true para entidades afectadas por física (IA, jugador).
     * @param isSolid   true para entidades que no se superponen con otras sólidas.
     * @param mass      Masa en unidades arbitrarias. Por defecto 1.
     */
    RigidBodyComponent(bool isDynamic = false, bool isSolid = false, float mass = 1) {
        this->isDynamic = isDynamic;
        this->isSolid   = isSolid;
        this->mass      = mass;
        this->invMass   = 1 / mass;
    }
};


#endif // RIGIDBODYCOMPONENT_HPP
