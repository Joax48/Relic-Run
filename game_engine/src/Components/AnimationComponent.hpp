#ifndef ANIMATIONCOMPONENT_HPP
#define ANIMATIONCOMPONENT_HPP

#include <SDL2/SDL.h>

struct AnimationComponent {
    int currentFrame;
    int numFrames;
    int frameSpeedRate; // Duración de cada frame en segundos
    int startTime; // Tiempo acumulado desde el último cambio de frame
    bool isLoop = true; // Indica si la animación debe repetirse

    AnimationComponent(int numFrames = 1, int frameSpeedRate = 1, bool loop = true) {
        this->currentFrame = 1;
        this->numFrames = numFrames;
        this->frameSpeedRate = frameSpeedRate;
        this->startTime = SDL_GetTicks();
        this->isLoop = loop;
    }
};

#endif // ANIMATIONCOMPONENT_HPP