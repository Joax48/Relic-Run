local SPEED          = 90
local SPEED_DIAGONAL = math.sqrt((SPEED * SPEED) / 2)
local PROJ_SPEED     = 280

-- Dirección en la que mira el jugador (cardinal preferida)
local facing_x = 1
local facing_y = 0

-- Melee
local melee_active   = false
local melee_timer    = 0.0
local melee_entity   = nil
local MELEE_DURATION = 0.15

-- Collider del jugador (debe coincidir con scene_level_01.lua box_collider)
local BODY_W  = 38
local BODY_H  = 48
local BODY_OX = 19   -- offset.x del collider dentro del sprite
local BODY_OY = 14   -- offset.y del collider dentro del sprite

-- Disparo
local shoot_cooldown = 0.0
local SHOOT_COOLDOWN = 0.35

-- HP e invencibilidad
local INVINCIBLE_DURATION = 2.5

-- Capa de invisibilidad
local CLOAK_DURATION = 5.0
local CLOAK_COOLDOWN = 10.0

-- Orbe señuelo
local DECOY_DURATION = 8.0
local DECOY_COOLDOWN = 12.0

-- Pergamino temporal
local TIMESLOW_DURATION = 5.0
local TIMESLOW_COOLDOWN = 15.0

-- ===========================================================
-- SISTEMA DE ANIMACIÓN
-- ===========================================================
-- Frames por dirección para cada animación (índice 0=S,1=W,2=E,3=N)
local ANIM_FRAMES = {
    ["player-idle"]   = {[0]=12, [1]=12, [2]=12, [3]=4},
    ["player-walk"]   = {[0]=6,  [1]=6,  [2]=6,  [3]=6},
    ["player-attack"] = {[0]=8,  [1]=8,  [2]=8,  [3]=8},
    ["player-hurt"]   = {[0]=5,  [1]=5,  [2]=5,  [3]=5},
    ["player-dead"]   = {[0]=7,  [1]=7,  [2]=7,  [3]=7},
}
local ANIM_SPEED = {
    ["player-idle"]   = 6,
    ["player-walk"]   = 8,
    ["player-attack"] = 12,
    ["player-hurt"]   = 10,
    ["player-dead"]   = 6,
}

local ATTACK_ANIM_DUR = 4 / 12.0   -- duración del one-shot de ataque (medio ciclo para que se sienta ágil)
local HURT_ANIM_DUR   = 5 / 10.0   -- duración del one-shot de daño
local DEATH_ANIM_DUR  = 7 / 6.0    -- duración de la animación de muerte

local cur_anim_type   = ""    -- tipo activo ("player-idle", etc.)
local cur_anim_row    = -1    -- fila activa (0-3)
local anim_lock_timer = 0.0   -- > 0 = one-shot activo (ataque/daño/muerte)
local dying           = false
local got_hurt        = false -- se setea en on_collision, consume en update

local function facing_row()
    if facing_x == -1 then return 1
    elseif facing_x == 1 then return 2
    elseif facing_y == -1 then return 3
    else return 0
    end
end

-- Llama play_animation solo cuando cambia el tipo O el frame count de la fila.
-- Llama set_sprite_row siempre (para mantener la dirección correcta).
local function apply_anim(anim_type, row)
    local frames_tbl = ANIM_FRAMES[anim_type]
    local new_frames = frames_tbl[row]
    local old_frames = (cur_anim_row >= 0) and frames_tbl[cur_anim_row] or nil

    if cur_anim_type ~= anim_type or new_frames ~= old_frames then
        play_animation(this, anim_type, new_frames, ANIM_SPEED[anim_type])
        cur_anim_type = anim_type
    end
    set_sprite_row(this, row)
    cur_anim_row = row
end

-- Fuerza un one-shot (ataque/daño/muerte): bloquea idle/walk hasta que expire.
local function play_one_shot(anim_type, duration, row)
    anim_lock_timer = duration
    cur_anim_type   = anim_type
    cur_anim_row    = row
    play_animation(this, anim_type, ANIM_FRAMES[anim_type][row], ANIM_SPEED[anim_type])
    set_sprite_row(this, row)
end

-- ===========================================================

function on_awake()
    player_hp               = 5
    player_invincible       = false
    player_invincible_timer = 0.0
    player_invisible        = false
    player_invisible_timer  = 0.0
    cloak_cooldown          = 0
    decoy_active            = false
    decoy_timer             = 0.0
    decoy_cooldown          = 0
    decoy_x                 = 0
    decoy_y                 = 0
    time_slow               = false
    timeslow_timer          = 0.0
    timeslow_cooldown       = 0
end

function update(dt)
    -- exponer posición y centro de collider para la IA de enemigos
    player_x, player_y = get_position(this)
    player_cx = player_x + BODY_OX + BODY_W / 2
    player_cy = player_y + BODY_OY + BODY_H / 2

    -- cooldown de disparo
    if shoot_cooldown > 0 then shoot_cooldown = shoot_cooldown - dt end

    -- invencibilidad temporal
    if player_invincible then
        player_invincible_timer = player_invincible_timer - dt
        if player_invincible_timer <= 0 then
            player_invincible = false
        end
    end

    -- capa: cooldown y efecto activo
    if cloak_cooldown and cloak_cooldown > 0 then
        cloak_cooldown = cloak_cooldown - dt
        if cloak_cooldown < 0 then cloak_cooldown = 0 end
    end
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
    if is_action_just_pressed("USE_SLOT3") and has_cloak
       and not player_invisible and cloak_cooldown <= 0 then
        player_invisible       = true
        player_invisible_timer = CLOAK_DURATION
    end

    -- señuelo: cooldown y timer activo
    if decoy_active then
        decoy_timer = decoy_timer - dt
        if decoy_timer <= 0 then
            decoy_active   = false
            decoy_timer    = 0.0
            decoy_cooldown = DECOY_COOLDOWN
        end
    end
    if decoy_cooldown and decoy_cooldown > 0 then
        decoy_cooldown = decoy_cooldown - dt
        if decoy_cooldown < 0 then decoy_cooldown = 0 end
    end
    if is_action_just_pressed("USE_SLOT1") and has_decoy then
        if not decoy_active and (not decoy_cooldown or decoy_cooldown <= 0) then
            decoy_active = true
            decoy_timer  = DECOY_DURATION
            -- lanzar el señuelo 150px adelante en la dirección que mira el jugador
            local offset = 150
            decoy_x = player_cx + facing_x * offset
            decoy_y = player_cy + facing_y * offset
            play_sfx("./assets/audio/effects/001_Hover_01.wav")
        end
    end

    -- tiempo lento: cooldown y timer activo
    if time_slow then
        timeslow_timer = timeslow_timer - dt
        if timeslow_timer <= 0 then
            time_slow         = false
            timeslow_timer    = 0.0
            timeslow_cooldown = TIMESLOW_COOLDOWN
        end
    end
    if timeslow_cooldown and timeslow_cooldown > 0 then
        timeslow_cooldown = timeslow_cooldown - dt
        if timeslow_cooldown < 0 then timeslow_cooldown = 0 end
    end
    if is_action_just_pressed("USE_SLOT2") and has_timeslow
       and not time_slow and timeslow_cooldown <= 0 then
        time_slow      = true
        timeslow_timer = TIMESLOW_DURATION
    end

    -- timer de hitbox melee (siempre corre aunque haya lock de animación)
    if melee_active then
        melee_timer = melee_timer - dt
        if melee_timer <= 0 then
            kill_entity(melee_entity)
            melee_active = false
            melee_entity = nil
        end
    end

    -- ANIMACIÓN: consumir got_hurt (viene de on_collision)
    if got_hurt and not dying then
        got_hurt = false
        play_one_shot("player-hurt", HURT_ANIM_DUR, facing_row())
    end

    -- ANIMACIÓN: decrementar lock timer
    if anim_lock_timer > 0 then
        anim_lock_timer = anim_lock_timer - dt
        if anim_lock_timer < 0 then anim_lock_timer = 0 end
    end

    -- MUERTE: congelar todo y esperar que termine la animación
    if dying then
        set_velocity(this, 0, 0)
        if anim_lock_timer <= 0 then
            go_to_scene("game_over")
        end
        return
    end

    -- -------------------------
    -- INPUT de movimiento
    -- -------------------------
    local vx = 0
    local vy = 0
    if is_action_activated("UP")    then vy = vy - 1 end
    if is_action_activated("DOWN")  then vy = vy + 1 end
    if is_action_activated("LEFT")  then vx = vx - 1 end
    if is_action_activated("RIGHT") then vx = vx + 1 end

    -- actualizar dirección cardinal (horizontal tiene prioridad)
    if vx ~= 0 then
        facing_x = vx
        facing_y = 0
    elseif vy ~= 0 then
        facing_x = 0
        facing_y = vy
    end

    local row = facing_row()

    -- ATAQUE melee (Z)
    -- Melee se posiciona relativo al collider real (BODY_W/BODY_H), no al sprite completo.
    -- BoxCollisionSystem ignora el offset del collider y usa transform.position directamente.
    if is_action_activated("ATTACK") and not melee_active then
        play_sfx("./assets/audio/effects/56_Attack_03.wav")
        local px, py = get_position(this)
        local hw, hh = 32, 32
        -- collider real empieza en (px+BODY_OX, py+BODY_OY)
        local cx = px + BODY_OX  -- izquierda del collider
        local cy = py + BODY_OY  -- tope del collider
        local hx, hy
        if facing_x == 1 then
            hx = cx + BODY_W
            hy = cy + (BODY_H - hh) / 2
        elseif facing_x == -1 then
            hx = cx - hw
            hy = cy + (BODY_H - hh) / 2
        elseif facing_y == 1 then
            hx = cx + (BODY_W - hw) / 2
            hy = cy + BODY_H
        else  -- facing_y == -1
            hx = cx + (BODY_W - hw) / 2
            hy = cy - hh
        end

        melee_entity = spawn_melee(hx, hy, hw, hh)
        melee_active  = true
        melee_timer   = MELEE_DURATION

        if anim_lock_timer <= 0 then
            play_one_shot("player-attack", ATTACK_ANIM_DUR, row)
        end
    end

    -- DISPARO mágico (X) — sin animación de ataque, solo dispara
    if is_action_activated("SHOOT") and shoot_cooldown <= 0 then
        local px, py = get_position(this)
        -- centro del collider real
        local cx = px + BODY_OX + BODY_W / 2
        local cy = py + BODY_OY + BODY_H / 2
        local offset = BODY_W / 2 + 10
        local sx = cx + facing_x * offset - 8
        local sy = cy + facing_y * offset - 8
        spawn_projectile(sx, sy, facing_x * PROJ_SPEED, facing_y * PROJ_SPEED)
        shoot_cooldown = SHOOT_COOLDOWN
    end

    -- ANIMACIÓN: idle / walk (solo cuando no hay one-shot activo)
    if anim_lock_timer <= 0 then
        if vx ~= 0 or vy ~= 0 then
            apply_anim("player-walk", row)
        else
            apply_anim("player-idle", row)
        end
    else
        -- durante one-shot: actualizar fila si cambió la dirección
        if row ~= cur_anim_row then
            set_sprite_row(this, row)
            cur_anim_row = row
        end
    end

    -- Normalizar velocidad y aplicar
    if vx ~= 0 and vy ~= 0 then
        vx = vx * SPEED_DIAGONAL
        vy = vy * SPEED_DIAGONAL
    else
        vx = vx * SPEED
        vy = vy * SPEED
    end

    -- Clamp de posición: evitar salir del mapa
    if map_w and map_h then
        local px, py = get_position(this)
        local min_x = -BODY_OX
        local max_x = map_w - BODY_OX - BODY_W
        local min_y = -BODY_OY
        local max_y = map_h - BODY_OY - BODY_H
        if (vx < 0 and px <= min_x) or (vx > 0 and px >= max_x) then vx = 0 end
        if (vy < 0 and py <= min_y) or (vy > 0 and py >= max_y) then vy = 0 end
    end

    set_velocity(this, vx, vy)
end

function on_collision(other)
    local tag = get_tag(other)

    if tag == "wall" then
        local px, py = get_position(this)
        local ox, oy = get_position(other)
        local ow, oh = get_size(other)
        local cvx, cvy = get_velocity(this)

        -- Bordes del collider del jugador en espacio mundo
        local pleft   = px + BODY_OX
        local pright  = px + BODY_OX + BODY_W
        local ptop    = py + BODY_OY
        local pbottom = py + BODY_OY + BODY_H

        -- Bordes de la pared
        local wleft   = ox
        local wright  = ox + ow
        local wtop    = oy
        local wbottom = oy + oh

        -- Penetración en cada eje (cuánto se solapa)
        local pen_left   = pright  - wleft    -- jugador entra por izquierda de pared
        local pen_right  = wright  - pleft    -- jugador entra por derecha de pared
        local pen_top    = pbottom - wtop     -- jugador entra por arriba de pared
        local pen_bottom = wbottom - ptop     -- jugador entra por abajo de pared

        local min_x = math.min(pen_left, pen_right)
        local min_y = math.min(pen_top,  pen_bottom)

        if min_x < min_y then
            -- Colisión lateral (menor penetración en X)
            if pen_left < pen_right then
                set_velocity(this, 0, cvy)
                set_position(this, wleft - BODY_OX - BODY_W, py)
            else
                set_velocity(this, 0, cvy)
                set_position(this, wright - BODY_OX, py)
            end
        else
            -- Colisión vertical (menor penetración en Y)
            if pen_top < pen_bottom then
                set_velocity(this, cvx, 0)
                set_position(this, px, wtop - BODY_OY - BODY_H)
            else
                set_velocity(this, cvx, 0)
                set_position(this, px, wbottom - BODY_OY)
            end
        end
        return
    end

    if not player_invincible then
        if tag == "enemy_projectile" or tag == "slime" or
           tag == "vampire" or tag == "vampire_boss" or tag == "orc" or tag == "orc_boss" or tag == "mimic" or tag == "dragon" then
            player_hp = player_hp - 1
            play_sfx("./assets/audio/effects/61_Hit_03.wav")
            player_invincible       = true
            player_invincible_timer = INVINCIBLE_DURATION
            if player_hp <= 0 then
                dying = true
                play_one_shot("player-dead", DEATH_ANIM_DUR, facing_row())
            else
                got_hurt = true
            end
        end
    end
end

function on_click()
end
