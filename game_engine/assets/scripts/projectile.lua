function on_awake()
end

function update(dt)
end

function on_collision(other)
    local tag = get_tag(other)
    if tag ~= "player" and tag ~= "projectile" and tag ~= "player_melee" then
        kill_entity(this)
    end
end

function on_click()
end
