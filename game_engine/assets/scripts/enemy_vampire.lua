local HP     = 2
local hp     = HP
local POINTS = 35

local DETECT_RANGE = 280
local FLEE_RANGE   = 130  -- keeps at least this distance from player
local MOVE_SPEED   = 80
local PROJ_SPEED   = 280
local SHOOT_CD     = 1.8

local dead        = false
local dying       = false
local got_hurt    = false
local shoot_timer = 0.0

local facing_x = 1
local facing_y = 0

-- Per-direction frame counts (all directions share same count for vampire)
local ANIM = {
    idle   = {id = "vampire-idle",   frames = 4,  speed = 6},
    walk   = {id = "vampire-walk",   frames = 6,  speed = 8},
    attack = {id = "vampire-attack", frames = 12, speed = 12},
    hurt   = {id = "vampire-hurt",   frames = 4,  speed = 10},
    death  = {id = "vampire-death",  frames = 11, speed = 6},
}

local cur_anim        = ""
local cur_row         = 0
local anim_lock_timer = 0.0

local function get_facing_row()
    if facing_x == -1 then return 1
    elseif facing_x == 1 then return 2
    elseif facing_y == -1 then return 3
    else return 0
    end
end

local function play_anim(a, row)
    if cur_anim ~= a.id then
        play_animation(this, a.id, a.frames, a.speed)
        cur_anim = a.id
    end
    set_sprite_row(this, row)
    cur_row = row
end

local function play_one_shot(a, row)
    anim_lock_timer = a.frames / a.speed
    cur_anim = a.id
    cur_row  = row
    play_animation(this, a.id, a.frames, a.speed)
    set_sprite_row(this, row)
end

function on_awake()
    shoot_timer = SHOOT_CD * math.random()
end

function update(dt)
    local mult = (time_slow and 0.2) or 1.0

    if not dying then
        if shoot_timer > 0 then shoot_timer = shoot_timer - dt end
    end

    if got_hurt and not dying then
        got_hurt = false
        play_one_shot(ANIM.hurt, get_facing_row())
    end

    -- always decrement: needed for death animation to finish
    if anim_lock_timer > 0 then
        anim_lock_timer = anim_lock_timer - dt
        if anim_lock_timer < 0 then anim_lock_timer = 0 end
    end

    if dying then
        set_velocity(this, 0, 0)
        if anim_lock_timer <= 0 then
            kill_entity(this)
        end
        return
    end

    -- Resolve target: decoy > player center > player pos
    local tx, ty
    if decoy_active and decoy_x and decoy_y then
        tx, ty = decoy_x, decoy_y
    elseif player_cx and player_cy then
        tx, ty = player_cx, player_cy
    elseif player_x and player_y then
        tx, ty = player_x, player_y
    end

    if not tx then
        set_velocity(this, 0, 0)
        if anim_lock_timer <= 0 then play_anim(ANIM.idle, get_facing_row()) end
        return
    end

    local sx, sy = get_position(this)
    -- center of vampire sprite (64×64 at scale 1.5 = 96×96)
    local cx = sx + 48
    local cy = sy + 48
    local dx = tx - cx
    local dy = ty - cy
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist < DETECT_RANGE and not player_invisible then
        -- update facing
        if math.abs(dx) >= math.abs(dy) then
            facing_x = dx > 0 and 1 or -1
            facing_y = 0
        else
            facing_x = 0
            facing_y = dy > 0 and 1 or -1
        end
        local row = get_facing_row()

        -- movement: flee if too close, else stand still (keeping range)
        local vx, vy = 0, 0
        if dist < FLEE_RANGE then
            local nx = -dx / dist
            local ny = -dy / dist
            vx = nx * MOVE_SPEED * mult
            vy = ny * MOVE_SPEED * mult
        end
        set_velocity(this, vx, vy)

        -- shoot toward player
        if shoot_timer <= 0 then
            local nx = dx / dist
            local ny = dy / dist
            local offset = 48 + 12
            local px = cx + nx * offset - 8
            local py = cy + ny * offset - 8
            spawn_enemy_projectile(px, py, nx * PROJ_SPEED * mult, ny * PROJ_SPEED * mult)
            shoot_timer = SHOOT_CD
            if anim_lock_timer <= 0 then
                play_one_shot(ANIM.attack, row)
            end
        end

        if anim_lock_timer <= 0 then
            if vx ~= 0 or vy ~= 0 then
                play_anim(ANIM.walk, row)
            else
                play_anim(ANIM.idle, row)
            end
        elseif row ~= cur_row then
            set_sprite_row(this, row)
            cur_row = row
        end
    else
        set_velocity(this, 0, 0)
        if anim_lock_timer <= 0 then
            play_anim(ANIM.idle, get_facing_row())
        end
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
        return
    end

    if tag == "projectile" or tag == "player_melee" then
        hp = hp - 1
        if hp <= 0 then
            dead  = true
            dying = true
            score = score + POINTS
            play_one_shot(ANIM.death, get_facing_row())
        else
            got_hurt = true
        end
    end
end

function on_click()
end
