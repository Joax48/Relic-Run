#ifndef SCENE_MANAGER_HPP
#define SCENE_MANAGER_HPP

#include <map>
#include <string>
#include <memory>
#include <sol/sol.hpp>

#include "SceneLoader.hpp"

/**
 * @class SceneManager
 * @brief Controla el ciclo de vida de las escenas del juego.
 *
 * Mantiene un registro de nombre → ruta de script Lua para cada escena
 * (cargado desde @c scenes.lua al inicio). Cuando un script Lua llama
 * @c go_to_scene("level_02"), SceneManager registra la próxima escena y
 * detiene la actual; el bucle de Game::RunScene() detecta el cambio,
 * limpia assets y entidades, y carga la nueva escena.
 *
 * @par Flujo de transición
 * @code
 * go_to_scene("level_02")          // desde Lua
 *   → SetNextScene("level_02")
 *   → StopScene()
 * // Game::RunScene detecta !IsSceneRunning()
 *   → assetManager->ClearAssets()
 *   → registry->ClearAllEntities()
 *   → LoadScene()  →  SceneLoader::Load()
 * @endcode
 */
class SceneManager {
    private:
        /// Registro name → ruta al script Lua de la escena.
        std::map<std::string, std::string> scenes;
        std::string nextScene;              ///< Nombre de la escena a cargar en el próximo ciclo.
        bool isSceneRUnning = false;        ///< Flag que controla el bucle interno de RunScene().
        std::unique_ptr<SceneLoader> sceneLoader; ///< Cargador que interpreta la tabla Lua @c scene{}.

    public:
        SceneManager();
        ~SceneManager();

        /**
         * @brief Lee el archivo @c scenes.lua y registra todos los pares nombre/ruta.
         * Llamado una vez desde Game::SetUp().
         * @param path Ruta al archivo scenes.lua.
         * @param lua  Estado Lua compartido del motor.
         */
        void LoadSCeneFromScript(const std::string path, sol::state& lua);

        /**
         * @brief Ejecuta el script de la escena activa y construye sus entidades.
         * Delega en SceneLoader::Load() para parsear la tabla @c scene{} de Lua.
         */
        void LoadScene();

        /** @return Nombre de la próxima escena a cargar. */
        std::string GetNextScene() const;

        /**
         * @brief Establece la escena que se cargará tras detener la actual.
         * @param nextScene Nombre registrado en scenes.lua.
         */
        void SetNextScene(const std::string& nextScene);

        /** @return true si el bucle interno de la escena sigue activo. */
        bool IsSceneRunning() const;

        /** @brief Marca la escena como activa e inicializa el flag de bucle. */
        void StartScene();

        /** @brief Interrumpe el bucle interno de la escena. */
        void StopScene();
};

#endif // SCENE_MANAGER_HPP
