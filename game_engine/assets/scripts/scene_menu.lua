scene = {
    -- Tabla de imagenes y sprites
    sprites = {},
    -- Tabala de fuentes
    fonts = {
        [0] =
        {fontId = "press_start_24", filePath = "./assets/fonts/PressStart.ttf", fontSize = 24},
        {fontId = "press_start_32", filePath = "./assets/fonts/PressStart.ttf", fontSize = 32},
    },

    -- Tabla de acciones y teclas
    keys = {
        [0] =
        {name = "UP", key = 119}, -- SDLK_w
        {name = "LEFT", key = 97}, -- SDLK_a
        {name = "DOWN", key = 115}, -- SDLK_s
        {name = "RIGHT", key = 100}, -- SDLK_d
    },

    -- Tabla de aciones y botones del mouse
    buttons = {
        [0] =
        {name = "SHOOT", button = 1}, -- SDL_BUTTON_LEFT
    },

    -- Tabla de entidades
    entities = {
        [0] =
    {
            components = {
                clickable = {
                },
                text = {
                    text = "Galaxian",
                    fontId = "press_start_32",
                    r = 150,
                    g = 0,
                    b = 150,
                    a = 255,
                },
                transform = {
                    position = {x = 50.0, y = 50.0},
                    scale = {x = 1.0, y = 1.0},
                    rotation = 0.0,
                },
            }
        },
     {
            components = {
                clickable = {
                },
                script = {
                    path = "./assets/scripts/menu_button01.lua",
                },
                text = {
                    text = "Level 01",
                    fontId = "press_start_24",
                    r = 150,
                    g = 150,
                    b = 0,
                    a = 255,
                },
                transform = {
                    position = {x = 50.0, y = 150.0},
                    scale = {x = 1.0, y = 1.0},
                    rotation = 0.0,
                },
            }
        },
     {
            components = {
                clickable = {
                },
                script = {
                    path = "./assets/scripts/menu_button02.lua",
                },
                text = {
                    text = "Level 02",
                    fontId = "press_start_24",
                    r = 150,
                    g = 150,
                    b = 0,
                    a = 255,
                },
                transform = {
                    position = {x = 50.0, y = 250.0},
                    scale = {x = 1.0, y = 1.0},
                    rotation = 0.0,
                },
            }
        },
    }
}