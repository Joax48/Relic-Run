local active       = false
local activating   = false
local cur_row      = 0
local MAX_ROW      = 6
local ROW_INTERVAL = 0.28
local row_timer    = 0.0

function on_awake()
    play_animation(this, "portal-open", 1, 1)
    set_sprite_row(this, 0)
end

function update(dt)
    if not active and key_collected then
        active     = true
        activating = true
        cur_row    = 0
        row_timer  = ROW_INTERVAL
        play_animation(this, "portal-open", 6, 8)
        set_sprite_row(this, 0)
    end

    if activating then
        row_timer = row_timer - dt
        if row_timer <= 0 then
            cur_row = cur_row + 1
            set_sprite_row(this, cur_row)
            if cur_row >= MAX_ROW then
                activating = false
                play_animation(this, "portal-open", 6, 10)
            else
                play_animation(this, "portal-open", 6, 8)
                row_timer = ROW_INTERVAL
            end
        end
    end
end

function on_collision(other)
    local tag = get_tag(other)
    if tag == "player" and active and not activating then
        go_to_scene("victory")
    end
end

function on_click()
end
