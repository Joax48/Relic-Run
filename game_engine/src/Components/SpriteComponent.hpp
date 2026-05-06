#ifndef SPRITECOMPONENT_HPP
#define SPRITECOMPONENT_HPP

#include <SDL2/SDL.h>
#include <string>

struct SpriteComponent{
    std::string textureId;
    int width;
    int height;
    SDL_Rect srcRect;

    SpriteComponent(const std::string& textureId = "none", int width = 0
        , int height = 0, int srcRectX = 0, int srcRectY = 0 ) {
            this->textureId = textureId;
            this->width = width;
            this->height = height;
            this->srcRect = {srcRectX, srcRectY, width, height};
        }
};


#endif // SPRITECOMPONENT_HPP