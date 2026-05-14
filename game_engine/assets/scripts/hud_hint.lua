function on_awake()
    powerup_hint_text  = powerup_hint_text  or ""
    powerup_hint_timer = powerup_hint_timer or 0.0
end

function update(dt)
    if powerup_hint_timer and powerup_hint_timer > 0 then
        powerup_hint_timer = powerup_hint_timer - dt
        set_text(this, powerup_hint_text or "")
        local tw = get_text_width(this)
        local w  = get_window_width()
        if tw > 0 then
            set_position(this, (w - tw) / 2, 250)
        end
    else
        set_text(this, "")
    end
end

function on_collision(other) end
function on_click() end
