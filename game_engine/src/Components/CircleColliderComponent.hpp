#ifndef CIRCLECOLLIDERCOMPONENT_HPP
#define CIRCLECOLLIDERCOMPONENT_HPP

/**
 * @struct CircleColliderComponent
 * @brief Hitbox circular para detección de rango o proximidad.
 *
 * CircleCollisionSystem detecta solapamientos entre entidades con este
 * componente usando distancia entre centros vs. suma de radios.
 *
 * Se usa principalmente para rangos de detección (p. ej. el radio en que
 * el Mimic "despierta" al jugador) sin la rigidez de las hitbox rectangulares.
 *
 * @c width y @c height se usan para calcular el centro de la entidad cuando
 * no existe un @c SpriteComponent del que inferirlo.
 */
struct CircleColliderComponent {
    int radius; ///< Radio del círculo en píxeles.
    int width;  ///< Ancho del bounding box (para calcular centro si no hay sprite).
    int height; ///< Alto del bounding box (para calcular centro si no hay sprite).

    /**
     * @param radius Radio del colisionador en píxeles.
     * @param width  Ancho auxiliar para cálculo de centro.
     * @param height Alto auxiliar para cálculo de centro.
     */
    CircleColliderComponent(int radius = 0, int width = 0, int height = 0) {
        this->radius = radius;
        this->width  = width;
        this->height = height;
    }
};


#endif // CIRCLECOLLIDERCOMPONENT_HPP
