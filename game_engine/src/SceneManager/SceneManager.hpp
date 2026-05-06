#ifndef SCENE_MANAGER_HPP
#define SCENE_MANAGER_HPP

#include <map>
#include <string>
#include <memory>
#include <sol/sol.hpp>

#include "SceneLoader.hpp"

class SceneManager {
    private:
        std::map<std::string, std::string> scenes;
        std::string nextScene;
        bool isSceneRUnning = false;
        std::unique_ptr<SceneLoader> sceneLoader;

    public:
        SceneManager();
        ~SceneManager();

        void LoadSCeneFromScript(const std::string path, sol::state& lua);
        void LoadScene();

        std::string GetNextScene() const;
        void SetNextScene(const std::string& nextScene);

        bool IsSceneRunning() const;
        void StartScene();
        void StopScene();

};


#endif // SCENE_MANAGER_HPP