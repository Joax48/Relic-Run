#ifndef ASSETMANAGER_HPP
#define ASSETMANAGER_HPP

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>

#include <map>
#include <string>

/**
 * @class AssetManager
 * @brief Caché centralizada de texturas SDL y fuentes TTF.
 *
 * Todas las texturas y fuentes se identifican por un @c assetId (string).
 * Los sistemas de render los recuperan mediante GetTexture() / GetFont()
 * sin volver a cargarlos desde disco.
 *
 * Al cambiar de escena, ClearAssets() libera todos los recursos para evitar
 * fugas de memoria antes de cargar los assets de la nueva escena.
 */
class AssetManager {
    private:
        std::map<std::string, SDL_Texture*> textures; ///< Mapa assetId → textura SDL.
        std::map<std::string, TTF_Font*>    fonts;    ///< Mapa fontId → fuente TTF.

    public:
        AssetManager();
        ~AssetManager();

        /**
         * @brief Destruye todas las texturas y fuentes cargadas.
         * Llamado automáticamente por SceneManager al finalizar una escena.
         */
        void ClearAssets();

        /**
         * @brief Carga una imagen desde disco y la almacena como textura SDL.
         * Si el @c textureId ya existe, la carga se omite silenciosamente.
         * @param renderer  Renderer SDL usado para crear la textura.
         * @param textureId Identificador único (p. ej. "player-idle").
         * @param filePath  Ruta relativa al archivo de imagen.
         */
        void AddTexture(SDL_Renderer* renderer, const std::string& textureId,
                        const std::string& filePath);

        /**
         * @brief Registra una textura SDL ya creada externamente (p. ej. generada por TinyXML2).
         * @param textureId Identificador único.
         * @param texture   Puntero a la textura SDL ya inicializada.
         */
        void AddTextureRaw(const std::string& textureId, SDL_Texture* texture);

        /**
         * @brief Recupera una textura por su identificador.
         * @param textureId Identificador registrado con AddTexture().
         * @return Puntero a SDL_Texture, o nullptr si no existe.
         */
        SDL_Texture* GetTexture(const std::string& textureId);

        /**
         * @brief Carga una fuente TTF con el tamaño indicado.
         * @param fontId   Identificador único (p. ej. "press_start_24").
         * @param filePath Ruta relativa al archivo .ttf.
         * @param fontSize Tamaño en puntos.
         */
        void AddFont(const std::string& fontId, const std::string& filePath, int fontSize);

        /**
         * @brief Recupera una fuente por su identificador.
         * @param fontId Identificador registrado con AddFont().
         * @return Puntero a TTF_Font, o nullptr si no existe.
         */
        TTF_Font* GetFont(const std::string& fontId);
};

#endif // ASSETMANAGER_HPP
