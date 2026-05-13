#ifndef SCRIPT_SYSTEM_HPP
#define SCRIPT_SYSTEM_HPP

#include <memory>
#include <sol/sol.hpp>

#include "../Binding/LuaBinding.hpp"
#include "../Components/ScriptComponent.hpp"
#include "../ECS/ECS.hpp"

class ScriptSystem : public System {
public:
    ScriptSystem() {
        RequireComponent<ScriptComponent>();
    }

    void CreateLuaBinding(sol::state& lua) {
        // Classes
        lua.new_usertype<Entity>("entity");

        // Functions
        lua.set_function("is_action_activated", IsActionActived);

        lua.set_function("set_velocity", SetVelocity);
        lua.set_function("get_velocity", GetVelocity);

        lua.set_function("get_tag", GetTag);

        lua.set_function("get_position", GetPosition);
        lua.set_function("set_position", SetPosition);

        lua.set_function("get_size", GetSize);

        lua.set_function("go_to_scene", GoToScene);

        lua.set_function("left_collision", LeftCollision);
        lua.set_function("right_collision", RightCollision);
        lua.set_function("up_collision", UpCollision);
        lua.set_function("down_collision", DownCollision);

        lua.set_function("spawn_projectile", SpawnProjectile);
        lua.set_function("spawn_enemy_projectile", SpawnEnemyProjectile);
        lua.set_function("spawn_melee", SpawnMelee);
        lua.set_function("kill_entity", KillEntity);

        lua.set_function("load_map", LoadMap);

        lua.set_function("set_text", SetText);
        lua.set_function("set_sprite", SetSprite);
        lua.set_function("set_sprite_size", SetSpriteSize);
        lua.set_function("set_box_collider", SetBoxCollider);
        lua.set_function("set_alpha", SetAlpha);
        lua.set_function("set_sprite_row", SetSpriteRow);
        lua.set_function("play_animation", PlayAnimation);

        lua.set_function("set_health", SetHealth);
        lua.set_function("spawn_orc", SpawnOrc);
        lua.set_function("spawn_goblin",          SpawnGoblin);
        lua.set_function("spawn_vampire_enemy",   SpawnVampireEnemy);

        lua.set_function("play_music", PlayMusic);
        lua.set_function("stop_music", StopMusic);
        lua.set_function("play_sfx",   PlaySFX);

        lua.set_function("get_text_width",    GetTextWidth);
        lua.set_function("set_sprite_width", SetSpriteWidth);
        lua.set_function("set_visible",      SetVisible);
        lua.set_function("get_window_width",  GetWindowWidth);
        lua.set_function("get_window_height", GetWindowHeight);
        lua.set_function("get_camera_x",      GetCameraX);
        lua.set_function("get_camera_y",      GetCameraY);
        lua.set_function("get_mouse_x",       GetMouseX);
        lua.set_function("get_mouse_y",       GetMouseY);
    }

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