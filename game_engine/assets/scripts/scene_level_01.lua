-- Nivel 1: Mazmorra (mapa cargado desde level_01.tmx 1024×1280)

score            = 0
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

-- Carga el mapa Tiled: bake de capas de tiles + muros de colisión del TMX
-- (crea entidades antes que el scene table para que queden detrás en render order)
load_map("./assets/maps/level_01.tmx")

scene = {
    sprites = {
        -- Player
        [0] = {assetId = "player-idle",      filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Idle_without_shadow.png"},
              {assetId = "player-walk",      filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Walk_without_shadow.png"},
              {assetId = "player-attack",    filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_attack_without_shadow.png"},
              {assetId = "player-hurt",      filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Hurt_without_shadow.png"},
              {assetId = "player-dead",      filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Death_without_shadow.png"},
              -- Projectiles
              {assetId = "projectile",       filePath = "./assets/images/barrier_gem.png"},
              -- Slime enemy
              {assetId = "slime-idle",       filePath = "./assets/images/sllime/PNG/Slime1/Idle/Slime1_Idle_full.png"},
              {assetId = "slime-walk",       filePath = "./assets/images/sllime/PNG/Slime1/Walk/Slime1_Walk_full.png"},
              {assetId = "slime-hurt",       filePath = "./assets/images/sllime/PNG/Slime1/Hurt/Slime1_Hurt_full.png"},
              {assetId = "slime-death",      filePath = "./assets/images/sllime/PNG/Slime1/Death/Slime1_Death_full.png"},
              -- Vampire enemy
              {assetId = "vampire-idle",     filePath = "./assets/images/vampire/PNG/Vampires1/Idle/Vampires1_Idle_full.png"},
              {assetId = "vampire-walk",     filePath = "./assets/images/vampire/PNG/Vampires1/Walk/Vampires1_Walk_full.png"},
              {assetId = "vampire-attack",   filePath = "./assets/images/vampire/PNG/Vampires1/Attack/Vampires1_Attack_full.png"},
              {assetId = "vampire-hurt",     filePath = "./assets/images/vampire/PNG/Vampires1/Hurt/Vampires1_Hurt_full.png"},
              {assetId = "vampire-death",    filePath = "./assets/images/vampire/PNG/Vampires1/Death/Vampires1_Death_full.png"},
              -- Orc enemy (orc/ folder, 64×64 frames, 4 dirs)
              {assetId = "orc1-idle",   filePath = "./assets/images/orc/PNG/Orc1/Orc1_idle/orc1_idle_full.png"},
              {assetId = "orc1-walk",   filePath = "./assets/images/orc/PNG/Orc1/Orc1_walk/orc1_walk_full.png"},
              {assetId = "orc1-attack", filePath = "./assets/images/orc/PNG/Orc1/Orc1_attack/orc1_attack_full.png"},
              {assetId = "orc1-hurt",   filePath = "./assets/images/orc/PNG/Orc1/Orc1_hurt/orc1_hurt_full.png"},
              {assetId = "orc1-death",  filePath = "./assets/images/orc/PNG/Orc1/Orc1_death/orc1_death_full.png"},
              -- Orc3 para el boss
              {assetId = "orc3-idle",   filePath = "./assets/images/orc/PNG/Orc3/orc3_idle/orc3_idle_full.png"},
              {assetId = "orc3-walk",   filePath = "./assets/images/orc/PNG/Orc3/orc3_walk/orc3_walk_full.png"},
              {assetId = "orc3-run",    filePath = "./assets/images/orc/PNG/Orc3/orc3_run/orc3_run_full.png"},
              -- Pickup / HUD placeholders
              {assetId = "relic-item",       filePath = "./assets/images/barrier_gem.png"},
              {assetId = "portal-open", filePath = "./assets/images/portal/End Portal/End Portal Open.png"},
              {assetId = "powerup-cloak",    filePath = "./assets/images/barrier_gem.png"},
              {assetId = "powerup-decoy",    filePath = "./assets/images/barrier_gem.png"},
              {assetId = "powerup-timeslow", filePath = "./assets/images/barrier_gem.png"},
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
              {name = "SHOOT",    key = 107},  -- K
              {name = "USE_SLOT1", key = 49},  -- 1
              {name = "USE_SLOT2", key = 50},  -- 2
              {name = "USE_SLOT3", key = 51},  -- 3
    },
    buttons = {},
    entities = {
        -- Paredes perimetrales del mapa 1024×1280
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
        -- Jugador (spawn desde TMX: x=239, y=1148)
        {
            components = {
                camera_follow = {},
                animation = {num_frames = 12, speed_rate = 6, is_loop = true},
                box_collider = {
                    width  = 38,
                    height = 48,
                    offset = {x = 19, y = 14},
                },
                rigid_body = {is_dynamic = false, is_solid = false, mass = 1},
                sprite = {
                    assetId  = "player-idle",
                    width    = 64,
                    height   = 64,
                    src_rect = {x = 0, y = 0},
                },
                transform = {
                    position = {x = 450.0, y = 900.0},
                    scale    = {x = 1.2,   y = 1.2},
                    rotation = 0.0,
                },
                tag    = {tag = "player"},
                script = {path = "./assets/scripts/player_level01.lua"},
            }
        },
        -- === ENEMIGOS ===

        -- Slime cerca del portal (area derecha)
        {
            components = {
                animation    = {num_frames = 6, speed_rate = 6, is_loop = true},
                box_collider = {width = 44, height = 36, offset = {x = 26, y = 46}},
                health_bar   = {hp = 1, max_hp = 1},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "slime-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 870.0, y = 820.0}, scale = {x = 1.5, y = 1.5}, rotation = 0.0},
                tag          = {tag = "slime"},
                script       = {path = "./assets/scripts/enemy_slime.lua"},
            }
        },
        -- Slime en cluster superior
        {
            components = {
                animation    = {num_frames = 6, speed_rate = 6, is_loop = true},
                box_collider = {width = 44, height = 36, offset = {x = 26, y = 46}},
                health_bar   = {hp = 1, max_hp = 1},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "slime-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 750.0, y = 200.0}, scale = {x = 1.5, y = 1.5}, rotation = 0.0},
                tag          = {tag = "slime"},
                script       = {path = "./assets/scripts/enemy_slime.lua"},
            }
        },
        -- Orc en caja de piedra izquierda #1
        {
            components = {
                animation    = {num_frames = 4, speed_rate = 8, is_loop = true},
                box_collider = {width = 40, height = 55, offset = {x = 21, y = 13}},
                health_bar   = {hp = 3, max_hp = 3},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "orc1-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 150.0, y = 540.0}, scale = {x = 1.2, y = 1.2}, rotation = 0.0},
                tag          = {tag = "orc"},
                script       = {path = "./assets/scripts/enemy_orc.lua"},
            }
        },
        -- Orc en caja de piedra izquierda #2
        {
            components = {
                animation    = {num_frames = 4, speed_rate = 8, is_loop = true},
                box_collider = {width = 40, height = 55, offset = {x = 21, y = 13}},
                health_bar   = {hp = 3, max_hp = 3},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "orc1-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 150.0, y = 700.0}, scale = {x = 1.2, y = 1.2}, rotation = 0.0},
                tag          = {tag = "orc"},
                script       = {path = "./assets/scripts/enemy_orc.lua"},
            }
        },
        -- Orc en cluster de pilares superior #1
        {
            components = {
                animation    = {num_frames = 4, speed_rate = 8, is_loop = true},
                box_collider = {width = 40, height = 55, offset = {x = 21, y = 13}},
                health_bar   = {hp = 3, max_hp = 3},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "orc1-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 580.0, y = 260.0}, scale = {x = 1.2, y = 1.2}, rotation = 0.0},
                tag          = {tag = "orc"},
                script       = {path = "./assets/scripts/enemy_orc.lua"},
            }
        },
        -- Orc en cluster de pilares superior #2
        {
            components = {
                animation    = {num_frames = 4, speed_rate = 8, is_loop = true},
                box_collider = {width = 40, height = 55, offset = {x = 21, y = 13}},
                health_bar   = {hp = 3, max_hp = 3},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "orc1-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 400.0, y = 340.0}, scale = {x = 1.2, y = 1.2}, rotation = 0.0},
                tag          = {tag = "orc"},
                script       = {path = "./assets/scripts/enemy_orc.lua"},
            }
        },
        -- Orc Boss (area central-derecha, guarda la ruta al portal)
        {
            components = {
                animation    = {num_frames = 4, speed_rate = 7, is_loop = true},
                box_collider = {width = 64, height = 88, offset = {x = 36, y = 12}},
                health_bar   = {hp = 6, max_hp = 6},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "orc3-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 60.0, y = 60.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "orc_boss"},
                script       = {path = "./assets/scripts/enemy_orc_boss.lua"},
            }
        },
        -- Reliquia #1
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "relic-item", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 100.0, y = 600.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
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
                transform    = {position = {x = 350.0, y = 750.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
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
                transform    = {position = {x = 240.0, y = 80.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "relic"},
                script       = {path = "./assets/scripts/relic.lua"},
            }
        },
        -- Portal de salida (posición del TMX: x=928, y=738)
        {
            components = {
                box_collider = {width = 64, height = 64, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "portal-open", width = 320, height = 320, src_rect = {x = 0, y = 0}},
                animation    = {num_frames = 6, speed_rate = 8, is_loop = true},
                transform    = {position = {x = 896.0, y = 706.0}, scale = {x = 0.2, y = 0.2}, rotation = 0.0},
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
                transform    = {position = {x = 400.0, y = 1050.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
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
                transform    = {position = {x = 700.0, y = 1150.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
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
                transform    = {position = {x = 500.0, y = 850.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "powerup_cloak"},
                script       = {path = "./assets/scripts/powerup_cloak.lua"},
            }
        },
        -- HUD: Score
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
        -- Capa superior del mapa (árboles, techo, vallas) — z_index=2 → siempre encima
        {
            components = {
                sprite    = {assetId = "map-top", width = 1024, height = 1280, src_rect = {x = 0, y = 0}, z_index = 2},
                transform = {position = {x = 0.0, y = 0.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
            }
        },
    }
}
