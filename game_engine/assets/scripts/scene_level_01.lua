-- Nivel 1: Bosque Encantado (escena base)
-- Mapa 2000x2000. Paredes perimetrales invisibles con BoxCollider.

score            = 0   -- global accesible desde cualquier script
relics_total     = 3
relics_collected = 0
has_cloak        = false
cloak_cooldown   = 0
has_decoy        = false
decoy_cooldown   = 0
decoy_active     = false
decoy_x          = 0
decoy_y          = 0
has_timeslow     = false
timeslow_cooldown = 0
time_slow        = false

scene = {
    sprites = {
        [0] = {assetId = "background",      filePath = "./assets/images/background.png"},
              {assetId = "player-idle",      filePath = "./assets/images/Player_Ship.png"},
              {assetId = "projectile",       filePath = "./assets/images/barrier_gem.png"},
              {assetId = "skeleton-base",    filePath = "./assets/images/Enemy_Alan.png"},
              {assetId = "relic-item",       filePath = "./assets/images/barrier_gem.png"},
              {assetId = "portal-closed",    filePath = "./assets/images/Enemy_Alan.png"},
              {assetId = "portal-open",      filePath = "./assets/images/Player_Ship.png"},
              {assetId = "powerup-cloak",    filePath = "./assets/images/barrier_gem.png"},
              {assetId = "powerup-decoy",    filePath = "./assets/images/barrier_gem.png"},
              {assetId = "powerup-timeslow", filePath = "./assets/images/barrier_gem.png"},
    },
    fonts = {
        [0] = {fontId = "press_start_24", filePath = "./assets/fonts/PressStart.ttf", fontSize = 24},
    },
    keys = {
        [0] = {name = "UP",     key = 119},  -- W
              {name = "LEFT",   key = 97},   -- A
              {name = "DOWN",   key = 115},  -- S
              {name = "RIGHT",  key = 100},  -- D
              {name = "ATTACK",    key = 122},  -- Z
              {name = "SHOOT",    key = 120},  -- X
              {name = "USE_SLOT1", key = 49},  -- 1
              {name = "USE_SLOT2", key = 50},  -- 2
              {name = "USE_SLOT3", key = 51},  -- 3
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
        -- Skeleton base #1
        {
            components = {
                animation = {num_frames = 6, speed_rate = 8, is_loop = true},
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "skeleton-base", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 800.0,  y = 800.0},  scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "skeleton_base"},
                script       = {path = "./assets/scripts/enemy_skeleton_base.lua"},
            }
        },
        -- Skeleton base #2
        {
            components = {
                animation = {num_frames = 6, speed_rate = 8, is_loop = true},
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "skeleton-base", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 1200.0, y = 800.0},  scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "skeleton_base"},
                script       = {path = "./assets/scripts/enemy_skeleton_base.lua"},
            }
        },
        -- Skeleton base #3
        {
            components = {
                animation = {num_frames = 6, speed_rate = 8, is_loop = true},
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "skeleton-base", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 1000.0, y = 1300.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "skeleton_base"},
                script       = {path = "./assets/scripts/enemy_skeleton_base.lua"},
            }
        },
        -- Skeleton mage #1
        {
            components = {
                animation    = {num_frames = 6, speed_rate = 8, is_loop = true},
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "skeleton-base", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 700.0, y = 1100.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "skeleton_mage"},
                script       = {path = "./assets/scripts/enemy_skeleton_mage.lua"},
            }
        },
        -- Skeleton mage #2
        {
            components = {
                animation    = {num_frames = 6, speed_rate = 8, is_loop = true},
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "skeleton-base", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 1300.0, y = 1100.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "skeleton_mage"},
                script       = {path = "./assets/scripts/enemy_skeleton_mage.lua"},
            }
        },
        -- Reliquia #1
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "relic-item", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 500.0, y = 500.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "relic"},
                script       = {path = "./assets/scripts/relic.lua"},
            }
        },
        -- Reliquia #2
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "relic-item", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 1500.0, y = 500.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "relic"},
                script       = {path = "./assets/scripts/relic.lua"},
            }
        },
        -- Reliquia #3
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "relic-item", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 1000.0, y = 1700.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "relic"},
                script       = {path = "./assets/scripts/relic.lua"},
            }
        },
        -- Portal de salida (inactivo hasta recolectar todas las reliquias)
        {
            components = {
                box_collider = {width = 64, height = 64, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "portal-closed", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 950.0, y = 200.0}, scale = {x = 4.0, y = 4.0}, rotation = 0.0},
                tag          = {tag = "portal"},
                script       = {path = "./assets/scripts/portal.lua"},
            }
        },
        -- Power-up: Orbe señuelo
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "powerup-decoy", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 1100.0, y = 1500.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "powerup_decoy"},
                script       = {path = "./assets/scripts/powerup_decoy.lua"},
            }
        },
        -- Power-up: Pergamino temporal
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "powerup-timeslow", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 400.0, y = 1400.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "powerup_timeslow"},
                script       = {path = "./assets/scripts/powerup_timeslow.lua"},
            }
        },
        -- Power-up: Capa de invisibilidad
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "powerup-cloak", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 900.0, y = 900.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "powerup_cloak"},
                script       = {path = "./assets/scripts/powerup_cloak.lua"},
            }
        },
        -- Mimic #1 (disfrazado de reliquia)
        {
            components = {
                box_collider = {width = 16, height = 16, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "relic-item", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 600.0, y = 600.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "mimic"},
                script       = {path = "./assets/scripts/enemy_mimic.lua"},
            }
        },
        -- Mimic #2 (disfrazado de reliquia)
        {
            components = {
                box_collider = {width = 16, height = 16, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "relic-item", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 1400.0, y = 1400.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "mimic"},
                script       = {path = "./assets/scripts/enemy_mimic.lua"},
            }
        },
        -- HUD: Score (posición fija en pantalla; RenderTextSystem no aplica offset de cámara)
        {
            components = {
                transform = {
                    position = {x = 16.0, y = 16.0},
                    scale    = {x = 1.0,  y = 1.0},
                    rotation = 0.0,
                },
                text = {
                    text   = "Score: 0",
                    fontId = "press_start_24",
                    r = 255, g = 255, b = 255, a = 255,
                },
                script = {path = "./assets/scripts/hud.lua"},
            }
        },
    }
}
