#ifndef HEALTHBARCOMPONENT_HPP
#define HEALTHBARCOMPONENT_HPP

struct HealthBarComponent {
    int hp;
    int maxHp;
    HealthBarComponent(int hp = 1, int maxHp = 1) : hp(hp), maxHp(maxHp) {}
};

#endif // HEALTHBARCOMPONENT_HPP
