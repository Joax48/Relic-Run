#ifndef MAP_LOADER_HPP
#define MAP_LOADER_HPP

#include <memory>
#include <string>
#include <vector>

#include <SDL2/SDL.h>

#include "../AssetManager/AssetManager.hpp"
#include "../ECS/ECS.hpp"

class MapLoader {
public:
    void LoadMap(const std::string& tmxPath,
                 std::unique_ptr<Registry>& registry,
                 std::unique_ptr<AssetManager>& assetManager,
                 SDL_Renderer* renderer,
                 int& outMapWidth, int& outMapHeight);

private:
    struct TilesetInfo {
        std::string assetId;
        int firstGid   = 0;
        int columns    = 1;
        int tileWidth  = 16;
        int tileHeight = 16;
        bool available = false;
    };

    std::vector<TilesetInfo> tilesets_;
    int mapTileW_ = 0;
    int mapTileH_ = 0;
    int tileW_    = 16;
    int tileH_    = 16;

    const TilesetInfo* FindTileset(int gid) const;
    std::string        ExtractFilename(const std::string& path) const;
    std::vector<int>   ParseCSV(const char* csv) const;
};

#endif // MAP_LOADER_HPP
