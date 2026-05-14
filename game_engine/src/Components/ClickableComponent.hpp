#ifndef CLICKABLE_COMPONENT_HPP
#define CLICKABLE_COMPONENT_HPP

/**
 * @struct ClickableComponent
 * @brief Marca una entidad como interactuable con el clic del ratón.
 *
 * UISystem emite un ClickEvent cuando el usuario hace clic sobre un área que
 * contiene la posición del cursor. OverlapSystem (o el propio UISystem) llama
 * entonces a @c ScriptComponent::on_click() en la entidad marcada.
 *
 * @c isClicked se pone a true en el frame del clic y se resetea en el siguiente.
 *
 * En la escena Lua se añade con:
 * @code{.lua}
 * clickable = {},  -- sin parámetros
 * @endcode
 */
struct ClickableComponent {
    bool isClicked; ///< True durante el frame en que la entidad fue clicada.

    ClickableComponent() {
        isClicked = false;
    }
};


#endif // CLICKABLE_COMPONENT_HPP
