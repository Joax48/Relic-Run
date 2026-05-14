#ifndef BOXCOLLIDERCOMPONENT_HPP
#define BOXCOLLIDERCOMPONENT_HPP

#include <glm/glm.hpp>

/**
 * @struct BoxColliderComponent
 * @brief Hitbox rectangular (AABB) usada para colisiones y overlaps.
 *
 * BoxCollisionSystem y OverlapSystem usan este componente para detectar
 * intersecciones entre entidades. La caja se posiciona en
 * @c TransformComponent::position + @c offset, lo que permite centrar
 * la hitbox dentro del sprite (que suele tener padding).
 *
 * Entidades con @c RigidBodyComponent::isSolid = true resuelven la
 * colisión empujando al otro actor fuera del área de solapamiento.
 * Entidades sin ese flag solo generan un evento de colisión sin resolución.
 *
 * El binding Lua @c set_box_collider(entity, w, h) permite redimensionar
 * esta hitbox en runtime (p.ej. al cambiar de forma un mimic).
 */
struct BoxColliderComponent {
    int       width;  ///< Ancho de la hitbox en píxeles.
    int       height; ///< Alto de la hitbox en píxeles.
    glm::vec2 offset; ///< Desplazamiento relativo a TransformComponent::position.

    /**
     * @param width  Ancho de la caja en píxeles.
     * @param height Alto de la caja en píxeles.
     * @param offset Offset de la caja respecto a la posición de la entidad.
     */
    BoxColliderComponent(int width = 0, int height = 0,
                         glm::vec2 offset = glm::vec2(0)) {
        this->width  = width;
        this->height = height;
        this->offset = offset;
    }
};


#endif // BOXCOLLIDERCOMPONENT_HPP
