local collected = false

function on_awake()
end

function update(dt)
end

function on_collision(other)
    if collected then return end
    if get_tag(other) == "player" then
        collected    = true
        has_timeslow = true
        kill_entity(this)
    end
end

function on_click()
end
