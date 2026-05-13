-- HUD: indicador de power-up activo — bottom-left, vacío cuando no hay nada activo

function on_awake()
end

function update(dt)
    local win_h = get_window_height()
    local msg   = ""

    if time_slow then
        msg = "[3] SLOW"
    elseif player_invisible then
        msg = "[1] CLOAK"
    elseif decoy_active then
        msg = "[2] DECOY"
    end

    set_text(this, msg)
    set_position(this, 14, win_h - 30)
end

function on_collision(other)
end

function on_click()
end
