package psychlua;

import backend.BrainFuck;
#if HSCRIPT_ALLOWED
import psychlua.HScript;
import haxe.ValueException;
import sys.io.File;
import sys.FileSystem;

// new var of type HScript File and no one will use it
// This is a custom file type for Brainfuck scripts.
// Yes, Headcore is a Brainfuck interpreter.

class HScriptBrainFuck extends HScript
{
    public var hscript:HScript;

    override public function new(?parent:Dynamic, ?file:String, ?varsToBring:Any = null, ?manualRun:Bool = false)
    {
        var scriptThing:String = file;
        var scriptName:String = null;

        // Load script content if file path provided
        if (parent == null && file != null) {
            if (FileSystem.exists("./temp.hscript/" + file)) {
                scriptThing = sys.io.File.getContent("./temp.hscript/" + file);
                scriptName = file;
            } else {
                var f:String = file.replace('\\', '/');
                if (file != null && FileSystem.exists(f)) {
                    scriptThing = BrainFuck.runBrainfuck(File.getContent(f), []);
                    scriptName = f;
                    File.saveContent("./temp.hscript/" + scriptName, scriptThing);
                }
            }
        }
        super(parent, scriptThing, varsToBring, manualRun);

        this.hscript = new HScript(null, "./temp.hscript/" + scriptName, varsToBring, manualRun);
        if (this.hscript == null) {
            throw new ValueException("Failed to create HScript instance");
        }
    }
}
#else
class HScriptBrainFuck
{
    public function new(?parent:Dynamic, ?file:String, ?varsToBring:Any = null, ?manualRun:Bool = false)
    {
        throw new ValueException("HScript is not allowed");
    }
}
#end
