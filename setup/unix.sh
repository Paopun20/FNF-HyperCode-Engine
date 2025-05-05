#!/bin/bash

# Colors
GREEN="\033[0;32m"
RESET="\033[0m"

echo -e "${GREEN}Installing dependencies..."
echo "This might take a few moments depending on your internet speed."
echo -e "${RESET}"

# Core libraries
haxelib install lime 8.2.2 > /dev/null
haxelib install openfl 9.4.1 > /dev/null
haxelib install flixel 5.6.1 > /dev/null
haxelib install flixel-addons 3.2.2 > /dev/null
haxelib install flixel-tools 1.5.1 > /dev/null

# Script and tooling
haxelib install hscript-iris 1.1.3 > /dev/null
haxelib install hscript > /dev/null
haxelib install hxp > /dev/null
haxelib install hxcpp-debug-server > /dev/null

# JSON and async tools
haxelib install tjson 1.4.0 > /dev/null
haxelib install tink_core > /dev/null
haxelib install tink_await > /dev/null

# Discord & media
haxelib install hxdiscord_rpc 1.2.4 > /dev/null
haxelib install hxvlc 2.0.1 --skip-dependencies > /dev/null

# Set specific versions
haxelib set lime 8.2.2 > /dev/null
haxelib set openfl 9.4.1 > /dev/null

# Git dependencies
haxelib git flxanimate https://github.com/Dot-Stuff/flxanimate 768740a56b26aa0c072720e0d1236b94afe68e3e > /dev/null
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit 1906c4a96f6bb6df66562b3f24c62f4c5bba14a7 > /dev/null
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90 > /dev/null
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666 > /dev/null
haxelib git away3d https://github.com/CodenameCrew/away3d.git > /dev/null
haxelib git hscript-improved https://github.com/CodenameCrew/hscript-improved.git > /dev/null

sudo apt-get install -y vlc libvlc-dev libvlccore-dev vlc-bin > /dev/null

echo -e "${GREEN}All dependencies installed successfully!${RESET}"
