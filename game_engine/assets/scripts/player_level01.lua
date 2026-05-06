local SPEED          = 150
local SPEED_DIAGONAL = math.sqrt((SPEED * SPEED) / 2)
local PROJ_SPEED     = 350

-- Dirección en la que mira el jugador (cardinal preferida)
local facing_x = 1
local facing_y = 0

-- Melee
local melee_active   = false
local melee_timer    = 0.0
local melee_entity   = nil
local MELEE_DURATION = 0.15

-- Disparo
local shoot_cooldown = 0.0
local SHOOT_COOLDOWN = 0.35

function on_awake()
end

function update(dt)
    -- timers
    if shoot_cooldown > 0 then shoot_cooldown = shoot_cooldown - dt end

    if melee_active then
        melee_timer = melee_timer - dt
        if melee_timer <= 0 then
            kill_entity(melee_entity)
            melee_active = false
            melee_entity = nil
        end
    end

    -- input de movimiento
    local vx = 0
    local vy = 0
    if is_action_activated("UP")    then vy = vy - 1 end
    if is_action_activated("DOWN")  then vy = vy + 1 end
    if is_action_activated("LEFT")  then vx = vx - 1 end
    if is_action_activated("RIGHT") then vx = vx + 1 end

    -- actualizar dirección cardinal (horizontal tiene prioridad sobre vertical)
    if vx ~= 0 then
        facing_x = vx
        facing_y = 0
    elseif vy ~= 0 then
        facing_x = 0
        facing_y = vy
    end

    -- normalizar diagonal
    if vx ~= 0 and vy ~= 0 then
        vx = vx * SPEED_DIAGONAL
        vy = vy * SPEED_DIAGONAL
    else
        vx = vx * SPEED
        vy = vy * SPEED
    end
    set_velocity(this, vx, vy)

    -- ataque melee (Z)
    if is_action_activated("ATTACK") and not melee_active then
        local px, py = get_position(this)
        local pw, ph = get_size(this)
        local hw, hh = 28, 28
        -- hitbox adyacente al frente del jugador
        local hx = px + facing_x * pw
        local hy = py + facing_y * ph
        -- ajuste para centrar en el eje perpendicular
        if facing_x ~= 0 then hy = py + (ph - hh) / 2 end
        if facing_y ~= 0 then hx = px + (pw - hw) / 2 end

        melee_entity = spawn_melee(hx, hy, hw, hh)
        melee_active  = true
        melee_timer   = MELEE_DURATION
    end

    -- disparo mágico (X)
    if is_action_activated("SHOOT") and shoot_cooldown <= 0 then
        local px, py = get_position(this)
        local pw, ph = get_size(this)
        local sx = px + pw / 2 - 8   -- centrado en el jugador
        local sy = py + ph / 2 - 8
        spawn_projectile(sx, sy, facing_x * PROJ_SPEED, facing_y * PROJ_SPEED)
        shoot_cooldown = SHOOT_COOLDOWN
    end
end

function on_collision(other)
    local tag = get_tag(other)
    if tag == "wall" then
        local px, py = get_position(this)
        local pw, ph = get_size(this)
        local ox, oy = get_position(other)
        local ow, oh = get_size(other)
        local cvx, cvy = get_velocity(this)

        if right_collision(this, other) then
            set_velocity(this, 0, cvy)
            set_position(this, ox - pw, py)
        elseif left_collision(this, other) then
            set_velocity(this, 0, cvy)
            set_position(this, ox + ow, py)
        elseif down_collision(this, other) then
            set_velocity(this, cvx, 0)
            set_position(this, px, oy - ph)
        elseif up_collision(this, other) then
            set_velocity(this, cvx, 0)
            set_position(this, px, oy + oh)
        end
    end
end

function on_click()
end
