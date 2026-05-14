function on_awake()
end

function update(dt)
    local s = score or 0
    set_text(this,  tostring(s))
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
