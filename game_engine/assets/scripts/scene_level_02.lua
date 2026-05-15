-- Nivel 2: Bosque oscuro (mapa 1024×1536)

game_current_level = "level_02"

score             = score or 0
score_level_start = score
relics_total      = 4
relics_collected  = 0
key_collected     = false
player_hp         = 5
player_invisible  = false
-- Power-ups: tiempo lento se desbloquea al entrar al nivel 2
has_decoy         = true
decoy_cooldown    = 0
decoy_active      = false
decoy_x           = 0
decoy_y           = 0
has_timeslow      = true
timeslow_cooldown = 0
time_slow         = false
has_cloak         = has_cloak or false
cloak_cooldown    = 0
powerup_hint_text  = "TIEMPO [2] DESBLOQUEADO"
powerup_hint_timer = 4.0

map_w = 1024
map_h = 1536

play_music("./assets/audio/Field - The Little Warrior.ogg", true)
load_map("./assets/maps/level_02/level_02.tmx")

scene = {
    sprites = {
        -- Player
        [0] = {assetId = "player-idle",   filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Idle_without_shadow.png"},
              {assetId = "player-walk",   filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Walk_without_shadow.png"},
              {assetId = "player-attack", filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_attack_without_shadow.png"},
              {assetId = "player-hurt",   filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Hurt_without_shadow.png"},
              {assetId = "player-dead",   filePath = "./assets/images/player/PNG/Swordsman_lvl1/Without_shadow/Swordsman_lvl1_Death_without_shadow.png"},
              -- Projectiles
              {assetId = "projectile",    filePath = "./assets/images/All_Fire_Bullet_Pixel_16x16.png"},
              -- Slime enemy
              {assetId = "slime-idle",    filePath = "./assets/images/sllime/PNG/Slime1/Idle/Slime1_Idle_full.png"},
              {assetId = "slime-walk",    filePath = "./assets/images/sllime/PNG/Slime1/Walk/Slime1_Walk_full.png"},
              {assetId = "slime-hurt",    filePath = "./assets/images/sllime/PNG/Slime1/Hurt/Slime1_Hurt_full.png"},
              {assetId = "slime-death",   filePath = "./assets/images/sllime/PNG/Slime1/Death/Slime1_Death_full.png"},
              -- Vampire enemy / boss
              {assetId = "vampire-idle",   filePath = "./assets/images/vampire/PNG/Vampires1/Idle/Vampires1_Idle_full.png"},
              {assetId = "vampire-walk",   filePath = "./assets/images/vampire/PNG/Vampires1/Walk/Vampires1_Walk_full.png"},
              {assetId = "vampire-attack", filePath = "./assets/images/vampire/PNG/Vampires1/Attack/Vampires1_Attack_full.png"},
              {assetId = "vampire-hurt",   filePath = "./assets/images/vampire/PNG/Vampires1/Hurt/Vampires1_Hurt_full.png"},
              {assetId = "vampire-death",  filePath = "./assets/images/vampire/PNG/Vampires1/Death/Vampires1_Death_full.png"},
              -- Vampire3 (boss)
              {assetId = "vampire3-idle",   filePath = "./assets/images/vampire/PNG/Vampires3/Idle/Vampires3_Idle_full.png"},
              {assetId = "vampire3-walk",   filePath = "./assets/images/vampire/PNG/Vampires3/Walk/Vampires3_Walk_full.png"},
              {assetId = "vampire3-attack", filePath = "./assets/images/vampire/PNG/Vampires3/Attack/Vampires3_Attack_full.png"},
              {assetId = "vampire3-death",  filePath = "./assets/images/vampire/PNG/Vampires3/Death/Vampires3_Death_full.png"},
              {assetId = "vampire3-hurt",   filePath = "./assets/images/vampire/PNG/Vampires3/Hurt/Vampires3_Hurt_full.png"},
              -- Orc enemy
              {assetId = "orc1-idle",   filePath = "./assets/images/orc/PNG/Orc1/Orc1_idle/orc1_idle_full.png"},
              {assetId = "orc1-walk",   filePath = "./assets/images/orc/PNG/Orc1/Orc1_walk/orc1_walk_full.png"},
              {assetId = "orc1-attack", filePath = "./assets/images/orc/PNG/Orc1/Orc1_attack/orc1_attack_full.png"},
              {assetId = "orc1-hurt",   filePath = "./assets/images/orc/PNG/Orc1/Orc1_hurt/orc1_hurt_full.png"},
              {assetId = "orc1-death",  filePath = "./assets/images/orc/PNG/Orc1/Orc1_death/orc1_death_full.png"},
              -- Pickups / HUD
              {assetId = "statue-item",      filePath = "./assets/images/treasures/Treasure_pack_statues.png"},
              {assetId = "key-item",         filePath = "./assets/images/treasures/Treasure_pack_keys.png"},
              {assetId = "portal-open",      filePath = "./assets/images/portal/End Portal/End Portal Open.png"},
              {assetId = "powerup-cloak",    filePath = "./assets/images/barrier_gem.png"},
              {assetId = "powerup-decoy",    filePath = "./assets/images/barrier_gem.png"},
              {assetId = "powerup-timeslow", filePath = "./assets/images/barrier_gem.png"},
              -- HUD icons
              {assetId = "icon-cloak",    filePath = "./assets/images/icons/1 Icons/7/Skill-icons_28.png"},
              {assetId = "icon-decoy",    filePath = "./assets/images/icons/1 Icons/7/Skill-icons_35.png"},
              {assetId = "icon-timeslow", filePath = "./assets/images/icons/1 Icons/7/Skill-icons_07.png"},
    },
    fonts = {
        [0] = {fontId = "press_start_24", filePath = "./assets/fonts/PressStart.ttf", fontSize = 24},
              {fontId = "press_start_16", filePath = "./assets/fonts/PressStart.ttf", fontSize = 16},
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
              {name = "SHOOT",    key = 107}, -- K
    },
    buttons = {},
    entities = {
        -- === PAREDES PERIMETRALES (mapa 1024×1536) ===
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
                transform    = {position = {x = -64.0, y = 1536.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                tag          = {tag = "wall"},
            }
        },
        {
            components = {
                box_collider = {width = 64, height = 1664, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = true, mass = 1},
                transform    = {position = {x = -64.0, y = -64.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                tag          = {tag = "wall"},
            }
        },
        {
            components = {
                box_collider = {width = 64, height = 1664, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = true, mass = 1},
                transform    = {position = {x = 1024.0, y = -64.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                tag          = {tag = "wall"},
            }
        },

        -- === PORTAL DE ENTRADA (jugador llega aquí desde nivel 1) ===
        {
            components = {
                box_collider = {width = 64, height = 64, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "portal-open", width = 320, height = 320, src_rect = {x = 0, y = 0}, z_index = 2},
                animation    = {num_frames = 6, speed_rate = 10, is_loop = true},
                transform    = {position = {x = 124.0, y = 5.0}, scale = {x = 0.2, y = 0.2}, rotation = 0.0},
                tag          = {tag = "portal_entry"},
                script       = {path = "./assets/scripts/portal_entry.lua"},
            }
        },

        -- === JUGADOR ===
        {
            components = {
                transform    = {position = {x = 124.0, y = 60.0}, scale = {x = 1.2, y = 1.2}, rotation = 0.0},
                sprite       = {assetId = "player-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                animation    = {num_frames = 12, speed_rate = 6, is_loop = true},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                box_collider = {width = 38, height = 48, offset = {x = 19, y = 14}},
                tag          = {tag = "player"},
                camera_follow = {},
                script       = {path = "./assets/scripts/player_level01.lua"},
            }
        },

        -- === ENEMIGOS ===

        -- === ENEMIGOS ACTIVOS ===
        -- Slime 1 — zona superior derecha
        {
            components = {
                animation    = {num_frames = 6, speed_rate = 6, is_loop = true},
                box_collider = {width = 44, height = 36, offset = {x = 26, y = 30}},
                health_bar   = {hp = 1, max_hp = 1},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "slime-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 780.0, y = 290.0}, scale = {x = 1.5, y = 1.5}, rotation = 0.0},
                tag          = {tag = "slime"},
                script       = {path = "./assets/scripts/enemy_slime.lua"},
            }
        },
        -- Slime 2 — zona media izquierda
        {
            components = {
                animation    = {num_frames = 6, speed_rate = 6, is_loop = true},
                box_collider = {width = 44, height = 36, offset = {x = 26, y = 30}},
                health_bar   = {hp = 1, max_hp = 1},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "slime-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 160.0, y = 720.0}, scale = {x = 1.5, y = 1.5}, rotation = 0.0},
                tag          = {tag = "slime"},
                script       = {path = "./assets/scripts/enemy_slime.lua"},
            }
        },
        -- Slime 3 — zona inferior
        {
            components = {
                animation    = {num_frames = 6, speed_rate = 6, is_loop = true},
                box_collider = {width = 44, height = 36, offset = {x = 26, y = 30}},
                health_bar   = {hp = 1, max_hp = 1},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "slime-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 580.0, y = 1220.0}, scale = {x = 1.5, y = 1.5}, rotation = 0.0},
                tag          = {tag = "slime"},
                script       = {path = "./assets/scripts/enemy_slime.lua"},
            }
        },
        -- Vampiro 1 — zona media superior
        {
            components = {
                animation    = {num_frames = 4, speed_rate = 6, is_loop = true},
                box_collider = {width = 44, height = 60, offset = {x = 26, y = 16}},
                health_bar   = {hp = 2, max_hp = 2},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "vampire-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 580.0, y = 340.0}, scale = {x = 1.5, y = 1.5}, rotation = 0.0},
                tag          = {tag = "vampire"},
                script       = {path = "./assets/scripts/enemy_vampire.lua"},
            }
        },
        -- Vampiro 2 — zona inferior derecha
        {
            components = {
                animation    = {num_frames = 4, speed_rate = 6, is_loop = true},
                box_collider = {width = 44, height = 60, offset = {x = 26, y = 16}},
                health_bar   = {hp = 2, max_hp = 2},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "vampire-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 800.0, y = 860.0}, scale = {x = 1.5, y = 1.5}, rotation = 0.0},
                tag          = {tag = "vampire"},
                script       = {path = "./assets/scripts/enemy_vampire.lua"},
            }
        },
        -- Orc 1 — corredor izquierdo
        {
            components = {
                animation    = {num_frames = 4, speed_rate = 8, is_loop = true},
                box_collider = {width = 40, height = 55, offset = {x = 21, y = 13}},
                health_bar   = {hp = 3, max_hp = 3},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "orc1-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 180.0, y = 580.0}, scale = {x = 1.2, y = 1.2}, rotation = 0.0},
                tag          = {tag = "orc"},
                script       = {path = "./assets/scripts/enemy_orc.lua"},
            }
        },
        -- Orc 2 — zona media derecha
        {
            components = {
                animation    = {num_frames = 4, speed_rate = 8, is_loop = true},
                box_collider = {width = 40, height = 55, offset = {x = 21, y = 13}},
                health_bar   = {hp = 3, max_hp = 3},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "orc1-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 200.0, y = 800.0}, scale = {x = 1.2, y = 1.2}, rotation = 0.0},
                tag          = {tag = "orc"},
                script       = {path = "./assets/scripts/enemy_orc.lua"},
            }
        },
        -- Orc 3 — zona inferior izquierda
        {
            components = {
                animation    = {num_frames = 4, speed_rate = 8, is_loop = true},
                box_collider = {width = 40, height = 55, offset = {x = 21, y = 13}},
                health_bar   = {hp = 3, max_hp = 3},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "orc1-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 140.0, y = 1050.0}, scale = {x = 1.2, y = 1.2}, rotation = 0.0},
                tag          = {tag = "orc"},
                script       = {path = "./assets/scripts/enemy_orc.lua"},
            }
        },
        -- Mimic 1 — disfrazado de estatua, zona media
        {
            components = {
                animation    = {num_frames = 1, speed_rate = 1, is_loop = false},
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "statue-item", width = 16, height = 16, src_rect = {x = 0, y = 16}},
                transform    = {position = {x = 310.0, y = 690.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "mimic"},
                script       = {path = "./assets/scripts/enemy_mimic.lua"},
            }
        },
        -- Mimic 2 — disfrazado de estatua, zona inferior
        {
            components = {
                animation    = {num_frames = 1, speed_rate = 1, is_loop = false},
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "statue-item", width = 16, height = 16, src_rect = {x = 0, y = 16}},
                transform    = {position = {x = 700.0, y = 1080.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "mimic"},
                script       = {path = "./assets/scripts/enemy_mimic.lua"},
            }
        },
        -- === VAMPIRE BOSS — guarda la llave, zona inferior central ===
        {
            components = {
                animation    = {num_frames = 4, speed_rate = 6, is_loop = true},
                box_collider = {width = 76, height = 108, offset = {x = 26, y = 10}},
                health_bar   = {hp = 10, max_hp = 10},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "vampire3-idle", width = 64, height = 64, src_rect = {x = 0, y = 0}},
                transform    = {position = {x = 250.0, y = 1080.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "vampire_boss"},
                script       = {path = "./assets/scripts/vampire_boss.lua"},
            }
        },

        -- === LLAVE (cerca del vampire boss, la obtiene el jugador al explorar) ===
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "key-item", width = 16, height = 16, src_rect = {x = 0, y = 32}},
                transform    = {position = {x = 220.0, y = 1180.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "key"},
                script       = {path = "./assets/scripts/key.lua"},
            }
        },

        -- === ESTATUAS (dan puntos al recolectar) ===

        -- Estatua 1 — zona superior izquierda
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "statue-item", width = 16, height = 16, src_rect = {x = 0, y = 16}},
                transform    = {position = {x = 120.0, y = 350.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "statue"},
                script       = {path = "./assets/scripts/statue.lua"},
            }
        },
        -- Estatua 2 — zona media derecha
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "statue-item", width = 16, height = 16, src_rect = {x = 0, y = 16}},
                transform    = {position = {x = 860.0, y = 710.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "statue"},
                script       = {path = "./assets/scripts/statue.lua"},
            }
        },
        -- Estatua 3 — zona inferior izquierda
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "statue-item", width = 16, height = 16, src_rect = {x = 0, y = 16}},
                transform    = {position = {x = 100.0, y = 1140.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "statue"},
                script       = {path = "./assets/scripts/statue.lua"},
            }
        },
        -- Estatua 4 — zona inferior derecha (cerca del portal)
        {
            components = {
                box_collider = {width = 32, height = 32, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "statue-item", width = 16, height = 16, src_rect = {x = 0, y = 16}},
                transform    = {position = {x = 650.0, y = 1360.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                tag          = {tag = "statue"},
                script       = {path = "./assets/scripts/statue.lua"},
            }
        },

        -- === PORTAL DE SALIDA ===
        {
            components = {
                box_collider = {width = 64, height = 64, offset = {x = 0, y = 0}},
                rigid_body   = {is_dynamic = false, is_solid = false, mass = 1},
                sprite       = {assetId = "portal-open", width = 320, height = 320, src_rect = {x = 0, y = 0}, z_index = 2},
                animation    = {num_frames = 6, speed_rate = 8, is_loop = true},
                transform    = {position = {x = 464.0, y = 1440.0}, scale = {x = 0.2, y = 0.2}, rotation = 0.0},
                tag          = {tag = "portal"},
                script       = {path = "./assets/scripts/portal_l02.lua"},
            }
        },

        -- === HUD: Score (top-right) ===
        {
            components = {
                transform = {position = {x = 0.0, y = 14.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                text      = {text = "0", fontId = "press_start_24", r = 255, g = 255, b = 255, a = 255},
                script    = {path = "./assets/scripts/hud.lua"},
            }
        },
        -- === HUD: Key indicator (below HP bar, top-left) ===
        {
            components = {
                transform = {position = {x = 14.0, y = 32.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                text      = {text = "", fontId = "press_start_16", r = 200, g = 200, b = 200, a = 255},
                script    = {path = "./assets/scripts/hud_relics.lua"},
            }
        },
        -- === HUD: cooldown text (encima de los íconos) ===
        {
            components = {
                transform = {position = {x = 10.0, y = 505.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                text      = {text = "", fontId = "press_start_16", r = 100, g = 220, b = 255, a = 255},
                script    = {path = "./assets/scripts/hud_powerup.lua"},
            }
        },
        -- HUD: ícono power-up Cloak (slot 1)
        {
            components = {
                sprite    = {assetId = "icon-cloak", width = 32, height = 32, src_rect = {x = 0, y = 0}, z_index = 3},
                transform = {position = {x = 0.0, y = 0.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                script    = {path = "./assets/scripts/hud_icon_cloak.lua"},
            }
        },
        -- HUD: ícono power-up Decoy (slot 2)
        {
            components = {
                sprite    = {assetId = "icon-decoy", width = 32, height = 32, src_rect = {x = 0, y = 0}, z_index = 3},
                transform = {position = {x = 0.0, y = 0.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                script    = {path = "./assets/scripts/hud_icon_decoy.lua"},
            }
        },
        -- HUD: ícono power-up TimeSlow (slot 3)
        {
            components = {
                sprite    = {assetId = "icon-timeslow", width = 32, height = 32, src_rect = {x = 0, y = 0}, z_index = 3},
                transform = {position = {x = 0.0, y = 0.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                script    = {path = "./assets/scripts/hud_icon_timeslow.lua"},
            }
        },

        -- HUD: sprite de llave (aparece cuando se recoge)
        {
            components = {
                sprite    = {assetId = "key-item", width = 16, height = 16, src_rect = {x = 0, y = 32}, z_index = 3},
                transform = {position = {x = 0.0, y = 0.0}, scale = {x = 2.0, y = 2.0}, rotation = 0.0},
                script    = {path = "./assets/scripts/hud_key_sprite.lua"},
            }
        },
        -- HUD: hint de power-up (texto centrado, aparece al recoger)
        {
            components = {
                transform = {position = {x = 400.0, y = 250.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
                text      = {text = "", fontId = "press_start_16", r = 255, g = 220, b = 60, a = 255},
                script    = {path = "./assets/scripts/hud_hint.lua"},
            }
        },
        -- === CAPA SUPERIOR DEL MAPA (árboles) — z_index=2 ===
        {
            components = {
                sprite    = {assetId = "map-top", width = 1024, height = 1536, src_rect = {x = 0, y = 0}, z_index = 2},
                transform = {position = {x = 0.0, y = 0.0}, scale = {x = 1.0, y = 1.0}, rotation = 0.0},
            }
        },
    }
}
