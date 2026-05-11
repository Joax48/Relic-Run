function on_awake()
end

function update(dt)
end

function on_collision(other)
    local tag = get_tag(other)
    -- destroy when hitting player, walls, or player melee
    -- pass through enemies and other projectiles
    if tag == "player" or tag == "wall" or tag == "player_melee" then
        kill_entity(this)
    end
end

function on_click()
end
