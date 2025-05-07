package utils;

#if windows
@:cppFileCode("#include <windows.h>")
class TransparentWindow {
    private static var hwnd:Dynamic = null;
    private static var isTransparent:Bool = false;
    private static var clickThroughEnabled:Bool = false;

    public static function applyTransparency(?r:Int = 0, ?g:Int = 0, ?b:Int = 0, ?a:Int = 255, enableClickThrough:Bool = false):Void {
        try {
            trace('applyTransparency called with r: $r, g: $g, b: $b, a: $a, clickThrough: $enableClickThrough');

            if (hwnd == null) {
                trace('Getting window handle...');
                @:privateAccess
                hwnd = cast(lime.app.Application.current.window).__backend.handle;
            }

            if (hwnd == null || hwnd == 0) {
                trace('Invalid HWND');
                return;
            }

            if (isTransparent) {
                trace('Transparency already applied');
                return;
            }

            untyped __cpp__('
                HWND hWnd = (HWND){0};
                if (!IsWindow(hWnd)) return;
                LONG exStyle = GetWindowLong(hWnd, GWL_EXSTYLE);
                exStyle |= WS_EX_LAYERED;
                if ({5}) exStyle |= WS_EX_TRANSPARENT;
                SetWindowLong(hWnd, GWL_EXSTYLE, exStyle);
                SetLayeredWindowAttributes(hWnd, RGB({1},{2},{3}), {4}, LWA_COLORKEY | LWA_ALPHA);
            ', hwnd, r, g, b, a, enableClickThrough ? 1 : 0);

            isTransparent = true;
            clickThroughEnabled = enableClickThrough;

            trace('Transparency applied.');
        } catch (e:Dynamic) {
            trace('Error in applyTransparency: $e');
        }
    }

    public static function removeTransparency():Void {
        try {
            trace('removeTransparency called');

            if (hwnd == null) {
                trace('Getting window handle...');
                @:privateAccess
                hwnd = cast(lime.app.Application.current.window).__backend.handle;
            }

            if (hwnd == null || hwnd == 0) {
                trace('Invalid HWND');
                return;
            }

            if (!isTransparent) {
                trace('Transparency is not active.');
                return;
            }

            untyped __cpp__('
                HWND hWnd = (HWND){0};
                if (!IsWindow(hWnd)) return;
                LONG exStyle = GetWindowLong(hWnd, GWL_EXSTYLE);
                exStyle &= ~WS_EX_LAYERED;
                exStyle &= ~WS_EX_TRANSPARENT;
                SetWindowLong(hWnd, GWL_EXSTYLE, exStyle);
            ', hwnd);

            isTransparent = false;
            clickThroughEnabled = false;

            trace('Transparency removed.');
        } catch (e:Dynamic) {
            trace('Error in removeTransparency: $e');
        }
    }
}
#end
