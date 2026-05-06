scene = {
    -- Tabla de imagenes y sprites
    sprites = {
        [0] = 
        {assetId = "enemy_alan", filePath = "./assets/images/Enemy_Alan.png"},
        {assetId = "player_ship", filePath = "./assets/images/Player_Ship.png"},
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
        -- Player
        {
            components = {
                camera_follow = {
                },
                circle_collider = {
                    radius = 8,
                    width = 16,
                    height = 16,
                },
                rigid_body ={
                    is_dynamic = false,
                    is_solid = false,
                    mass = 1,
                },
                sprite = {
                    assetId = "player_ship",
                    width = 16,
                    height = 16,
                    src_rect = {x = 16, y = 0},
                },
                transform = {
                    position = {x = 400.0, y = 300.0},
                    scale = {x = 2.0, y = 2.0},
                    rotation = 0.0,
                },
                script = {
                    path = "./assets/scripts/player.lua",
                },
            }
        },
        -- Enemigos
        -- {
        --     components = {
        --         animation = {
        --             num_frames = 6,
        --             speed_rate = 10,
        --             is_loop = true,
        --         },
        --          box_collider = {
        --             width = 16 * 2,
        --             height = 16 * 2, -- redimensionar el box collider para que coincida con el sprite escalado
        --             offset = {x = 0, y = 0},
        --         },
        --         rigid_body ={
        --             velocity = {x = 50.0, y = 0.0},
        --         },
        --         script = {
        --             path = "./assets/scripts/enemy_alan.lua",
        --         },
        --         sprite = {
        --             assetId = "enemy_alan",
        --             width = 16,
        --             height = 16,
        --             src_rect = {x = 0, y = 0},
        --         },
        --         tag = {
        --             tag = "Enemy 01",
        --         },
        --         transform = {
        --             position = {x = 200.0, y = 100.0},
        --             scale = {x = 2.0, y = 2.0},
        --             rotation = 0.0,
        --         },
        --     }
        -- } ,
        -- Barrera
        {
            components = {
                box_collider = {
                    width = 16 * 2,
                    height = 16 * 2, -- redimensionar el box collider para que coincida con el sprite escalado
                    offset = {x = 0, y = 0},
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
                    position = {x = 100.0, y = 100.0},
                    scale = {x = 2.0, y = 2.0},
                    rotation = 0.0,
                },
            }
        },
        -- Barrera 2
        {
            components = {
                box_collider = {
                    width = 16 * 2,
                    height = 16 * 2, -- redimensionar el box collider para que coincida con el sprite escalado
                    offset = {x = 0, y = 0},
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
                    position = {x = 400.0, y = 100.0},
                    scale = {x = 2.0, y = 2.0},
                    rotation = 0.0,
                },
            }
        },
        {
            components = {
                animation = {
                    num_frames = 6,
                    speed_rate = 10,
                    is_loop = true,
                },
                box_collider = {
                    width = 16 * 2,
                    height = 16 * 2, -- redimensionar el box collider para que coincida con el sprite escalado
                    offset = {x = 0, y = 0},
                },
                rigid_body ={
                    is_dynamic = false,
                    is_solid = false,
                    mass = 1,
                },
                script = {
                    path = "./assets/scripts/enemy_alan.lua",
                },
                sprite = {
                    assetId = "enemy_alan",
                    width = 16,
                    height = 16,
                    src_rect = {x = 0, y = 0},
                },
                tag = {
                    tag = "Enemy",
                },
                transform = {
                    position = {x = 200.0, y = 100.0},
                    scale = {x = 2.0, y = 2.0},
                    rotation = 0.0,
                },
            }
        },
    {
            components = {
                clickable = {
                },
                text = {
                    text = "Score: 100",
                    fontId = "press_start_24",
                    r = 150,
                    g = 0,
                    b = 150,
                    a = 255,
                },
                transform = {
                    position = {x = 500.0, y = 50.0},
                    scale = {x = 1.0, y = 1.0},
                    rotation = 0.0,
                },
            }
        },
    }
}