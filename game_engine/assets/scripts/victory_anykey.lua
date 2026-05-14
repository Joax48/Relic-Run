local delay = 1.0

function on_awake() end

function update(dt)
    delay = delay - dt
    if delay <= 0 and is_any_key_pressed() then
        if game_current_level == "level_01" then
            go_to_scene("level_02")
        elseif game_current_level == "level_02" then
            go_to_scene("level_03")
        else
            go_to_scene("main_menu")
        end
    end
end

function on_collision(other) end
function on_click() end
