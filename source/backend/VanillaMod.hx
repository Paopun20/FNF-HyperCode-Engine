package backend;

#if HSCRIPT_ALLOWED
import psychlua.HScript;
#end

import backend.Subprocess;
import backend.Mods;
import sys.FileSystem;

#if HSCRIPT_ALLOWED
import customstage.CustomStageScriptHandler;
import customstage.API;
#end

class VanillaMod {
    #if HSCRIPT_ALLOWED
    private static var hscript:HScript = null;
    #end

    /**
     * Returns the full file path to a stage script by name.
     */
    public static function getStagePath(stageName:String):String {
        return Paths.vanillaModStage(stageName); // e.g., "mod/yourmodname/customstage/vanillaModStages/TitleState.hx"
    }

    /**
     * Loads and initializes a stage script if it exists and is valid.
     */
    public static function loadStage(stageName:String):Void {
        Mods.loadTopMod();
        var filePath = getStagePath(stageName);
        trace("Attempting to load stage from: " + filePath);

        if (!FileSystem.exists(filePath)) {
            trace('File not found: ' + filePath);
            return;
        }

        #if HSCRIPT_ALLOWED
        if (!filePath.toLowerCase().endsWith(".hx")) {
            trace('Not a valid .hx file: ' + filePath);
            return;
        }

        if (hscript != null) {
            trace('Script already loaded, unloading current script.');
            destroyHScript();
        }

        try {
            initHScript(filePath);
        } catch (e:Dynamic) {
            trace('Failed to initialize script: ' + e);
        }
        #end
    }

    /**
     * Unloads the currently active script, if any.
     */
    public static function unloadStage():Void {
        #if HSCRIPT_ALLOWED
        if (hscript != null) {
            destroyHScript();
        } else {
            trace('No script to unload.');
        }
        #end
    }

    /**
     * Attempts to call a function in the loaded script.
     */
    public static function tryCall(func:String, args:Array<Dynamic> = null):Void {
        #if HSCRIPT_ALLOWED
        APIScriptHandler.tryCall(hscript, func, args);
        #end
    }

    // ─────────────────────────────────────────────────────────────────────────────

    #if HSCRIPT_ALLOWED
    private static function initHScript(file:String):Void {
        var script = new HScript(null, file);
        API.injectAPI(script);
        hscript = script;
        trace('Script initialized: ' + file);
    }

    private static function destroyHScript():Void {
        hscript.destroy();
        trace('Script destroyed.');
        hscript = null;
    }
    #end
}
