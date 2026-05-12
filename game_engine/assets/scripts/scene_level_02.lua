-- Nivel 2: Bosque (mapa 512×1536, solo mapa + jugador + portal entrada)

score             = 0
relics_total      = 0
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

load_map("./assets/maps/level_02.tmx")

scene = {
    sprites = {
        [0] = {assetId = "player-idle",   filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Idle_without_shadow.png"},
              {assetId = "player-walk",   filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Walk_without_shadow.png"},
              {assetId = "player-attack", filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_attack_without_shadow.png"},
              {assetId = "player-hurt",   filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Hurt_without_shadow.png"},
              {assetId = "player-dead",   filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Death_without_shadow.png"},
              {assetId = "projectile",    filePath = "./assets/images/barrier_gem.png"},
              {assetId = "portal-open",   filePath = "./assets/images/portal/End Portal/End Portal Open.png"},
    },
    fonts = {
        [0] = {fontId = "press_start_24", filePath = "./assets/fonts/PressStart.ttf", fontSize = 24},
    },
    keys = {
        [0] = {name = "UP",       key = 119},  -- W
              {name = "LEFT",     key = 97},   -- A
              {name = "DOWN",     key = 115},  -- S
              {name = "RIGHT",    key = 100},  -- D
              {name = "ATTACK",   key = 106},  -- J
              {name = "USE_SLOT1", key = 49},
              {name = "USE_SLOT2", key = 50},
              {name = "USE_SLOT3", key = 51},
    },
    buttons = {},
    entities = {
        -- Portal de entrada (jugador acaba de salir por aquí)
        [0] = {
            components = {
                box_collider = {width = 64, height = 64, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "portal-open", width = 320, height = 320, src_rect = {x = 0, y = 0}, z_index = 2},
                animation    = {num_frames = 6, speed_rate = 10, is_loop = true},
                transform    = {position = {x = 224.0, y = 60.0}, scale = {x = 0.2, y = 0.2}, rotation = 0.0},
                tag          = {tag = "portal_entry"},
                script       = {path = "./assets/scripts/portal_entry.lua"},
            }
        },
        -- Jugador (aparece saliendo del portal, justo debajo)
        {
            components = {
                transform    = {position = {x = 217.0, y = 160.0}, scale = {x = 1.5, y = 1.5}, rotation = 0.0},
                sprite       = {assetId = "player-idle", width = 68, height = 68, src_rect = {x = 0, y = 0}},
                animation    = {num_frames = 12, speed_rate = 6, is_loop = true},
                rigid_body   = {is_dynamic = true, is_solid = true, mass = 1},
                box_collider = {width = 38, height = 48, offset = {x = 19, y = 14}},
                tag          = {tag = "player"},
                camera_follow = {},
                script       = {path = "./assets/scripts/player_level01.lua"},
            }
        },
        -- HUD score/HP
        {
            components = {
                transform = {position = {x = 10.0, y = 10.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                text      = {text = "Score: 0", fontId = "press_start_24", r = 255, g = 255, b = 255, a = 255},
                script    = {path = "./assets/scripts/hud.lua"},
            }
        },
        -- Capa superior del mapa (árboles) — z_index=2 → encima de entidades
        {
            components = {
                sprite    = {assetId = "map-top", width = 512, height = 1536, src_rect = {x = 0, y = 0}, z_index = 2},
                transform = {position = {x = 0.0, y = 0.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
            }
        },
    }
}
