#ifndef ASSETMANAGER_HPP
#define ASSETMANAGER_HPP

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h> 

#include <map>
#include <string>

class AssetManager {
    private:
    std::map<std::string, SDL_Texture*> textures;
    std::map<std::string, TTF_Font*> fonts; // Agregado para manejar texturas de fuentes

    public:
    AssetManager();
    ~AssetManager();

    void ClearAssets();

    void AddTexture(SDL_Renderer* renderer, const std::string& textureId
    , const std::string& filePath);
    
    SDL_Texture* GetTexture(const std::string& textureId);

    void AddFont(const std::string& fontId, const std::string& filePath, int fontSize);
    TTF_Font* GetFont(const std::string& fontId);
};

#endif // ASSETMANAGER_HPP