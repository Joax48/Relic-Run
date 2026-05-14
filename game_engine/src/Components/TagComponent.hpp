#ifndef TAG_COMPONENT_HPP
#define TAG_COMPONENT_HPP

#include <string>

/**
 * @struct TagComponent
 * @brief Etiqueta de texto que identifica el tipo de una entidad.
 *
 * Los scripts Lua usan @c get_tag(entity) dentro de @c on_collision para
 * determinar con qué tipo de entidad colisionaron y actuar en consecuencia:
 *
 * @code{.lua}
 * function on_collision(other)
 *     if get_tag(other) == "player" then
 *         -- aplicar daño
 *     end
 * end
 * @endcode
 *
 * Convención del proyecto: tags en snake_case.
 * Tags usados actualmente: @c "player", @c "wall", @c "relic", @c "portal",
 * @c "projectile", @c "enemy_projectile", @c "player_melee",
 * @c "goblin", @c "orc", @c "vampire", @c "mimic", @c "dragon",
 * @c "goblin_boss", @c "orc2", @c "vampire_boss",
 * @c "powerup_cloak", @c "powerup_decoy", @c "powerup_time".
 */
struct TagComponent {
    std::string tag; ///< Identificador de tipo de la entidad.

    /** @param tag Etiqueta de tipo (p. ej. "player", "goblin"). */
    TagComponent(const std::string& tag = "") {
        this->tag = tag;
    }
};


#endif // TAG_COMPONENT_HPP
