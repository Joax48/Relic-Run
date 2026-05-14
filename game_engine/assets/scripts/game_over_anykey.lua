local delay = 1.0

function on_awake() end

function update(dt)
    delay = delay - dt
    if delay <= 0 and is_any_key_pressed() then
        score = score_level_start or 0
        go_to_scene(game_current_level or "level_01")
    end
end

function on_collision(other) end
function on_click() end
