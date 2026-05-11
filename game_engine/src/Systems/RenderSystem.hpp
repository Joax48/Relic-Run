#ifndef RENDERSYSTEM_HPP
#define RENDERSYSTEM_HPP

#include <algorithm>
#include <SDL2/SDL.h>

#include "../AssetManager/AssetManager.hpp"
#include "../Components/SpriteComponent.hpp"
#include "../Components/TransformComponent.hpp"
#include "../ECS/ECS.hpp"

class RenderSystem: public System {
    public:
        RenderSystem() {
            RequireComponent<SpriteComponent>();
            RequireComponent<TransformComponent>();
        }

        void Update(SDL_Renderer* renderer, SDL_Rect& camera
            , const std::unique_ptr<AssetManager>& AssetManager) {

                auto entities = GetSystemEntities();
                std::stable_sort(entities.begin(), entities.end(), [](const Entity& a, const Entity& b) {
                    return a.GetComponent<SpriteComponent>().zIndex <
                           b.GetComponent<SpriteComponent>().zIndex;
                });

                for (auto entity : entities) {
                    const auto sprite = entity.GetComponent<SpriteComponent>();
                    const auto transform = entity.GetComponent<TransformComponent>();

                    SDL_Rect srcRect = sprite.srcRect;
                    SDL_Rect dstRect = {
                        static_cast<int>(transform.position.x - camera.x),
                        static_cast<int>(transform.position.y - camera.y),
                        static_cast<int>(sprite.width * transform.scale.x),
                        static_cast<int>(sprite.height * transform.scale.y)
                    };

                    SDL_Texture* tex = AssetManager->GetTexture(sprite.textureId);
                    SDL_SetTextureAlphaMod(tex, sprite.alpha);
                    SDL_RenderCopyEx(
                        renderer,
                        tex,
                        &srcRect,
                        &dstRect,
                        transform.rotation,
                        NULL,
                        SDL_FLIP_NONE
                    );
                    SDL_SetTextureAlphaMod(tex, 255);
                }
        }
};

#endif // RENDERSYSTEM_HPP