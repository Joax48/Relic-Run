local was_hovering = false

function on_awake()
end

function update(dt)
    local tw = get_text_width(this)
    if tw > 0 then
        local w = get_window_width()
        local _, y = get_position(this)
        local nx = (w - tw) / 2
        set_position(this, nx, y)
        local mx = get_mouse_x()
        local my = get_mouse_y()
        local hovering = mx >= nx and mx <= nx + tw and my >= y and my <= y + 20
        if hovering and not was_hovering then
            play_sfx("./assets/audio/effects/001_Hover_01.wav")
        end
        was_hovering = hovering
    end
end

function on_collision(other)
end

function on_click()
    go_to_scene("main_menu")
end
