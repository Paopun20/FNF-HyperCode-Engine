package core;

import openfl.display.Screen;
import lime.system.System;
import haxe.ds.IntMap;

// Define a proper type for screen resolution data
typedef ScreenResolution = {
    width:Float,
    height:Float
}

@:privateAccess
class ScreenInfo {

    // Unified screen information retrieval
    public static function getScreenResolutions(includeAll:Bool = true):IntMap<ScreenResolution> {
        var resolutions = new IntMap<ScreenResolution>();
        
        #if desktop
        if (includeAll) {
            try {
                final screens = Screen.screens;
                if (screens != null) {
                    for (screen in screens) {
                        final id = getDisplayIndex(screen);
                        if (id != -1) {
                            resolutions.set(id, getScreenResolution(screen));
                        }
                    }
                    return resolutions;
                }
            } catch (e:Dynamic) {
                log("Multi-screen detection failed, falling back to main screen", Warn);
            }
        }
        #end

        // Fallback to main screen
        final mainScreen = Screen.mainScreen;
        if (mainScreen != null) {
            resolutions.set(0, getScreenResolution(mainScreen));
        } else {
            log("Failed to retrieve any screen information", Error);
        }

        return resolutions;
    }

    // Helper to safely extract display index
    private static function getDisplayIndex(screen:Screen):Int {
        try {
            // Safer reflection-based approach
            final dynamicScreen:Dynamic = screen;
            return (Reflect.hasField(dynamicScreen, "displayIndex"))
                ? dynamicScreen.displayIndex
                : -1;
        } catch (e:Dynamic) {
            log('Failed to get screen ID: ${e}', Warn);
            return -1;
        }
    }

    // Unified resolution extraction
    private static function getScreenResolution(screen:Screen):ScreenResolution {
        return {
            width: screen.bounds.width,
            height: screen.bounds.height
        };
    }

    // Logging utility
    private static function log(message:String, level:LogLevel = Info) {
        #if debug
        final prefix = switch(level) {
            case Error: "[ERROR]";
            case Warn: "[WARN]";
            case Info: "[INFO]";
        };
        trace('$prefix $message');
        #end
    }
}

enum LogLevel {
    Error;
    Warn;
    Info;
}