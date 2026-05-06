#ifndef RIGIDBODYCOMPONENT_HPP
#define RIGIDBODYCOMPONENT_HPP

#include <glm/glm.hpp>

struct RigidBodyComponent{
    glm::vec2 velocity = glm::vec2(0);
    glm::vec2 sumForces = glm::vec2(0);
    glm::vec2 acceleration = glm::vec2(0);

    float mass;
    float invMass;

    bool isDynamic;
    bool isSolid;


    RigidBodyComponent(bool isDynamic = false, bool isSolid = false, float mass = 1){
        this->isDynamic = isDynamic;
        this->isSolid = isSolid;
        this->mass = mass;
        this->invMass = 1 / mass;
    }
};


#endif // RIGIDBODYCOMPONENT_HPP