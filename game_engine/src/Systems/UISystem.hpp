#ifndef UISYSTEM_HPP
#define UISYSTEM_HPP

#include <SDL2/SDL.h>

#include <memory>
#include <string>
#include <iostream>

#include "../ECS/ECS.hpp"
#include "../Components/ClickableComponent.hpp"
#include "../Components/TextComponent.hpp"
#include "../Components/TransformComponent.hpp"
#include "../Components/ScriptComponent.hpp"
#include "../EventManager/EventManager.hpp"
#include "../Events/ClickEvent.hpp"

class UISystem : public System {
    public:
        UISystem() {
            RequireComponent<ClickableComponent>();
            RequireComponent<TextComponent>();
            RequireComponent<TransformComponent>();
        }

        void SubscribeToClickEvent(std::unique_ptr<EventManager>& eventManager) {
            eventManager->SubscribeToEvent<ClickEvent, UISystem>(this, &UISystem::OnClickEvent);
        }

        void OnClickEvent(ClickEvent& e) {
            for (auto entity : GetSystemEntities()) {
                auto& transform = entity.GetComponent<TransformComponent>();
                auto& text = entity.GetComponent<TextComponent>();
                auto& clickable = entity.GetComponent<ClickableComponent>();

                // Verificar si el clic está dentro del área del texto
                if (e.posX > transform.position.x &&
                    e.posX < transform.position.x + text.width &&
                    e.posY > transform.position.y &&
                    e.posY < transform.position.y + text.height) {
                    clickable.isClicked = true;
                    if(entity.hasComponent<ScriptComponent>()) {
                        const auto& script = entity.GetComponent<ScriptComponent>();
                        if (script.on_click != sol::lua_nil) {
                            script.on_click();
                        }
                    }
                }
            }
        }
    };

#endif // UISYSTEM_HPP