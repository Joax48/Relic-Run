-- Nivel 3: Cementerio maldito (stub — pendiente de implementar)
-- Por ahora reutiliza el setup de nivel 1 y muestra texto de aviso.

score             = 0
relics_total      = 1
relics_collected  = 0
has_cloak         = false
cloak_cooldown    = 0
has_decoy         = false
decoy_cooldown    = 0
decoy_active      = false
decoy_x           = 0
decoy_y           = 0
has_timeslow      = false
timeslow_cooldown = 0
time_slow         = false

load_map("./assets/maps/level_01.tmx")

scene = {
    sprites = {
        [0] = {assetId = "player-idle",   filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Idle_without_shadow.png"},
              {assetId = "player-walk",   filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Walk_without_shadow.png"},
              {assetId = "player-attack", filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_attack_without_shadow.png"},
              {assetId = "player-hurt",   filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Hurt_without_shadow.png"},
              {assetId = "player-dead",   filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Death_without_shadow.png"},
              {assetId = "projectile",    filePath = "./assets/images/barrier_gem.png"},
              {assetId = "portal-open",   filePath = "./assets/images/portal/End Portal/End Portal Open.png"},
              {assetId = "relic-item",    filePath = "./assets/images/barrier_gem.png"},
    },
    fonts = {
        [0] = {fontId = "press_start_24", filePath = "./assets/fonts/PressStart.ttf", fontSize = 24},
    },
    keys = {
        [0] = {name = "UP",       key = 119},
              {name = "LEFT",     key = 97},
              {name = "DOWN",     key = 115},
              {name = "RIGHT",    key = 100},
              {name = "ATTACK",   key = 106},
              {name = "USE_SLOT1", key = 49},
              {name = "USE_SLOT2", key = 50},
              {name = "USE_SLOT3", key = 51},
    },
    buttons = {},
    entities = {
        -- Paredes perimetrales (mapa 1024×1280)
        [0] = {
            components = {
                box_collider = {width = 1152, height = 64, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = true, mass = 1},
                transform    = {position = {x = -64.0, y = -64.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                tag          = {tag = "wall"},
            }
        },
        {
            components = {
                box_collider = {width = 1152, height = 64, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = true, mass = 1},
                transform    = {position = {x = -64.0, y = 1280.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                tag          = {tag = "wall"},
            }
        },
        {
            components = {
                box_collider = {width = 64, height = 1408, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = true, mass = 1},
                transform    = {position = {x = -64.0, y = -64.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                tag          = {tag = "wall"},
            }
        },
        {
            components = {
                box_collider = {width = 64, height = 1408, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = true, mass = 1},
                transform    = {position = {x = 1024.0, y = -64.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                tag          = {tag = "wall"},
            }
        },
        -- Jugador
        {
            components = {
                transform    = {position = {x = 450.0, y = 900.0}, scale = {x = 1.2, y = 1.2}, rotation = 0.0},
                sprite       = {assetId = "player-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                animation    = {num_frames = 12, speed_rate = 6, is_loop = true},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                box_collider = {width = 38, height = 48, offset = {x = 19, y = 14}},
                tag          = {tag = "player"},
                camera_follow = {},
                script       = {path = "./assets/scripts/player_level01.lua"},
            }
        },
        -- Reliquia única → activa el portal y vuelve al menú
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "relic-item", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 500.0, y = 640.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "relic"},
                script       = {path = "./assets/scripts/relic.lua"},
            }
        },
        -- Portal de salida → menú principal
        {
            components = {
                box_collider = {width = 64, height = 64, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "portal-open", width = 320, height = 320, src_rect = {x = 0, y = 0}, z_index = 2},
                animation    = {num_frames = 6, speed_rate = 8, is_loop = true},
                transform    = {position = {x = 480.0, y = 560.0}, scale = {x = 0.2, y = 0.2}, rotation = 0.0},
                tag          = {tag = "portal"},
                script       = {path = "./assets/scripts/portal_l02.lua"},
            }
        },
        -- HUD
        {
            components = {
                transform = {position = {x = 16.0, y = 16.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                text      = {text = "NIVEL 3 - PROXIMAMENTE", fontId = "press_start_24", r = 255, g = 200, b = 50, a = 255},
                script    = {path = "./assets/scripts/hud.lua"},
            }
        },
        -- Capa superior del mapa
        {
            components = {
                sprite    = {assetId = "map-top", width = 1024, height = 1280, src_rect = {x = 0, y = 0}, z_index = 2},
                transform = {position = {x = 0.0, y = 0.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
            }
        },
    }
}
