-- HUD: score — top-right, alineado al borde

function on_awake()
end

function update(dt)
    local win_w = get_window_width()
    local score_str = tostring(score or 0)
    set_text(this, score_str)
    local tw = get_text_width(this)
    if tw > 0 then
        set_position(this, win_w - tw - 14, 14)
    end
end

function on_collision(other)
end

function on_click()
end
