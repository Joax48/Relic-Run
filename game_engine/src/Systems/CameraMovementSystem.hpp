#ifndef CAMARAMOVEMENTSYSTEM_HPP
#define CAMARAMOVEMENTSYSTEM_HPP

#include <algorithm>
#include <SDL2/SDL.h>

#include "../Components/CameraFollowComponent.hpp"
#include "../Components/TransformComponent.hpp"
#include "../ECS/ECS.hpp"
#include "../Game/Game.hpp"

class CameraMovementSystem : public System {
    public:
        CameraMovementSystem() {
            RequireComponent<CameraFollowComponent>();
            RequireComponent<TransformComponent>();
        }

        void Update(SDL_Rect& camera) {
            auto& game = Game::GetInstance();
            for (auto entity : GetSystemEntities()) {
                const auto& transform = entity.GetComponent<TransformComponent>();

                camera.x = static_cast<int>(transform.position.x) - camera.w / 2;
                camera.y = static_cast<int>(transform.position.y) - camera.h / 2;

                int maxX = game.mapWidth  - camera.w;
                int maxY = game.mapHeight - camera.h;

                camera.x = std::max(0, maxX > 0 ? std::min(camera.x, maxX) : 0);
                camera.y = std::max(0, maxY > 0 ? std::min(camera.y, maxY) : 0);
            }
        }
};

#endif // CAMARAMOVEMENTSYSTEM_HPP
