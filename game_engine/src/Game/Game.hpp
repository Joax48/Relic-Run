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

/** @brief Fotogramas por segundo objetivo del bucle principal. */
const int FPS = 60;

/** @brief Milisegundos que debe durar cada frame (1000 / FPS). */
const int FRAME_DELAY = 1000 / FPS;

/**
 * @class Game
 * @brief Punto de entrada y núcleo del motor. Singleton que posee todos los subsistemas.
 *
 * Inicializa SDL2 y sus extensiones (image, ttf, mixer), crea la ventana y el renderer,
 * instancia los managers (assets, audio, ECS, escenas, input) y ejecuta el bucle
 * principal: ProcessInput → Update → Render.
 *
 * La instancia única se obtiene con Game::GetInstance(). Los atributos públicos
 * (renderer, camera, managers) son accedidos directamente por LuaBinding para
 * exponer funcionalidad a los scripts Lua.
 *
 * @par Ciclo de vida
 * @code
 * Game::GetInstance().Init();
 * Game::GetInstance().Run();
 * Game::GetInstance().Destroy();
 * @endcode
 */
class Game {
    private:
        SDL_Window* window          = nullptr; ///< Ventana SDL creada en Init().
        int  milisPreviousFrame     = 0;       ///< Timestamp del frame anterior (ms).
        bool isRunning              = false;   ///< Controla el bucle principal.
        bool showColliders          = false;   ///< Activa la superposición de debug de colisores (F1).

        TTF_Font* pauseFont         = nullptr; ///< Fuente 32pt para el texto "PAUSA".
        TTF_Font* pauseSmallFont    = nullptr; ///< Fuente 18pt para los botones del menú de pausa.

        /// Rectángulos de los botones del menú de pausa: [0]=Continuar, [1]=Reintentar, [2]=Menú.
        SDL_Rect pauseBtn[3]        = {};

    public:
        SDL_Renderer* renderer = nullptr; ///< Renderer SDL usado por todos los sistemas de render.

        /// Rectángulo de la cámara en coordenadas de mundo. Público para que LuaBinding lo lea.
        SDL_Rect camera        = {0, 0, 0, 0};
        bool     isPaused      = false; ///< Estado de pausa; pausar congela Update pero no Render.

        std::unique_ptr<AssetManager>      assetManager;      ///< Caché de texturas y fuentes.
        std::unique_ptr<AudioManager>      audioManager;      ///< Reproducción de música y SFX.
        std::unique_ptr<EventManager>      eventManager;      ///< Bus de eventos Pub/Sub.
        std::unique_ptr<Registry>          registry;          ///< Registro ECS de entidades y sistemas.
        std::unique_ptr<ControllerManager> controllerManager; ///< Estado del teclado y ratón.
        std::unique_ptr<SceneManager>      sceneManager;      ///< Carga y transición de escenas Lua.

        sol::state lua; ///< Máquina virtual Lua compartida por todos los scripts.

        int windowWidth  = 0; ///< Ancho de la ventana en píxeles.
        int windowHeight = 0; ///< Alto de la ventana en píxeles.
        int mapWidth     = 0; ///< Ancho del mapa activo en píxeles (leído por LuaBinding).
        int mapHeight    = 0; ///< Alto del mapa activo en píxeles (leído por LuaBinding).

    private:
        /**
         * @brief Registra sistemas ECS, carga scenes.lua y abre las bibliotecas Lua estándar.
         * Llamado una sola vez desde Init().
         */
        void SetUp();

        /**
         * @brief Bucle interno de una escena: llama LoadScene(), luego itera
         * ProcessInput/Update/Render hasta que la escena se detiene.
         */
        void RunScene();

        /**
         * @brief Procesa eventos SDL (teclado, ratón, cierre de ventana) y los
         * delega al ControllerManager. Llama ResetJustPressed al inicio.
         */
        void ProcessInput();

        /**
         * @brief Ejecuta todos los sistemas ECS en orden: Script → Physics →
         * Movement → Collision → Animation → Camera.
         */
        void Update();

        /**
         * @brief Limpia el buffer, ejecuta los sistemas de render y muestra el frame.
         * Si el juego está pausado, superpone el menú de pausa.
         */
        void Render();

        Game();  ///< Constructor privado (Singleton).
        ~Game(); ///< Destructor privado; llama a Destroy() si aún está activo.

    public:
        /**
         * @brief Devuelve la única instancia del juego (Singleton de Meyer).
         * @return Referencia a la instancia global de Game.
         */
        static Game& GetInstance();

        /**
         * @brief Inicializa SDL2, crea ventana/renderer y llama SetUp().
         * Debe llamarse antes que Run().
         */
        void Init();

        /**
         * @brief Bucle externo: itera escenas llamando a RunScene() hasta que
         * el juego se cierre o no haya más escenas.
         */
        void Run();

        /**
         * @brief Libera todos los recursos SDL y cierra los subsistemas.
         * Llamar al finalizar Run().
         */
        void Destroy();
};

#endif // GAME_HPP
