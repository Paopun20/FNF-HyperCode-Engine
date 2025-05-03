package hscript;
import backend.*;
import utils.NdllUtil;

class Classes {
    public static var loadMap:Map<String, Dynamic> = [ //All the default classes
		//Haxe Classes
        "Math" => Math,
        "Std" => Std,
		"StringTools" => StringTools,
		"Reflect" => Reflect,

		//Flixel Classes
        "FlxG" => flixel.FlxG,
        "FlxSprite" => flixel.FlxSprite,
        "FlxTimer" => flixel.util.FlxTimer,

        "BrainFuck" => BrainFuck,
		"GetArgs" => GetArgs,
		"HttpClient" => HttpClient,
		"JsonHelper" => JsonHelper,
		"ScreenInfo" => ScreenInfo,
		"UrlGen" => UrlGen,
		"WindowManager" => WindowManager,
		"NdllUtil" => NdllUtil,

        "FlxTween" => flixel.tweens.FlxTween,
        "FlxEase" => flixel.tweens.FlxEase,
        "FlxText" => flixel.text.FlxText,
		#if sys
        "File" => sys.io.File,
        "FileSystem" => sys.FileSystem,
		#end
		
		//Friday Night Funkin' Classes
        "Paths" => Paths,
        "Conductor" => Conductor,
        "PlayState" => PlayState,
		"CoolUtil"	=> CoolUtil,
        "ClientPrefs" => ClientPrefs,

		//T-Bar Engine specific classes
		#if SOFTCODED_STATES
		"MusicBeatState" => MusicBeatState,
		"MusicBeatSubstate" => MusicBeatSubstate,
		#end
		
		//away3d specific classes
		#if away3d
		"Flx3DCamera" => flx3d.Flx3DCamera,
        "Flx3DView" => flx3d.Flx3DView,
        "FlxView3D" => flx3d.FlxView3D,
        "Flx3DUtil" => flx3d.Flx3DUtil,
		#end

		//Extras
		"Json" => haxe.Json,
		"FlxBasic" => flixel.FlxBasic,
		"FlxCamera" => flixel.FlxCamera,
		"FlxSound" => #if (flixel >= "5.3.0") flixel.sound.FlxSound #else flixel.system.FlxSound #end,
		"FlxMath" => flixel.math.FlxMath,
		"FlxGroup" => flixel.group.FlxGroup,
		"FlxTypedGroup" => flixel.group.FlxGroup.FlxTypedGroup,
		"FlxSpriteGroup" => flixel.group.FlxSpriteGroup,
		#if (!flash) 
		"FlxRuntimeShader" => flixel.addons.display.FlxRuntimeShader, 
		#end
		"ShaderFilter"	=> openfl.filters.ShaderFilter,


		//Extras with abstracts/enums
		"FlxPoint" => CoolUtil.getMacroAbstractClass("flixel.math.FlxPoint"),
		"FlxAxes" => CoolUtil.getMacroAbstractClass("flixel.util.FlxAxes"),
		"FlxColor" => CoolUtil.getMacroAbstractClass("flixel.util.FlxColor")
    ];
}