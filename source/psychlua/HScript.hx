package psychlua;

import flixel.FlxBasic;
import objects.Character;
import psychlua.LuaUtils;
import psychlua.CustomSubstate;
import backend.*;
import utils.NdllUtil;

#if LUA_ALLOWED
import psychlua.FunkinLua;
#end

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import crowplexus.iris.IrisConfig;
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Printer;

import haxe.ValueException;

//======================================================
// Type Definitions
//======================================================
/**
 * Extended position information for HScript errors
 */
typedef HScriptInfos = {
    > haxe.PosInfos,
    var ?funcName:String;
    var ?showLine:Null<Bool>;
    #if LUA_ALLOWED
    var ?isLua:Null<Bool>;
    #end
}

/**
 * HScript integration for Psych Engine, providing Haxe scripting capabilities.
 * 
 * Features:
 * - Full Haxe script execution
 * - Lua interoperability
 * - Error handling and reporting
 * - Access to game engine classes and functions
 */
class HScript extends Iris
{
    //======================================================
    // Configuration
    //======================================================
    public var filePath:String;
    public var modFolder:String;
    public var returnValue:Dynamic;
    
    #if LUA_ALLOWED
    public var parentLua:FunkinLua;
    #end

    //======================================================
    // Lua Integration
    //======================================================
    #if LUA_ALLOWED
    /**
     * Initialize HScript module for a Lua script
     */
    public static function initHaxeModule(parent:FunkinLua)
    {
        if(parent.hscript == null)
        {
            trace('Initializing Haxe interp for: ${parent.scriptName}');
            parent.hscript = new HScript(parent);
        }
    }

    /**
     * Initialize HScript module with custom code
     */
    public static function initHaxeModuleCode(parent:FunkinLua, code:String, ?varsToBring:Any = null)
    {
        var hs:HScript = try parent.hscript catch (e) null;
        
        if(hs == null)
        {
            trace('Initializing Haxe interp for: ${parent.scriptName}');
            try {
                parent.hscript = new HScript(parent, code, varsToBring);
            }
            catch(e:IrisError) {
                var pos:HScriptInfos = cast {fileName: parent.scriptName, isLua: true};
                if(parent.lastCalledFunction != '') pos.funcName = parent.lastCalledFunction;
                Iris.error(Printer.errorToString(e, false), pos);
                parent.hscript = null;
            }
        }
        else
        {
            try {
                hs.scriptCode = code;
                hs.varsToBring = varsToBring;
                hs.parse(true);
                var ret:Dynamic = hs.execute();
                hs.returnValue = ret;
            }
            catch(e:IrisError) {
                var pos:HScriptInfos = cast hs.interp.posInfos();
                pos.isLua = true;
                if(parent.lastCalledFunction != '') pos.funcName = parent.lastCalledFunction;
                Iris.error(Printer.errorToString(e, false), pos);
                hs.returnValue = null;
            }
        }
    }
    #end

    //======================================================
    // Initialization
    //======================================================
    public var origin:String;
    
    /**
     * Create a new HScript instance
     */
    override public function new(?parent:Dynamic, ?file:String, ?varsToBring:Any = null, ?manualRun:Bool = false)
    {
        if (file == null) file = '';
        filePath = file;
        
        // Set origin and mod folder
        if (filePath != null && filePath.length > 0) {
            this.origin = filePath;
            #if MODS_ALLOWED
            var myFolder:Array<String> = filePath.split('/');
            if(myFolder[0] + '/' == Paths.mods() && (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) {
                this.modFolder = myFolder[1];
            }
            #end
        }

        var scriptThing:String = file;
        var scriptName:String = null;
        
        // Load script content if file path provided
        if(parent == null && file != null) {
            var f:String = file.replace('\\', '/');
            if(f.contains('/') && !f.contains('\n')) {
                scriptThing = File.getContent(f);
                scriptName = f;
            }
        }
        
        #if LUA_ALLOWED
        if (scriptName == null && parent != null) {
            scriptName = parent.scriptName;
        }
        #end

        // Initialize Iris interpreter
        super(scriptThing, new IrisConfig(scriptName, false, false));
        
        // Set up custom interpreter
        var customInterp:CustomInterp = new CustomInterp();
        customInterp.parentInstance = FlxG.state;
        customInterp.showPosOnLog = false;
        this.interp = customInterp;
        
        #if LUA_ALLOWED
        parentLua = parent;
        if (parent != null) {
            this.origin = parent.scriptName;
            this.modFolder = parent.modFolder;
        }
        #end
        
        // Preset variables and execute
        preset();
        this.varsToBring = varsToBring;
        
        if (!manualRun) {
            try {
                var ret:Dynamic = execute();
                returnValue = ret;
            } 
            catch(e:IrisError) {
                returnValue = null;
                this.destroy();
                throw e;
            }
        }
    }

    //======================================================
    // Variable Management
    //======================================================
    var varsToBring(default, set):Any = null;
    
    /**
     * Preset common variables and functions
     */
    override function preset() {
        super.preset();

        // Core classes
        set('Type', Type);
        #if sys
        set('File', File);
        set('FileSystem', FileSystem);
        #end
        
        // Flixel classes
        set('FlxG', flixel.FlxG);
        set('FlxMath', flixel.math.FlxMath);
        set('FlxSprite', flixel.FlxSprite);
        set('FlxText', flixel.text.FlxText);
        set('FlxCamera', flixel.FlxCamera);
        set('PsychCamera', backend.PsychCamera);
        set('FlxTimer', flixel.util.FlxTimer);
        set('FlxTween', flixel.tweens.FlxTween);
        set('FlxEase', flixel.tweens.FlxEase);
        set('FlxColor', CustomFlxColor);
        
        // Game classes
        set('Countdown', backend.BaseStage.Countdown);
        set('PlayState', PlayState);
        set('Paths', Paths);
        set('Conductor', Conductor);
        set('ClientPrefs', ClientPrefs);
        #if ACHIEVEMENTS_ALLOWED
        set('Achievements', Achievements);
        #end
        set('Character', Character);
        set('Alphabet', Alphabet);
        set('Note', objects.Note);
        set('CustomSubstate', CustomSubstate);
        
        // Shaders
        #if (!flash && sys)
        set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
        set('ErrorHandledRuntimeShader', shaders.ErrorHandledShader.ErrorHandledRuntimeShader);
        #end
        set('ShaderFilter', openfl.filters.ShaderFilter);
        
        // Utilities
        set('StringTools', StringTools);
        #if flxanimate
        set('FlxAnimate', FlxAnimate);
        #end

		// Custom classes
		set("BrainFuck", BrainFuck);
		set("GetArgs", GetArgs);
		set("HttpClient", HttpClient);
		set("JsonHelper", JsonHelper);
		set("ScreenInfo", ScreenInfo);
		set("UrlGen", UrlGen);
		set("WindowManager", WindowManager);
		set("NdllUtil", NdllUtil);

        // Variable functions
        set('setVar', function(name:String, value:Dynamic) {
            MusicBeatState.getVariables().set(name, value);
            return value;
        });
        
        set('getVar', function(name:String) {
            return MusicBeatState.getVariables().exists(name) 
                ? MusicBeatState.getVariables().get(name) 
                : null;
        });
        
        set('removeVar', function(name:String) {
            if(MusicBeatState.getVariables().exists(name)) {
                MusicBeatState.getVariables().remove(name);
                return true;
            }
            return false;
        });
        
        // Debugging
        set('debugPrint', function(text:String, ?color:FlxColor = null) {
            PlayState.instance.addTextToDebug(text, color != null ? color : FlxColor.WHITE);
        });
        
        // Mod settings
        set('getModSetting', function(saveTag:String, ?modName:String = null) {
            if(modName == null) {
                if(this.modFolder == null) {
                    Iris.error('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', this.interp.posInfos());
                    return null;
                }
                modName = this.modFolder;
            }
            return LuaUtils.getModSetting(saveTag, modName);
        });

        // Input handling
        presetInputFunctions();
        
        // Callback creation
        #if LUA_ALLOWED
        presetCallbackFunctions();
        #end
        
        // Library management
        set('addHaxeLibrary', function(libName:String, ?libPackage:String = '') {
            try {
                var str:String = '';
                if(libPackage.length > 0)
                    str = libPackage + '.';

                set(libName, Type.resolveClass(str + libName));
            }
            catch (e:IrisError) {
                Iris.error(Printer.errorToString(e, false), this.interp.posInfos());
            }
        });
        
        // References
        #if LUA_ALLOWED
        set('parentLua', parentLua);
        #else
        set('parentLua', null);
        #end
        set('this', this);
        set('game', FlxG.state);
        set('controls', Controls.instance);

        // Utility references
        set('buildTarget', LuaUtils.getBuildTarget());
        set('customSubstate', CustomSubstate.instance);
        set('customSubstateName', CustomSubstate.name);

        // Control flow
        set('Function_Stop', LuaUtils.Function_Stop);
        set('Function_Continue', LuaUtils.Function_Continue);
        set('Function_StopLua', LuaUtils.Function_StopLua);
        set('Function_StopHScript', LuaUtils.Function_StopHScript);
        set('Function_StopAll', LuaUtils.Function_StopAll);
    }

    /**
     * Preset input-related functions
     */
    private function presetInputFunctions():Void
    {
        // Keyboard
        set('keyboardJustPressed', function(name:String) 
            return Reflect.getProperty(FlxG.keys.justPressed, name));
        
        set('keyboardPressed', function(name:String) 
            return Reflect.getProperty(FlxG.keys.pressed, name));
            
        set('keyboardReleased', function(name:String) 
            return Reflect.getProperty(FlxG.keys.justReleased, name));

        // Gamepad
        set('anyGamepadJustPressed', function(name:String) 
            return FlxG.gamepads.anyJustPressed(name));
            
        set('anyGamepadPressed', function(name:String) 
            return FlxG.gamepads.anyPressed(name));
            
        set('anyGamepadReleased', function(name:String) 
            return FlxG.gamepads.anyJustReleased(name));

        // Gamepad analog
        set('gamepadAnalogX', function(id:Int, ?leftStick:Bool = true) {
            var controller = FlxG.gamepads.getByID(id);
            return controller != null 
                ? controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK)
                : 0.0;
        });
        
        set('gamepadAnalogY', function(id:Int, ?leftStick:Bool = true) {
            var controller = FlxG.gamepads.getByID(id);
            return controller != null 
                ? controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK)
                : 0.0;
        });

        // Gamepad buttons
        set('gamepadJustPressed', function(id:Int, name:String) {
            var controller = FlxG.gamepads.getByID(id);
            return controller != null && Reflect.getProperty(controller.justPressed, name) == true;
        });
        
        set('gamepadPressed', function(id:Int, name:String) {
            var controller = FlxG.gamepads.getByID(id);
            return controller != null && Reflect.getProperty(controller.pressed, name) == true;
        });
        
        set('gamepadReleased', function(id:Int, name:String) {
            var controller = FlxG.gamepads.getByID(id);
            return controller != null && Reflect.getProperty(controller.justReleased, name) == true;
        });

        // Note input
        set('keyJustPressed', function(name:String = '') {
            name = name.toLowerCase();
            return switch(name) {
                case 'left': Controls.instance.NOTE_LEFT_P;
                case 'down': Controls.instance.NOTE_DOWN_P;
                case 'up': Controls.instance.NOTE_UP_P;
                case 'right': Controls.instance.NOTE_RIGHT_P;
                default: Controls.instance.justPressed(name);
            }
        });
        
        set('keyPressed', function(name:String = '') {
            name = name.toLowerCase();
            return switch(name) {
                case 'left': Controls.instance.NOTE_LEFT;
                case 'down': Controls.instance.NOTE_DOWN;
                case 'up': Controls.instance.NOTE_UP;
                case 'right': Controls.instance.NOTE_RIGHT;
                default: Controls.instance.pressed(name);
            }
        });
        
        set('keyReleased', function(name:String = '') {
            name = name.toLowerCase();
            return switch(name) {
                case 'left': Controls.instance.NOTE_LEFT_R;
                case 'down': Controls.instance.NOTE_DOWN_R;
                case 'up': Controls.instance.NOTE_UP_R;
                case 'right': Controls.instance.NOTE_RIGHT_R;
                default: Controls.instance.justReleased(name);
            }
        });
    }

    #if LUA_ALLOWED
    /**
     * Preset Lua callback functions
     */
    private function presetCallbackFunctions():Void
    {
        set('createGlobalCallback', function(name:String, func:Dynamic) {
            for (script in PlayState.instance.luaArray)
                if(script != null && script.lua != null && !script.closed)
                    Lua_helper.add_callback(script.lua, name, func);

            FunkinLua.customFunctions.set(name, func);
        });

        set('createCallback', function(name:String, func:Dynamic, ?funk:FunkinLua = null) {
            if(funk == null) funk = parentLua;
            
            if(funk != null) {
                funk.addLocalCallback(name, func);
            }
            else {
                Iris.error('createCallback ($name): 3rd argument is null', this.interp.posInfos());
            }
        });
    }

    /**
     * Implement Lua callbacks for HScript functionality
     */
    public static function implement(funk:FunkinLua) {
        funk.addLocalCallback("runHaxeCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):Dynamic {
            initHaxeModuleCode(funk, codeToRun, varsToBring);
            if (funk.hscript != null) {
                final retVal:IrisCall = funk.hscript.call(funcToRun, funcArgs);
                if (retVal != null) {
                    return (LuaUtils.isLuaSupported(retVal.returnValue)) ? retVal.returnValue : null;
                }
                else if (funk.hscript.returnValue != null) {
                    return funk.hscript.returnValue;
                }
            }
            return null;
        });
        
        funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
            if (funk.hscript != null) {
                final retVal:IrisCall = funk.hscript.call(funcToRun, funcArgs);
                if (retVal != null) {
                    return (LuaUtils.isLuaSupported(retVal.returnValue)) ? retVal.returnValue : null;
                }
            }
            else {
                var pos:HScriptInfos = cast {fileName: funk.scriptName, showLine: false};
                if (funk.lastCalledFunction != '') pos.funcName = funk.lastCalledFunction;
                Iris.error("runHaxeFunction: HScript has not been initialized yet! Use \"runHaxeCode\" to initialize it", pos);
            }
            return null;
        });
        
        funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
            var str:String = '';
            if (libPackage.length > 0)
                str = libPackage + '.';
            else if (libName == null)
                libName = '';

            var c:Dynamic = Type.resolveClass(str + libName);
            if (c == null)
                c = Type.resolveEnum(str + libName);

            if (funk.hscript == null)
                initHaxeModule(funk);

            var pos:HScriptInfos = cast funk.hscript.interp.posInfos();
            pos.showLine = false;
            if (funk.lastCalledFunction != '')
                 pos.funcName = funk.lastCalledFunction;

            try {
                if (c != null)
                    funk.hscript.set(libName, c);
            }
            catch (e:IrisError) {
                Iris.error(Printer.errorToString(e, false), pos);
            }
            
            if (FunkinLua.getBool('luaDebugMode') && FunkinLua.getBool('luaDeprecatedWarnings')) {
                Iris.warn("addHaxeLibrary is deprecated! Import classes through \"import\" in HScript!", pos);
            }
        });
    }
    #end

    //======================================================
    // Execution
    //======================================================
    /**
     * Call a function in the script
     */
    override function call(funcToRun:String, ?args:Array<Dynamic>):IrisCall {
        if (funcToRun == null || interp == null) return null;

        if (!exists(funcToRun)) {
            Iris.error('No function named: $funcToRun', this.interp.posInfos());
            return null;
        }

        try {
            var func:Dynamic = interp.variables.get(funcToRun);
            final ret = Reflect.callMethod(null, func, args ?? []);
            return {funName: funcToRun, signature: func, returnValue: ret};
        }
        catch(e:IrisError) {
            logError(e, funcToRun);
        }
        catch (e:ValueException) {
            logError(e, funcToRun);
        }
        return null;
    }

    /**
     * Log an error with position information
     */
    private function logError(error:Dynamic, funcName:String):Void {
        var pos:HScriptInfos = cast this.interp.posInfos();
        pos.funcName = funcName;
        #if LUA_ALLOWED
        if (parentLua != null) {
            pos.isLua = true;
            if (parentLua.lastCalledFunction != '') pos.funcName = parentLua.lastCalledFunction;
        }
        #end
        Iris.error(Std.string(error), pos);
    }

    //======================================================
    // Cleanup
    //======================================================
    override public function destroy() {
        origin = null;
        #if LUA_ALLOWED 
        parentLua = null; 
        #end
        super.destroy();
    }

    //======================================================
    // Variable Management
    //======================================================
    /**
     * Set variables to bring into the script
     */
    function set_varsToBring(values:Any) {
        if (varsToBring != null) {
            for (key in Reflect.fields(varsToBring)) {
                if (exists(key.trim())) {
                    interp.variables.remove(key.trim());
                }
            }
        }

        if (values != null) {
            for (key in Reflect.fields(values)) {
                key = key.trim();
                set(key, Reflect.field(values, key));
            }
        }

        return varsToBring = values;
    }
}

//======================================================
// Supporting Classes
//======================================================

/**
 * Custom FlxColor implementation for HScript
 */
class CustomFlxColor {
    // Color constants
    public static var TRANSPARENT(default, null):Int = FlxColor.TRANSPARENT;
    public static var BLACK(default, null):Int = FlxColor.BLACK;
    public static var WHITE(default, null):Int = FlxColor.WHITE;
    public static var GRAY(default, null):Int = FlxColor.GRAY;

    public static var GREEN(default, null):Int = FlxColor.GREEN;
    public static var LIME(default, null):Int = FlxColor.LIME;
    public static var YELLOW(default, null):Int = FlxColor.YELLOW;
    public static var ORANGE(default, null):Int = FlxColor.ORANGE;
    public static var RED(default, null):Int = FlxColor.RED;
    public static var PURPLE(default, null):Int = FlxColor.PURPLE;
    public static var BLUE(default, null):Int = FlxColor.BLUE;
    public static var BROWN(default, null):Int = FlxColor.BROWN;
    public static var PINK(default, null):Int = FlxColor.PINK;
    public static var MAGENTA(default, null):Int = FlxColor.MAGENTA;
    public static var CYAN(default, null):Int = FlxColor.CYAN;

    // Color creation methods
    public static function fromInt(Value:Int):Int return cast FlxColor.fromInt(Value);
    public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int return cast FlxColor.fromRGB(Red, Green, Blue, Alpha);
    public static function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int return cast FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);
    public static inline function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Int return cast FlxColor.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha);
    public static function fromHSB(Hue:Float, Sat:Float, Brt:Float, Alpha:Float = 1):Int return cast FlxColor.fromHSB(Hue, Sat, Brt, Alpha);
    public static function fromHSL(Hue:Float, Sat:Float, Light:Float, Alpha:Float = 1):Int return cast FlxColor.fromHSL(Hue, Sat, Light, Alpha);
    public static function fromString(str:String):Int return cast FlxColor.fromString(str);
}

/**
 * Custom interpreter with parent instance access
 */
 class CustomInterp extends crowplexus.hscript.Interp {
    public var parentInstance(default, set):Dynamic;
    private var _instanceFields:Array<String>;
    
    public function new() {
        super();
    }

    function set_parentInstance(inst:Dynamic):Dynamic {
        parentInstance = inst;
        _instanceFields = (inst != null) ? Type.getInstanceFields(Type.getClass(inst)) : [];
        return inst;
    }

    override function resolve(id:String):Dynamic {
        if (locals.exists(id)) return locals.get(id).r;
        if (variables.exists(id)) return variables.get(id);
        if (imports.exists(id)) return imports.get(id);
        if (parentInstance != null && _instanceFields.contains(id)) {
            return Reflect.getProperty(parentInstance, id);
        }
        error(EUnknownVariable(id));
        return null;
    }
}
#else
// Fallback implementation when HSCRIPT_ALLOWED is false

class HScript extends Iris {
    #if LUA_ALLOWED
    public static function implement(funk:FunkinLua) {
        funk.addLocalCallback("runHaxeCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):Dynamic {
            FunkinLua.luaTrace("runHaxeCode: HScript not supported on this platform", false, false, FlxColor.RED);
            return null;
        });
        
        funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
            FunkinLua.luaTrace("runHaxeFunction: HScript not supported on this platform", false, false, FlxColor.RED);
            return null;
        });
        
        funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
            FunkinLua.luaTrace("addHaxeLibrary: HScript not supported on this platform", false, false, FlxColor.RED);
            return null;
        });
    }
    #end
}
#end
