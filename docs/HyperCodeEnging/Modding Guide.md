HyperCode Engine - Modding Guide
How to Use This Folder
The example_mods folder is where your mods will be stored and loaded by HyperCode Engine when the game starts.
Basic Mod Structure

yourModNameHere/
  pack.json       - Mod configuration file (required)
  pack.png        - Mod Icon file
  /characters/    - Custom characters
  /songs/         - Custom songs
  /images/        - Custom images
  /data/          - Chart data and other information
  /scripts/       - Lua and HScript scripts
  /videos/        - Custom videos (if applicable)
  /shaders/       - Custom shaders
  /fonts/         - Custom fonts

Example pack.json
{
    "name": "Your Mod Name",
    "description": "Description about your mod",
    "author": "Your Name",
    "version": "1.0.0",
    "discordRPC": "Bot_Discord_ID" (https://discord.com/developers/applications)
}

Special Features in HyperCode Engine
3D Model support in the /models/ folder
Access to special libraries through HScript and Lua
Customizable menus using HScript in the /custom_stages/ folder
Additional Help
If you need more help with creating mods, check the documentation at:
Lua API Documentation: https://github.com/HyperCodeCrew/FNF-HyperCode-Engine/blob/main/docs/HyperCodeEnging/LuaAPI.md ( wait for 2.0 documentation )