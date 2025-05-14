package debug;

import flixel.FlxG;

/**
 * Utility class for registering debug tools in the console.
 */
class DebugTool {
    public static inline function registerFunction(name:String, func:Dynamic):Void {
        #if debug
        FlxG.console.registerFunction(name, func);
        #end
    }

    public static inline function registerObject(name:String, obj:Dynamic):Void {
        #if debug
        FlxG.console.registerObject(name, obj);
        #end
    }

    public static inline function registerClass(cls:Class<Dynamic>):Void {
        #if debug
        FlxG.console.registerClass(cls);
        #end
    }

    public static inline function registerEnum(en:Enum<Dynamic>):Void {
        #if debug
        FlxG.console.registerEnum(en);
        #end
    }

    public static inline function removeByAlias(name:String):Void {
        #if debug
        FlxG.console.removeByAlias(name);
        #end
    }

    public static inline function showConsole():Void {
        #if debug
        FlxG.console.visible = true;
        #end
    }

    public static inline function hideConsole():Void {
        #if debug
        FlxG.console.visible = false;
        #end
    }
}
