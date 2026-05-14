local blink_t = 0.0

function on_awake()
    set_visible(this, false)
end

function update(dt)
    blink_t = blink_t + dt
    set_position(this, get_camera_x() + 82, get_camera_y() + 66)
    if has_cloak then
        if cloak_cooldown and cloak_cooldown > 0 then
            set_visible(this, math.floor(blink_t * 3) % 2 == 0)
        else
            set_visible(this, true)
        end
    else
        set_visible(this, false)
    end
end

function on_collision(other)
end

function on_click()
end
