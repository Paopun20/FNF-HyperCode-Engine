package core;

#if FLX_RECORD
import flixel.FlxG;
#if sys
import sys.io.File;
import sys.FileSystem;
import sys.io.FileOutput;
import sys.io.FileInput;
#end


import haxe.ds.StringMap;
import backend.JsonHelper;
import haxe.ds.Map;

class Replay {
    public static var data:Array<{frame:Int, keys:Array<{key:String, state:Bool}>}> = new Array<{frame:Int, keys:Array<{key:String, state:Bool}>}>(); // Frame -> { KEY_TYPE -> IsHold }
    public static var slash:String = #if linux "/" #else "\\" #end;
    static var replayDir:String = "replay" + slash;

    public static function clear():Void {
        data = new Array<{frame:Int, keys:Array<{key:String, state:Bool}>}>();
    }

    public static function addFrame(frame:Int, keys:Map<String, Bool>):Void {
        // Frame { { KEY_TYPE , IsHold } , ... }
        if (data.get(frame) != null) {
            
        } else {

        }
    }

    public static function removeFrame(frame:Int):Void {
        data.remove(frame);
    }
    
    public static function getFrame(frame:Int) {
        return data.get(frame);
    }

    public static function playFrame(frame:Int):Void {

    }

    public static function save(filename:String):Void {
        #if sys
        // Ensure replay directory exists
        if (!FileSystem.exists(replayDir)) {
            FileSystem.createDirectory(replayDir);
        } else if (!FileSystem.isDirectory(replayDir)) {
            FileSystem.deleteFile(replayDir);
            FileSystem.createDirectory(replayDir);
        }

        var path = replayDir + filename + ".json";
        if (FileSystem.exists(path) && !FileSystem.isDirectory(path)) {
            FileSystem.deleteFile(path);
        }

        var out = File.write(path, false);
        out.writeString(JsonHelper.encode(data));
        out.close();
        #end
    }

    public static function load(filename:String):Void {
        #if sys
        var path = replayDir + filename + ".json";
        if (FileSystem.exists(path)) {
            try {
                var input = File.read(path, false);
                var json = input.readAll().toString();
                input.close();
                data = JsonHelper.decode(json);
            } catch (e) {
                trace('Error loading replay: $e');
            }
        }
        #end
    }
}
#end
