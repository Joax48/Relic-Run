local active = false

function on_awake()
end

function update(dt)
    if not active and relics_collected and relics_total then
        if relics_collected >= relics_total then
            active = true
            set_sprite(this, "portal-open")
        end
    end
end

function on_collision(other)
    local tag = get_tag(other)
    if tag == "player" and active then
        go_to_scene("main_menu")
    end
end

function on_click()
end
