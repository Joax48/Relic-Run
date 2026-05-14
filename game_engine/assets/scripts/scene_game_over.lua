-- Pantalla Game Over

play_music("./assets/audio/Jingle - Lose.ogg", false)

scene = {
    sprites = {
        [0] = {assetId = "defeat-bg", filePath = "./assets/images/ui/defeat_bg.png"},
    },
    fonts = {
        [0] = {fontId = "press_start_32", filePath = "./assets/fonts/PressStart.ttf", fontSize = 32},
              {fontId = "press_start_24", filePath = "./assets/fonts/PressStart.ttf", fontSize = 24},
              {fontId = "press_start_16", filePath = "./assets/fonts/PressStart.ttf", fontSize = 16},
    },
    keys   = {},
    buttons = {},
    entities = {
        -- ── Fondo animado ────────────────────────────────────────────────────────
        [0] = {
            components = {
                transform = {position = {x = 0.0, y = 0.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                sprite    = {assetId = "defeat-bg", width = 800, height = 600,
                             src_rect = {x = 0, y = 0}, z_index = -1},
                animation = {num_frames = 10, speed_rate = 8, is_loop = true},
                script    = {path = "./assets/scripts/ui_bg_follow.lua"},
            }
        },

        -- ── Press any key ────────────────────────────────────────────────────────
        {
            components = {
                transform = {position = {x = 0.0, y = 460.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},

                script    = {path = "./assets/scripts/game_over_anykey.lua"},
            }
        },
    }
}
