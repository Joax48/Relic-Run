#ifndef AUDIO_MANAGER_HPP
#define AUDIO_MANAGER_HPP

#include <SDL2/SDL_mixer.h>
#include <string>
#include <unordered_map>
#include <iostream>

class AudioManager {
public:
    AudioManager() = default;

    ~AudioManager() {
        Clear();
    }

    void PlayMusic(const std::string& path, bool loop) {
        if (currentPath == path && Mix_PlayingMusic()) {
            return;
        }
        if (currentMusic) {
            Mix_HaltMusic();
            Mix_FreeMusic(currentMusic);
            currentMusic = nullptr;
        }
        currentMusic = Mix_LoadMUS(path.c_str());
        if (!currentMusic) {
            std::cerr << "[AUDIO] Error cargando música: " << Mix_GetError() << " (" << path << ")\n";
            return;
        }
        currentPath = path;
        Mix_PlayMusic(currentMusic, loop ? -1 : 0);
    }

    void StopMusic() {
        Mix_HaltMusic();
    }

    void PlaySFX(const std::string& path) {
        Mix_Chunk* chunk = nullptr;
        auto it = sfxCache.find(path);
        if (it != sfxCache.end()) {
            chunk = it->second;
        } else {
            chunk = Mix_LoadWAV(path.c_str());
            if (!chunk) {
                std::cerr << "[AUDIO] Error cargando sfx: " << Mix_GetError() << " (" << path << ")\n";
                return;
            }
            sfxCache[path] = chunk;
        }
        Mix_PlayChannel(-1, chunk, 0);
    }

    void Clear() {
        Mix_HaltMusic();
        if (currentMusic) {
            Mix_FreeMusic(currentMusic);
            currentMusic = nullptr;
        }
        currentPath.clear();
        for (auto& [path, chunk] : sfxCache) {
            Mix_FreeChunk(chunk);
        }
        sfxCache.clear();
    }

private:
    Mix_Music* currentMusic = nullptr;
    std::string currentPath;
    std::unordered_map<std::string, Mix_Chunk*> sfxCache;
};

#endif // AUDIO_MANAGER_HPP
