-- Pantalla Game Over

scene = {
    sprites = {},
    fonts = {
        [0] = {fontId = "press_start_32", filePath = "./assets/fonts/PressStart.ttf", fontSize = 32},
              {fontId = "press_start_16", filePath = "./assets/fonts/PressStart.ttf", fontSize = 16},
    },
    keys   = {},
    buttons = {
        [0] = {name = "SHOOT", button = 1},
    },
    entities = {
        -- ── "YOU DIED" ──────────────────────────────────────────────────────────
        [0] = {
            components = {
                transform = {position = {x = 0.0, y = 160.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                text      = {text = "YOU DIED", fontId = "press_start_32",
                             r = 200, g = 30, b = 30, a = 255},
                script    = {path = "./assets/scripts/menu_center.lua"},
            }
        },
        -- ── REINTENTAR ──────────────────────────────────────────────────────────
        {
            components = {
                transform = {position = {x = 0.0, y = 320.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                text      = {text = "REINTENTAR", fontId = "press_start_16",
                             r = 80, g = 215, b = 110, a = 255},
                clickable = {},
                script    = {path = "./assets/scripts/game_over_retry.lua"},
            }
        },
        -- ── MENÚ PRINCIPAL ──────────────────────────────────────────────────────
        {
            components = {
                transform = {position = {x = 0.0, y = 390.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                text      = {text = "MENU PRINCIPAL", fontId = "press_start_16",
                             r = 190, g = 190, b = 190, a = 255},
                clickable = {},
                script    = {path = "./assets/scripts/game_over_menu.lua"},
            }
        },
    }
}
