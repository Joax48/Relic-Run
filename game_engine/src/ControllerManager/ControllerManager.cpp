#include "ControllerManager.hpp"

#include <iostream>

ControllerManager::ControllerManager() {
std::cout << "[CONTROLLERMANAGER] se ejecuta constructor" << std::endl;
}

ControllerManager::~ControllerManager() {
std::cout << "[CONTROLLERMANAGER] se ejecuta destructor" << std::endl;
}

void ControllerManager::Clear() {
    actionKeyName.clear();
    keyDown.clear();
}

void ControllerManager::AddActionKey(const std::string& action, int keyCode) {
    actionKeyName.emplace(action, keyCode);
    keyDown.emplace(keyCode, false);
    keyJustPressed.emplace(keyCode, false);
}

void ControllerManager::KeyDown(int keyCode) {
    anyKeyJustPressed = true;
    auto it = keyDown.find(keyCode);
    if (it != keyDown.end()) {
        keyDown[keyCode] = true;
        keyJustPressed[keyCode] = true;
    }
}

bool ControllerManager::IsAnyKeyJustPressed() {
    return anyKeyJustPressed;
}

void ControllerManager::ResetJustPressed() {
    anyKeyJustPressed = false;
    for (auto& [key, val] : keyJustPressed) val = false;
}

bool ControllerManager::IsActionJustPressed(const std::string& action) {
    auto it = actionKeyName.find(action);
    if (it != actionKeyName.end()) {
        auto jt = keyJustPressed.find(it->second);
        if (jt != keyJustPressed.end()) return jt->second;
    }
    return false;
}

void ControllerManager::KeyUp(int keyCode) {
    auto it = keyDown.find(keyCode);
    if (it != keyDown.end()) {
        keyDown[keyCode] = false;
    }
}

bool ControllerManager::IsActionActived(const std::string& action) {
    auto it = actionKeyName.find(action);
    if (it != actionKeyName.end()) {
        int keyCode = actionKeyName[action];
        return keyDown[keyCode];
    }
    return false;
}

void ControllerManager::AddMouseButton(const std::string& name, int buttonCode){
    mouseButtonName.emplace(name, buttonCode);
    mouseButtonDown.emplace(buttonCode, false);
}

void ControllerManager::MouseButtonDown(int buttonCode){
    auto it = mouseButtonDown.find(buttonCode);
    if (it != mouseButtonDown.end()) {
        mouseButtonDown[buttonCode] = true;
    }
}

void ControllerManager::MouseButtonUp(int buttonCode){
    auto it = mouseButtonDown.find(buttonCode);
    if (it != mouseButtonDown.end()) {
        mouseButtonDown[buttonCode] = false;
    }
}
bool ControllerManager::IsMouseButtonDown(const std::string& name){
    auto it = mouseButtonName.find(name);
    if (it != mouseButtonName.end()) {
        int buttonCode = mouseButtonName[name];
        return mouseButtonDown[buttonCode];
    }
    return false;
}

void ControllerManager::SetMousePosition(int x, int y){
    mousePosX = x;
    mousePosY = y;
}
std::tuple<int, int> ControllerManager::GetMousePosition() {
    return {mousePosX, mousePosY};
}