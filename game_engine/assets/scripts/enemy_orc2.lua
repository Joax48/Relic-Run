-- Orc2: mini-boss L3. Persigue, melee con lunge. Fase 2 al 50% HP.
-- Frames: idle=4, walk=6, attack=8, death=8 | 4 filas dirección (S/W/E/N)

local HP           = 6
local MAX_HP       = 6
local POINTS       = 60
local DETECT_RANGE = 300
local CHASE_SPEED  = 70
local ATTACK_RANGE = 90
local PATROL_SPEED = 35
local PATROL_RANGE = 130
local PATROL_WAIT  = 1.5

local dead     = false
local dying    = false
local facing_x = 0
local facing_y = 1
local phase2   = false

local DEATH_DUR       = 8 / 6.0
local anim_lock_timer = 0.0
local cur_mode        = ""

local lunge_timer = 0.0
local LUNGE_DUR   = 0.4
local LUNGE_SPEED = 220

local attack_cd       = 0.0
local ATTACK_COOLDOWN = 0.9

local hit_timer   = 0.0
local HIT_IFRAMES = 0.45

local wall_avoid_timer = 0.0
local WALL_AVOID_DUR   = 0.5
local wall_avoid_vx    = 0.0
local wall_avoid_vy    = 0.0

-- 64×scale2.0 / 2 = 64
local HALF = 64
local OX, OY, BW, BH = 20, 10, 48, 68

local home_x, home_y       = nil, nil
local patrol_tx, patrol_ty = nil, nil
local patrol_timer         = 0.0

-- last known player position (used when player goes invisible)
local last_seen_x  = nil
local last_seen_y  = nil
local search_timer = 0.0
local SEARCH_DUR   = 3.0

local function get_row()
    if     facing_x == -1 then return 1
    elseif facing_x ==  1 then return 3
    elseif facing_y == -1 then return 2
    else                        return 0
    end
end

local function set_mode(mode)
    if cur_mode ~= mode then
        if mode == "idle" then
            play_animation(this, "orc2-idle", 4, 6)
        elseif mode == "walk" then
            play_animation(this, "orc2-walk", 6, 10)
        elseif mode == "attack" then
            play_animation(this, "orc2-attack", 8, 12)
        end
        cur_mode = mode
    end
    set_sprite_row(this, get_row())
end

function on_awake()
    set_health(this, HP, MAX_HP)
end

function update(dt)
    if dying then
        set_velocity(this, 0, 0)
        anim_lock_timer = anim_lock_timer - dt
        if anim_lock_timer <= 0 then kill_entity(this) end
        return
    end
    if dead then return end

    -- phase 2 at 50% HP: faster and more aggressive
    if not phase2 and HP <= MAX_HP / 2 then
        phase2         = true
        CHASE_SPEED    = 110
        LUNGE_SPEED    = 290
        ATTACK_COOLDOWN = 0.6
        DETECT_RANGE   = 380
    end

    set_health(this, HP, MAX_HP)
    if attack_cd > 0 then attack_cd = attack_cd - dt end
    if hit_timer  > 0 then hit_timer  = hit_timer  - dt end
    if search_timer > 0 then search_timer = search_timer - dt end

    if lunge_timer > 0 then
        if player_invisible and not (decoy_active and decoy_x and decoy_y) then
            lunge_timer = 0
            set_velocity(this, 0, 0)
        else
            lunge_timer = lunge_timer - dt
            local sx, sy = get_position(this)
            local ltx = (decoy_active and decoy_x) or player_cx
            local lty = (decoy_active and decoy_y) or player_cy
            local dx = ltx - (sx + HALF)
            local dy = lty - (sy + HALF)
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist > 1 then
                if math.abs(dx) > math.abs(dy) then
                    facing_x = dx > 0 and 1 or -1; facing_y = 0
                else
                    facing_x = 0; facing_y = dy > 0 and 1 or -1
                end
                local spd = (time_slow and 0.2 or 1.0) * LUNGE_SPEED
                set_velocity(this, dx/dist * spd, dy/dist * spd)
            end
            set_mode("attack")
        end
        return
    end

    if wall_avoid_timer > 0 then
        wall_avoid_timer = wall_avoid_timer - dt
        set_velocity(this, wall_avoid_vx, wall_avoid_vy)
        set_mode("walk")
        return
    end

    local mult = (time_slow and 0.2) or 1.0

    local tx, ty
    if decoy_active and decoy_x and decoy_y then
        tx, ty = decoy_x, decoy_y
        last_seen_x = tx; last_seen_y = ty
        search_timer = SEARCH_DUR
    elseif not player_invisible then
        tx, ty = player_cx, player_cy
        last_seen_x = tx; last_seen_y = ty
        search_timer = SEARCH_DUR
    elseif search_timer > 0 and last_seen_x then
        -- walk to last known position then idle
        tx, ty = last_seen_x, last_seen_y
    end

    local sx2, sy2 = get_position(this)
    if not home_x then home_x = sx2; home_y = sy2 end

    local in_range = false
    if tx then
        local dx = tx - (sx2 + HALF)
        local dy = ty - (sy2 + HALF)
        if math.sqrt(dx*dx + dy*dy) < DETECT_RANGE then
            in_range = true
        end
    end

    if not in_range then
        -- if searching after losing player, idle in place until timer expires
        if search_timer > 0 and last_seen_x then
            set_velocity(this, 0, 0)
            set_mode("idle")
        else
            patrol_timer = patrol_timer - dt
            if patrol_timer <= 0 or not patrol_tx then
                local angle  = math.random() * math.pi * 2
                local r      = math.random() * PATROL_RANGE
                patrol_tx    = home_x + math.cos(angle) * r
                patrol_ty    = home_y + math.sin(angle) * r
                patrol_timer = PATROL_WAIT
            end
            local pdx   = patrol_tx - (sx2 + HALF)
            local pdy   = patrol_ty - (sy2 + HALF)
            local pdist = math.sqrt(pdx*pdx + pdy*pdy)
            if pdist > 8 then
                if math.abs(pdx) > math.abs(pdy) then
                    facing_x = pdx > 0 and 1 or -1; facing_y = 0
                else
                    facing_x = 0; facing_y = pdy > 0 and 1 or -1
                end
                set_velocity(this, pdx/pdist * PATROL_SPEED * mult, pdy/pdist * PATROL_SPEED * mult)
                set_mode("walk")
            else
                set_velocity(this, 0, 0)
                set_mode("idle")
            end
        end
        return
    end

    local sx, sy = get_position(this)
    local dx = tx - (sx + HALF)
    local dy = ty - (sy + HALF)
    local dist = math.sqrt(dx*dx + dy*dy)

    if math.abs(dx) > math.abs(dy) then
        facing_x = dx > 0 and 1 or -1; facing_y = 0
    else
        facing_x = 0; facing_y = dy > 0 and 1 or -1
    end

    if dist < ATTACK_RANGE then
        set_velocity(this, 0, 0)
        set_mode("attack")
        if attack_cd <= 0 then
            lunge_timer = LUNGE_DUR
            attack_cd   = ATTACK_COOLDOWN
        end
    else
        set_velocity(this, dx/dist * CHASE_SPEED * mult, dy/dist * CHASE_SPEED * mult)
        set_mode("walk")
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
        if lunge_timer <= 0 and wall_avoid_timer <= 0 then
            wall_avoid_timer = WALL_AVOID_DUR
            if math.abs(cvx) > math.abs(cvy) then
                wall_avoid_vx = 0
                wall_avoid_vy = (math.random() < 0.5 and 1 or -1) * CHASE_SPEED * 0.8
            else
                wall_avoid_vx = (math.random() < 0.5 and 1 or -1) * CHASE_SPEED * 0.8
                wall_avoid_vy = 0
            end
        end
        return
    end

    if tag == "projectile" or tag == "player_melee" then
        if hit_timer > 0 then return end
        hit_timer = HIT_IFRAMES
        HP = HP - 1
        set_health(this, HP, MAX_HP)
        if HP <= 0 then
            dead = true; dying = true
            anim_lock_timer = DEATH_DUR
            score = score + POINTS
            play_animation(this, "orc2-death", 8, 6)
            set_sprite_row(this, get_row())
        else
            lunge_timer = LUNGE_DUR
        end
    end
end

function on_click() end
