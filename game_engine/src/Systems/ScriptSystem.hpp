#ifndef SCRIPT_SYSTEM_HPP
#define SCRIPT_SYSTEM_HPP

#include <memory>
#include <sol/sol.hpp>

#include "../Binding/LuaBinding.hpp"
#include "../Components/ScriptComponent.hpp"
#include "../ECS/ECS.hpp"

/**
 * @class ScriptSystem
 * @brief Sistema ECS que registra los bindings Lua y ejecuta los scripts de entidad.
 *
 * Tiene dos responsabilidades principales:
 *
 * 1. **CreateLuaBinding()** — registra todas las funciones C++ como globales Lua.
 *    Debe llamarse una sola vez durante la inicialización, antes de cargar cualquier escena.
 *    Expone a Lua: input, transform, velocidad, colisiones, spawn de entidades, audio,
 *    HUD, cámara y carga de mapas.
 *
 * 2. **Update()** — itera todas las entidades con @c ScriptComponent y llama su
 *    función @c update(dt). Antes de cada llamada, establece @c lua["this"] a la
 *    entidad actual para que los scripts puedan referenciarse a sí mismos.
 *
 * Este sistema corre antes de PhysicsSystem y MovementSystem en el game loop,
 * de modo que las velocidades escritas por scripts se aplican en el mismo frame.
 */
class ScriptSystem : public System {
public:
    ScriptSystem() {
        RequireComponent<ScriptComponent>();
    }

    /**
     * @brief Registra todas las funciones C++ como funciones globales en el estado Lua.
     *
     * Expone el tipo @c entity a Lua y registra funciones de las categorías:
     * - Input: @c is_action_activated, @c is_action_just_pressed, @c is_any_key_pressed
     * - Física: @c get_velocity, @c set_velocity, @c get_position, @c set_position, @c get_size
     * - Tags: @c get_tag
     * - Escenas: @c go_to_scene
     * - Colisiones: @c left_collision, @c right_collision, @c up_collision, @c down_collision
     * - Spawn: @c spawn_projectile, @c spawn_enemy_projectile, @c spawn_melee, @c kill_entity
     * - Mapa: @c load_map
     * - HUD: @c set_text, @c set_sprite, @c set_sprite_size, @c set_box_collider,
     *        @c set_alpha, @c set_sprite_row, @c set_sprite_width, @c set_visible,
     *        @c set_health, @c play_animation, @c get_text_width
     * - Spawn de enemigos: @c spawn_orc, @c spawn_goblin, @c spawn_vampire_enemy
     * - Audio: @c play_music, @c stop_music, @c play_sfx
     * - Ventana/cámara: @c get_window_width, @c get_window_height,
     *                   @c get_camera_x, @c get_camera_y, @c get_mouse_x, @c get_mouse_y
     *
     * @param lua Estado Lua compartido del motor.
     */
    void CreateLuaBinding(sol::state& lua) {
        // Classes
        lua.new_usertype<Entity>("entity");

        // Functions
        lua.set_function("is_action_activated",    IsActionActived);
        lua.set_function("is_action_just_pressed", IsActionJustPressed);
        lua.set_function("is_any_key_pressed",     IsAnyKeyJustPressed);

        lua.set_function("set_velocity", SetVelocity);
        lua.set_function("get_velocity", GetVelocity);

        lua.set_function("get_tag", GetTag);

        lua.set_function("get_position", GetPosition);
        lua.set_function("set_position", SetPosition);

        lua.set_function("get_size", GetSize);

        lua.set_function("go_to_scene", GoToScene);

        lua.set_function("left_collision",  LeftCollision);
        lua.set_function("right_collision", RightCollision);
        lua.set_function("up_collision",    UpCollision);
        lua.set_function("down_collision",  DownCollision);

        lua.set_function("spawn_projectile",       SpawnProjectile);
        lua.set_function("spawn_enemy_projectile", SpawnEnemyProjectile);
        lua.set_function("spawn_melee",            SpawnMelee);
        lua.set_function("kill_entity",            KillEntity);

        lua.set_function("load_map", LoadMap);

        lua.set_function("set_text",        SetText);
        lua.set_function("set_sprite",      SetSprite);
        lua.set_function("set_sprite_size", SetSpriteSize);
        lua.set_function("set_box_collider",SetBoxCollider);
        lua.set_function("set_alpha",       SetAlpha);
        lua.set_function("set_sprite_row",  SetSpriteRow);
        lua.set_function("play_animation",  PlayAnimation);

        lua.set_function("set_health",       SetHealth);
        lua.set_function("spawn_orc",        SpawnOrc);
        lua.set_function("spawn_goblin",         SpawnGoblin);
        lua.set_function("spawn_vampire_enemy",  SpawnVampireEnemy);

        lua.set_function("play_music", PlayMusic);
        lua.set_function("stop_music", StopMusic);
        lua.set_function("play_sfx",   PlaySFX);

        lua.set_function("get_text_width",    GetTextWidth);
        lua.set_function("set_sprite_width",  SetSpriteWidth);
        lua.set_function("set_visible",       SetVisible);
        lua.set_function("get_window_width",  GetWindowWidth);
        lua.set_function("get_window_height", GetWindowHeight);
        lua.set_function("get_camera_x",      GetCameraX);
        lua.set_function("get_camera_y",      GetCameraY);
        lua.set_function("get_mouse_x",       GetMouseX);
        lua.set_function("get_mouse_y",       GetMouseY);
    }

    /**
     * @brief Llama @c update(dt) en cada entidad que tenga ScriptComponent activo.
     *
     * Antes de cada llamada establece @c lua["this"] a la entidad actual,
     * de modo que el script puede referenciarse a sí mismo con la variable global @c this.
     *
     * @param lua Estado Lua compartido del motor.
     * @param dt  Delta time en segundos desde el frame anterior.
     */
    void Update(sol::state& lua, double dt) {
        for (auto entity : GetSystemEntities()) {
            const auto& script = entity.GetComponent<ScriptComponent>();

            if (script.update != sol::lua_nil) {
                lua["this"] = entity;
                script.update(dt);
            }
        }
    }
};


#endif // SCRIPT_SYSTEM_HPP
