#include "MapLoader.hpp"

#include <tinyxml2.h>
#include <glm/glm.hpp>

#include <climits>
#include <cstdlib>
#include <cstring>
#include <iostream>

#include "../Components/BoxColliderComponent.hpp"
#include "../Components/RigidBodyComponent.hpp"
#include "../Components/SpriteComponent.hpp"
#include "../Components/TagComponent.hpp"
#include "../Components/TransformComponent.hpp"

// ── helpers ───────────────────────────────────────────────────────────────────

std::string MapLoader::ExtractFilename(const std::string& path) const {
    size_t pos = path.find_last_of("/\\");
    return pos == std::string::npos ? path : path.substr(pos + 1);
}

std::vector<int> MapLoader::ParseCSV(const char* csv) const {
    std::vector<int> result;
    if (!csv) return result;
    result.reserve(mapTileW_ * mapTileH_);
    const char* p = csv;
    while (*p) {
        while (*p == ' ' || *p == '\n' || *p == '\r' || *p == '\t') p++;
        if (!*p) break;
        if (*p == ',') { p++; continue; }
        char* end;
        int val = static_cast<int>(strtol(p, &end, 10));
        if (end != p) { result.push_back(val); p = end; }
        else p++;
    }
    return result;
}

const MapLoader::TilesetInfo* MapLoader::FindTileset(int gid) const {
    const TilesetInfo* best = nullptr;
    for (const auto& ts : tilesets_) {
        if (ts.firstGid <= gid) best = &ts;
        else break;
    }
    return best;
}

// Layers that render BELOW game entities (floor/ground)
static bool IsBottomLayer(const char* name) {
    if (!name) return true;
    static const char* bottom[] = {
        // level_01 / level_02 (undead tileset)
        "Water", "Water Effect", "Ground", "Ground 2", "Rocks",
        "Bridge", "Elevated Space", "Stairs", "Ground Details",
        "Spots", "Plates", "Grass", "Grass2",
        "Grass_Details6", "Grass_Detail3", "Grass_Detail5",
        // level_03 (Flying Islands tileset)
        "Background", "Floor", "Rocks_Flying", "Water_Highlights",
        "Waterfall", "Clouds", "Clouds2", "Clouds3",
        nullptr
    };
    for (int i = 0; bottom[i]; ++i)
        if (strcmp(name, bottom[i]) == 0) return true;
    return false;
}

// ── LoadMap ───────────────────────────────────────────────────────────────────

void MapLoader::LoadMap(const std::string& tmxPath,
                        std::unique_ptr<Registry>& registry,
                        std::unique_ptr<AssetManager>& assetManager,
                        SDL_Renderer* renderer,
                        int& outMapWidth, int& outMapHeight) {
    tmxPath_ = tmxPath;

    tinyxml2::XMLDocument doc;
    if (doc.LoadFile(tmxPath.c_str()) != tinyxml2::XML_SUCCESS) {
        std::cerr << "[MAPLOADER] No se pudo cargar: " << tmxPath
                  << " — " << doc.ErrorStr() << "\n";
        return;
    }

    tinyxml2::XMLElement* mapElem = doc.FirstChildElement("map");
    if (!mapElem) { std::cerr << "[MAPLOADER] Sin <map>\n"; return; }

    mapTileW_ = mapElem->IntAttribute("width");
    mapTileH_ = mapElem->IntAttribute("height");
    tileW_    = mapElem->IntAttribute("tilewidth");
    tileH_    = mapElem->IntAttribute("tileheight");

    int pixelW = mapTileW_ * tileW_;
    int pixelH = mapTileH_ * tileH_;
    outMapWidth  = pixelW;
    outMapHeight = pixelH;
    std::cout << "[MAPLOADER] " << mapTileW_ << "×" << mapTileH_
              << " tiles = " << pixelW << "×" << pixelH << " px\n";

    // ── 1. Tilesets ───────────────────────────────────────────────────────────
    // For external .tsx files (no .tsx on disk), we hardcode image info
    // derived from known image dimensions ÷ tile size.
    // mapHint: substring of tmxPath to prefer map-specific entries over generic ones.
    struct ExtFallback { int firstGid; const char* img; int cols; const char* mapHint; };
    static const ExtFallback kExt[] = {
        // level_01
        {2623, "ground_grass_details.png", 21, "level_01"},
        {3001, "Trees_animation.png",      36, "level_01"},
        {5341, "Interior.png",             14, "level_01"},
        {5719, "house_details.png",        10, "level_01"},
        // level_02
        {1,    "Ground_rocks.png",         26, "level_02"},
        {2263, "details.png",               40, "level_02"},
        {2823, "Objects.png",               75, "level_02"},
        {6423, "water_coasts.png",         23, "level_02"},
        {7826, "Objects_animated.png",     44, "level_02"},
        {9542, "water_detilazation.png",   37, "level_02"},
        // level_03 (Flying Islands tileset) — files ending in _flying.png avoid
        // collisions with level_02's same-named tilesets
        {1,     "Flying_rocks_animation.png",   24, "level_03"},
        {289,   "Ground_grass.png",             28, "level_03"},
        {737,   "Objects_flying.png",           31, "level_03"},
        {1112,  "Shadow_gradients.png",         21, "level_03"},
        {1232,  "Statues_animation1.png",       60, "level_03"},
        {1772,  "Statues_animation2.png",       19, "level_03"},
        {1962,  "Tree_animation.png",           60, "level_03"},
        {2562,  "Water_coasts_flying.png",        29, "level_03"},
        {2772,  "Water_coasts2.png",            29, "level_03"},
        {2982,  "water_detilazation_flying.png",   37, "level_03"},
        {3684,  "water_detilazation_v2_flying.png", 37, "level_03"},
        {4386,  "water_detilazation_v2_flying.png", 37, "level_03"},
        {7272,  "Waterfalls.png",               19, "level_03"},
        {7569,  "Clouds.png",                   31, "level_03"},
        {8034,  "Clouds_animated.png",          13, "level_03"},
        {8294,  "Clouds_animated2.png",         13, "level_03"},
        {8354,  "details_flying.png",           19, "level_03"},
        {8381,  "flying_flower_animation.png",  24, "level_03"},
        {13445, "Objects_flying.png",           31, "level_03"},
        {16904, "Tree_animation.png",           60, "level_03"},
        {17504, "Statues_animation1.png",       60, "level_03"},
        {18044, "Statues_animation2.png",       19, "level_03"},
        {18234, "Clouds.png",                   31, "level_03"},
        {18699, "Clouds_animated.png",          13, "level_03"},
        {18959, "Flying_rocks_animation.png",   24, "level_03"},
        {19247, "flying_flower_animation.png",  24, "level_03"},
        {19439, "details_flying.png",           19, "level_03"},
        {0, nullptr, 0, nullptr}
    };

    for (auto* ts = mapElem->FirstChildElement("tileset"); ts;
         ts = ts->NextSiblingElement("tileset")) {

        int firstGid = ts->IntAttribute("firstgid");

        if (ts->Attribute("source")) {
            // External .tsx — prefer map-specific entry, fall back to hint-less
            const ExtFallback* fb = nullptr;
            for (int i = 0; kExt[i].img; ++i) {
                if (kExt[i].firstGid != firstGid) continue;
                if (kExt[i].mapHint && tmxPath_.find(kExt[i].mapHint) != std::string::npos) {
                    fb = &kExt[i]; break;
                }
                if (!kExt[i].mapHint && !fb) fb = &kExt[i];
            }

            if (fb) {
                std::string aid  = "tileset-" + std::string(fb->img);
                std::string path = "./assets/images/tilesets/" + std::string(fb->img);
                assetManager->AddTexture(renderer, aid, path);
                TilesetInfo info;
                info.assetId    = aid;
                info.firstGid   = firstGid;
                info.columns    = fb->cols;
                info.tileWidth  = tileW_;
                info.tileHeight = tileH_;
                info.available  = (assetManager->GetTexture(aid) != nullptr);
                tilesets_.push_back(info);
                std::cout << "[MAPLOADER] Ext gid=" << firstGid
                          << " '" << fb->img << "' " << (info.available?"OK":"NO") << "\n";
            } else {
                TilesetInfo info;
                info.firstGid  = firstGid;
                info.available = false;
                tilesets_.push_back(info);
            }
            continue;
        }

        // Inline tileset with embedded <image>
        tinyxml2::XMLElement* img = ts->FirstChildElement("image");
        if (!img) continue;
        const char* src = img->Attribute("source");
        if (!src) continue;

        std::string fn    = ExtractFilename(std::string(src));
        std::string aid   = "tileset-" + fn;
        std::string path  = "./assets/images/tilesets/" + fn;
        assetManager->AddTexture(renderer, aid, path);

        TilesetInfo info;
        info.assetId    = aid;
        info.firstGid   = firstGid;
        info.columns    = ts->IntAttribute("columns");
        info.tileWidth  = ts->IntAttribute("tilewidth",  tileW_);
        info.tileHeight = ts->IntAttribute("tileheight", tileH_);
        info.available  = (assetManager->GetTexture(aid) != nullptr);
        tilesets_.push_back(info);
        std::cout << "[MAPLOADER] Tileset '" << ts->Attribute("name","?")
                  << "' gid=" << firstGid << (info.available?" OK":" NO") << "\n";
    }

    // ── 2. Find "Map" layer group ─────────────────────────────────────────────
    tinyxml2::XMLElement* mapGroup = nullptr;
    for (auto* g = mapElem->FirstChildElement("group"); g;
         g = g->NextSiblingElement("group")) {
        const char* n = g->Attribute("name");
        if (n && (strcmp(n, "Map") == 0 || strcmp(n, "Environment") == 0)) { mapGroup = g; break; }
    }

    // Bake helper: render all matching layers onto `target`
    auto bake = [&](SDL_Texture* target, bool bottom) {
        SDL_SetRenderTarget(renderer, target);
        SDL_SetTextureBlendMode(target, SDL_BLENDMODE_BLEND);
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0);
        SDL_RenderClear(renderer);
        if (!mapGroup) return;

        for (auto* layer = mapGroup->FirstChildElement("layer"); layer;
             layer = layer->NextSiblingElement("layer")) {

            const char* name = layer->Attribute("name", "");
            if (IsBottomLayer(name) != bottom) continue;

            tinyxml2::XMLElement* data = layer->FirstChildElement("data");
            if (!data) continue;
            const char* enc = data->Attribute("encoding");
            if (!enc || strcmp(enc, "csv") != 0) continue;

            std::vector<int> tiles = ParseCSV(data->GetText());
            if (static_cast<int>(tiles.size()) != mapTileW_ * mapTileH_) continue;

            for (int row = 0; row < mapTileH_; row++) {
                for (int col = 0; col < mapTileW_; col++) {
                    int gid = tiles[row * mapTileW_ + col];
                    if (gid == 0) continue;
                    const TilesetInfo* ts = FindTileset(gid);
                    if (!ts || !ts->available) continue;

                    int localId = gid - ts->firstGid;
                    int sc = localId % ts->columns;
                    int sr = localId / ts->columns;
                    SDL_Rect src = {sc*ts->tileWidth, sr*ts->tileHeight,
                                    ts->tileWidth, ts->tileHeight};
                    SDL_Rect dst = {col*tileW_, row*tileH_, tileW_, tileH_};

                    SDL_Texture* ttex = assetManager->GetTexture(ts->assetId);
                    if (!ttex) continue;
                    SDL_SetTextureBlendMode(ttex, SDL_BLENDMODE_BLEND);
                    SDL_RenderCopy(renderer, ttex, &src, &dst);
                }
            }
            std::cout << "[MAPLOADER] '" << name << "' → "
                      << (bottom ? "suelo" : "techo") << "\n";
        }
    };

    // ── 3. Create two baked textures ──────────────────────────────────────────
    auto makeTex = [&]() {
        return SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888,
                                 SDL_TEXTUREACCESS_TARGET, pixelW, pixelH);
    };

    SDL_Texture* bottomTex = makeTex();
    SDL_Texture* topTex    = makeTex();
    if (!bottomTex || !topTex) {
        std::cerr << "[MAPLOADER] SDL_CreateTexture falló: " << SDL_GetError() << "\n";
        return;
    }

    bake(bottomTex, true);   // ground/water/grass — behind entities
    bake(topTex,    false);  // trees/roof/fence   — in front of entities
    SDL_SetRenderTarget(renderer, nullptr);

    assetManager->AddTextureRaw("map-bottom", bottomTex);
    assetManager->AddTextureRaw("map-top",    topTex);

    // Bottom entity: zIndex=0 → siempre detrás de todo
    Entity bot = registry->CreateEntity();
    bot.AddComponent<TransformComponent>(glm::vec2(0,0), glm::vec2(1,1), 0.0);
    bot.AddComponent<SpriteComponent>("map-bottom", pixelW, pixelH, 0, 0);
    bot.GetComponent<SpriteComponent>().zIndex = 0;
    // Top entity: la escena lo crea con z_index=2 → siempre encima de todo

    // ── 4. Collision walls from Collisions objectgroup ────────────────────────
    tinyxml2::XMLElement* collGroup = nullptr;
    for (auto* e = mapElem->FirstChildElement("objectgroup"); e;
         e = e->NextSiblingElement("objectgroup")) {
        const char* n = e->Attribute("name");
        if (n && (strcmp(n, "Collisions") == 0 || strcmp(n, "Colliders") == 0)) { collGroup = e; break; }
    }

    int wallCount = 0;
    if (collGroup) {
        for (auto* obj = collGroup->FirstChildElement("object"); obj;
             obj = obj->NextSiblingElement("object")) {
            float x = obj->FloatAttribute("x");
            float y = obj->FloatAttribute("y");
            float w = obj->FloatAttribute("width");
            float h = obj->FloatAttribute("height");
            if (w <= 0.0f || h <= 0.0f) continue;

            Entity wall = registry->CreateEntity();
            wall.AddComponent<TransformComponent>(glm::vec2(x,y), glm::vec2(1,1), 0.0);
            wall.AddComponent<BoxColliderComponent>(
                static_cast<int>(w), static_cast<int>(h), glm::vec2(0.0f));
            wall.AddComponent<TagComponent>("wall");
            wall.AddComponent<RigidBodyComponent>(false, true, 1.0f);
            wallCount++;
        }
    }
    std::cout << "[MAPLOADER] " << wallCount << " muros. Listo.\n";
}
