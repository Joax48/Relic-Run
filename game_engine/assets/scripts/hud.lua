score_entity = nil

function on_awake()
    score_entity = this
end

function update(dt)
    local relics = (relics_collected or 0) .. "/" .. (relics_total or 0)

    local cloak_str = ""
    if has_cloak then
        if player_invisible then
            cloak_str = "  [1] ACTIVA"
        elseif cloak_cooldown and cloak_cooldown > 0 then
            cloak_str = "  [1] CD:" .. math.ceil(cloak_cooldown) .. "s"
        else
            cloak_str = "  [1] LISTA"
        end
    end

    local decoy_str = ""
    if has_decoy then
        if decoy_active then
            decoy_str = "  [2] ACTIVO"
        elseif decoy_cooldown and decoy_cooldown > 0 then
            decoy_str = "  [2] CD:" .. math.ceil(decoy_cooldown) .. "s"
        else
            decoy_str = "  [2] LISTO"
        end
    end

    local ts_str = ""
    if has_timeslow then
        if time_slow then
            ts_str = "  [3] ACTIVO"
        elseif timeslow_cooldown and timeslow_cooldown > 0 then
            ts_str = "  [3] CD:" .. math.ceil(timeslow_cooldown) .. "s"
        else
            ts_str = "  [3] LISTO"
        end
    end

    set_text(this, "Score: " .. score .. "  HP: " .. (player_hp or 0) .. "  Relics: " .. relics .. cloak_str .. decoy_str .. ts_str)
end

function on_collision(other)
end

function on_click()
end
