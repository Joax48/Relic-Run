-- Jefe final (Orc3). Melee puro: patrulla → persigue → carga → golpe en área.
-- Fase 2 al 50% HP: más rápido, más agresivo.

local HP     = 12
local hp     = HP
local POINTS = 150

-- stats fase 1
local PATROL_SPEED = 40
local CHASE_SPEED  = 80
local CHARGE_SPEED = 300
local CHARGE_DUR   = 0.55
local CHARGE_CD    = 3.5
local STOMP_CD     = 6.0
local DETECT_RANGE = 380
local ATTACK_RANGE = 120  -- distancia para desencadenar carga

-- escala 2.5 × 64 / 2 = 80
local HALF   = 80
local ARRIVE = 8

local dead         = false
local battle_music = false
local waypoints    = {}
local wp_index     = 1
local phase2       = false

-- estado principal
local state        = "patrol"
-- "patrol" | "chase" | "windup" | "charge" | "stomp_wind" | "stomp"

local charge_timer  = 0.0
local charge_cd     = 0.5          -- arranca con cooldown corto para atacar pronto
local charge_dx     = 0.0
local charge_dy     = 0.0

local stomp_cd      = STOMP_CD
local stomp_timer   = 0.0
local STOMP_DUR     = 0.25

local windup_timer  = 0.0

local hit_timer    = 0.0
local HIT_IFRAMES  = 0.5

local function enter_state(s)
    state = s
end

function on_awake()
    local sx, sy = get_position(this)
    -- patrulla cuadrada de 180px
    waypoints = {
        {x = sx + 180, y = sy},
        {x = sx + 180, y = sy + 180},
        {x = sx,       y = sy + 180},
        {x = sx,       y = sy},
    }
    set_health(this, hp, HP)
end

function update(dt)
    if dead then return end

    if hit_timer  > 0 then hit_timer  = hit_timer  - dt end
    if charge_cd  > 0 then charge_cd  = charge_cd  - dt end
    if stomp_cd   > 0 then stomp_cd   = stomp_cd   - dt end

    -- transición a fase 2
    if not phase2 and hp <= HP / 2 then
        phase2        = true
        CHASE_SPEED   = 115
        CHARGE_SPEED  = 380
        CHARGE_CD     = 2.2
        STOMP_CD      = 3.5
        DETECT_RANGE  = 450
        ATTACK_RANGE  = 150
    end

    local mult = time_slow and 0.2 or 1.0
    local sx, sy = get_position(this)

    -- === CARGA ACTIVA ===
    if state == "charge" then
        charge_timer = charge_timer - dt
        set_velocity(this, charge_dx * mult, charge_dy * mult)
        if charge_timer <= 0 then
            set_velocity(this, 0, 0)
            charge_cd = CHARGE_CD
            enter_state("chase")
        end
        return
    end

    -- === GOLPE EN ÁREA ACTIVO ===
    if state == "stomp" then
        stomp_timer = stomp_timer - dt
        set_velocity(this, 0, 0)
        if stomp_timer <= 0 then
            stomp_cd = STOMP_CD
            enter_state("chase")
        end
        return
    end

    -- === PRE-CARGA (se detiene antes de lanzarse) ===
    if state == "windup" then
        windup_timer = windup_timer - dt
        set_velocity(this, 0, 0)
        if windup_timer <= 0 then
            local tx, ty = player_cx, player_cy
            local dx = tx - (sx + HALF)
            local dy = ty - (sy + HALF)
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist > 1 then
                charge_dx = dx / dist * CHARGE_SPEED
                charge_dy = dy / dist * CHARGE_SPEED
            else
                charge_dx = 0; charge_dy = CHARGE_SPEED
            end
            charge_timer = CHARGE_DUR
            enter_state("charge")
        end
        return
    end

    -- === PRE-GOLPE EN ÁREA ===
    if state == "stomp_wind" then
        windup_timer = windup_timer - dt
        set_velocity(this, 0, 0)
        if windup_timer <= 0 then
            local sw, sh = get_size(this)
            spawn_melee(sx - 50, sy - 50, sw + 100, sh + 100)
            stomp_timer = STOMP_DUR
            enter_state("stomp")
        end
        return
    end

    -- === LÓGICA DE DETECCIÓN ===
    local target_x, target_y = nil, nil
    if decoy_active and decoy_x and decoy_y then
        target_x, target_y = decoy_x, decoy_y
    elseif not player_invisible then
        target_x, target_y = player_cx, player_cy
    end

    if target_x then
        local dx   = target_x - (sx + HALF)
        local dy   = target_y - (sy + HALF)
        local dist = math.sqrt(dx*dx + dy*dy)

        if dist < DETECT_RANGE then
            if not battle_music then
                battle_music = true
                play_music("./assets/audio/Battle - Magic Battle.ogg", true)
            end
            enter_state("chase")

            -- prioridad: golpe en área (fase 2, muy cerca)
            if phase2 and stomp_cd <= 0 and dist < ATTACK_RANGE * 0.6 then
                windup_timer = 0.5
                enter_state("stomp_wind")
                return
            end

            -- carga cuando está en rango de ataque
            if charge_cd <= 0 and dist < ATTACK_RANGE then
                windup_timer = 0.6
                enter_state("windup")
                return
            end

            -- persecución normal
            if dist > 1 then
                set_velocity(this, dx / dist * CHASE_SPEED * mult,
                                   dy / dist * CHASE_SPEED * mult)
            end
            return
        end
    end

    -- === PATRULLA ===
    enter_state("patrol")
    local wp   = waypoints[wp_index]
    local dx   = wp.x - sx
    local dy   = wp.y - sy
    local dist = math.sqrt(dx*dx + dy*dy)

    if dist < ARRIVE then
        wp_index = (wp_index % #waypoints) + 1
    elseif dist > 1 then
        set_velocity(this, dx / dist * PATROL_SPEED * mult,
                           dy / dist * PATROL_SPEED * mult)
    end
end

function on_collision(other)
    if dead then return end
    local tag = get_tag(other)

    if tag == "wall" then
        local sx, sy = get_position(this)
        local sw, sh = get_size(this)
        local ox, oy = get_position(other)
        local ow, oh = get_size(other)
        if right_collision(this, other) then
            set_position(this, ox - sw, sy)
        elseif left_collision(this, other) then
            set_position(this, ox + ow, sy)
        elseif down_collision(this, other) then
            set_position(this, sx, oy - sh)
        elseif up_collision(this, other) then
            set_position(this, sx, oy + oh)
        end
        set_velocity(this, 0, 0)
        -- interrumpir carga para no quedarse pegado en la pared
        if state == "charge" then
            charge_cd = CHARGE_CD * 0.5
            enter_state("chase")
        end
        return
    end

    if tag == "projectile" or tag == "player_melee" then
        if hit_timer > 0 then return end
        hit_timer = HIT_IFRAMES
        hp = hp - 1
        set_health(this, hp, HP)
        if hp <= 0 then
            dead  = true
            score = score + POINTS
            set_velocity(this, 0, 0)
            play_music("./assets/audio/Dungeon - Ancient Light.ogg", true)
            kill_entity(this)
        end
    end
end

function on_click() end
