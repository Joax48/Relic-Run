-- Menú principal — Relic Run

play_music("./assets/audio/Theme - Magical Rainbow.ogg", true)

scene = {
    sprites = {
        [0] = {assetId = "menu-bg", filePath = "./assets/images/menu.png"},
    },
    fonts = {
        [0] = {fontId = "press_start_32", filePath = "./assets/fonts/PressStart.ttf", fontSize = 32},
              {fontId = "press_start_24", filePath = "./assets/fonts/PressStart.ttf", fontSize = 24},
              {fontId = "press_start_16", filePath = "./assets/fonts/PressStart.ttf", fontSize = 16},
    },
    keys   = {},
    buttons = {
        [0] = {name = "SHOOT", button = 1},
    },
    entities = {
        -- ── Fondo del menú ───────────────────────────────────────────────────
        [0] = {
            components = {
                -- menu.png es 1850×997 → escalar a 800×600
                transform = {position = {x = 0.0, y = 0.0},
                             scale    = {x = 800.0/1850.0, y = 600.0/997.0},
                             rotation = 0.0},
                sprite    = {assetId = "menu-bg", width = 1850, height = 997,
                             src_rect = {x = 0, y = 0}, z_index = -1},
            }
        },
        -- ── Botón START ─────────────────────────────────────────────────────
        {
            components = {
                transform = {position = {x = 310.0, y = 490.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                text      = {text = "START", fontId = "press_start_32",
                             r = 80, g = 215, b = 110, a = 255},
                clickable = {},
                script    = {path = "./assets/scripts/menu_start.lua"},
            }
        },
        -- ── Versión / crédito ────────────────────────────────────────────────
        {
            components = {
                transform = {position = {x = 16.0, y = 568.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                text      = {text = "v0.1", fontId = "press_start_16",
                             r = 70, g = 70, b = 70, a = 255},
            }
        },
        -- ── Toggle música ────────────────────────────────────────────────────
        {
            components = {
                transform = {position = {x = 0.0, y = 568.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                text      = {text = "[SND]", fontId = "press_start_16",
                             r = 90, g = 90, b = 90, a = 255},
                clickable = {},
                script    = {path = "./assets/scripts/menu_sound.lua"},
            }
        },
    }
}
