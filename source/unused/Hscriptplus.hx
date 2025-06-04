package psychlua;
// haxelib git hscript-plus https://github.com/DleanJeans/hscript-plus/

#if !NotDeveloper
import hscript.plus.ScriptState;
import sys.FileSystem;
import sys.io.File;

class Hscriptplus {
    public static function runFromFile(path:String, rootPath:String): ScriptState {
        var state = new ScriptState();
        state.executeFile(path);
        return state;
    }

    public static function runFromString(code:String): ScriptState {
        var state = new ScriptState();
        state.executeString(code);
        return state;
    }
}
#else
class hscriptplus {
    public static function runFromFile(path:String, rootPath:String): Void {
        throw "Hscriptplus is not allowed, please use git clone for development and compile it";
    }

    public static function runFromString(code:String): Void {
        throw "Hscriptplus is not allowed, please use git clone for development and compile it";
    }
}
#end