#ifndef CONTROLLER_MANAGER_HPP
#define CONTROLLER_MANAGER_HPP

#include <SDL2/SDL.h>

#include <map>
#include <string>
#include <tuple>


class ControllerManager {
    private:
        std::map<std::string, int> actionKeyName;
        std::map<int, bool> keyDown;

        std::map<std::string, int> mouseButtonName;
        std::map<int, bool> mouseButtonDown;

        int mousePosX;
        int mousePosY;

    public:
        ControllerManager();
        ~ControllerManager();

        void Clear();

        // Keyboard
        void AddActionKey(const std::string& action, int keyCode);
        void KeyDown(int);
        void KeyUp(int keyCode);
        bool IsActionActived(const std::string& action);

        // Mouse
        void AddMouseButton(const std::string& name, int buttonCode);
        void MouseButtonDown(int buttonCode);
        void MouseButtonUp(int buttonCode);
        bool IsMouseButtonDown(const std::string& name);

        void SetMousePosition(int x, int y);
        std::tuple<int, int> GetMousePosition();

};

#endif // CONTROLLER_MANAGER_HPP