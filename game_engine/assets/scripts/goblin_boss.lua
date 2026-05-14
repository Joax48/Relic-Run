-- Goblin Jefe — Boss Nivel 1 (usa sprites Goblin3)
-- Fase 1 (100→50% HP): patrulla + dash cada 8s (windup 0.8s) + 1 minion/15s
-- Fase 2 (50→0% HP):   dash cada 5s a DASH_SPEED=550 + 2 minions/10s

local HP    = 8
local MAX_HP = 8
local POINTS = 150

-- Patrulla
local PATROL_SPEED = 35
local PATROL_RANGE = 130
local PATROL_WAIT  = 2.0
local DETECT_RANGE = 420
local CHASE_SPEED  = 45   -- persecución lenta entre dashes

-- Dash
local DASH_SPEED    = 400
local DASH_DURATION = 0.5
local WINDUP_DUR    = 0.8
local DASH_COOLDOWN = 8.0

-- Spawn de miniones
local SPAWN_COOLDOWN = 15.0

-- Sprite: goblin3 a scale 2.0 → sprite 64px → rendered 128px → center = 64
local HALF = 64
local OX, OY, BW, BH = 36, 12, 64, 88

local dead          = false
local dying         = false
local phase2        = false
local battle_music  = false

local hit_cd        = 0.0
local HIT_IFRAMES   = 0.45   -- segundos de invencibilidad tras cada impacto

local facing_x = 0
local facing_y = 1

local dash_cd   = 0.0   -- se inicializa en on_awake
local spawn_cd  = 0.0
local in_windup = false
local windup_t  = 0.0
local in_dash   = false
local dash_t    = 0.0
local dash_vx   = 0.0
local dash_vy   = 0.0

local DEATH_DUR       = 6 / 6.0   -- goblin3-death: 6 frames @ speed 6
local anim_lock_timer = 0.0
local cur_mode        = ""

local home_x, home_y       = nil, nil
local patrol_tx, patrol_ty = nil, nil
local patrol_timer         = 0.0

local function get_row()
    if     facing_x == -1 then return 1
    elseif facing_x ==  1 then return 3
    elseif facing_y == -1 then return 2
    else                        return 0
    end
end

local function set_mode(mode, row)
    if cur_mode ~= mode then
        if     mode == "idle"   then play_animation(this, "goblin3-idle", 4, 5)
        elseif mode == "walk"   then play_animation(this, "goblin3-walk", 6, 8)
        elseif mode == "run"    then play_animation(this, "goblin3-run",  8, 14)
        elseif mode == "windup" then play_animation(this, "goblin3-idle", 4, 3)
        end
        cur_mode = mode
    end
    set_sprite_row(this, row)
end

function on_awake()
    dash_cd  = DASH_COOLDOWN  * (0.4 + math.random() * 0.3)
    spawn_cd = SPAWN_COOLDOWN * (0.5 + math.random() * 0.4)
end

function update(dt)
    if dying then
        set_velocity(this, 0, 0)
        anim_lock_timer = anim_lock_timer - dt
        if anim_lock_timer <= 0 then kill_entity(this) end
        return
    end
    if dead then return end

    if hit_cd > 0 then hit_cd = hit_cd - dt end

    set_health(this, HP, MAX_HP)

    -- Transición a fase 2
    if not phase2 and HP <= MAX_HP * 0.5 then
        phase2         = true
        DASH_COOLDOWN  = 5.0
        DASH_SPEED     = 550
        SPAWN_COOLDOWN = 10.0
    end

    local mult = (time_slow and 0.2) or 1.0
    local sx, sy = get_position(this)
    local cx = sx + HALF
    local cy = sy + HALF

    if not home_x then home_x = cx; home_y = cy end

    -- Objetivo activo: señuelo confunde al boss (patrulla), jugador visible lo persigue
    local tx, ty
    if not decoy_active and not player_invisible and player_cx then
        tx, ty = player_cx, player_cy
    end
    -- decoy_active → tx = nil → boss patrulla sin perseguir

    -- ─── WINDUP ───────────────────────────────────────────────
    if in_windup then
        set_velocity(this, 0, 0)
        set_mode("windup", get_row())
        windup_t = windup_t - dt
        if windup_t <= 0 then
            in_windup = false
            in_dash   = true
            dash_t    = DASH_DURATION
            -- Dirección fijada al comienzo del windup (ya calculada)
            set_velocity(this, dash_vx * mult, dash_vy * mult)
        end
        return
    end

    -- ─── DASH ─────────────────────────────────────────────────
    if in_dash then
        set_velocity(this, dash_vx * mult, dash_vy * mult)
        set_mode("run", get_row())
        dash_t = dash_t - dt
        if dash_t <= 0 then
            in_dash = false
            set_velocity(this, 0, 0)
            dash_cd = DASH_COOLDOWN
        end
        return
    end

    -- ─── TIMERS ───────────────────────────────────────────────
    dash_cd  = dash_cd  - dt
    spawn_cd = spawn_cd - dt

    -- Spawn de miniones
    if spawn_cd <= 0 then
        local count = phase2 and 2 or 1
        for i = 1, count do
            local angle = math.random() * math.pi * 2
            local r     = 80 + math.random() * 60
            spawn_goblin(sx + math.cos(angle) * r, sy + math.sin(angle) * r)
        end
        spawn_cd = SPAWN_COOLDOWN
    end

    -- Iniciar windup de dash (solo si el jugador es visible)
    if dash_cd <= 0 and tx then
        local ddx = tx - cx
        local ddy = ty - cy
        local dd  = math.sqrt(ddx * ddx + ddy * ddy)
        if dd > 1 then
            dash_vx = (ddx / dd) * DASH_SPEED
            dash_vy = (ddy / dd) * DASH_SPEED
        else
            dash_vx = 0
            dash_vy = DASH_SPEED
        end
        -- Facing hacia el jugador
        if math.abs(ddx) >= math.abs(ddy) then
            facing_x = ddx > 0 and 1 or -1; facing_y = 0
        else
            facing_x = 0; facing_y = ddy > 0 and 1 or -1
        end
        in_windup = true
        windup_t  = WINDUP_DUR
        return
    end

    -- ─── PERSECUCIÓN / PATRULLA ───────────────────────────────
    if tx then
        local ddx  = tx - cx
        local ddy  = ty - cy
        local dist = math.sqrt(ddx * ddx + ddy * ddy)
        if dist < DETECT_RANGE then
            if not battle_music then
                battle_music = true
                play_music("./assets/audio/Battle - Demon Hunter.ogg", true)
            end
            if math.abs(ddx) >= math.abs(ddy) then
                facing_x = ddx > 0 and 1 or -1; facing_y = 0
            else
                facing_x = 0; facing_y = ddy > 0 and 1 or -1
            end
            set_velocity(this, (ddx / dist) * CHASE_SPEED * mult,
                               (ddy / dist) * CHASE_SPEED * mult)
            set_mode("walk", get_row())
            return
        end
    end

    -- Patrulla alrededor del punto inicial
    patrol_timer = patrol_timer - dt
    if patrol_timer <= 0 or not patrol_tx then
        local angle  = math.random() * math.pi * 2
        local r      = math.random() * PATROL_RANGE
        patrol_tx    = home_x + math.cos(angle) * r
        patrol_ty    = home_y + math.sin(angle) * r
        patrol_timer = PATROL_WAIT
    end
    local pdx   = patrol_tx - cx
    local pdy   = patrol_ty - cy
    local pdist = math.sqrt(pdx * pdx + pdy * pdy)
    if pdist > 8 then
        if math.abs(pdx) >= math.abs(pdy) then
            facing_x = pdx > 0 and 1 or -1; facing_y = 0
        else
            facing_x = 0; facing_y = pdy > 0 and 1 or -1
        end
        set_velocity(this, (pdx / pdist) * PATROL_SPEED * mult,
                           (pdy / pdist) * PATROL_SPEED * mult)
        set_mode("walk", get_row())
    else
        set_velocity(this, 0, 0)
        set_mode("idle", get_row())
    end
end

function on_collision(other)
    if dying or dead then return end
    local tag = get_tag(other)

    if tag == "wall" then
        local ox, oy   = get_position(other)
        local ow, oh   = get_size(other)
        local cvx, cvy = get_velocity(this)
        local sx2, sy2 = get_position(this)
        local pen_l = (sx2 + OX + BW) - ox
        local pen_r = (ox + ow)        - (sx2 + OX)
        local pen_t = (sy2 + OY + BH) - oy
        local pen_b = (oy + oh)        - (sy2 + OY)
        if math.min(pen_l, pen_r) < math.min(pen_t, pen_b) then
            if pen_l < pen_r then set_position(this, ox - OX - BW, sy2)
            else                  set_position(this, ox + ow - OX, sy2) end
            set_velocity(this, 0, cvy)
        else
            if pen_t < pen_b then set_position(this, sx2, oy - OY - BH)
            else                  set_position(this, sx2, oy + oh - OY) end
            set_velocity(this, cvx, 0)
        end
        -- Interrumpir dash al golpear pared
        if in_dash then
            in_dash = false
            dash_t  = 0
            dash_cd = DASH_COOLDOWN * 0.5
        end
        return
    end

    if tag == "projectile" or tag == "player_melee" then
        if hit_cd > 0 then return end
        hit_cd = HIT_IFRAMES
        HP = HP - 1
        play_sfx("./assets/audio/effects/61_Hit_03.wav")
        set_health(this, HP, MAX_HP)
        if HP <= 0 then
            dead            = true
            dying           = true
            anim_lock_timer = DEATH_DUR
            score           = score + POINTS
            play_sfx("./assets/audio/effects/69_Enemy_death_01.wav")
            play_music("./assets/audio/Field - The Little Warrior.ogg", true)
            play_animation(this, "goblin3-death", 6, 6)
            set_sprite_row(this, get_row())
        end
    end
end

function on_click()
end
