-- Nivel 1: Mazmorra (mapa cargado desde level_01.tmx 1024×1280)

game_current_level = "level_01"

score            = 0
relics_collected = 0
relics_total     = 3
key_collected    = false
has_decoy        = false
decoy_cooldown   = 0
decoy_active     = false
decoy_x          = 0
decoy_y          = 0
time_slow        = false
player_hp        = 5

-- Carga el mapa Tiled: bake de capas de tiles + muros de colisión del TMX
-- (crea entidades antes que el scene table para que queden detrás en render order)
play_music("./assets/audio/Field - The Little Warrior.ogg", true)
load_map("./assets/maps/level_01.tmx")

scene = {
    sprites = {
        -- Player
        [0] = {assetId = "player-idle",      filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Idle_without_shadow.png"},
              {assetId = "player-walk",      filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Walk_without_shadow.png"},
              {assetId = "player-attack",    filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_attack_without_shadow.png"},
              {assetId = "player-hurt",      filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Hurt_without_shadow.png"},
              {assetId = "player-dead",      filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Death_without_shadow.png"},
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
              -- Goblin enemy (goblin/ folder, 64×64 frames, 4 filas dir)
              {assetId = "goblin1-idle",   filePath = "./assets/images/goblin/Goblin1/Idle/Idle0_full.png"},
              {assetId = "goblin1-walk",   filePath = "./assets/images/goblin/Goblin1/Walk/Walk0_full.png"},
              {assetId = "goblin1-attack", filePath = "./assets/images/goblin/Goblin1/Attack/Attack0_full.png"},
              {assetId = "goblin1-hurt",   filePath = "./assets/images/goblin/Goblin1/Hurt/Hurt0_full.png"},
              {assetId = "goblin1-death",  filePath = "./assets/images/goblin/Goblin1/Death/Death0_full.png"},
              -- Goblin3 para el boss
              {assetId = "goblin3-idle",   filePath = "./assets/images/goblin/Goblin3/Idle/Idle_full.png"},
              {assetId = "goblin3-walk",   filePath = "./assets/images/goblin/Goblin3/Walk/Walk_full.png"},
              {assetId = "goblin3-run",    filePath = "./assets/images/goblin/Goblin3/Run/Run_full.png"},
              {assetId = "goblin3-death",  filePath = "./assets/images/goblin/Goblin3/Death/Death_full.png"},
              -- Pickup / HUD
              {assetId = "projectile",       filePath = "./assets/images/All_Fire_Bullet_Pixel_16x16.png"},
              {assetId = "statue-item",      filePath = "./assets/images/treasures/Treasure_pack_statues.png"},
              {assetId = "key-item",         filePath = "./assets/images/treasures/Treasure_pack_keys.png"},
              {assetId = "portal-open",      filePath = "./assets/images/portal/End Portal/End Portal Open.png"},
              {assetId = "powerup-decoy",    filePath = "./assets/images/barrier_gem.png"},
    },
    fonts = {
        [0] = {fontId = "press_start_24", filePath = "./assets/fonts/PressStart.ttf", fontSize = 24},
              {fontId = "press_start_16", filePath = "./assets/fonts/PressStart.ttf", fontSize = 16},
    },
    keys = {
        [0] = {name = "UP",       key = 119},  -- W
              {name = "LEFT",     key = 97},   -- A
              {name = "DOWN",     key = 115},  -- S
              {name = "RIGHT",    key = 100},  -- D
              {name = "ATTACK",   key = 106},  -- J
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
                box_collider = {width = 44, height = 36, offset = {x = 26, y = 30}},
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
                box_collider = {width = 44, height = 36, offset = {x = 26, y = 30}},
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
                sprite       = {assetId = "goblin1-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 150.0, y = 540.0}, scale = {x = 1.2, y = 1.2}, rotation = 0.0},
                tag          = {tag = "orc"},
                script       = {path = "./assets/scripts/enemy_goblin.lua"},
            }
        },
        -- Orc en caja de piedra izquierda #2
        {
            components = {
                animation    = {num_frames = 4, speed_rate = 8, is_loop = true},
                box_collider = {width = 40, height = 55, offset = {x = 21, y = 13}},
                health_bar   = {hp = 3, max_hp = 3},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "goblin1-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 150.0, y = 700.0}, scale = {x = 1.2, y = 1.2}, rotation = 0.0},
                tag          = {tag = "orc"},
                script       = {path = "./assets/scripts/enemy_goblin.lua"},
            }
        },
        -- Orc en cluster de pilares superior #1
        {
            components = {
                animation    = {num_frames = 4, speed_rate = 8, is_loop = true},
                box_collider = {width = 40, height = 55, offset = {x = 21, y = 13}},
                health_bar   = {hp = 3, max_hp = 3},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "goblin1-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 580.0, y = 260.0}, scale = {x = 1.2, y = 1.2}, rotation = 0.0},
                tag          = {tag = "orc"},
                script       = {path = "./assets/scripts/enemy_goblin.lua"},
            }
        },
        -- Orc en cluster de pilares superior #2
        {
            components = {
                animation    = {num_frames = 4, speed_rate = 8, is_loop = true},
                box_collider = {width = 40, height = 55, offset = {x = 21, y = 13}},
                health_bar   = {hp = 3, max_hp = 3},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "goblin1-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 400.0, y = 340.0}, scale = {x = 1.2, y = 1.2}, rotation = 0.0},
                tag          = {tag = "orc"},
                script       = {path = "./assets/scripts/enemy_goblin.lua"},
            }
        },
        -- Orc Boss (area central-derecha, guarda la ruta al portal)
        {
            components = {
                animation    = {num_frames = 4, speed_rate = 7, is_loop = true},
                box_collider = {width = 64, height = 88, offset = {x = 36, y = 12}},
                health_bar   = {hp = 8, max_hp = 8},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "goblin3-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 60.0, y = 60.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "orc_boss"},
                script       = {path = "./assets/scripts/goblin_boss.lua"},
            }
        },
        -- Reliquia #1
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "statue-item", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 100.0, y = 600.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "relic"},
                script       = {path = "./assets/scripts/statue.lua"},
            }
        },
        -- Reliquia #2
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "statue-item", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 350.0, y = 750.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "relic"},
                script       = {path = "./assets/scripts/statue.lua"},
            }
        },
        -- Reliquia #3
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "statue-item", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 240.0, y = 80.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "relic"},
                script       = {path = "./assets/scripts/statue.lua"},
            }
        },
        -- Portal de salida (posición del TMX: x=928, y=738)
        {
            components = {
                box_collider = {width = 64, height = 64, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "portal-open", width = 320, height = 320, src_rect = {x = 0, y = 0}, z_index = 2},
                animation    = {num_frames = 6, speed_rate = 8, is_loop = true},
                transform    = {position = {x = 928.0, y = 674.0}, scale = {x = 0.2, y = 0.2}, rotation = 0.0},
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
        -- Llave del nivel (cerca del boss, zona superior-izquierda)
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "key-item", width = 16, height = 16, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 160.0, y = 180.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "key"},
                script       = {path = "./assets/scripts/key.lua"},
            }
        },
        -- HUD: Score (top-right)
        {
            components = {
                transform = {position = {x = 0.0, y = 14.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                text      = {text = "0", fontId = "press_start_24", r = 255, g = 255, b = 255, a = 255},
                script    = {path = "./assets/scripts/hud.lua"},
            }
        },
        -- HUD: Relics (below HP bar, top-left)
        {
            components = {
                transform = {position = {x = 14.0, y = 32.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                text      = {text = "0/0", fontId = "press_start_16", r = 200, g = 200, b = 200, a = 255},
                script    = {path = "./assets/scripts/hud_relics.lua"},
            }
        },
        -- HUD: Power-up indicator (bottom-left, only when active)
        {
            components = {
                transform = {position = {x = 14.0, y = 570.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                text      = {text = "", fontId = "press_start_16", r = 100, g = 220, b = 255, a = 255},
                script    = {path = "./assets/scripts/hud_powerup.lua"},
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
