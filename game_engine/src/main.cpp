#include <iostream>

#include "Game/Game.hpp"

int main(int argc, char* argv[]) {
    (void)argc;
    (void)argv;

    std::cout << "Game Engine 2D" << std::endl;

    Game& game = Game::GetInstance();
    game.Init();
    game.Run();
    game.Destroy();

    return 0;
}