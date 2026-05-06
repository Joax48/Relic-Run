#include "Game.hpp"

#include <iostream>

#include "../Events/ClickEvent.hpp"

#include "../Systems/CircleCollisionSystem.hpp"
#include "../Systems/MovementSystem.hpp"
#include "../Systems/OverlapSystem.hpp"
#include "../Systems/PhysicsSystem.hpp"
#include "../Systems/RenderSystem.hpp"
// #include "../Systems/DamageSystem.hpp"
#include "../Systems/AnimationSystem.hpp"
#include "../Systems/ScriptSystem.hpp"
#include "../Systems/RenderTextSystem.hpp"
#include "../Systems/UISystem.hpp"
#include "../Systems/CameraMovementSystem.hpp"
#include "../Systems/BoxCollisionSystem.hpp"

// Constructor
Game::Game(){
    std::cout << "[GAME] Se ejecuta constructor" << std::endl;

    assetManager = std::make_unique<AssetManager>();
    eventManager = std::make_unique<EventManager>();
    controllerManager = std::make_unique<ControllerManager>();
    registry = std::make_unique<Registry>();
    sceneManager = std::make_unique<SceneManager>();

}

// Destructor
Game::~Game() {
    assetManager.reset();
    eventManager.reset();
    controllerManager.reset();
    registry.reset();
    sceneManager.reset();
    std::cout << "[GAME] Se ejecuta destructor" << std::endl;
}

Game& Game::GetInstance() {
    static Game game;
    return game;
}

// Inicializador
void Game::Init() {
    // Inicializar SDL2
    if (SDL_Init(SDL_INIT_EVERYTHING) != 0) {
        std::cerr << "[GAME] Error al inicializar SDL" << std::endl;
        return;
    }

    // Inicializar SDL2_ttf
    if (TTF_Init() != 0) {
        std::cerr << "[GAME] Error al inicializar SDL_ttf" << std::endl;
        return;
    }

    windowWidth = 800;
    windowHeight = 600;

    mapHeight = 2000;
    mapWidth = 2000;

    // Creacion de la ventana
    window = SDL_CreateWindow(
        "Game Engine",  //Titulo de la ventana
        SDL_WINDOWPOS_CENTERED,  // Pos x en la pantalla
        SDL_WINDOWPOS_CENTERED,  // Pos y en la pantalla
        windowWidth,  // Ancho
        windowHeight,  // Alto
        SDL_WINDOW_SHOWN  // Flags
    );

    if (!window) {
        std::cerr << "[GAME] Error al crear la ventana" << std::endl;
    }

    // Creacion del renderer
    renderer = SDL_CreateRenderer(
        window,
        -1, // Driver de la pantalla; [ The index of the rendering driver]
        0 // Banderas; 0 es sin banderas
    );

    if (!renderer) {
        std::cerr << "[GAME] Error al crear el renderer" << std::endl;
    }

    camera.x = 0;
    camera.y = 0;
    camera.w = windowWidth;
    camera.h = windowHeight;

    isRunning = true;
}

void Game::SetUp() {
    registry->AddSystem<AnimationSystem>();
    registry->AddSystem<CircleCollisionSystem>();
    registry->AddSystem<BoxCollisionSystem>();
    registry->AddSystem<RenderSystem>();
    registry->AddSystem<MovementSystem>();
    registry->AddSystem<OverlapSystem>();
    registry->AddSystem<PhysicsSystem>();
    // registry->AddSystem<DamageSystem>();
    registry->AddSystem<ScriptSystem>();
    registry->AddSystem<RenderTextSystem>();
    registry->AddSystem<UISystem>();
    registry->AddSystem<CameraMovementSystem>();
    sceneManager->LoadSCeneFromScript("./assets/scripts/scenes.lua", lua);

    lua.open_libraries(sol::lib::base, sol::lib::math);
    registry->GetSystem<ScriptSystem>().CreateLuaBinding(lua);

}


void Game::ProcessInput() {
        SDL_Event sdlEvent;

        while(SDL_PollEvent(&sdlEvent)) {
            switch (sdlEvent.type) {
            case SDL_QUIT:
                sceneManager->StopScene();
                isRunning = false;
                break;
            case SDL_KEYDOWN:
                if (sdlEvent.key.keysym.sym == SDLK_ESCAPE) {
                    sceneManager->StopScene();
                    isRunning = false;
                    break;
                }
                controllerManager->KeyDown(sdlEvent.key.keysym.sym);
                break;
            case SDL_KEYUP:
                controllerManager->KeyUp(sdlEvent.key.keysym.sym);
                break;
            case SDL_MOUSEBUTTONDOWN:
                controllerManager->SetMousePosition(sdlEvent.button.x, sdlEvent.button.y);
                controllerManager->MouseButtonDown(static_cast<int>(sdlEvent.button.button));
                std::cout << "Mouse button down: " << static_cast<int>(sdlEvent.button.button) << std::endl;
                eventManager->EmitEvent<ClickEvent>(sdlEvent.button.x, sdlEvent.button.y, static_cast<int>(sdlEvent.button.button));
                break;
            case SDL_MOUSEBUTTONUP:
                controllerManager->MouseButtonUp(static_cast<int>(sdlEvent.button.button));
                std::cout << "Mouse button up: " << static_cast<int>(sdlEvent.button.button) << std::endl;
                break;
            case SDL_MOUSEMOTION:
                int x, y;
                SDL_GetMouseState(&x, &y);
                controllerManager->SetMousePosition(x, y);
                break;
            default:
                break;
            }
        }
}

void Game::Update() {
    int timeToWait = FRAME_DELAY - (SDL_GetTicks() - milisPreviousFrame);

    if (timeToWait > 0 && timeToWait <= FRAME_DELAY) {
        SDL_Delay(timeToWait);
    }

    double dt = (SDL_GetTicks() - milisPreviousFrame) / 1000.0;
    
    milisPreviousFrame = SDL_GetTicks();

    // Reiniciar las subscripciones a eventos para evitar que se acumulen
    eventManager->Reset();
    // registry->GetSystem<DamageSystem>().SubscribeToCollisionEvent(eventManager);

    registry->GetSystem<OverlapSystem>().SubscribeToCollisionEvent(eventManager);
    registry->GetSystem<UISystem>().SubscribeToClickEvent(eventManager);

    registry->Update();

    registry->GetSystem<ScriptSystem>().Update(lua);

    registry->GetSystem<PhysicsSystem>().Update();
    registry->GetSystem<MovementSystem>().Update(dt);    
    registry->GetSystem<BoxCollisionSystem>().Update(lua, eventManager); 
    registry->GetSystem<CircleCollisionSystem>().Update(eventManager);

    registry->GetSystem<AnimationSystem>().Update();    
    registry->GetSystem<CameraMovementSystem>().Update(camera);
}

void Game::Render() {
    SDL_SetRenderDrawColor(renderer, 31, 31, 31, 255);
    SDL_RenderClear(renderer);

    registry->GetSystem<RenderSystem>().Update(renderer,camera, assetManager);
    registry->GetSystem<RenderTextSystem>().Update(renderer, assetManager);

    SDL_RenderPresent(renderer);
}

void Game::RunScene() {
    sceneManager->LoadScene();
    while (sceneManager->IsSceneRunning()){
        ProcessInput();
        Update();
        Render();
    }
    assetManager->ClearAssets();
    registry->ClearAllEntities();
}

void Game::Run() {
    SetUp();
    while (isRunning) {
        sceneManager->StartScene();
        RunScene();
    }

}

// Destructor de objetos en juego
void Game::Destroy() {
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    TTF_Quit();
    SDL_Quit();
}