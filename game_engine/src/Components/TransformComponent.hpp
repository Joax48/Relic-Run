#ifndef TRANSFORMCOMPONENT_HPP
#define TRANSFORMCOMPONENT_HPP

#include <glm/glm.hpp>

/**
 * @struct TransformComponent
 * @brief Posición, escala y rotación de una entidad en el mundo.
 *
 * Es el componente más fundamental del ECS: define dónde está y cómo
 * aparece visualmente cada entidad. Todos los sistemas de render,
 * colisión y cámara leen este componente.
 *
 * @c previousPosition se actualiza cada frame antes de mover la entidad,
 * permitiendo detectar la dirección de colisión con las funciones
 * @c left_collision / @c right_collision / @c up_collision / @c down_collision.
 */
struct TransformComponent {
    glm::vec2 position;         ///< Posición actual en píxeles de mundo.
    glm::vec2 previousPosition; ///< Posición del frame anterior (usada en resolución de colisiones).
    glm::vec2 scale;            ///< Factores de escala X e Y (1.0 = tamaño original).
    double    rotation;         ///< Rotación en grados.

    /**
     * @param position Posición inicial en el mundo. Por defecto (0, 0).
     * @param scale    Escala inicial. Por defecto (1, 1).
     * @param rotation Rotación inicial en grados. Por defecto 0.
     */
    TransformComponent(glm::vec2 position = glm::vec2(0.0, 0.0),
                       glm::vec2 scale    = glm::vec2(1.0, 1.0),
                       double    rotation = 0.0) {
        this->position         = position;
        this->previousPosition = position;
        this->scale            = scale;
        this->rotation         = rotation;
    }
};


#endif // TRANSFORMCOMPONENT_HPP
