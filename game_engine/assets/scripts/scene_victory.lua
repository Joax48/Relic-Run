-- Pantalla de victoria

play_music("./assets/audio/Jingle - Victory.ogg", false)

scene = {
    sprites = {
        [0] = {assetId = "victory-bg", filePath = "./assets/images/ui/victory_bg.png"},
    },
    fonts = {
        [0] = {fontId = "press_start_32", filePath = "./assets/fonts/PressStart.ttf", fontSize = 32},
              {fontId = "press_start_24", filePath = "./assets/fonts/PressStart.ttf", fontSize = 24},
              {fontId = "press_start_16", filePath = "./assets/fonts/PressStart.ttf", fontSize = 16},
              {fontId = "press_start_10", filePath = "./assets/fonts/PressStart.ttf", fontSize = 10},
    },
    keys   = {},
    buttons = {},
    entities = {
        -- ── Fondo animado ────────────────────────────────────────────────────────
        [0] = {
            components = {
                transform = {position = {x = 0.0, y = 0.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                sprite    = {assetId = "victory-bg", width = 800, height = 600,
                             src_rect = {x = 0, y = 0}, z_index = -1},
                animation = {num_frames = 10, speed_rate = 8, is_loop = true},
                script    = {path = "./assets/scripts/ui_bg_follow.lua"},
            }
        },
        -- ── Score final ──────────────────────────────────────────────────────────
        {
            components = {
                transform = {position = {x = 440.0, y = 460.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                text      = {text = "SCORE: 0", fontId = "press_start_10",
                             r = 255, g = 220, b = 50, a = 255},
                script    = {path = "./assets/scripts/victory_score.lua"},
            }
        },
        -- ── Press any key ────────────────────────────────────────────────────────
        {
            components = {
                transform = {position = {x = 0.0, y = 460.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                script    = {path = "./assets/scripts/victory_anykey.lua"},
            }
        },
    }
}
