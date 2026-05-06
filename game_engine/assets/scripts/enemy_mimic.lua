local HP     = 2
local hp     = HP
local POINTS = 50

local CHASE_SPEED  = 90
local DETECT_RANGE = 120   -- rango en que "revela" y persigue

local dead     = false
local revealed = false     -- false = disfrazado de reliquia, true = enemigo activo

function on_awake()
end

function update(dt)
    if dead then return end

    if not revealed then
        -- quieto, esperando al jugador
        set_velocity(this, 0, 0)

        if player_x and player_y then
            local sx, sy = get_position(this)
            local dx = player_x - sx
            local dy = player_y - sy
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist < DETECT_RANGE then
                revealed = true
                -- cambiar sprite a skeleton para que sea reconocible como enemigo
                set_sprite(this, "skeleton-base")
            end
        end
        return
    end

    -- perseguir al jugador (o señuelo si está activo)
    local target_x, target_y
    if decoy_active and decoy_x and decoy_y then
        target_x, target_y = decoy_x, decoy_y
    elseif player_x and player_y then
        target_x, target_y = player_x, player_y
    end

    if target_x then
        local sx, sy = get_position(this)
        local dx = target_x - sx
        local dy = target_y - sy
        local dist = math.sqrt(dx * dx + dy * dy)
        local mult = (time_slow and 0.2) or 1.0
        if dist > 4 then
            local nx = dx / dist
            local ny = dy / dist
            set_velocity(this, nx * CHASE_SPEED * mult, ny * CHASE_SPEED * mult)
        else
            set_velocity(this, 0, 0)
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
        -- solo toma daño si ya está revelado (o al primer hit lo revela)
        if not revealed then
            revealed = true
            set_sprite(this, "skeleton-base")
        end
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
