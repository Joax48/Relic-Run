-- Vampiro Jefe — Boss Nivel 2
-- Fase 1: mantiene distancia, abanico 5 proj/5s, rueda 8 proj/20s, spawn 1 vampiro/18s
-- Fase 2 (50% HP): teleporta, 3 vampiros, abanico 7 proj, rueda cada 12s

local HP      = 10
local MAX_HP  = 10
local POINTS  = 150

local DETECT_RANGE  = 450
local FLEE_RANGE    = 160
local MOVE_SPEED    = 70
local PROJ_SPEED    = 160

-- Timers fase 1
local FAN_CD    = 5.0
local WHEEL_CD  = 20.0
local SPAWN_CD  = 18.0
local FAN_COUNT = 5

local dead   = false
local dying  = false
local phase2 = false
local battle_music = false

local hit_cd      = 0.0
local HIT_IFRAMES = 0.45

local fan_timer   = 3.0
local wheel_timer = 10.0
local spawn_timer = 9.0

local facing_x = 1
local facing_y = 0

local ANIM = {
    idle   = {id = "vampire3-idle",   frames = 4,  speed = 6},
    walk   = {id = "vampire3-walk",   frames = 6,  speed = 8},
    attack = {id = "vampire3-attack", frames = 12, speed = 16},
    death  = {id = "vampire3-death",  frames = 11, speed = 6},
}

local DEATH_DUR       = 11 / 6.0
local anim_lock_timer = 0.0
local cur_anim        = ""

-- Tamaño: scale 2.0 → sprite 64×64 → render 128×128 → centro = 64
local HALF = 64
local OX, OY, BW, BH = 20, 10, 64, 88

local function get_row()
    if     facing_x == -1 then return 2  -- West
    elseif facing_x ==  1 then return 3  -- East
    elseif facing_y == -1 then return 1  -- North
    else                        return 0  -- South
    end
end

local function play_anim(a, row)
    if cur_anim ~= a.id then
        play_animation(this, a.id, a.frames, a.speed)
        cur_anim = a.id
    end
    set_sprite_row(this, row)
end

local function spawn_fan(sx, sy, tx, ty, count)
    local dx  = tx - (sx + HALF)
    local dy  = ty - (sy + HALF)
    local len = math.sqrt(dx*dx + dy*dy)
    if len < 1 then return end
    local base_angle = math.atan(dy, dx)
    local spread     = math.pi / 3.0            -- 60° total
    for i = 0, count - 1 do
        local t     = (count > 1) and (i / (count - 1)) or 0.5
        local angle = base_angle - spread/2 + t * spread
        local vx    = math.cos(angle) * PROJ_SPEED
        local vy    = math.sin(angle) * PROJ_SPEED
        local px    = sx + HALF + dx/len * 40
        local py    = sy + HALF + dy/len * 40
        spawn_enemy_projectile(px - 8, py - 8, vx, vy)
    end
end

local function spawn_fire_wheel(sx, sy)
    for i = 0, 7 do
        local angle = (i / 8.0) * math.pi * 2
        local vx    = math.cos(angle) * PROJ_SPEED * 0.6
        local vy    = math.sin(angle) * PROJ_SPEED * 0.6
        spawn_enemy_projectile(sx + HALF - 8, sy + HALF - 8, vx, vy)
    end
end

function on_awake()
    -- stagger timers para no atacar inmediatamente
    fan_timer   = FAN_CD * 0.6
    wheel_timer = WHEEL_CD * 0.5
    spawn_timer = SPAWN_CD * 0.7
end

function update(dt)
    local mult = (time_slow and 0.2) or 1.0

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
        phase2    = true
        FAN_CD    = 5.0
        WHEEL_CD  = 12.0
        SPAWN_CD  = 10.0
        FAN_COUNT = 7
        -- Teleport a posición aleatoria del mapa
        local rx = 100 + math.random() * 800
        local ry = 100 + math.random() * 1300
        set_position(this, rx, ry)
        -- Spawn 3 vampiros alrededor
        for i = 1, 3 do
            local angle = (i / 3.0) * math.pi * 2
            spawn_vampire_enemy(rx + math.cos(angle) * 120,
                                ry + math.sin(angle) * 120)
        end
    end

    local sx, sy = get_position(this)

    -- Objetivo: señuelo confunde al boss (deja de atacar), jugador visible lo activa
    local tx, ty
    if not decoy_active and not player_invisible and player_cx then
        tx, ty = player_cx, player_cy
    end

    if not tx then
        set_velocity(this, 0, 0)
        play_anim(ANIM.idle, get_row())
        return
    end

    local dx   = tx - (sx + HALF)
    local dy   = ty - (sy + HALF)
    local dist = math.sqrt(dx*dx + dy*dy)

    -- Facing
    if math.abs(dx) >= math.abs(dy) then
        facing_x = dx > 0 and 1 or -1; facing_y = 0
    else
        facing_x = 0; facing_y = dy > 0 and 1 or -1
    end

    -- Batalla música
    if not battle_music then
        battle_music = true
        play_music("./assets/audio/Boss - The Last Twilight.ogg", true)
    end

    -- Timers
    fan_timer   = fan_timer   - dt * mult
    wheel_timer = wheel_timer - dt * mult
    spawn_timer = spawn_timer - dt

    -- Ataques
    if fan_timer <= 0 and dist < DETECT_RANGE then
        spawn_fan(sx, sy, tx, ty, FAN_COUNT)
        fan_timer = FAN_CD
        play_anim(ANIM.attack, get_row())
        anim_lock_timer = ANIM.attack.frames / ANIM.attack.speed
    end

    if wheel_timer <= 0 then
        spawn_fire_wheel(sx, sy)
        wheel_timer = WHEEL_CD
    end

    if spawn_timer <= 0 then
        local count = phase2 and 3 or 1
        for i = 1, count do
            local angle = math.random() * math.pi * 2
            spawn_vampire_enemy(sx + math.cos(angle) * 150,
                                sy + math.sin(angle) * 150)
        end
        spawn_timer = SPAWN_CD
    end

    -- Movimiento: huir si el jugador está demasiado cerca
    if anim_lock_timer > 0 then
        anim_lock_timer = anim_lock_timer - dt
        if anim_lock_timer < 0 then anim_lock_timer = 0 end
    end

    local vx, vy = 0, 0
    if dist < DETECT_RANGE then
        if dist < FLEE_RANGE and dist > 1 then
            vx = (-dx / dist) * MOVE_SPEED * mult
            vy = (-dy / dist) * MOVE_SPEED * mult
        end
    end
    set_velocity(this, vx, vy)

    if anim_lock_timer <= 0 then
        if vx ~= 0 or vy ~= 0 then
            play_anim(ANIM.walk, get_row())
        else
            play_anim(ANIM.idle, get_row())
        end
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
            play_animation(this, ANIM.death.id, ANIM.death.frames, ANIM.death.speed)
            set_sprite_row(this, get_row())
        end
    end
end

function on_click()
end
