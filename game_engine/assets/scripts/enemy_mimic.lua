local HP     = 2
local hp     = HP
local POINTS = 50

local CHASE_SPEED  = 90
local DETECT_RANGE = 120

local dead     = false
local dying    = false
local revealed = false

local ANIM_DEATH_DUR = 10 / 6.0
local anim_lock_timer = 0.0

local function reveal()
    revealed = true
    set_sprite(this, "slime-idle")
    set_sprite_size(this, 64, 64)
    set_box_collider(this, 96, 96)
    play_animation(this, "slime-idle", 6, 6)
end

function on_awake()
end

function update(dt)
    -- siempre corre el timer (para muerte)
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

    if dead then return end

    if not revealed then
        set_velocity(this, 0, 0)
        if player_cx and player_cy and not player_invisible then
            local sx, sy = get_position(this)
            local dx = player_cx - sx
            local dy = player_cy - sy
            if math.sqrt(dx*dx + dy*dy) < DETECT_RANGE then
                reveal()
            end
        end
        return
    end

    -- perseguir al jugador (o señuelo)
    local tx, ty
    if decoy_active and decoy_x and decoy_y then
        tx, ty = decoy_x, decoy_y
    elseif player_cx and player_cy and not player_invisible then
        tx, ty = player_cx, player_cy
    end

    if tx then
        local sx, sy = get_position(this)
        local dx = tx - sx
        local dy = ty - sy
        local dist = math.sqrt(dx*dx + dy*dy)
        local mult = (time_slow and 0.2) or 1.0
        if dist > 4 then
            set_velocity(this, dx/dist * CHASE_SPEED * mult, dy/dist * CHASE_SPEED * mult)
        else
            set_velocity(this, 0, 0)
        end
    end
end

function on_collision(other)
    if dying or dead then return end

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
        if not revealed then reveal() end
        hp = hp - 1
        if hp <= 0 then
            dead  = true
            dying = true
            score = score + POINTS
            play_animation(this, "slime-death", 10, 6)
            set_sprite_row(this, 0)
            anim_lock_timer = ANIM_DEATH_DUR
        end
    end
end

function on_click()
end
