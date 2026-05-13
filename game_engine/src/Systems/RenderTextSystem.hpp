#ifndef RENDER_TEXT_SYSTEM_HPP
#define RENDER_TEXT_SYSTEM_HPP  

#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>

#include <memory>

#include "../AssetManager/AssetManager.hpp"
#include "../Components/TextComponent.hpp"
#include "../Components/TransformComponent.hpp"
#include "../ECS/ECS.hpp"


class RenderTextSystem : public System {
    public:
        RenderTextSystem() {
            RequireComponent<TextComponent>();
            RequireComponent<TransformComponent>();
    }
    void Update(SDL_Renderer* renderer, std::unique_ptr<AssetManager>& assetManager) {
        for (auto entity : GetSystemEntities()) {
            auto& text = entity.GetComponent<TextComponent>();
            auto& transform = entity.GetComponent<TransformComponent>();

            if (text.text.empty()) continue;

            SDL_Surface* surface = TTF_RenderText_Blended(assetManager->GetFont(text.fontId), text.text.c_str(), text.color);
            if (!surface) {
                std::cerr << "[RenderTextSystem] Error al crear la superficie de texto: " << TTF_GetError() << std::endl;
                continue;
            }
                
            text.width = surface->w;
            text.height = surface->h;

            SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surface);
            if (!texture) {
                std::cerr << "[RenderTextSystem] Error al crear la textura de texto: " << SDL_GetError() << std::endl;
                SDL_FreeSurface(surface);
                continue;
            }

            text.width = surface->w;
            text.height = surface->h;

            SDL_FreeSurface(surface);

            SDL_Rect dstRect = {
                static_cast<int>(transform.position.x),
                static_cast<int>(transform.position.y),
                text.width * static_cast<int>(transform.scale.x),
                text.height * static_cast<int>(transform.scale.y)
            };

            SDL_RenderCopy(renderer, texture, NULL, &dstRect);

            SDL_DestroyTexture(texture);
        }
    }

};

#endif // RENDER_TEXT_SYSTEM_HPP