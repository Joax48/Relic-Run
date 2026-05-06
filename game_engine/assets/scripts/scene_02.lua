scene = {
    -- Tabla de imagenes y sprites
    sprites = {
        [0] = 
        {assetId = "frog_idle", filePath = "./assets/images/frog_idle.png"},
        {assetId = "background", filePath = "./assets/images/background.png"},
        {assetId = "barrier_gem", filePath = "./assets/images/barrier_gem.png"},
    },
    -- Tabala de fuentes
    fonts = {
        [0] =
        {fontId = "press_start_24", filePath = "./assets/fonts/PressStart.ttf", fontSize = 24},
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
        -- Background
        {
            components = {
                sprite = {
                    assetId = "background",
                    width = 2000,
                    height = 2000,
                    src_rect = {x = 0, y = 0},
                },
                transform = {
                    position = {x = 0.0, y = 0.0},
                    scale = {x = 1.0, y = 1.0},
                    rotation = 0.0,
                },
            }
        },
        {
            components = {
                box_collider = {
                    width = 16 * 2,
                    height = 16 * 2, -- redimensionar el box collider para que coincida con el sprite escalado
                    offset = {x = 0, y = 0},
                },
                rigid_body ={
                    is_dynamic = false,
                    is_solid = true,
                    mass = 9999999.0,
                },
                sprite = {
                    assetId = "barrier_gem",
                    width = 16,
                    height = 16,
                    src_rect = {x = 0, y = 0},
                },
                tag = {
                    tag = "Barrier",
                },
                transform = {
                    position = {x = 400.0, y = 300.0},
                    scale = {x = 2.0, y = 2.0},
                    rotation = 0.0,
                },
            }
        },
        {
            components = {
                camera_follow = {
                },
                box_colider = {
                    width = 32,
                    height = 32,
                    offset = { x = 0, y = 0},
                },
                rigid_body ={
                    is_dynamic = true,
                    is_solid = true,
                    mass = 10,
                },
                sprite = {
                    assetId = "frog_idle",
                    width = 32,
                    height = 32,
                    src_rect = {x = 32, y = 0},
                },
                transform = {
                    position = {x = 400.0, y = 100.0},
                    scale = {x = 1.0, y = 1.0},
                    rotation = 0.0,
                },
                script = {
                    path = "./assets/scripts/player_frog.lua",
                },
            }
        },
        
   
    }
}