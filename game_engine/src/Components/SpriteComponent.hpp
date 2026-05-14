#ifndef SPRITECOMPONENT_HPP
#define SPRITECOMPONENT_HPP

#include <SDL2/SDL.h>
#include <string>

/**
 * @struct SpriteComponent
 * @brief Referencia a una textura SDL y el recorte dentro del spritesheet.
 *
 * RenderSystem usa @c textureId para obtener la textura de AssetManager y
 * @c srcRect para copiar solo el frame correcto al renderer.
 *
 * @c zIndex determina el orden de dibujado: 0 = fondo (tiles), 1 = entidades
 * (jugador, enemigos), 2 = capa superior (techos, ramas que tapan al jugador).
 *
 * La transparencia se controla con @c alpha (0 = invisible, 255 = opaco).
 * Usado por los scripts del power-up de capa (@c set_alpha) y por
 * @c SetVisible para ocultar/mostrar una entidad sin destruirla.
 */
struct SpriteComponent {
    std::string textureId; ///< Identificador registrado en AssetManager.
    int         width;     ///< Ancho del frame en píxeles (dentro del spritesheet).
    int         height;    ///< Alto del frame en píxeles (dentro del spritesheet).
    SDL_Rect    srcRect;   ///< Rectángulo de recorte dentro de la textura.
    Uint8       alpha  = 255; ///< Transparencia: 0=invisible, 255=opaco.
    int         zIndex = 1;   ///< Orden de renderizado: 0=fondo, 1=entidades, 2=techo.

    /**
     * @param textureId Identificador de la textura en AssetManager.
     * @param width     Ancho del frame en píxeles.
     * @param height    Alto del frame en píxeles.
     * @param srcRectX  Offset X dentro del spritesheet (columna × ancho).
     * @param srcRectY  Offset Y dentro del spritesheet (fila × alto).
     */
    SpriteComponent(const std::string& textureId = "none",
                    int width    = 0,
                    int height   = 0,
                    int srcRectX = 0,
                    int srcRectY = 0) {
        this->textureId = textureId;
        this->width     = width;
        this->height    = height;
        this->srcRect   = {srcRectX, srcRectY, width, height};
    }
};


#endif // SPRITECOMPONENT_HPP
