-- Nivel 1: Bosque Encantado (escena base)
-- Mapa 2000x2000. Paredes perimetrales invisibles con BoxCollider.

scene = {
    sprites = {
        [0] = {assetId = "background",   filePath = "./assets/images/background.png"},
              {assetId = "player-idle",   filePath = "./assets/images/Player_Ship.png"},
              {assetId = "projectile",    filePath = "./assets/images/barrier_gem.png"},
    },
    fonts = {
        [0] = {fontId = "press_start_24", filePath = "./assets/fonts/PressStart.ttf", fontSize = 24},
    },
    keys = {
        [0] = {name = "UP",     key = 119},  -- W
              {name = "LEFT",   key = 97},   -- A
              {name = "DOWN",   key = 115},  -- S
              {name = "RIGHT",  key = 100},  -- D
              {name = "ATTACK", key = 122},  -- Z
              {name = "SHOOT",  key = 120},  -- X
    },
    buttons = {},
    entities = {
        -- Fondo del mapa (2000x2000)
        [0] = {
            components = {
                sprite = {
                    assetId  = "background",
                    width    = 2000,
                    height   = 2000,
                    src_rect = {x = 0, y = 0},
                },
                transform = {
                    position = {x = 0.0, y = 0.0},
                    scale    = {x = 1.0, y = 1.0},
                    rotation = 0.0,
                },
            }
        },
        -- Jugador
        {
            components = {
                camera_follow = {},
                box_collider = {
                    width  = 32,
                    height = 32,
                    offset = {x = 0, y = 0},
                },
                rigid_body = {
                    is_dynamic = false,
                    is_solid   = false,
                    mass       = 1,
                },
                sprite = {
                    assetId  = "player-idle",
                    width    = 16,
                    height   = 16,
                    src_rect = {x = 16, y = 0},
                },
                transform = {
                    position = {x = 1000.0, y = 1000.0},
                    scale    = {x = 2.0,    y = 2.0},
                    rotation = 0.0,
                },
                tag    = {tag = "player"},
                script = {path = "./assets/scripts/player_level01.lua"},
            }
        },
        -- Pared superior (invisible, 2000x64, encima del mapa)
        {
            components = {
                box_collider = {
                    width  = 2000,
                    height = 64,
                    offset = {x = 0, y = 0},
                },
                rigid_body = {
                    is_dynamic = false,
                    is_solid   = true,
                    mass       = 1,
                },
                transform = {
                    position = {x = 0.0, y = -64.0},
                    scale    = {x = 1.0, y = 1.0},
                    rotation = 0.0,
                },
                tag = {tag = "wall"},
            }
        },
        -- Pared inferior (invisible, 2000x64, debajo del mapa)
        {
            components = {
                box_collider = {
                    width  = 2000,
                    height = 64,
                    offset = {x = 0, y = 0},
                },
                rigid_body = {
                    is_dynamic = false,
                    is_solid   = true,
                    mass       = 1,
                },
                transform = {
                    position = {x = 0.0, y = 2000.0},
                    scale    = {x = 1.0, y = 1.0},
                    rotation = 0.0,
                },
                tag = {tag = "wall"},
            }
        },
        -- Pared izquierda (invisible, 64x2000)
        {
            components = {
                box_collider = {
                    width  = 64,
                    height = 2000,
                    offset = {x = 0, y = 0},
                },
                rigid_body = {
                    is_dynamic = false,
                    is_solid   = true,
                    mass       = 1,
                },
                transform = {
                    position = {x = -64.0, y = 0.0},
                    scale    = {x = 1.0, y = 1.0},
                    rotation = 0.0,
                },
                tag = {tag = "wall"},
            }
        },
        -- Pared derecha (invisible, 64x2000)
        {
            components = {
                box_collider = {
                    width  = 64,
                    height = 2000,
                    offset = {x = 0, y = 0},
                },
                rigid_body = {
                    is_dynamic = false,
                    is_solid   = true,
                    mass       = 1,
                },
                transform = {
                    position = {x = 2000.0, y = 0.0},
                    scale    = {x = 1.0, y = 1.0},
                    rotation = 0.0,
                },
                tag = {tag = "wall"},
            }
        },
    }
}
