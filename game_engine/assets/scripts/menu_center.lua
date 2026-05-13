-- Centra horizontalmente un texto en pantalla cada frame
-- get_text_width devuelve 0 en el primer frame (antes de renderizar);
-- a partir del segundo frame ya tiene el ancho real.

function on_awake()
end

function update(dt)
    local tw = get_text_width(this)
    if tw > 0 then
        local w = get_window_width()
        local _, y = get_position(this)
        set_position(this, (w - tw) / 2, y)
    end
end

function on_collision(other)
end

function on_click()
end
