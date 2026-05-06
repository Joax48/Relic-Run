local SPEED          = 150
local SPEED_DIAGONAL = math.sqrt((SPEED * SPEED) / 2)
local PROJ_SPEED     = 350

-- Dirección en la que mira el jugador (cardinal preferida)
local facing_x = 1
local facing_y = 0

-- Melee
local melee_active   = false
local melee_timer    = 0.0
local melee_entity   = nil
local MELEE_DURATION = 0.15

-- Disparo
local shoot_cooldown = 0.0
local SHOOT_COOLDOWN = 0.35

-- HP e invencibilidad
local INVINCIBLE_DURATION = 1.5

-- Capa de invisibilidad
local CLOAK_DURATION = 5.0
local CLOAK_COOLDOWN = 10.0

-- Orbe señuelo
local DECOY_DURATION = 8.0
local DECOY_COOLDOWN = 12.0

-- Pergamino temporal
local TIMESLOW_DURATION = 5.0
local TIMESLOW_COOLDOWN = 15.0

function on_awake()
    player_hp               = 3
    player_invincible       = false
    player_invincible_timer = 0.0
    player_invisible        = false
    player_invisible_timer  = 0.0
    decoy_active            = false
    decoy_timer             = 0.0
    decoy_x                 = 0
    decoy_y                 = 0
    time_slow               = false
    timeslow_timer          = 0.0
end

function update(dt)
    -- exponer posición para la IA de enemigos
    player_x, player_y = get_position(this)

    -- timers
    if shoot_cooldown > 0 then shoot_cooldown = shoot_cooldown - dt end

    if player_invincible then
        player_invincible_timer = player_invincible_timer - dt
        if player_invincible_timer <= 0 then
            player_invincible = false
        end
    end

    -- cooldown de la capa
    if cloak_cooldown and cloak_cooldown > 0 then
        cloak_cooldown = cloak_cooldown - dt
        if cloak_cooldown < 0 then cloak_cooldown = 0 end
    end

    -- efecto activo de la capa
    if player_invisible then
        player_invisible_timer = player_invisible_timer - dt
        set_alpha(this, 80)
        if player_invisible_timer <= 0 then
            player_invisible       = false
            player_invisible_timer = 0.0
            cloak_cooldown         = CLOAK_COOLDOWN
            set_alpha(this, 255)
        end
    end

    -- activar capa con tecla 1
    if is_action_activated("USE_SLOT1") and has_cloak
       and not player_invisible and cloak_cooldown <= 0 then
        player_invisible       = true
        player_invisible_timer = CLOAK_DURATION
    end

    -- señuelo: timer activo
    if decoy_active then
        decoy_timer = decoy_timer - dt
        if decoy_timer <= 0 then
            decoy_active   = false
            decoy_timer    = 0.0
            decoy_cooldown = DECOY_COOLDOWN
        end
    end

    -- cooldown del señuelo
    if decoy_cooldown and decoy_cooldown > 0 then
        decoy_cooldown = decoy_cooldown - dt
        if decoy_cooldown < 0 then decoy_cooldown = 0 end
    end

    -- activar señuelo con tecla 2 (suelta el señuelo en la posición actual)
    if is_action_activated("USE_SLOT2") and has_decoy
       and not decoy_active and decoy_cooldown <= 0 then
        decoy_active = true
        decoy_timer  = DECOY_DURATION
        decoy_x, decoy_y = get_position(this)
    end

    -- tiempo lento: timer activo
    if time_slow then
        timeslow_timer = timeslow_timer - dt
        if timeslow_timer <= 0 then
            time_slow        = false
            timeslow_timer   = 0.0
            timeslow_cooldown = TIMESLOW_COOLDOWN
        end
    end

    -- cooldown del pergamino
    if timeslow_cooldown and timeslow_cooldown > 0 then
        timeslow_cooldown = timeslow_cooldown - dt
        if timeslow_cooldown < 0 then timeslow_cooldown = 0 end
    end

    -- activar pergamino con tecla 3
    if is_action_activated("USE_SLOT3") and has_timeslow
       and not time_slow and timeslow_cooldown <= 0 then
        time_slow      = true
        timeslow_timer = TIMESLOW_DURATION
    end

    if melee_active then
        melee_timer = melee_timer - dt
        if melee_timer <= 0 then
            kill_entity(melee_entity)
            melee_active = false
            melee_entity = nil
        end
    end

    -- input de movimiento
    local vx = 0
    local vy = 0
    if is_action_activated("UP")    then vy = vy - 1 end
    if is_action_activated("DOWN")  then vy = vy + 1 end
    if is_action_activated("LEFT")  then vx = vx - 1 end
    if is_action_activated("RIGHT") then vx = vx + 1 end

    -- actualizar dirección cardinal (horizontal tiene prioridad sobre vertical)
    if vx ~= 0 then
        facing_x = vx
        facing_y = 0
    elseif vy ~= 0 then
        facing_x = 0
        facing_y = vy
    end

    -- normalizar diagonal
    if vx ~= 0 and vy ~= 0 then
        vx = vx * SPEED_DIAGONAL
        vy = vy * SPEED_DIAGONAL
    else
        vx = vx * SPEED
        vy = vy * SPEED
    end
    set_velocity(this, vx, vy)

    -- ataque melee (Z)
    if is_action_activated("ATTACK") and not melee_active then
        local px, py = get_position(this)
        local pw, ph = get_size(this)
        local hw, hh = 28, 28
        -- hitbox adyacente al frente del jugador
        local hx = px + facing_x * pw
        local hy = py + facing_y * ph
        -- ajuste para centrar en el eje perpendicular
        if facing_x ~= 0 then hy = py + (ph - hh) / 2 end
        if facing_y ~= 0 then hx = px + (pw - hw) / 2 end

        melee_entity = spawn_melee(hx, hy, hw, hh)
        melee_active  = true
        melee_timer   = MELEE_DURATION
    end

    -- disparo mágico (X)
    if is_action_activated("SHOOT") and shoot_cooldown <= 0 then
        local px, py = get_position(this)
        local pw, ph = get_size(this)
        -- spawn fuera del collider del jugador en la dirección de disparo
        local cx = px + pw / 2
        local cy = py + ph / 2
        local offset = pw / 2 + 10
        local sx = cx + facing_x * offset - 8
        local sy = cy + facing_y * offset - 8
        spawn_projectile(sx, sy, facing_x * PROJ_SPEED, facing_y * PROJ_SPEED)
        shoot_cooldown = SHOOT_COOLDOWN
    end
end

function on_collision(other)
    local tag = get_tag(other)
    if tag == "wall" then
        local px, py = get_position(this)
        local pw, ph = get_size(this)
        local ox, oy = get_position(other)
        local ow, oh = get_size(other)
        local cvx, cvy = get_velocity(this)

        if right_collision(this, other) then
            set_velocity(this, 0, cvy)
            set_position(this, ox - pw, py)
        elseif left_collision(this, other) then
            set_velocity(this, 0, cvy)
            set_position(this, ox + ow, py)
        elseif down_collision(this, other) then
            set_velocity(this, cvx, 0)
            set_position(this, px, oy - ph)
        elseif up_collision(this, other) then
            set_velocity(this, cvx, 0)
            set_position(this, px, oy + oh)
        end
        return
    end

    -- daño al jugador por enemigos o proyectiles enemigos
    if not player_invincible then
        if tag == "projectile" or tag == "skeleton_base" or
           tag == "skeleton_mage" or tag == "mimic" then
            player_hp = player_hp - 1
            player_invincible = true
            player_invincible_timer = INVINCIBLE_DURATION
            if player_hp <= 0 then
                go_to_scene("main_menu")
            end
        end
    end
end

function on_click()
end
