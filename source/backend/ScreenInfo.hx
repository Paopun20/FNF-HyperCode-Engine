package backend;

import openfl.display.Screen;
import haxe.ds.Map;

// Define a type for screen resolution data
typedef ScreenResolution = {
    index:Int,
    width:Float,
    height:Float
}

class ScreenInfo {
    public static function getScreenResolutions(getall:Bool): Array<ScreenResolution> {
        var screenList: Array<ScreenResolution> = [];

        if (getall == true) {
            #if desktop
            // Attempt to handle multi-screen setups
            try {
                var screens = Reflect.field(Screen, "get_screens");
                if (screens != null) {
                    var screenArray: Array<Screen> = cast screens();
                    for (screen in screenArray) {
                        @:privateAccess {
                            screenList.insert(
                                screen.__displayIndex,
                                {
                                    "index": screen.__displayIndex,
                                    "width": screen.bounds.width,
                                    "height": screen.bounds.height
                                }
                            );
                        }
                    }
                    return screenList;
                }
            } catch (e: Dynamic) {
                // Handle platforms without multi-screen support
                trace("Multi-screen support is not available. Falling back to primary screen.");
            }
            #end
        }

        // Fallback to primary screen resolution
        var primaryScreen = Screen.mainScreen;
        screenList.push({
            "index": 0,
            "width": primaryScreen.bounds.width,
            "height": primaryScreen.bounds.height
        });

        return screenList;
    }

    private static function getScreenResolution(screen:Screen):ScreenResolution {
        var width:Float = screen.visibleBounds.width;
        var height:Float = screen.visibleBounds.height;

        return {
            index: 0,
            width: width,
            height: height
        };
    }
}