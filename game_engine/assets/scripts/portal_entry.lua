-- Portal de entrada: arranca abierto (fila 6) y cierra hacia fila 0 tras unos segundos
local MAX_ROW      = 6
local cur_row      = MAX_ROW
local closing      = false
local closed       = false
local OPEN_STAY    = 2.5     -- segundos abierto antes de empezar a cerrar
local ROW_INTERVAL = 0.28
local stay_timer   = OPEN_STAY
local row_timer    = 0.0

function on_awake()
    play_animation(this, "portal-open", 6, 10)
    set_sprite_row(this, MAX_ROW)
end

function update(dt)
    if closed then return end

    if not closing then
        stay_timer = stay_timer - dt
        if stay_timer <= 0 then
            closing   = true
            row_timer = ROW_INTERVAL
        end
        return
    end

    row_timer = row_timer - dt
    if row_timer <= 0 then
        cur_row = cur_row - 1
        if cur_row <= 0 then
            cur_row = 0
            closed  = true
            play_animation(this, "portal-open", 1, 1)
        else
            play_animation(this, "portal-open", 6, 10)
        end
        set_sprite_row(this, cur_row)
        row_timer = ROW_INTERVAL
    end
end

function on_collision(other)
end

function on_click()
end
