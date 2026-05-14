#ifndef CAMARAFOLLOWCOMPONENT_HPP
#define CAMARAFOLLOWCOMPONENT_HPP

/**
 * @struct CameraFollowComponent
 * @brief Marca una entidad como el objetivo de seguimiento de la cámara.
 *
 * CameraMovementSystem busca la primera entidad con este componente y centra
 * la cámara (@c Game::camera) sobre ella cada frame, respetando los límites
 * del mapa (@c Game::mapWidth / @c Game::mapHeight) para no mostrar
 * áreas fuera del mundo.
 *
 * Solo una entidad debería tener este componente activo simultáneamente.
 * En la escena Lua se añade con:
 * @code{.lua}
 * camera_follow = {},  -- sin parámetros
 * @endcode
 */
struct CameraFollowComponent {
    CameraFollowComponent() {}
};


#endif // CAMARAFOLLOWCOMPONENT_HPP
