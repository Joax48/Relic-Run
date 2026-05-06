#include "AssetManager.hpp"

#include <SDL2/SDL_image.h>

#include <iostream>

AssetManager::AssetManager() {
    std::cout << "[ASSETMANAGER] Se ejecuta constructor" << std::endl;
}
AssetManager::~AssetManager() {
    std::cout << "[ASSETMANAGER] Se ejecuta destructor" << std::endl;
}

void AssetManager::ClearAssets() {
    for (auto texture : textures) {
        SDL_DestroyTexture(texture.second);
    }
    textures.clear();
    for (auto font : fonts) {
        TTF_CloseFont(font.second);
    }
    fonts.clear();
}

void AssetManager::AddTexture(SDL_Renderer* renderer
, const std::string& textureId, const std::string& filePath) {
    SDL_Surface* surface = IMG_Load(filePath.c_str());
    SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_FreeSurface(surface);

    textures.emplace(textureId, texture);
}

SDL_Texture* AssetManager::GetTexture(const std::string& textureId) {
    return textures[textureId];
}

void AssetManager::AddFont(const std::string& fontId, const std::string& filePath, int fontSize) {
    TTF_Font* font = TTF_OpenFont(filePath.c_str(), fontSize);
    if (font == NULL) {
        std::string error = TTF_GetError();
        std::cerr << "[ASSETMANAGER] Error al cargar la fuente: " << error << std::endl;
        return;
    }
    fonts.emplace(fontId, font);
}

TTF_Font* AssetManager::GetFont(const std::string& fontId) {
    return fonts[fontId];
}