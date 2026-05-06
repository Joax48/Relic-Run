#ifndef ECS_HPP
#define ECS_HPP

#include "../Utils/Pool.hpp"

#include <iostream>

#include <bitset>
#include <deque>
#include <memory>
#include <set>
#include <typeindex>
#include <vector>
#include <unordered_map>

const unsigned int MAX_COMPONENTS = 64;

// Signature
typedef std::bitset<MAX_COMPONENTS> Signature;

struct IComponent {
    protected:
        static int nextId;
};

template <typename TComponent>
class Component : public IComponent {
    public:
        static int GetId() {
            static int id = nextId++;
            return id;
        }
};

class Entity {
    private:
        int id;

    public:
        Entity(int id) : id(id) {}
        int GetId() const;
        void Kill();

        bool operator==(const Entity& other) const {
            return id == other.id;
        }
        bool operator!=(const Entity& other) const {
            return id != other.id;
        }
        bool operator>(const Entity& other) const {
            return id > other.id;
        }
        bool operator<(const Entity& other) const {
            return id < other.id;
        }

        template<typename TComponent, typename... TArgs>
        void AddComponent(TArgs&&... args);

        template<typename TComponent>
        void RemoveComponent();
        
        template<typename TComponent>
        bool hasComponent() const;

        template<typename TComponent>
        TComponent& GetComponent() const;

        class Registry* registry;

};

class System {
    private:
        Signature componentSignature;
        std::vector<Entity> entities;
    
    public:
        System() = default;
        ~System() = default;

        void AddEntityToSystem(Entity entity);
        void RemoveEntityFromSystem(Entity entity);
        std::vector<Entity> GetSystemEntities() const;
        const Signature& GetComponentSignature() const;

        template <typename TComponent>
        void RequireComponent();
};

class Registry {
    private:
        int numEntity = 0;

    std::vector<std::shared_ptr<IPool>> componentsPools;
    std::vector<Signature> entityComponentSigantures;

    std::unordered_map<std::type_index, std::shared_ptr<System>> systems;

    std::set<Entity> entitiesToBeAdded;
    std::set<Entity> entitiesToBeKilled;
    std::deque<int> freeIds;

    public:
        Registry();
        ~Registry();

        void Update();

        // Entity Management
        Entity CreateEntity();
        void KillEntity(Entity entity);

        // Component Management
        template<typename TComponent, typename... TArgs>
        void AddComponent(Entity entity, TArgs&&... args);

        template<typename TComponent>
        void RemoveComponent(Entity entity);
        
        template<typename TComponent>
        bool hasComponent(Entity entity) const;

        template<typename TComponent>
        TComponent& GetComponent(Entity entity) const;

        // System Management
        template<typename TSystem, typename... TArgs>
        void AddSystem(TArgs&&... args);

        template<typename TSystem>
        void RemoveSystem();
        
        template<typename TSystem>
        bool hasSystem();

        template<typename TSystem>
        TSystem& GetSystem() const;

        // Add and remove entities to systems
        void AddEntityToSystems(Entity entity);
        void RemoveEntityfromSystems(Entity entity);

        // Reset Registry
        void ClearAllEntities();

};

template <typename TComponent>
void System::RequireComponent() {
    const int componentID = Component<TComponent>::GetId();
    componentSignature.set(componentID);
}

template<typename TComponent, typename... TArgs>
void Registry::AddComponent(Entity entity, TArgs&&... args) {
    const int componentId = Component<TComponent>::GetId();
    const int entityId = entity.GetId();

    if (static_cast<long unsigned int>(componentId) >= componentsPools.size()) {
        componentsPools.resize(componentId + 10, nullptr);
    }

    if (!componentsPools[componentId]) {
        std::shared_ptr<Pool<TComponent>> newComponentPool 
        = std::make_shared<Pool<TComponent>>();
        componentsPools[componentId] = newComponentPool;
    }

    std::shared_ptr<Pool<TComponent>> componentPool 
    = std::static_pointer_cast<Pool<TComponent>>(componentsPools[componentId]);


    if (entityId >= componentPool->GetSize()) {
        componentPool->Resize(numEntity + 100);
    }

    TComponent newComponent(std::forward<TArgs>(args)...);
    
    componentPool->Set(entityId, newComponent);
    entityComponentSigantures[entityId].set(componentId);

    std::cout << "[REGISTRY] se agrega componente " << componentId << " a la entidad " << entityId << std::endl;
}

template<typename TComponent>
void Registry::RemoveComponent(Entity entity) {
    const int componentId = Component<TComponent>::GetId;
    const int entityId = entity.GetId();

    entityComponentSigantures[entityId].set(componentId, false);
}

template<typename TComponent>
bool Registry::hasComponent(Entity entity) const{
    const int componentId = Component<TComponent>::GetId();
    const int entityId = entity.GetId();

    return entityComponentSigantures[entityId].test(componentId);
}

template<typename TComponent>
TComponent& Registry::GetComponent(Entity entity) const {
    const int componentId = Component<TComponent>::GetId();
    const int entityId = entity.GetId();

    auto componentPool 
    = std::static_pointer_cast<Pool<TComponent>>(componentsPools[componentId]);
    
    return componentPool->Get(entityId);
}

template<typename TSystem, typename... TArgs>
void Registry::AddSystem(TArgs&&... args) {
    std::shared_ptr<TSystem> newSystem 
    = std::make_shared<TSystem>(std::forward<TArgs>(args)...);
    systems.insert(std::make_pair(std::type_index(typeid(TSystem)), newSystem));
}

template<typename TSystem>
void Registry::RemoveSystem() {
    auto system = systems.find(std::type_index(typeid(TSystem)));
    systems.erase(system);
}

template<typename TSystem>
bool Registry::hasSystem() {
    return systems.find(std::type_index(typeid(TSystem))) != systems.end();
}

template<typename TSystem>
TSystem& Registry::GetSystem() const {
    auto system = systems.find(std::type_index(typeid(TSystem)));
    return *(std::static_pointer_cast<TSystem>(system->second));
}

template<typename TComponent, typename... TArgs>
void Entity::AddComponent(TArgs&&... args) {
    registry->AddComponent<TComponent>(*this, std::forward<TArgs>(args)...);
}

template<typename TComponent>
void Entity::RemoveComponent() {
    registry->RemoveComponent<TComponent>(*this);
}

template<typename TComponent>
bool Entity::hasComponent() const {
    return registry->hasComponent<TComponent>(*this);
}

template<typename TComponent>
TComponent& Entity::GetComponent() const {
    return registry->GetComponent<TComponent>(*this);
}

#endif // ECS_HPP