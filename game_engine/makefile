CC = g++

STD = -std=c++17
CFLAGS = -Wall -Wextra

INC_PATH = -I./libs/ -I./libs/lua -I./libs/sol -I./libs/glm

SRC = src/*.cpp \
src/Game/*.cpp \
src/ECS/*.cpp \
src/AssetManager/*.cpp \
src/ControllerManager/*.cpp \
src/SceneManager/*.cpp 

LFLAGS = -lSDL2 -lSDL2_image -lSDL2_ttf -lSDL2_mixer -llua5.3

EXEC = game_engine

build:
	$(CC) $(CFLAGS) $(STD) $(INC_PATH) $(SRC) $(LFLAGS) -o $(EXEC)

run:
	./$(EXEC)

clean:
	rm $(EXEC)
