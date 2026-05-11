#include "SceneLoader.hpp"

#include "../Components/AnimationComponent.hpp"
#include "../Components/CircleColliderComponent.hpp"
#include "../Components/HealthBarComponent.hpp"
#include "../Components/TransformComponent.hpp"
#include "../Components/SpriteComponent.hpp"
#include "../Components/RigidBodyComponent.hpp"
#include "../Components/ScriptComponent.hpp"
#include "../Components/TextComponent.hpp"
#include "../Components/TagComponent.hpp"
#include "../Components/ClickableComponent.hpp"
#include "../Components/CameraFollowComponent.hpp"
#include "../Components/BoxColliderComponent.hpp"

#include <iostream>
#include <glm/glm.hpp>

SceneLoader::SceneLoader() {
    std::cout << "[SCENELOADER] Se ejecuta constructor" << std::endl;
}

SceneLoader::~SceneLoader() {
    std::cout << "[SCENELOADER] Se ejecuta destructor" << std::endl;
}

void SceneLoader::LoadScene(const std::string& scenePath, sol::state& lua
    , std::unique_ptr<AssetManager>& assetManager
    , std::unique_ptr<ControllerManager>& controllerManager
    , std::unique_ptr<Registry>& registry, SDL_Renderer* renderer) {
    
    sol::load_result script_result = lua.load_file(scenePath);
    if (!script_result.valid()) {
        sol::error err = script_result;
        std::string errorMessage = err.what();
        std::cerr << "[SCENELOADER] Error al cargar el script: " << errorMessage << std::endl;
        return; 
    }

    lua.script_file(scenePath);

    sol::table scene = lua["scene"];

    sol::table sprites = scene["sprites"];
    LoadSprites(renderer, sprites, assetManager);

    sol::table keys = scene["keys"];
    LoadKeys(keys, controllerManager);

    sol::table fonts = scene["fonts"];
    LoadFonts(fonts, assetManager);

    sol::table buttons = scene["buttons"];
    LoadButtons(buttons, controllerManager);

    sol::table entities = scene["entities"];
    LoadEntities(lua, entities, registry);

}


void SceneLoader::LoadSprites(SDL_Renderer* renderer, const sol::table& sprites
, std::unique_ptr<AssetManager>& assetManager) {
    int index = 0;
    while (true) {
        sol::optional<sol::table> hasSprite = sprites[index];
        if (hasSprite == sol::nullopt) {
            break;
        }
        sol::table sprite = sprites[index];
        std::string assetId = sprite["assetId"];
        std::string filePath = sprite["filePath"];
        assetManager->AddTexture(renderer, assetId, filePath);
        index++;
    }
}

void SceneLoader::LoadFonts(const sol::table& fonts, std::unique_ptr<AssetManager>& assetManager) {
    int index = 0;
    while (true) {
        sol::optional<sol::table> hasFont = fonts[index];
        if (hasFont == sol::nullopt) {
            break;
        }
        sol::table font = fonts[index];
        std::string fontId = font["fontId"];
        std::string filePath = font["filePath"];
        int size = font["fontSize"];
        assetManager->AddFont(fontId, filePath, size);
        index++;
    }
}

void SceneLoader::LoadKeys(const sol::table& keys, std::unique_ptr<ControllerManager>& controllerManager) {
    int index = 0;
    while (true) {
        sol::optional<sol::table> hasKey = keys[index];
        if (hasKey == sol::nullopt) {
            break;
        }
        sol::table key = keys[index];
        std::string name = key["name"];
        int keyCode = key["key"];
        controllerManager->AddActionKey(name, keyCode);
        index++;
    }
}

void SceneLoader::LoadButtons(const sol::table& buttons, std::unique_ptr<ControllerManager>& controllerManager) {
    int index = 0;
    while (true) {
        sol::optional<sol::table> hasButton = buttons[index];
        if (hasButton == sol::nullopt) {
            break;
        }
        sol::table button = buttons[index];
        std::string name = button["name"];
        int buttonCode = button["button"];
        controllerManager->AddMouseButton(name, buttonCode);
        index++;
    }
}

void SceneLoader::LoadEntities(sol::state& lua, const sol::table& entities, std::unique_ptr<Registry>& registry) {
    int index = 0;
    while (true) {
        sol::optional<sol::table> hasEntity = entities[index];
        if (hasEntity == sol::nullopt) {
            break;
        }
        sol::table entity = entities[index];

        Entity newEntity = registry->CreateEntity();

        sol::optional<sol::table> hasComponents = entity["components"];
        if (hasComponents != sol::nullopt) {
            sol::table components = entity["components"];

            //* AnimationComponent
            sol::optional<sol::table> hasAnimationComponent = components["animation"];
            if (hasAnimationComponent != sol::nullopt) {
                newEntity.AddComponent<AnimationComponent>(
                    components["animation"]["num_frames"],
                    components["animation"]["speed_rate"],
                    components["animation"]["is_loop"]
                );
            }

            //* CircleColliderComponent
            sol::optional<sol::table> hasCircleColliderComponent = components["circle_collider"];
            if (hasCircleColliderComponent != sol::nullopt) {    
            newEntity.AddComponent<CircleColliderComponent>(
                    components["circle_collider"]["radius"],
                    components["circle_collider"]["width"],
                    components["circle_collider"]["height"]
                );
            }

            //* BoxColliderComponent
            sol::optional<sol::table> hasBoxCollider = components["box_collider"];
            if (hasBoxCollider != sol::nullopt) {
                newEntity.AddComponent<BoxColliderComponent>(
                    components["box_collider"]["width"],
                    components["box_collider"]["height"],
                    glm::vec2(
                        components["box_collider"]["offset"]["x"],
                        components["box_collider"]["offset"]["y"]
                    )
                );
            }

            //* CameraFollowComponent
            sol::optional<sol::table> hasCameraFollow = components["camera_follow"];
            if (hasCameraFollow != sol::nullopt) {
                newEntity.AddComponent<CameraFollowComponent>();
            }

            //* ClickableComponent
            sol::optional<sol::table> hasClickable = components["clickable"];
            if (hasClickable != sol::nullopt) {
                newEntity.AddComponent<ClickableComponent>();
            }

            //* RigidBodyComponent
            sol::optional<sol::table> hasRigidBodyComponent = components["rigid_body"];
            if (hasRigidBodyComponent != sol::nullopt) {
                newEntity.AddComponent<RigidBodyComponent>(
                    components["rigid_body"]["is_dynamic"],
                    components["rigid_body"]["is_solid"],
                    components["rigid_body"]["mass"]
                );
            }

            //* SpriteComponent
            sol::optional<sol::table> hasSpriteComponent = components["sprite"];
            if (hasSpriteComponent != sol::nullopt) {
                newEntity.AddComponent<SpriteComponent>(
                    components["sprite"]["assetId"],
                    components["sprite"]["width"],
                    components["sprite"]["height"],
                    components["sprite"]["src_rect"]["x"],
                    components["sprite"]["src_rect"]["y"]
                );
                {
                    sol::table st = components["sprite"];
                    newEntity.GetComponent<SpriteComponent>().zIndex = st.get_or("z_index", 1);
                }
            }

            //* HealthBarComponent
            sol::optional<sol::table> hasHealthBar = components["health_bar"];
            if (hasHealthBar != sol::nullopt) {
                int hp    = components["health_bar"]["hp"];
                int maxHp = components["health_bar"]["max_hp"];
                newEntity.AddComponent<HealthBarComponent>(hp, maxHp);
            }

            //* TagComponent
            sol::optional<sol::table> hasTagComponent = components["tag"];
            if (hasTagComponent != sol::nullopt) {
                std::string tag = components["tag"]["tag"];
                newEntity.AddComponent<TagComponent>(
                tag
                );
            }

            //* TextComponent
            sol::optional<sol::table> hasText = components["text"];
            if (hasText != sol::nullopt) {
                newEntity.AddComponent<TextComponent>(
                    components["text"]["text"],
                    components["text"]["fontId"],
                    components["text"]["r"],
                    components["text"]["g"],
                    components["text"]["b"],
                    components["text"]["a"]
                );
            }
                
            //* TransformComponent
            sol::optional<sol::table> hasTransformComponent = components["transform"];
            if (hasTransformComponent != sol::nullopt) {
                newEntity.AddComponent<TransformComponent>(
                    glm::vec2(
                        components["transform"]["position"]["x"],
                        components["transform"]["position"]["y"]
                    ),
                    glm::vec2(
                        components["transform"]["scale"]["x"],
                        components["transform"]["scale"]["y"]
                    ),
                    components["transform"]["rotation"]
                );
            }

            //* ScriptComponent
            sol::optional<sol::table> hasScriptComponent = components["script"];
            if (hasScriptComponent != sol::nullopt) {
                lua["on_awake"] = sol::nil;
                lua["update"] = sol::nil; // Limpiar la función update antes de cargar el nuevo script
                lua["on_click"] = sol::nil; // Limpiar la función on_click antes de cargar el nuevo script
                lua["on_collision"] = sol::nil; // Limpiar la función on_collision antes de cargar el nuevo script

                std::string path = components["script"]["path"];
                lua.script_file(path);

                sol::optional<sol::function> hasOnAwake = lua["on_awake"];
                 if (hasOnAwake == sol::nullopt) {
                    std::cerr << "[SCENELOADER] El script " << path << " no tiene una función on_awake definida." << std::endl;
                } else {
                    lua["this"] = newEntity;
                    sol::function on_awake = lua["on_awake"];
                    on_awake();
                }

                sol::optional<sol::function> hasOnClickFunction = lua["on_click"];
                sol::function on_click = sol::nil;
                if (hasOnClickFunction == sol::nullopt) {
                    std::cerr << "[SCENELOADER] El script " << path << " no tiene una función on_click definida." << std::endl;
                } else {
                    on_click = lua["on_click"]; // Guardar la función on_click para su uso posterior
                }

                sol::optional<sol::function> hasOnCollisionFunction = lua["on_collision"];
                sol::function on_collision = sol::nil;
                if (hasOnCollisionFunction == sol::nullopt) {
                    std::cerr << "[SCENELOADER] El script " << path << " no tiene una función on_collision definida." << std::endl;
                } else {
                    on_collision = lua["on_collision"]; // Guardar la función on_collision para su uso posterior
                }

                sol::optional<sol::function> hasUpdateFunction = lua["update"];
                sol::function update = sol::nil;
                if (hasUpdateFunction == sol::nullopt) {
                    std::cerr << "[SCENELOADER] El script " << path << " no tiene una función update definida." << std::endl;
                } else {
                    update = lua["update"]; // Guardar la función update para su uso posterior
                }   
                newEntity.AddComponent<ScriptComponent>(update, on_click, on_collision);
            }
        }
        index++;
    }
}