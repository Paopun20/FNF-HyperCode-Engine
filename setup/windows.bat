@echo off
color 0a
cd ..
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
for /F "tokens=*" %%L in (setup/list.haxelib) do (
    %%L
)
echo Finished!