local HP     = 10
local hp     = HP
local POINTS = 150

local PATROL_SPEED = 35
local DETECT_RANGE = 400
local PROJ_SPEED   = 220
local FIRE_CD      = 2.5   -- segundos entre disparos
local ARRIVE_DIST  = 8

local dead       = false
local fire_timer = FIRE_CD
local waypoints  = {}
local wp_index   = 1

function on_awake()
    local sx, sy = get_position(this)
    -- patrulla cuadrada de 200px alrededor del spawn
    waypoints = {
        {x = sx + 200, y = sy},
        {x = sx + 200, y = sy + 200},
        {x = sx,       y = sy + 200},
        {x = sx,       y = sy},
    }
    fire_timer = FIRE_CD * 0.3  -- fase inicial
end

function update(dt)
    if dead then return end

    if fire_timer > 0 then fire_timer = fire_timer - dt end

    local sx, sy = get_position(this)

    if player_x and player_y then
        local dx = player_x - sx
        local dy = player_y - sy
        local dist = math.sqrt(dx * dx + dy * dy)

        if dist < DETECT_RANGE then
            -- detenerse y escupir fuego
            set_velocity(this, 0, 0)

            if fire_timer <= 0 then
                local nx = dx / dist
                local ny = dy / dist
                local sw, sh = get_size(this)
                local offset = sw / 2 + 16
                local px = sx + sw / 2 + nx * offset - 8
                local py = sy + sh / 2 + ny * offset - 8
                spawn_projectile(px, py, nx * PROJ_SPEED, ny * PROJ_SPEED)
                fire_timer = FIRE_CD
            end
            return
        end
    end

    -- patrullar waypoints
    local wp = waypoints[wp_index]
    local dx = wp.x - sx
    local dy = wp.y - sy
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist < ARRIVE_DIST then
        wp_index = (wp_index % #waypoints) + 1
    else
        local nx = dx / dist
        local ny = dy / dist
        set_velocity(this, nx * PATROL_SPEED, ny * PATROL_SPEED)
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
