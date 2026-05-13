#ifndef GAME_HPP
#define GAME_HPP

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>
#include <SDL2/SDL_mixer.h>

#include <sol/sol.hpp>

#include <memory>

#include "../AssetManager/AssetManager.hpp"
#include "../AudioManager/AudioManager.hpp"
#include "../ControllerManager/ControllerManager.hpp"
#include "../EventManager/EventManager.hpp"
#include "../ECS/ECS.hpp"
#include "../SceneManager/SceneManager.hpp"

const int FPS = 60;
const int FRAME_DELAY = 1000 / FPS;

class Game {
    private:
        SDL_Window* window          = nullptr;
        int  milisPreviousFrame     = 0;
        bool isRunning              = false;
        bool showColliders          = false;

        TTF_Font* pauseFont         = nullptr;   // 32pt — "PAUSA"
        TTF_Font* pauseSmallFont    = nullptr;   // 18pt — botones del menú de pausa

        // Rects de los botones del menú de pausa (calculados en Render, usados en ProcessInput)
        SDL_Rect pauseBtn[3]        = {};        // 0=continuar, 1=reintentar, 2=menú

    public:
        SDL_Renderer* renderer = nullptr;

        // camera es public para que LuaBinding pueda leerla con get_camera_x/y
        SDL_Rect camera        = {0, 0, 0, 0};
        bool     isPaused      = false;

        std::unique_ptr<AssetManager>     assetManager;
        std::unique_ptr<AudioManager>     audioManager;
        std::unique_ptr<EventManager>     eventManager;
        std::unique_ptr<Registry>         registry;
        std::unique_ptr<ControllerManager> controllerManager;
        std::unique_ptr<SceneManager>     sceneManager;

        sol::state lua;

        int windowWidth  = 0;
        int windowHeight = 0;
        int mapWidth     = 0;
        int mapHeight    = 0;

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
