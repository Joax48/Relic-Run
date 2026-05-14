#ifndef HEALTHBARCOMPONENT_HPP
#define HEALTHBARCOMPONENT_HPP

/**
 * @struct HealthBarComponent
 * @brief Puntos de vida actuales y máximos de una entidad.
 *
 * Usado por enemigos y bosses para llevar la cuenta del daño recibido.
 * El binding Lua @c set_health(entity, hp, maxHp) actualiza ambos valores
 * en runtime, permitiendo que los scripts de boss ajusten su HP al pasar
 * a la siguiente fase de combate.
 *
 * RenderSystem puede leer @c hp y @c maxHp para dibujar una barra de vida
 * sobre la entidad si se implementa ese render adicional.
 */
struct HealthBarComponent {
    int hp;    ///< Puntos de vida actuales.
    int maxHp; ///< Puntos de vida máximos.

    /**
     * @param hp    Vida inicial.
     * @param maxHp Vida máxima. Por defecto igual a @c hp.
     */
    HealthBarComponent(int hp = 1, int maxHp = 1) : hp(hp), maxHp(maxHp) {}
};

#endif // HEALTHBARCOMPONENT_HPP
