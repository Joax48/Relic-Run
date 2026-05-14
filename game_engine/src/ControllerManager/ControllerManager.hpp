#ifndef CONTROLLER_MANAGER_HPP
#define CONTROLLER_MANAGER_HPP

#include <SDL2/SDL.h>

#include <map>
#include <string>
#include <tuple>

/**
 * @class ControllerManager
 * @brief Gestiona el estado del teclado y el ratón, traduciendo keycodes SDL
 *        a nombres de acción definidos en la escena Lua.
 *
 * Cada escena registra sus acciones con AddActionKey() (p. ej. "UP" → SDLK_w).
 * El bucle principal llama KeyDown()/KeyUp() en respuesta a SDL_KEYDOWN/SDL_KEYUP,
 * y ResetJustPressed() al inicio de cada frame para limpiar el estado "recién pulsado".
 *
 * Los scripts Lua acceden a este manager a través de los bindings
 * @c is_action_activated y @c is_action_just_pressed.
 */
class ControllerManager {
    private:
        /// Mapea nombre de acción → keycode SDL (p. ej. "UP" → 119).
        std::map<std::string, int> actionKeyName;
        /// Estado actual de cada tecla registrada (true = mantenida).
        std::map<int, bool> keyDown;
        /// True sólo en el primer frame en que la tecla fue pulsada.
        std::map<int, bool> keyJustPressed;
        /// True si cualquier tecla fue pulsada en el frame actual (para pantallas "press any key").
        bool anyKeyJustPressed = false;

        /// Mapea nombre de botón → código de botón del ratón.
        std::map<std::string, int> mouseButtonName;
        /// Estado actual de cada botón del ratón registrado.
        std::map<int, bool> mouseButtonDown;

        int mousePosX; ///< Posición X actual del cursor en coordenadas de pantalla.
        int mousePosY; ///< Posición Y actual del cursor en coordenadas de pantalla.

    public:
        ControllerManager();
        ~ControllerManager();

        /**
         * @brief Elimina todas las acciones y teclas registradas.
         * Llamado al cambiar de escena para evitar teclas huérfanas.
         */
        void Clear();

        // ── Teclado ──────────────────────────────────────────────────────────

        /**
         * @brief Registra una acción con nombre y la asocia a un keycode SDL.
         * @param action  Nombre de la acción (p. ej. "ATTACK").
         * @param keyCode Keycode SDL (p. ej. SDLK_j = 106).
         */
        void AddActionKey(const std::string& action, int keyCode);

        /**
         * @brief Notifica que una tecla fue presionada.
         * Marca la tecla como activa en @c keyDown y como recién pulsada en @c keyJustPressed.
         * Llamado desde Game::ProcessInput() para cada evento SDL_KEYDOWN.
         * @param keyCode Keycode SDL del evento.
         */
        void KeyDown(int keyCode);

        /**
         * @brief Notifica que una tecla fue liberada.
         * Desactiva la tecla en @c keyDown.
         * @param keyCode Keycode SDL del evento.
         */
        void KeyUp(int keyCode);

        /**
         * @brief Indica si una acción está activa (tecla mantenida).
         * @param action Nombre de la acción registrada.
         * @return true si la tecla correspondiente está siendo mantenida.
         */
        bool IsActionActived(const std::string& action);

        /**
         * @brief Limpia los flags "recién pulsado" para todas las teclas y ratón.
         * Debe llamarse al inicio de cada frame (antes de procesar eventos SDL).
         */
        void ResetJustPressed();

        /**
         * @brief Indica si una acción fue pulsada en este frame (sin repetición).
         * @param action Nombre de la acción registrada.
         * @return true sólo en el frame en que la tecla pasó de soltada a presionada.
         */
        bool IsActionJustPressed(const std::string& action);

        /**
         * @brief Indica si cualquier tecla fue pulsada en el frame actual.
         * Usado en pantallas de "PRESS ANY KEY TO CONTINUE".
         * @return true si se detectó alguna pulsación de tecla este frame.
         */
        bool IsAnyKeyJustPressed();

        // ── Ratón ─────────────────────────────────────────────────────────────

        /**
         * @brief Registra un botón del ratón con un nombre de acción.
         * @param name       Nombre lógico (p. ej. "SHOOT").
         * @param buttonCode Código SDL del botón (p. ej. SDL_BUTTON_LEFT = 1).
         */
        void AddMouseButton(const std::string& name, int buttonCode);

        /** @brief Marca un botón del ratón como presionado. */
        void MouseButtonDown(int buttonCode);

        /** @brief Marca un botón del ratón como liberado. */
        void MouseButtonUp(int buttonCode);

        /**
         * @brief Indica si un botón del ratón está presionado.
         * @param name Nombre del botón registrado.
         * @return true si el botón está activo en este frame.
         */
        bool IsMouseButtonDown(const std::string& name);

        /**
         * @brief Actualiza la posición del cursor.
         * @param x Coordenada X en píxeles de pantalla.
         * @param y Coordenada Y en píxeles de pantalla.
         */
        void SetMousePosition(int x, int y);

        /**
         * @brief Devuelve la posición actual del cursor.
         * @return Par (x, y) en píxeles de pantalla.
         */
        std::tuple<int, int> GetMousePosition();
};

#endif // CONTROLLER_MANAGER_HPP
