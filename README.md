> [!Warning]
> This engine is still in development!
> If you encounter any bugs, please report them on GitHub Issues (https://github.com/Paopun20/FNF-HyPsych-Engine/issues).

# Welcome to HyPsych engine!

<video src="./docs/GHREADMEFile/HPE_Loop.mp4" width="100%" autoplay loop muted></video>

---

# HyPsych Enging Is next-gen of Psych Engine!
This is a Friday Night Funkin' engine based on Psych Engine.
This engine is a fork of Psych Engine 1.0.4, but with a lot of new features and improvements.

## About
This engine is made for fun and learning purposes.
I hope you enjoy it!

# Features:
- **HScript on Lua [Beta]**
  Classic HScript syntax now runs alongside Lua! This allows for greater flexibility in scripting. (We’re working on fixing one minor bug—stay tuned!)

- **Optimized Garbage Collection**
  Experience smoother gameplay with fewer performance hitches. Your mods won’t stutter, even during complex beats!

- **C++11 Codebase**
  A modern, efficient codebase to maximize performance and ensure compatibility with the latest systems.

- **Replay Functionality [Work in Progress]**
  Record your best (or worst) runs and play them back at any time!

- **Buffer [Work in Progress]**
  Buffers temporarily store data in memory for more efficient data handling, improving overall performance.

- **Gameplay**
  **HXCPP_GC_DYNAMIC_SIZE**
  This new feature allows you to change the size of dynamic memory allocation, providing flexibility for memory management during gameplay.

  **HXCPP_GC_BIG_BLOCKS**
  This feature optimizes memory allocation by using larger memory blocks, which can reduce fragmentation and improve performance.

  **HXCPP_GC_GENERATIONAL**
  A garbage collection approach that uses multiple generations of objects, optimizing memory usage and reducing the cost of collection in long-running processes.


# Lua Extensions

### These extensions expand Lua’s functionality in the HyPsych Engine:

| Extension           | Status         | Testing | Description |
|---------------------|----------------|---------|-------------|
| **`BrainF*ck`**      | Stable         | Yes     | Allows the execution of BrainF*ck code within your game’s songs. This quirky feature lets modders add unexpected logic or fun programming challenges in their music gameplay, adding an extra layer of meme-worthy fun to your mods. |
| **`GetArgs`**        | Stable         | Yes     | Enables access to command-line arguments, perfect for creating modding tools or integrating with external configurations. This extension helps retrieve input passed to the game on startup, which can be used for custom settings or tool integrations. |
| **`HttpClient`**     | Stable         | Yes     | Make HTTP(S) requests from within your mod to interact with external APIs, fetch data, or even interact with platforms like Discord. While it can handle requests and responses, file upload/download functionality is restricted for security purposes, ensuring safe communication. |
| **`JsonHelper`**     | Stable         | Yes     | A powerful extension to simplify working with JSON data. It provides easy-to-use functions to parse JSON strings into native Haxe objects and vice versa. Perfect for modders who need to handle external JSON configurations or data without dealing with complex parsing logic. |
| **`ScreenInfo`**     | Unstable (Crash Game) | Yes | Retrieve dynamic screen resolution and size information for any connected display. This is ideal for mods that need to adapt to different screen sizes and setups. However, it is currently unstable and may cause crashes, so use it cautiously. |
| **`UrlGen`**         | Stable         | Yes     | Build and manipulate URLs dynamically. This extension allows modders to generate custom URLs, append query parameters, and path segments on the fly. It pairs well with HttpClient for sending requests with custom parameters and paths, ideal for interacting with APIs or generating dynamic links within your game. |
| **`WindowManager`**  | Unstable (Buggy) | Yes     | Provides control over window properties such as position, size, and fullscreen mode. While mostly functional, it’s still in an experimental state, with some bugs related to window resizing and positioning. This feature is primarily useful for mods that need to control the in-game window’s appearance. |

---

## Q&A
### What makes HyPsych Engine different from Psych Engine?

HyPsych Engine offers many new features and improvements over Psych Engine, including:
- HScript on Lua, allowing for more flexible scripting.
- Optimized Garbage Collection for smoother gameplay.
- C++11-based codebase, offering better performance and system compatibility.
- New Lua Extensions, such as BrainF*ck, HttpClient, and JsonHelper, which add powerful new functionalities.

## Credits
- **Paopun20** - Main Developer \(Sole Developer for this cool engine\)

## Special Thanks
- **You** - For using this engine!