package utils;

#if windows
@:buildXml('
<compilerflag value="/DelayLoad:ComCtl32.dll"/>

<target id="haxe">
    <lib name="dwmapi.lib" if="windows" />
    <lib name="shell32.lib" if="windows" />
    <lib name="gdi32.lib" if="windows" />
</target>
')
@:cppFileCode('#include <windows.h>\n#include <dwmapi.h>\n\n#pragma comment(lib, "Dwmapi")')
#end
class TransparentWindow
{
    #if windows
    @:functionCode('HWND window = GetActiveWindow();
            		if (alpha > 255) alpha = 255;
            		if (alpha < 0) alpha = 0;
            		SetWindowLong(window, GWL_EXSTYLE, GetWindowLong(window, GWL_EXSTYLE) | WS_EX_LAYERED);
            		SetLayeredWindowAttributes(window, RGB(red, green, blue), alpha, LWA_COLORKEY | LWA_ALPHA);')
    #end
    static public function applyTransparency(red:Int, green:Int, blue:Int, alpha:Int = 255) {}

    #if windows
    @:functionCode('HWND window = GetActiveWindow();
            		SetWindowLong(window, GWL_EXSTYLE, GetWindowLong(window, GWL_EXSTYLE) ^ WS_EX_LAYERED);
            		SetLayeredWindowAttributes(window, RGB(0, 0, 0), 255, LWA_COLORKEY | LWA_ALPHA);')
    #end
    static public function removeTransparency() {}
}
