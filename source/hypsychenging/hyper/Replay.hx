package hypsychenging.hyper;

#if FLX_RECORD
import flixel.FlxG;
#if sys
import sys.FileSystem;
import sys.io.FileOutput;
import sys.io.FileInput;
#end

import haxe.ds.StringMap;
import hypsychenging.hyper.JsonHelper;

class Replay {
    public static var recording:Bool = false;
    static var savedata:Array<Dynamic> = [];

    public static var slash:String = #if linux "/" #else "\\" #end;
    static var target:String = "replay" + slash;

    public static function start():Void {
        recording = true;
    }

    public static function stop():Void {
        recording = false;
    }

    public static function save(file:String):Void {
        #if sys
        // Create replay folder if needed
        if (!FileSystem.exists(target)) {
            FileSystem.createDirectory(target);
        } else if (!FileSystem.isDirectory(target)) {
            FileSystem.deleteFile(target);
            FileSystem.createDirectory(target);
        }

        var filePath = target + file + ".json";
        if (FileSystem.exists(filePath) && !FileSystem.isDirectory(filePath)) {
            FileSystem.deleteFile(filePath);
        }

        var fileOutput = FileOutput.write(filePath, false);
        fileOutput.writeString(JsonHelper.encode(savedata));
        fileOutput.close();
        #end
    }

    public static function load(file:String):Void {
        #if sys
        var filePath = target + file + ".json";
        if (FileSystem.exists(filePath)) {
            var fileInput = FileInput.read(filePath, false);
            var jsonString = fileInput.readAll().toString();
            fileInput.close();
            savedata = JsonHelper.decode(jsonString);
        }
        #end
    }

    public static function AddFrame(F:Int, K:StringMap<Dynamic>):Void {
        if (recording) {
            savedata.push({ frame: F, key: K });
        }
    }

    public static function RemoveFrame(F:Int):Void {
        if (recording) {
            for (i in 0...savedata.length) {
                if (savedata[i].frame == F) {
                    savedata.splice(i, 1);
                    break;
                }
            }
        }
    }

    public static function GetFrame(F:Int):Dynamic {
        for (frame in savedata) {
            if (frame.frame == F) return frame;
        }
        return null;
    }

    public static function Clear():Void {
        savedata = [];
    }
}
#end
