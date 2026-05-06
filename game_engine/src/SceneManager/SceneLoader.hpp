#ifndef SCENE_LOADER_HPP
#define SCENE_LOADER_HPP

#include <string>
#include <memory>

#include <sol/sol.hpp>
#include <SDL2/SDL.h>

#include "../AssetManager/AssetManager.hpp"
#include "../ControllerManager/ControllerManager.hpp"
#include "../ECS/ECS.hpp"

class SceneLoader {
    private:
        void LoadSprites(SDL_Renderer* renderer, const sol::table& sprites
            , std::unique_ptr<AssetManager>& assetManager);
        void LoadFonts(const sol::table& fonts, std::unique_ptr<AssetManager>& assetManager);
        void LoadKeys(const sol::table& keys, std::unique_ptr<ControllerManager>& controllerManager);
        void LoadButtons(const sol::table& buttons, std::unique_ptr<ControllerManager>& controllerManager);
        void LoadEntities(sol::state& lua, const sol::table& entities, std::unique_ptr<Registry>& registry);
    public:
        SceneLoader();
        ~SceneLoader();

        void LoadScene(const std::string& scenePath, sol::state& lua
            , std::unique_ptr<AssetManager>& assetManager
            , std::unique_ptr<ControllerManager>& controllerManager
            , std::unique_ptr<Registry>& registry, SDL_Renderer* renderer);
};

#endif // SCENE_LOADER_HPP