package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import backend.MusicBeatState;
import backend.Paths;
import backend.Mods;
import states.AchievementsMenuState;
import states.CreditsState;
import states.MainMenuState;
import states.ModsMenuState;
import states.StoryMenuState;
import states.TitleState;
import states.CustomStage;
import objects.Character;
import psychlua.LuaUtils;
import psychlua.CustomSubstate;
#if HSCRIPT_ALLOWED
import psychlua.HScript;
import crowplexus.iris.Iris;
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Printer;
#end
import core.BrainFuck;
import core.Buffer;
import core.Format;
import core.GetArgs;
import core.HttpClient;
import core.ImportCore;
import core.JsonHelper;
import core.LuaCallbackInit;
import core.ScreenInfo;
import core.UrlGen;
import core.WindowManager;
import core.system.macros.Utils;
import core.utils.NdllUtil;
#if windows import core.winapi.ToastNotification; #end

class CustomStage extends MusicBeatState
{
	public var stagePath:String = null;
	public var stageName:String = null;

	public static var instance:CustomStage = null;

	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];

	private function stageAPI(script:HScript)
	{
		var set = script.set;

		// 🎮 Game States
		set("MusicBeatState", MusicBeatState);
		set("MainMenuState", MainMenuState);
		set("StoryMenuState", StoryMenuState);
		set("ModsMenuState", ModsMenuState);
		set("CreditsState", CreditsState);
		set("AchievementsMenuState", AchievementsMenuState);
		set("TitleState", TitleState);
		set("CustomStage", CustomStage);

		// ⚙️ Core Haxe + System
		set("Type", Type);
		set("Math", Math);
		set("Std", Std);
		set("StringTools", StringTools);

		#if sys
		set("File", sys.io.File);
		set("FileSystem", sys.FileSystem);
		set("Path", haxe.io.Path);
		#end

		// 📦 Flixel Essentials
		set("FlxG", flixel.FlxG);
		set("FlxSprite", flixel.FlxSprite);
		set("FlxText", flixel.text.FlxText);
		set("FlxObject", flixel.FlxObject);
		set("FlxGroup", flixel.group.FlxGroup);
		set("FlxTypedGroup", flixel.group.FlxGroup.FlxTypedGroup);
		set("FlxCamera", flixel.FlxCamera);
		set("FlxMath", flixel.math.FlxMath);
		set("FlxRect", flixel.math.FlxRect);
		// set("FlxPoint", flixel.math.FlxPoint);
		set("FlxTimer", flixel.util.FlxTimer);
		set("FlxEase", flixel.tweens.FlxEase);
		set("FlxTween", flixel.tweens.FlxTween);
		// set("FlxColor", flixel.util.FlxColor);

		// 🧪 Psych Engine & Backend
		set("ClientPrefs", ClientPrefs);
		set("PlayState", PlayState);
		set("Character", Character);
		set("Note", objects.Note);
		set("Paths", Paths);
		set("Conductor", Conductor);
		set("CustomSubstate", CustomSubstate);
		set("Alphabet", Alphabet);

		#if ACHIEVEMENTS_ALLOWED
		set("Achievements", Achievements);
		#end

		// ✨ Shaders (non-Flash)
		#if (!flash && sys)
		set("FlxRuntimeShader", flixel.addons.display.FlxRuntimeShader);
		set("ShaderFilter", openfl.filters.ShaderFilter);
		set("ErrorHandledRuntimeShader", shaders.ErrorHandledShader.ErrorHandledRuntimeShader);
		#end

		// 🧰 Utils / Custom Classes
		set("BrainFuck", BrainFuck);
		set("GetArgs", GetArgs);
		set("HttpClient", HttpClient);
		set("JsonHelper", JsonHelper);
		set("ScreenInfo", ScreenInfo);
		set("WindowManager", WindowManager);
		set("UrlGen", UrlGen);
		set("NdllUtil", NdllUtil);

		#if flxanimate
		set("FlxAnimate", FlxAnimate);
		#end

		set("Mathf", flixel.math.FlxMath);

		trace("[CustomStage] Script API injected successfully for " + script.name + ".");
	}

	public function initHScript(file:String)
	{
		var newScript:HScript = null;
		try
		{
			newScript = new HScript(null, file);
			if (newScript.exists('onCreate'))
				newScript.call('onCreate');
			trace('initialized hscript interp successfully: $file');
			hscriptArray.push(newScript);
			stageAPI(newScript);
		}
		catch (e:IrisError)
		{
			var pos:HScriptInfos = cast {fileName: file, showLine: false};
			Iris.error(Printer.errorToString(e, false), pos);
			var newScript:HScript = cast(Iris.instances.get(file), HScript);
			if (newScript != null)
				newScript.destroy();

			trace("HScript has be don't run because have error in file: " + file + "(" + e + ")");
		}
	}
	#end

	public static function haveCustomStage(stateName):Bool
	{
		if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0) {
			Mods.loadTopMod();
		}
		var stagePath = Paths.customStagePath(stateName);
		if (FileSystem.exists(stagePath) && FileSystem.isDirectory(stagePath))
		{
			var fileList:Array<String> = FileSystem.readDirectory(stagePath);

			for (file in fileList)
			{
				if (file.endsWith(".hx"))
				{
					return true;
				}
			}
		}

		return false;
	}

	public function new(stateName:String)
	{
		super();
		Mods.loadTopMod();
		instance = this;
		stageName = stateName;
		stagePath = Paths.customStagePath(stateName);
		trace("Loading custom stage: " + stagePath);
		if (stagePath == null || stagePath.length == 0 || stagePath == "null")
		{
			throw new haxe.Exception("Invalid stage path: " + stagePath);
		}
	}

	override public function create():Void
	{
		super.create();
		if (FileSystem.exists(stagePath) && FileSystem.isDirectory(stagePath))
		{
			var fileList:Array<String> = FileSystem.readDirectory(stagePath);

			for (file in fileList)
			{
				if (file.endsWith(".hx"))
				{
					trace('Found .hx file: $stagePath/$file');
					initHScript(stagePath + "/" + file);
				}
			}
		}
		else
		{
			trace('Stage path is invalid or not a directory: $stagePath');
		}
	}

	var holding:Bool = false;
	var holdtime:Float = 0.0;

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		for (script in hscriptArray)
		{
			try
			{
				if (script.exists('onUpdate'))
					script.call('onUpdate', [elapsed]);
			}
			catch (e:haxe.Exception)
			{
				trace('[ERROR] onUpdate(): ${e.message}');
			}
		}

		if (controls.pressed('debug_1') && controls.pressed("reset"))
		{
			holding = true;
			holdtime += elapsed;
		}
		else
		{
			holding = false;
			holdtime = 0.0;
		}
		trace("holding: " + holding + ", holdtime: " + holdtime);

		if (holding)
		{
			if (holdtime >= 0.5)
			{
				// Reload the stage
				trace("Reloading stage: " + stagePath);
				MusicBeatState.switchState(new CustomStage(stageName));
				holding = false;
				holdtime = 0.0;
			}
		}
		else
		{
			holding = false;
			holdtime = 0.0;
		}
	}

	override public function destroy():Void
	{
		super.destroy();
		for (script in hscriptArray)
		{
			try
			{
				if (script.exists('onDestroy'))
					script.call('onDestroy');
				script.destroy();
			}
			catch (e:haxe.Exception)
			{
				trace('[ERROR] onDestroy(): ${e.message}');
			}
			hscriptArray.remove(script);
		}
	}

	override function beatHit():Void
	{
		super.beatHit();
		for (script in hscriptArray)
		{
			try
			{
				if (script.exists('onBeatHit'))
					script.call('onBeatHit');
			}
			catch (e:haxe.Exception)
			{
				trace('[ERROR] onBeatHit(): ${e.message}');
			}
		}
	}

	override function stepHit():Void
	{
		super.stepHit();
		for (script in hscriptArray)
		{
			try
			{
				if (script.exists('onStepHit'))
					script.call('onStepHit');
			}
			catch (e:haxe.Exception)
			{
				trace('[ERROR] onStepHit(): ${e.message}');
			}
		}
	}
}
