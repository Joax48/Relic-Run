#include "Game.hpp"

#include <iostream>
#include <string>
#include <algorithm>

#include "../Events/ClickEvent.hpp"

#include "../Systems/CircleCollisionSystem.hpp"
#include "../Systems/MovementSystem.hpp"
#include "../Systems/OverlapSystem.hpp"
#include "../Systems/PhysicsSystem.hpp"
#include "../Systems/RenderSystem.hpp"
#include "../Systems/AnimationSystem.hpp"
#include "../Systems/ScriptSystem.hpp"
#include "../Systems/RenderTextSystem.hpp"
#include "../Systems/UISystem.hpp"
#include "../Systems/CameraMovementSystem.hpp"
#include "../Systems/BoxCollisionSystem.hpp"
#include "../Systems/RenderBoxColliderSystem.hpp"
#include "../Systems/RenderHealthBarSystem.hpp"

// ─── Constructor / Destructor ────────────────────────────────────────────────

Game::Game(){
    std::cout << "[GAME] Se ejecuta constructor" << std::endl;
    assetManager      = std::make_unique<AssetManager>();
    audioManager      = std::make_unique<AudioManager>();
    eventManager      = std::make_unique<EventManager>();
    controllerManager = std::make_unique<ControllerManager>();
    registry          = std::make_unique<Registry>();
    sceneManager      = std::make_unique<SceneManager>();
}

Game::~Game() {
    assetManager.reset();
    audioManager.reset();
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

// ─── Init ────────────────────────────────────────────────────────────────────

void Game::Init() {
    if (SDL_Init(SDL_INIT_EVERYTHING) != 0) {
        std::cerr << "[GAME] Error al inicializar SDL" << std::endl;
        return;
    }
    if (TTF_Init() != 0) {
        std::cerr << "[GAME] Error al inicializar SDL_ttf" << std::endl;
        return;
    }
    if (Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048) != 0) {
        std::cerr << "[GAME] Error al inicializar SDL_mixer: " << Mix_GetError() << std::endl;
    }
    Mix_Init(MIX_INIT_OGG);

    windowWidth  = 800;
    windowHeight = 600;
    mapHeight    = 2000;
    mapWidth     = 2000;

    window = SDL_CreateWindow(
        "Relic Run",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        windowWidth, windowHeight,
        SDL_WINDOW_SHOWN
    );
    if (!window) std::cerr << "[GAME] Error al crear la ventana" << std::endl;

    renderer = SDL_CreateRenderer(window, -1,
        SDL_RENDERER_ACCELERATED | SDL_RENDERER_TARGETTEXTURE);
    if (!renderer) std::cerr << "[GAME] Error al crear el renderer" << std::endl;

    camera = {0, 0, windowWidth, windowHeight};
    isRunning = true;

    pauseFont      = TTF_OpenFont("./assets/fonts/PressStart.ttf", 32);
    pauseSmallFont = TTF_OpenFont("./assets/fonts/PressStart.ttf", 16);
}

// ─── SetUp ───────────────────────────────────────────────────────────────────

void Game::SetUp() {
    registry->AddSystem<AnimationSystem>();
    registry->AddSystem<CircleCollisionSystem>();
    registry->AddSystem<BoxCollisionSystem>();
    registry->AddSystem<RenderSystem>();
    registry->AddSystem<MovementSystem>();
    registry->AddSystem<OverlapSystem>();
    registry->AddSystem<PhysicsSystem>();
    registry->AddSystem<ScriptSystem>();
    registry->AddSystem<RenderTextSystem>();
    registry->AddSystem<UISystem>();
    registry->AddSystem<CameraMovementSystem>();
    registry->AddSystem<RenderBoxColliderSystem>();
    registry->AddSystem<RenderHealthBarSystem>();

    sceneManager->LoadSCeneFromScript("./assets/scripts/scenes.lua", lua);
    lua.open_libraries(sol::lib::base, sol::lib::math);
    registry->GetSystem<ScriptSystem>().CreateLuaBinding(lua);
}

// ─── ProcessInput ────────────────────────────────────────────────────────────

void Game::ProcessInput() {
    controllerManager->ResetJustPressed();
    SDL_Event sdlEvent;
    while (SDL_PollEvent(&sdlEvent)) {
        switch (sdlEvent.type) {

        case SDL_QUIT:
            sceneManager->StopScene();
            isRunning = false;
            break;

        case SDL_KEYDOWN:
            if (sdlEvent.key.keysym.sym == SDLK_F1) {
                showColliders = !showColliders;
                break;
            }
            if (sdlEvent.key.keysym.sym == SDLK_ESCAPE) {
                isPaused = !isPaused;
                if (isPaused) {
                    audioManager->PlaySFX("./assets/audio/effects/092_Pause_04.wav");
                } else {
                    audioManager->PlaySFX("./assets/audio/effects/098_Unpause_04.wav");
                    milisPreviousFrame = SDL_GetTicks();
                }
                break;
            }
            if (!isPaused) controllerManager->KeyDown(sdlEvent.key.keysym.sym);
            break;

        case SDL_KEYUP:
            if (!isPaused) controllerManager->KeyUp(sdlEvent.key.keysym.sym);
            break;

        case SDL_MOUSEBUTTONDOWN: {
            int mx = sdlEvent.button.x;
            int my = sdlEvent.button.y;

            if (isPaused) {
                // ── Botones del menú de pausa ──────────────────────────────
                auto hit = [&](int i) {
                    return pauseBtn[i].w > 0
                        && mx >= pauseBtn[i].x && mx < pauseBtn[i].x + pauseBtn[i].w
                        && my >= pauseBtn[i].y && my < pauseBtn[i].y + pauseBtn[i].h;
                };
                if (hit(0)) {                           // CONTINUAR
                    isPaused = false;
                    milisPreviousFrame = SDL_GetTicks();
                } else if (hit(1)) {                    // REINTENTAR
                    isPaused = false;
                    sceneManager->StopScene();
                } else if (hit(2)) {                    // MENÚ PRINCIPAL
                    isPaused = false;
                    sceneManager->SetNextScene("main_menu");
                    sceneManager->StopScene();
                }
            } else {
                controllerManager->SetMousePosition(mx, my);
                controllerManager->MouseButtonDown(static_cast<int>(sdlEvent.button.button));
                eventManager->EmitEvent<ClickEvent>(mx, my, static_cast<int>(sdlEvent.button.button));
            }
            break;
        }

        case SDL_MOUSEBUTTONUP:
            if (!isPaused) {
                controllerManager->MouseButtonUp(static_cast<int>(sdlEvent.button.button));
            }
            break;

        case SDL_MOUSEMOTION: {
            controllerManager->SetMousePosition(sdlEvent.motion.x, sdlEvent.motion.y);
            break;
        }

        default:
            break;
        }
    }
}

// ─── Update ──────────────────────────────────────────────────────────────────

void Game::Update() {
    int timeToWait = FRAME_DELAY - (SDL_GetTicks() - milisPreviousFrame);
    if (timeToWait > 0 && timeToWait <= FRAME_DELAY) SDL_Delay(timeToWait);

    double dt = (SDL_GetTicks() - milisPreviousFrame) / 1000.0;
    if (dt > 0.05) dt = 0.05;
    milisPreviousFrame = SDL_GetTicks();

    eventManager->Reset();
    registry->GetSystem<OverlapSystem>().SubscribeToCollisionEvent(eventManager);
    registry->GetSystem<UISystem>().SubscribeToClickEvent(eventManager);

    registry->Update();
    registry->GetSystem<ScriptSystem>().Update(lua, dt);
    registry->GetSystem<PhysicsSystem>().Update();
    registry->GetSystem<MovementSystem>().Update(dt);
    registry->GetSystem<BoxCollisionSystem>().Update(lua, eventManager);
    registry->GetSystem<CircleCollisionSystem>().Update(eventManager);
    registry->GetSystem<AnimationSystem>().Update();
    registry->GetSystem<CameraMovementSystem>().Update(camera);
}

// ─── Render helpers ──────────────────────────────────────────────────────────

static SDL_Rect RenderCenteredText(SDL_Renderer* rdr, TTF_Font* font,
                                   const char* text, SDL_Color col,
                                   int winW, int y) {
    SDL_Surface* surf = TTF_RenderText_Solid(font, text, col);
    if (!surf) return {0, 0, 0, 0};
    SDL_Texture* tex  = SDL_CreateTextureFromSurface(rdr, surf);
    SDL_Rect dst = {(winW - surf->w) / 2, y, surf->w, surf->h};
    SDL_FreeSurface(surf);
    SDL_RenderCopy(rdr, tex, nullptr, &dst);
    SDL_DestroyTexture(tex);
    return dst;
}

// ─── Render ──────────────────────────────────────────────────────────────────

void Game::Render() {
    SDL_SetRenderDrawColor(renderer, 31, 31, 31, 255);
    SDL_RenderClear(renderer);

    registry->GetSystem<RenderSystem>().Update(renderer, camera, assetManager);
    registry->GetSystem<RenderTextSystem>().Update(renderer, assetManager);
    registry->GetSystem<RenderHealthBarSystem>().Update(renderer, camera);

    if (showColliders)
        registry->GetSystem<RenderBoxColliderSystem>().Update(renderer, camera);

    // ── Time-slow overlay ─────────────────────────────────────────────────────
    bool timeSlow = lua["time_slow"].get_or(false);
    if (timeSlow) {
        SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
        SDL_SetRenderDrawColor(renderer, 0, 80, 220, 55);
        SDL_Rect ov = {0, 0, windowWidth, windowHeight};
        SDL_RenderFillRect(renderer, &ov);
        SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE);
    }

    // ── HP bar (solo en escenas de nivel) ─────────────────────────────────────
    std::string sceneName = sceneManager->GetNextScene();
    bool isLevel = (sceneName.find("level") != std::string::npos);
    if (isLevel) {
        sol::object hp_obj = lua["player_hp"];
        if (hp_obj.get_type() == sol::type::number) {
            int hp     = hp_obj.as<int>();
            int max_hp = 5;

            // Posición fija top-left
            const int BAR_X = 14, BAR_Y = 14, BAR_W = 104, BAR_H = 11;

            SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);

            // Fondo
            SDL_SetRenderDrawColor(renderer, 30, 30, 30, 210);
            SDL_Rect bg = {BAR_X, BAR_Y, BAR_W, BAR_H};
            SDL_RenderFillRect(renderer, &bg);

            // Relleno (verde → amarillo → rojo)
            int fillW = std::max(0, BAR_W * hp / max_hp);
            Uint8 r = (hp <= 1) ? 210 : (hp <= 3 ? 200 : 30);
            Uint8 g = (hp <= 1) ?   0 : (hp <= 3 ? 160 :180);
            SDL_SetRenderDrawColor(renderer, r, g, 20, 255);
            SDL_Rect fill = {BAR_X, BAR_Y, fillW, BAR_H};
            SDL_RenderFillRect(renderer, &fill);

            // Borde
            SDL_SetRenderDrawColor(renderer, 180, 180, 180, 200);
            SDL_RenderDrawRect(renderer, &bg);

            SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE);
        }
    }

    // ── Menú de pausa ─────────────────────────────────────────────────────────
    if (isPaused && pauseFont && pauseSmallFont) {
        SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 170);
        SDL_Rect ov = {0, 0, windowWidth, windowHeight};
        SDL_RenderFillRect(renderer, &ov);
        SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE);

        // Título "PAUSA"
        SDL_Color white  = {255, 255, 255, 255};
        SDL_Color gray   = {190, 190, 190, 255};
        SDL_Color green  = {80,  210, 100, 255};

        RenderCenteredText(renderer, pauseFont, "PAUSA", white, windowWidth, 190);

        // Línea separadora
        SDL_SetRenderDrawColor(renderer, 120, 120, 120, 255);
        SDL_RenderDrawLine(renderer, windowWidth/2 - 80, 250, windowWidth/2 + 80, 250);

        // Botones (centrados, guardamos sus rects para click detection)
        struct { const char* label; SDL_Color col; int y; } btns[3] = {
            {"CONTINUAR",      green, 285},
            {"REINTENTAR",     gray,  345},
            {"MENU PRINCIPAL", gray,  405},
        };
        for (int i = 0; i < 3; i++) {
            pauseBtn[i] = RenderCenteredText(renderer, pauseSmallFont,
                                             btns[i].label, btns[i].col,
                                             windowWidth, btns[i].y);
        }
    }

    SDL_RenderPresent(renderer);
}

// ─── RunScene ────────────────────────────────────────────────────────────────

void Game::RunScene() {
    sceneManager->LoadScene();
    while (sceneManager->IsSceneRunning()) {
        ProcessInput();
        if (!isPaused) Update();
        Render();
    }
    isPaused = false;
    assetManager->ClearAssets();
    registry->ClearAllEntities();
    controllerManager->Clear();
    camera.x = 0;
    camera.y = 0;
}

// ─── Run / Destroy ───────────────────────────────────────────────────────────

void Game::Run() {
    SetUp();
    while (isRunning) {
        sceneManager->StartScene();
        RunScene();
    }
}

void Game::Destroy() {
    if (pauseFont)      TTF_CloseFont(pauseFont);
    if (pauseSmallFont) TTF_CloseFont(pauseSmallFont);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    TTF_Quit();
    Mix_CloseAudio();
    Mix_Quit();
    SDL_Quit();
}
