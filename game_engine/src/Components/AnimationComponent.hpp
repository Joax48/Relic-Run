#ifndef ANIMATIONCOMPONENT_HPP
#define ANIMATIONCOMPONENT_HPP

#include <SDL2/SDL.h>

/**
 * @struct AnimationComponent
 * @brief Control de animación por frames horizontales en un spritesheet.
 *
 * AnimationSystem avanza @c currentFrame en función del tiempo real (SDL_GetTicks)
 * y @c frameSpeedRate, actualizando @c SpriteComponent::srcRect.x para que
 * RenderSystem dibuje el frame correcto.
 *
 * Los frames se asumen dispuestos en fila horizontal dentro del spritesheet,
 * cada uno con el mismo ancho que @c SpriteComponent::width.
 *
 * La fila (animación) activa se controla externamente con @c set_sprite_row()
 * o @c play_animation() desde Lua, que modifican @c SpriteComponent::srcRect.y.
 */
struct AnimationComponent {
    int  currentFrame;   ///< Índice del frame actualmente visible (empieza en 1).
    int  numFrames;      ///< Total de frames de la animación activa.
    int  frameSpeedRate; ///< Velocidad: frames por segundo aproximados.
    int  startTime;      ///< Timestamp SDL en ms del inicio del ciclo actual.
    bool isLoop = true;  ///< Si es true, la animación se reinicia al llegar al último frame.

    /**
     * @param numFrames     Número de frames de la animación.
     * @param frameSpeedRate Velocidad de la animación en frames por segundo.
     * @param loop          true para repetir la animación indefinidamente.
     */
    AnimationComponent(int numFrames = 1, int frameSpeedRate = 1, bool loop = true) {
        this->currentFrame   = 1;
        this->numFrames      = numFrames;
        this->frameSpeedRate = frameSpeedRate;
        this->startTime      = SDL_GetTicks();
        this->isLoop         = loop;
    }
};

#endif // ANIMATIONCOMPONENT_HPP
