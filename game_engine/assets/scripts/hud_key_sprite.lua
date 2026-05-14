-- HUD: muestra el sprite de la llave cuando key_collected = true

function on_awake()
    set_visible(this, false)
end

function update(dt)
    set_visible(this, key_collected == true)
    set_position(this, get_camera_x() + 14, get_camera_y() + 32)
end

function on_collision(other)
end

function on_click()
end
