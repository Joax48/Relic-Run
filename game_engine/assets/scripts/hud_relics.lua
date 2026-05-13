-- HUD: estado de la llave (bajo la barra de HP)

function on_awake()
end

function update(dt)
    if key_collected then
        set_text(this, "[KEY]")
    else
        set_text(this, "")
    end
    set_position(this, 14, 32)
end

function on_collision(other)
end

function on_click()
end
