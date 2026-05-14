-- HUD: cooldown de power-ups (aparece encima de los íconos)

function on_awake()
end

function update(dt)
    set_position(this, get_camera_x() + 14, get_camera_y() + 100)

    local s = {}
    if has_decoy then
        if decoy_active then
            s[#s+1] = "1:ACT"
        elseif decoy_cooldown and decoy_cooldown > 0 then
            s[#s+1] = string.format("1:%ds", math.ceil(decoy_cooldown))
        end
    end
    if has_timeslow then
        if time_slow then
            s[#s+1] = "2:ACT"
        elseif timeslow_cooldown and timeslow_cooldown > 0 then
            s[#s+1] = string.format("2:%ds", math.ceil(timeslow_cooldown))
        end
    end
    if has_cloak then
        if player_invisible then
            s[#s+1] = "3:ACT"
        elseif cloak_cooldown and cloak_cooldown > 0 then
            s[#s+1] = string.format("3:%ds", math.ceil(cloak_cooldown))
        end
    end

    set_text(this, table.concat(s, " "))
end

function on_collision(other)
end

function on_click()
end
