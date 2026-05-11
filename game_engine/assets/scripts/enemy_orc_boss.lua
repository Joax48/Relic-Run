-- Orc3 Boss: scale 2.0, más HP, spawna 4 orcos al 50% HP
-- Frames: idle=4, walk=6, run=8 | 4 filas de dirección (S/W/E/N)

local HP           = 6
local MAX_HP       = 6
local POINTS       = 100
local DETECT_RANGE = 350
local CHASE_SPEED  = 35
local PATROL_SPEED = 22
local PATROL_RANGE = 90   -- radio de patrulla alrededor del punto inicial

local dead            = false
local dying           = false
local spawned_minions = false
local facing_x        = 0
local facing_y        = 1

local DEATH_DUR       = 8 / 6.0
local anim_lock_timer = 0.0
local cur_mode        = ""

local lunge_timer = 0.0
local LUNGE_DUR   = 0.5
local LUNGE_SPEED = 140

-- centro del sprite: 64×scale 2.0 / 2 = 64
local HALF = 64
-- collider: width=64 height=88 offset x=36 y=12
local OX, OY, BW, BH = 36, 12, 64, 88
local ATTACK_RANGE = 100

-- Patrulla idle
local home_x, home_y       = nil, nil
local patrol_tx, patrol_ty = nil, nil
local patrol_timer         = 0.0
local PATROL_WAIT          = 2.5

local function get_row()
    if facing_x == -1 then return 1
    elseif facing_x == 1 then return 2
    elseif facing_y == -1 then return 3
    else return 0
    end
end

local function set_mode(mode, row)
    if cur_mode ~= mode then
        if mode == "idle" then
            play_animation(this, "orc3-idle", 4, 5)
        elseif mode == "walk" then
            play_animation(this, "orc3-walk", 6, 8)
        elseif mode == "run" then
            play_animation(this, "orc3-run", 8, 12)
        end
        cur_mode = mode
    end
    set_sprite_row(this, row)
end

function on_awake()
end

function update(dt)
    if dying then
        set_velocity(this, 0, 0)
        anim_lock_timer = anim_lock_timer - dt
        if anim_lock_timer <= 0 then kill_entity(this) end
        return
    end
    if dead then return end

    set_health(this, HP, MAX_HP)

    -- Lunge al recibir daño
    if lunge_timer > 0 then
        lunge_timer = lunge_timer - dt
        local sx, sy = get_position(this)
        local dx = player_cx - (sx + HALF)
        local dy = player_cy - (sy + HALF)
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist > 1 then
            if math.abs(dx) >= math.abs(dy) then
                facing_x = dx > 0 and 1 or -1; facing_y = 0
            else
                facing_x = 0; facing_y = dy > 0 and 1 or -1
            end
            local spd = (time_slow and 0.2 or 1.0) * LUNGE_SPEED
            set_velocity(this, dx/dist * spd, dy/dist * spd)
        end
        set_mode("run", get_row())
        return
    end

    if not spawned_minions and HP <= MAX_HP / 2 then
        spawned_minions = true
        local bx, by = get_position(this)
        spawn_orc(bx - 90, by)
        spawn_orc(bx + 90, by)
        spawn_orc(bx, by - 90)
        spawn_orc(bx, by + 90)
    end

    local mult = (time_slow and 0.2) or 1.0

    local tx, ty
    if decoy_active and decoy_x and decoy_y then
        tx, ty = decoy_x, decoy_y
    elseif not player_invisible then
        tx, ty = player_cx, player_cy
    end

    if not tx then
        -- Patrulla alrededor del punto inicial
        local sx2, sy2 = get_position(this)
        if not home_x then home_x = sx2; home_y = sy2 end

        patrol_timer = patrol_timer - dt
        if patrol_timer <= 0 or not patrol_tx then
            local angle = math.random() * math.pi * 2
            local r     = math.random() * PATROL_RANGE
            patrol_tx   = home_x + math.cos(angle) * r
            patrol_ty   = home_y + math.sin(angle) * r
            patrol_timer = PATROL_WAIT
        end

        local pdx  = patrol_tx - (sx2 + HALF)
        local pdy  = patrol_ty - (sy2 + HALF)
        local pdist = math.sqrt(pdx*pdx + pdy*pdy)
        if pdist > 8 then
            if math.abs(pdx) >= math.abs(pdy) then
                facing_x = pdx > 0 and 1 or -1; facing_y = 0
            else
                facing_x = 0; facing_y = pdy > 0 and 1 or -1
            end
            local spd = (time_slow and 0.2 or 1.0) * PATROL_SPEED
            set_velocity(this, pdx/pdist * spd, pdy/pdist * spd)
            set_mode("walk", get_row())
        else
            set_velocity(this, 0, 0)
            set_mode("idle", get_row())
        end
        return
    end

    local sx, sy = get_position(this)
    local dx = tx - (sx + HALF)
    local dy = ty - (sy + HALF)
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist > DETECT_RANGE then
        set_velocity(this, 0, 0)
        set_mode("idle", get_row())
        return
    end

    if math.abs(dx) >= math.abs(dy) then
        facing_x = dx > 0 and 1 or -1; facing_y = 0
    else
        facing_x = 0; facing_y = dy > 0 and 1 or -1
    end
    local row = get_row()

    if dist < ATTACK_RANGE then
        set_velocity(this, 0, 0)
        set_mode("run", row)
    else
        set_velocity(this, dx / dist * CHASE_SPEED * mult, dy / dist * CHASE_SPEED * mult)
        set_mode("walk", row)
    end
end

function on_collision(other)
    if dying or dead then return end
    local tag = get_tag(other)

    if tag == "wall" then
        local sx, sy = get_position(this)
        local ox, oy = get_position(other)
        local ow, oh = get_size(other)
        local cvx, cvy = get_velocity(this)
        local pen_l = (sx+OX+BW) - ox
        local pen_r = (ox+ow)    - (sx+OX)
        local pen_t = (sy+OY+BH) - oy
        local pen_b = (oy+oh)    - (sy+OY)
        if math.min(pen_l, pen_r) < math.min(pen_t, pen_b) then
            if pen_l < pen_r then set_position(this, ox-OX-BW, sy)
            else               set_position(this, ox+ow-OX, sy) end
            set_velocity(this, 0, cvy)
        else
            if pen_t < pen_b then set_position(this, sx, oy-OY-BH)
            else               set_position(this, sx, oy+oh-OY) end
            set_velocity(this, cvx, 0)
        end
        return
    end

    if tag == "projectile" or tag == "player_melee" then
        HP = HP - 1
        set_health(this, HP, MAX_HP)
        if HP <= 0 then
            dead = true; dying = true
            anim_lock_timer = DEATH_DUR
            score = score + POINTS
            play_animation(this, "orc3-run", 8, 6)
            set_sprite_row(this, get_row())
        else
            lunge_timer = LUNGE_DUR
        end
    end
end

function on_click()
end
