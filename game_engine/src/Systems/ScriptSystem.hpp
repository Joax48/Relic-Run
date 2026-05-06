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

    }

    void Update(sol::state& lua) {
        for (auto entity : GetSystemEntities()) {
            const auto& script = entity.GetComponent<ScriptComponent>();
            
            if (script.update != sol::lua_nil) {
                lua["this"] = entity;
                script.update();
            }
        }
    }   
};


#endif // SCRIPT_SYSTEM_HPP