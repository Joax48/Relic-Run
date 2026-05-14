#ifndef TEXT_COMPONENT_HPP
#define TEXT_COMPONENT_HPP

#include <SDL2/SDL.h>
#include <string>

/**
 * @struct TextComponent
 * @brief Texto renderizado en pantalla con una fuente TTF.
 *
 * RenderTextSystem usa @c fontId para obtener la fuente de AssetManager y
 * renderiza @c text con el color @c color usando SDL_ttf.
 *
 * Las dimensiones @c width y @c height son calculadas y escritas por
 * RenderTextSystem tras renderizar el texto; se usan para alineación
 * en scripts Lua (p. ej. centrar el HUD de puntuación).
 *
 * El binding Lua @c set_text(entity, "nuevo texto") actualiza @c text
 * en runtime para mostrar valores dinámicos como el score o el HP.
 */
struct TextComponent {
    std::string text;   ///< Cadena a renderizar.
    std::string fontId; ///< Identificador de fuente registrado en AssetManager.
    SDL_Color   color;  ///< Color RGBA del texto.
    int         width;  ///< Ancho del texto renderizado en píxeles (calculado por RenderTextSystem).
    int         height; ///< Alto del texto renderizado en píxeles (calculado por RenderTextSystem).

    /**
     * @param text   Texto inicial a mostrar.
     * @param fontId Fuente registrada con AssetManager::AddFont().
     * @param r      Canal rojo (0–255).
     * @param g      Canal verde (0–255).
     * @param b      Canal azul (0–255).
     * @param a      Canal alfa (0=transparente, 255=opaco).
     */
    TextComponent(const std::string& text   = "",
                  const std::string& fontId = "",
                  u_char r = 0, u_char g = 0,
                  u_char b = 0, u_char a = 0) {
        this->text    = text;
        this->fontId  = fontId;
        this->color.r = r;
        this->color.g = g;
        this->color.b = b;
        this->color.a = a;
        this->width   = 0;
        this->height  = 0;
    }
};

#endif // TEXT_COMPONENT_HPP
