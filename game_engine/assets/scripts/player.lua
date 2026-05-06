-- VARIABLES GLOBALES
player_velocity = 150;

-- h = sqrt((150*150)+(150*150))
-- 150 = sqrt((x*x)+(y*y)) => x = y => a
-- 150 = sqrt((a*a)+(a*a))
-- 150 = sqrt(2*(a*a))
--150 * 150 = 2*(a*a)
-- 150 * 150 / 2 = (a*a)
-- sqrt(150 * 150 / 2) = a

fixed_player_velocity = math.sqrt((player_velocity * player_velocity) / 2);

function update()
    set_velocity(this, 0, 0);
    vel_x = 0;
    vel_y = 0;

    if is_action_activated("UP") then
        vel_y = vel_y-1;
    end
    if is_action_activated("DOWN") then
        vel_y = vel_y+1;
    end
    if is_action_activated("LEFT") then
        vel_x = vel_x-1;
    end
    if is_action_activated("RIGHT") then
        vel_x = vel_x+1;
    end

    if vel_x ~= 0 and vel_y ~= 0 then
        vel_x = vel_x * fixed_player_velocity;
        vel_y = vel_y * fixed_player_velocity;
    else
    vel_x = vel_x * player_velocity;
    vel_y = vel_y * player_velocity;
    end

    set_velocity(this, vel_x, vel_y);

end