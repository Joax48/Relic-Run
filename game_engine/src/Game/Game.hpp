#ifndef GAME_HPP
#define GAME_HPP

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>

#include <sol/sol.hpp>

#include <memory>

#include "../AssetManager/AssetManager.hpp"
#include "../ControllerManager/ControllerManager.hpp"
#include "../EventManager/EventManager.hpp"
#include "../ECS/ECS.hpp"
#include "../SceneManager/SceneManager.hpp"

const int FPS = 30;
const int FRAME_DELAY = 1000 / FPS;

class Game {
    private:
        SDL_Window* window = nullptr;

        SDL_Rect camera = {0, 0, 0, 0};

        int milisPreviousFrame = 0;

        bool isRunning = false;
        bool isPaused  = false;

        TTF_Font* pauseFont = nullptr;

    public:
        SDL_Renderer* renderer = nullptr;

        std::unique_ptr<AssetManager> assetManager;
        std::unique_ptr<EventManager> eventManager;
        std::unique_ptr<Registry> registry;
        std::unique_ptr<ControllerManager> controllerManager;
        std::unique_ptr<SceneManager> sceneManager;

        sol::state lua;


        int windowWidth = 0;
        int windowHeight = 0;

        int mapWidth = 0;
        int mapHeight = 0;

    private:
        void SetUp();
        void RunScene();
        void ProcessInput();
        void Update();
        void Render();
        Game();
        ~Game();

    public:
        static Game& GetInstance();
        
        void Init();
        void Run();
        void Destroy();
};

#endif // GAME_HPP