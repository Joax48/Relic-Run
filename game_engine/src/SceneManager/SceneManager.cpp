#include "SceneManager.hpp"

#include <iostream>

#include "../Game/Game.hpp"

SceneManager::SceneManager() {
    std::cout << "[SCENEMANAGER] Se ejecuta constructor" << std::endl;
    sceneLoader = std::make_unique<SceneLoader>();
}

SceneManager::~SceneManager() {
    sceneLoader.reset();
    std::cout << "[SCENEMANAGER] Se ejecuta destructor" << std::endl;
}

void SceneManager::LoadSCeneFromScript(const std::string path, sol::state& lua) {
    // TODO: Verificar que el codigo sea correcto
    lua.script_file(path);

    sol::table scenes = lua["scenes"];

    int index = 0;
    while (true) {
        sol::optional<sol::table> hasScenes = scenes[index];
        if (hasScenes == sol::nullopt) {
            break;
        }

        sol::table scene = scenes[index];

        this->scenes.emplace(scene["name"], scene["path"]);

        if (index == 0) {
            nextScene = scene["name"];
        }

        index++;
    }
    
}

void SceneManager::LoadScene() {
    Game& game = Game::GetInstance();
    std::string scenePath = scenes[nextScene];
    sceneLoader->LoadScene(scenePath, game.lua, game.assetManager, game.controllerManager, game.registry, game.renderer);
}

std::string SceneManager::GetNextScene() const {
    return nextScene;
}

void SceneManager::SetNextScene(const std::string& nextScene) {
    this->nextScene = nextScene;
}

bool SceneManager::IsSceneRunning() const {
    return isSceneRUnning;
}

void SceneManager::StartScene() {
    isSceneRUnning = true;
}

void SceneManager::StopScene() {
    isSceneRUnning = false;
}