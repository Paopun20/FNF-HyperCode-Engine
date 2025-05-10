package hscript;

import backend.Achievements;
import backend.ALSoftConfig;
import backend.BaseStage;
import backend.BrainFuck;
import backend.Buffer;
import backend.ClientPrefs;
import backend.Conductor;
import backend.Controls;
import backend.CoolUtil;
import backend.CustomFadeTransition;
import backend.Difficulty;
import backend.Discord;
import backend.Format;
import backend.GetArgs;
import backend.Highscore;
import backend.HttpClient;
import backend.InputFormatter;
import backend.JsonHelper;
import backend.Language;
import backend.Mods;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.Native;
import backend.NoteTypesConfig;
import backend.Paths;
import backend.PsychCamera;
import backend.Rating;
import backend.ScreenInfo;
import backend.Song;
import backend.StageData;
import backend.StageManager;
import backend.Subprocess;
import backend.UrlGen;
import backend.UUID;
import backend.WeekData;
import backend.WindowManager;
import backend.animation.PsychAnimationController;
import backend.ui.PsychUIBox;
import backend.ui.PsychUIButton;
import backend.ui.PsychUICheckBox;
import backend.ui.PsychUIDropDownMenu;
import backend.ui.PsychUIEventHandler;
import backend.ui.PsychUIInputText;
import backend.ui.PsychUINumericStepper;
import backend.ui.PsychUIRadioGroup;
import backend.ui.PsychUISlider;
import backend.ui.PsychUITab;

import utils.NdllUtil;
import utils.TransparentWindow;
import winapi.ToastNotification;
import flixel.addons.display.FlxPieDial;

#if hxvlc
import hxvlc.flixel.FlxVideoSprite;
#end

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
		
		"FlxPieDial" => FlxPieDial,
		#if hxvlc
		"FlxVideo" => FlxVideoSprite,
		#end

		"FlxObject" => flixel.FlxObject,
        "FlxRect" => flixel.math.FlxRect,

        "BrainFuck" => BrainFuck,
		"GetArgs" => GetArgs,
		"HttpClient" => HttpClient,
		"JsonHelper" => JsonHelper,
		"ScreenInfo" => ScreenInfo,
		"UrlGen" => UrlGen,
		"WindowManager" => WindowManager,
		"NdllUtil" => NdllUtil,

		#if windows
		"TransparentWindow" => TransparentWindow,
		"ToastNotification" => ToastNotification,
		"WindowColorMode" => WindowColorMode,
		#end
		
		"Discord" => DiscordClient,

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
    ];
}