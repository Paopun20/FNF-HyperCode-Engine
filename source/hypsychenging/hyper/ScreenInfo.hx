package hypsychenging.hyper;

import openfl.display.Screen;
import lime.system.System;
import haxe.ds.IntMap;
import haxe.ds.Map;

class ScreenInfo {
    /**
     * Retrieves the resolution of all connected screens.
     * @return A map with screen ID as key and a Dynamic object { width, height } as value.
     */
    public static function getScreensResolutions(): Map<Int, Map<String, Dynamic>> {
        var screenList: Map<Int, Map<String, Dynamic>> = new Map();

        #if desktop
        try {
            var screens = Screen.screens;
            if (screens != null) {
                for (screen in screens) {
                    var screenInfo = new Map<String, Dynamic>();
                    screenInfo.set("width", screen.bounds.width);
                    screenInfo.set("height", screen.bounds.height);
                    var screenId;
                    
                    try {
                        @:privateAccess screenId = screen.__displayIndex;
                    } catch (e: Dynamic) {
                        screenId = -1;
                        trace ("⚠️ Error: Cannot get screen id. [ error: " + e + " ]");
                    }

                    if (screenId != -1) {
                        screenList.set(screenId, screenInfo);
                    }
                }
                return screenList;
            }
        } catch (e: Dynamic) {
            trace("⚠️ Multi-screen not supported. Fallback to main screen.");
        }
        #end

        // Fallback to main screen if multi-screen not available
        var main = Screen.mainScreen;
        if (main != null) {
            var mainScreenInfo = new Map<String, Dynamic>();
            mainScreenInfo.set("width", main.bounds.width);
            mainScreenInfo.set("height", main.bounds.height);
            screenList.set(0, mainScreenInfo);
        } else {
            trace("❌ Error: Cannot retrieve screen info.");
        }

        return screenList;
    }

    /**
     * Retrieves the resolution of the main screen only.
     * @return A map { 0 => width, 1 => height }.
     */ 
    public static function getMainScreenResolution(): Map<Int, Map<String, Dynamic>> {
        var map = new Map<Int, Map<String, Dynamic>>();
        var main = Screen.mainScreen;
        if (main != null) {
            var mainScreenInfo = new Map<String, Dynamic>();
            mainScreenInfo.set("width", main.bounds.width);
            mainScreenInfo.set("height", main.bounds.height);
            map.set(0, mainScreenInfo);
        } else {
            trace("❌ Error: Cannot retrieve main screen info.");
        }

        return map;
    }
}
