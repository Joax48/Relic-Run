-- Mantiene el sprite de fondo UI alineado con la cámara (el RenderSystem aplica offset de cámara)
function on_awake()
end

function update(dt)
    set_position(this, get_camera_x(), get_camera_y())
end

function on_collision(other)
end

function on_click()
end
