local HP     = 1
local hp     = HP
local POINTS = 20

local PATROL_SPEED = 40
local DETECT_RANGE = 280
local PROJ_SPEED   = 280
local SHOOT_CD     = 1.8   -- segundos entre disparos

local dead        = false
local shoot_timer = 0.0
local waypoints   = {}
local wp_index    = 1
local ARRIVE_DIST = 6

function on_awake()
    local sx, sy = get_position(this)
    waypoints = {
        {x = sx + 80, y = sy},
        {x = sx + 80, y = sy + 80},
        {x = sx,      y = sy + 80},
        {x = sx,      y = sy},
    }
    shoot_timer = SHOOT_CD * 0.5  -- fase inicial aleatoria
end

function update(dt)
    if dead then return end

    if shoot_timer > 0 then shoot_timer = shoot_timer - dt end

    local sx, sy = get_position(this)
    local mult = (time_slow and 0.2) or 1.0

    if decoy_active and decoy_x and decoy_y then
        local dx = decoy_x - sx
        local dy = decoy_y - sy
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > 4 then
            local nx = dx / dist
            local ny = dy / dist
            set_velocity(this, nx * PATROL_SPEED * mult, ny * PATROL_SPEED * mult)
        else
            set_velocity(this, 0, 0)
        end
        return
    end

    if player_x and player_y and not player_invisible then
        local dx = player_x - sx
        local dy = player_y - sy
        local dist = math.sqrt(dx * dx + dy * dy)

        if dist < DETECT_RANGE then
            set_velocity(this, 0, 0)

            if shoot_timer <= 0 then
                local nx = dx / dist
                local ny = dy / dist
                local sw, sh = get_size(this)
                local offset = sw / 2 + 12
                local px = sx + sw / 2 + nx * offset - 8
                local py = sy + sh / 2 + ny * offset - 8
                spawn_projectile(px, py, nx * PROJ_SPEED * mult, ny * PROJ_SPEED * mult)
                shoot_timer = SHOOT_CD
            end
            return
        end
    end

    local wp = waypoints[wp_index]
    local dx = wp.x - sx
    local dy = wp.y - sy
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist < ARRIVE_DIST then
        wp_index = (wp_index % #waypoints) + 1
    else
        local nx = dx / dist
        local ny = dy / dist
        set_velocity(this, nx * PATROL_SPEED * mult, ny * PATROL_SPEED * mult)
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
            score = score + POINTS
            kill_entity(this)
        end
    end
end

function on_click()
end
