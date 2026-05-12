local HP     = 1
local hp     = HP
local POINTS = 10

local HOP_SPEED     = 55
local HOP_DURATION  = 0.6
local REST_DURATION = 0.9
local CHASE_SPEED   = 80
local DETECT_RANGE  = 240
local PATROL_RANGE  = 140

-- Slime sprite center offset (scale 1.2 × 32 / 2 ≈ 19)
local HALF = 19

local dead     = false
local dying    = false
local got_hurt = false

local hopping    = false
local hop_timer  = 0.0
local hop_vx     = 0
local hop_vy     = 0
local facing_row = 0  -- 0=S, 1=W, 2=E, 3=N

local home_x, home_y = nil, nil

local ANIM = {
    idle   = {id = "slime-idle",   frames = 6,  speed = 6},
    walk   = {id = "slime-walk",   frames = 8,  speed = 8},
    hurt   = {id = "slime-hurt",   frames = 5,  speed = 10},
    death  = {id = "slime-death",  frames = 10, speed = 6},
}

local cur_anim        = ""
local anim_lock_timer = 0.0

local function play_anim(a, row)
    if cur_anim ~= a.id then
        play_animation(this, a.id, a.frames, a.speed)
        cur_anim = a.id
    end
    set_sprite_row(this, row)
end

local function play_one_shot(a, row)
    anim_lock_timer = a.frames / a.speed
    cur_anim = a.id
    play_animation(this, a.id, a.frames, a.speed)
    set_sprite_row(this, row)
end

function on_awake()
    hop_timer = math.random() * REST_DURATION
    hopping   = false
end

function update(dt)
    local mult = (time_slow and 0.2) or 1.0

    if got_hurt and not dying then
        got_hurt = false
        play_one_shot(ANIM.hurt, 0)
    end

    if anim_lock_timer > 0 then
        anim_lock_timer = anim_lock_timer - dt
        if anim_lock_timer < 0 then anim_lock_timer = 0 end
    end

    if dying then
        set_velocity(this, 0, 0)
        if anim_lock_timer <= 0 then kill_entity(this) end
        return
    end

    local sx, sy = get_position(this)
    local cx = sx + HALF  -- slime center
    local cy = sy + HALF

    -- Record home on first frame
    if not home_x then home_x = cx; home_y = cy end

    -- Detect player (compare center-to-center)
    local tx, ty
    if decoy_active and decoy_x and decoy_y then
        tx, ty = decoy_x, decoy_y
    elseif not player_invisible and player_cx then
        local dx = player_cx - cx
        local dy = player_cy - cy
        if math.sqrt(dx*dx + dy*dy) < DETECT_RANGE then
            tx, ty = player_cx, player_cy
        end
    end

    -- Chase mode
    if tx then
        local dx = tx - cx
        local dy = ty - cy
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist > 1 then
            if math.abs(dx) > math.abs(dy) then
                facing_row = dx > 0 and 2 or 1
            else
                facing_row = dy > 0 and 0 or 3
            end
            if anim_lock_timer <= 0 then
                set_velocity(this, dx/dist * CHASE_SPEED * mult, dy/dist * CHASE_SPEED * mult)
                play_anim(ANIM.walk, facing_row)
            end
        end
        return
    end

    -- Redirect hop back toward home if too far
    if hopping then
        local hdx = home_x - cx
        local hdy = home_y - cy
        if math.sqrt(hdx*hdx + hdy*hdy) > PATROL_RANGE then
            local hd = math.sqrt(hdx*hdx + hdy*hdy)
            hop_vx = (hdx/hd) * HOP_SPEED
            hop_vy = (hdy/hd) * HOP_SPEED
        end
    end

    -- Random hop state machine
    hop_timer = hop_timer - dt * mult
    if hop_timer <= 0 then
        if hopping then
            hopping   = false
            hop_timer = REST_DURATION * (0.5 + math.random() * 1.0)
        else
            hopping   = true
            hop_timer = HOP_DURATION * (0.5 + math.random() * 1.0)
            local angle = math.random() * math.pi * 2
            hop_vx = math.cos(angle) * HOP_SPEED
            hop_vy = math.sin(angle) * HOP_SPEED
            if math.abs(hop_vx) > math.abs(hop_vy) then
                facing_row = hop_vx > 0 and 2 or 1
            else
                facing_row = hop_vy > 0 and 0 or 3
            end
        end
    end

    if anim_lock_timer <= 0 then
        if hopping then
            set_velocity(this, hop_vx * mult, hop_vy * mult)
            play_anim(ANIM.walk, facing_row)
        else
            set_velocity(this, 0, 0)
            play_anim(ANIM.idle, 0)
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
        hopping   = false
        hop_timer = REST_DURATION
        return
    end

    if tag == "projectile" or tag == "player_melee" then
        hp = hp - 1
        if hp <= 0 then
            dead  = true
            dying = true
            score = score + POINTS
            play_one_shot(ANIM.death, 0)
        else
            got_hurt = true
        end
    end
end

function on_click()
end
