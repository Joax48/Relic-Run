local collected = false

function on_awake()
end

function update(dt)
end

function on_collision(other)
    if collected then return end
    local tag = get_tag(other)
    if tag == "player" then
        collected      = true
        relics_collected = relics_collected + 1
        score          = score + 25
        kill_entity(this)
    end
end

function on_click()
end
