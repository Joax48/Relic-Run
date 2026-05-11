#ifndef RENDERHEALTHBARSYSTEM_HPP
#define RENDERHEALTHBARSYSTEM_HPP

#include <SDL2/SDL.h>
#include <algorithm>

#include "../Components/HealthBarComponent.hpp"
#include "../Components/SpriteComponent.hpp"
#include "../Components/TransformComponent.hpp"
#include "../ECS/ECS.hpp"

class RenderHealthBarSystem : public System {
public:
    RenderHealthBarSystem() {
        RequireComponent<HealthBarComponent>();
        RequireComponent<TransformComponent>();
        RequireComponent<SpriteComponent>();
    }

    void Update(SDL_Renderer* renderer, SDL_Rect& camera) {
        const int BAR_W = 40;
        const int BAR_H = 6;

        for (auto entity : GetSystemEntities()) {
            const auto& hb        = entity.GetComponent<HealthBarComponent>();
            const auto& transform = entity.GetComponent<TransformComponent>();
            const auto& sprite    = entity.GetComponent<SpriteComponent>();

            int renderedW = static_cast<int>(sprite.width  * transform.scale.x);
            int sx = static_cast<int>(transform.position.x) - camera.x + renderedW / 2 - BAR_W / 2;
            int sy = static_cast<int>(transform.position.y) - camera.y - BAR_H - 4;

            // Fondo oscuro
            SDL_SetRenderDrawColor(renderer, 60, 0, 0, 255);
            SDL_Rect bg = {sx, sy, BAR_W, BAR_H};
            SDL_RenderFillRect(renderer, &bg);

            // Relleno (verde → amarillo → rojo según HP)
            int fillW = std::max(0, BAR_W * hb.hp / std::max(1, hb.maxHp));
            Uint8 r = (hb.hp * 2 <= hb.maxHp) ? 200 : (hb.hp * 4 <= hb.maxHp * 3 ? 200 : 0);
            Uint8 g = (hb.hp * 2 <= hb.maxHp) ?   0 : (hb.hp * 4 <= hb.maxHp * 3 ? 200 : 200);
            SDL_SetRenderDrawColor(renderer, r, g, 0, 255);
            SDL_Rect fill = {sx, sy, fillW, BAR_H};
            SDL_RenderFillRect(renderer, &fill);

            // Borde blanco
            SDL_SetRenderDrawColor(renderer, 180, 180, 180, 255);
            SDL_RenderDrawRect(renderer, &bg);
        }
    }
};

#endif // RENDERHEALTHBARSYSTEM_HPP
