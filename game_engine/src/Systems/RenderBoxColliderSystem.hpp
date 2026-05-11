#ifndef RENDERBOXCOLLIDERSYSTEM_HPP
#define RENDERBOXCOLLIDERSYSTEM_HPP

#include <SDL2/SDL.h>

#include "../Components/BoxColliderComponent.hpp"
#include "../Components/TagComponent.hpp"
#include "../Components/TransformComponent.hpp"
#include "../ECS/ECS.hpp"

class RenderBoxColliderSystem : public System {
    public:
        RenderBoxColliderSystem() {
            RequireComponent<BoxColliderComponent>();
            RequireComponent<TransformComponent>();
        }

        void Update(SDL_Renderer* renderer, SDL_Rect& camera) {
            for (auto entity : GetSystemEntities()) {
                const auto& transform = entity.GetComponent<TransformComponent>();
                const auto& collider  = entity.GetComponent<BoxColliderComponent>();

                SDL_Rect rect = {
                    static_cast<int>(transform.position.x + collider.offset.x) - camera.x,
                    static_cast<int>(transform.position.y + collider.offset.y) - camera.y,
                    collider.width,
                    collider.height
                };

                if (entity.hasComponent<TagComponent>()) {
                    const std::string& tag = entity.GetComponent<TagComponent>().tag;
                    if (tag == "wall")
                        SDL_SetRenderDrawColor(renderer, 255, 0,   0,   255); // rojo
                    else if (tag == "player")
                        SDL_SetRenderDrawColor(renderer, 0,   255, 0,   255); // verde
                    else
                        SDL_SetRenderDrawColor(renderer, 255, 255, 0,   255); // amarillo
                } else {
                    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255); // blanco
                }

                SDL_RenderDrawRect(renderer, &rect);
            }
        }
};

#endif // RENDERBOXCOLLIDERSYSTEM_HPP
