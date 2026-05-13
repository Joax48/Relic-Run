-- Toggle de música (stub — sin audio aún)
local sound_on = true

function on_awake()
    local w = get_window_width()
    local tw = get_text_width(this)
    local _, y = get_position(this)
    set_position(this, w - 80, y)
end

function update(dt)
    -- mantener en esquina inferior derecha
    local w = get_window_width()
    local _, y = get_position(this)
    set_position(this, w - 80, y)
end

function on_collision(other)
end

function on_click()
    sound_on = not sound_on
    if sound_on then
        set_text(this, "[SND]")
    else
        set_text(this, "[MUT]")
    end
end
