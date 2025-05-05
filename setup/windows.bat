@echo off
color 0a
cd ..

echo ========================================
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
echo ========================================

REM -- Core Libraries --
haxelib install lime 8.2.2 > nul
haxelib install openfl 9.4.1 > nul
haxelib install flixel 5.6.1 > nul
haxelib install flixel-addons 3.2.2 > nul
haxelib install flixel-tools 1.5.1 > nul

REM -- Script & Tools --
haxelib install hscript-iris 1.1.3 > nul
haxelib install hscript > nul
haxelib install hxp > nul
haxelib install hxcpp-debug-server > nul

REM -- JSON & Async --
haxelib install tjson 1.4.0 > nul
haxelib install tink_core > nul
haxelib install tink_await > nul

REM -- Discord & Media --
haxelib install hxdiscord_rpc 1.2.4 > nul
haxelib install hxvlc 2.0.1 --skip-dependencies > nul

REM -- Set Versions --
haxelib set lime 8.2.2 > nul
haxelib set openfl 9.4.1 > nul

REM -- Git Dependencies --
haxelib git flxanimate https://github.com/Dot-Stuff/flxanimate 768740a56b26aa0c072720e0d1236b94afe68e3e > nul
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit 1906c4a96f6bb6df66562b3f24c62f4c5bba14a7 > nul
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90 > nul
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666 > nul
haxelib git away3d https://github.com/CodenameCrew/away3d > nul
haxelib git hscript-improved https://github.com/CodenameCrew/hscript-improved.git > nul

echo.
echo ========================================
echo All dependencies installed successfully!
echo ========================================
pause
