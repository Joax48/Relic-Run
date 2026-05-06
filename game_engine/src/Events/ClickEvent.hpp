#ifndef CLICKEVENT_HPP
#define CLICKEVENT_HPP

#include "../ECS/ECS.hpp"
#include "../EventManager/Event.hpp"

class ClickEvent : public Event {
    public:
        int posX;
        int posY;
        int buttonCode;

        ClickEvent(int x = 0, int y = 0, int buttonCode = 0) {
            this->posX = x;
            this->posY = y;
            this->buttonCode = buttonCode;
        }
};

#endif // CLICKEVENT_HPP