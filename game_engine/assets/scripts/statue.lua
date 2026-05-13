-- Estatua (reliquia decorativa): solo da puntos, no activa el portal

local POINTS = 50

function on_awake()
end

function update(dt)
end

function on_collision(other)
    local tag = get_tag(other)
    if tag == "player" then
        score = score + POINTS
        relics_collected = (relics_collected or 0) + 1
        play_sfx("./assets/audio/effects/04_Fire_explosion_04_medium.wav")
        kill_entity(this)
    end
end

function on_click()
end
