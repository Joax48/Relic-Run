-- Llave del nivel: al recogerla se activa el portal de salida

function on_awake()
end

function update(dt)
end

function on_collision(other)
    local tag = get_tag(other)
    if tag == "player" then
        key_collected = true
        play_sfx("./assets/audio/effects/04_Fire_explosion_04_medium.wav")
        kill_entity(this)
    end
end

function on_click()
end
