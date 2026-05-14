#ifndef SCRIPT_COMPONENT_HPP
#define SCRIPT_COMPONENT_HPP

#include <sol/sol.hpp>

/**
 * @struct ScriptComponent
 * @brief Almacena las funciones Lua que el motor llama en cada entidad con script.
 *
 * SceneLoader carga el archivo Lua asociado a la entidad, ejecuta @c on_awake()
 * de inmediato y guarda las funciones @c update, @c on_click y @c on_collision
 * en este componente para ser invocadas por los sistemas correspondientes.
 *
 * ScriptSystem llama @c update(dt) cada frame para cada entidad que tenga
 * este componente.
 *
 * BoxCollisionSystem y OverlapSystem llaman @c on_collision(other) cuando se
 * detecta una colisión o solapamiento.
 *
 * UISystem llama @c on_click() cuando el usuario hace clic sobre una entidad
 * con ClickableComponent.
 *
 * Si una función no está definida en el script, se almacena como @c sol::lua_nil
 * y el motor la omite sin error.
 */
struct ScriptComponent {
    sol::function update;       ///< Llamada cada frame con delta time (dt) como argumento.
    sol::function on_click;     ///< Llamada cuando el usuario hace clic sobre la entidad.
    sol::function on_collision; ///< Llamada con la entidad colisionada como argumento.

    /**
     * @param update       Función Lua @c update(dt).
     * @param on_click     Función Lua @c on_click().
     * @param on_collision Función Lua @c on_collision(other).
     */
    ScriptComponent(sol::function update       = sol::lua_nil,
                    sol::function on_click     = sol::lua_nil,
                    sol::function on_collision = sol::lua_nil) {
        this->update       = update;
        this->on_click     = on_click;
        this->on_collision = on_collision;
    }
};


#endif // SCRIPT_COMPONENT_HPP
