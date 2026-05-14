#ifndef MAP_LOADER_HPP
#define MAP_LOADER_HPP

#include <memory>
#include <string>
#include <vector>

#include <SDL2/SDL.h>

#include "../AssetManager/AssetManager.hpp"
#include "../ECS/ECS.hpp"

/**
 * @class MapLoader
 * @brief Carga mapas exportados por Tiled (.tmx) y los convierte en entidades ECS.
 *
 * Parsea el XML del archivo .tmx con TinyXML2. Por cada capa de tiles crea una
 * entidad con TransformComponent + SpriteComponent usando el tileset referenciado.
 * La capa superior del mapa (p. ej. techos, ramas) se registra con z_index = 2
 * para renderizarse sobre las entidades del juego.
 *
 * Se invoca desde Lua con el binding @c load_map(path):
 * @code{.lua}
 * load_map("./assets/maps/level_01/level_01.tmx")
 * @endcode
 *
 * @note El tileset debe estar en la misma carpeta que el .tmx o referenciado
 * con ruta relativa. MapLoader registra las texturas en AssetManager
 * con el nombre del archivo del tileset como assetId.
 */
class MapLoader {
public:
    /**
     * @brief Carga el mapa .tmx y crea las entidades de tile en el registro ECS.
     * @param tmxPath      Ruta relativa al archivo .tmx.
     * @param registry     Registro ECS donde se crearán las entidades de tile.
     * @param assetManager Gestor de assets para cargar/registrar texturas de tileset.
     * @param renderer     Renderer SDL para crear texturas.
     * @param outMapWidth  [out] Ancho total del mapa en píxeles.
     * @param outMapHeight [out] Alto total del mapa en píxeles.
     */
    void LoadMap(const std::string& tmxPath,
                 std::unique_ptr<Registry>& registry,
                 std::unique_ptr<AssetManager>& assetManager,
                 SDL_Renderer* renderer,
                 int& outMapWidth, int& outMapHeight);

private:
    /**
     * @brief Datos de un tileset referenciado en el .tmx.
     */
    struct TilesetInfo {
        std::string assetId;   ///< ID registrado en AssetManager.
        int firstGid   = 0;    ///< GID inicial de este tileset en el mapa.
        int columns    = 1;    ///< Número de columnas del tileset.
        int tileWidth  = 16;   ///< Ancho de cada tile en píxeles.
        int tileHeight = 16;   ///< Alto de cada tile en píxeles.
        bool available = false;///< true si la textura está registrada correctamente.
    };

    std::vector<TilesetInfo> tilesets_; ///< Lista de tilesets del mapa activo.
    std::string tmxPath_; ///< Ruta base del .tmx para resolver paths relativos.
    int mapTileW_ = 0;    ///< Ancho del mapa en tiles.
    int mapTileH_ = 0;    ///< Alto del mapa en tiles.
    int tileW_    = 16;   ///< Ancho de un tile en píxeles.
    int tileH_    = 16;   ///< Alto de un tile en píxeles.

    /**
     * @brief Busca el tileset que corresponde a un GID dado.
     * @param gid GID global del tile.
     * @return Puntero al TilesetInfo correspondiente, o nullptr si no se encuentra.
     */
    const TilesetInfo* FindTileset(int gid) const;

    /**
     * @brief Extrae el nombre de archivo de una ruta (última componente).
     * @param path Ruta completa o relativa.
     * @return Nombre de archivo con extensión.
     */
    std::string ExtractFilename(const std::string& path) const;

    /**
     * @brief Parsea una cadena CSV de GIDs y devuelve el vector de enteros.
     * @param csv Cadena de texto con valores separados por comas.
     * @return Vector de GIDs en orden de izquierda a derecha, arriba a abajo.
     */
    std::vector<int> ParseCSV(const char* csv) const;
};

#endif // MAP_LOADER_HPP
