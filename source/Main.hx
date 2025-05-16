package;

#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import states.PlayState;
import backend.WeekData;
#end

import debug.FPSCounter;
import debug.DebugPopup;
import EngineConfig;

import core.ImportCore;

import flixel.graphics.FlxGraphic;
import flixel.FlxGame;
import flixel.FlxState;
import haxe.io.Path;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;
import states.EngineLoadingStage;

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import psychlua.HScript.HScriptInfos;
#end

#if (linux || mac)
import lime.graphics.Image;
#end

#if desktop
import backend.ALSoftConfig; // Just to make sure DCE doesn't remove this, since it's not directly referenced anywhere else.
#end

//crash handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#end

import backend.Highscore;
import flixel.util.FlxStringUtil; // Added import

// NATIVE API STUFF, YOU CAN IGNORE THIS AND SCROLL //
#if (linux && !debug)
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end

// // // // // // // // //
class Main extends Sprite
{
	public static final game = {
		width: 1280,                           // WINDOW width
		height: 720,                           // WINDOW height
		initialState: EngineLoadingStage,      // initial game state
		framerate: 60,                         // default framerate
		skipSplash: true,                      // if the default flixel splash screen should be skipped
		startFullscreen: false                 // if the game should start at fullscreen mode
	};

	public static var fpsVar:FPSCounter;
	public static var debugPop:DebugPopup;
	public static var flxGame:FlxGame;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function _InitCustomStage():Void
	{
		FlxG.signals.gameResized.add(function(w, h) {
			if (FlxG.state is states.CustomStage)
			{
				var customStageCore:states.CustomStage = cast FlxG.state;
				customStageCore.callFunctions("onResize", [w, h]);
			}
		});

		FlxG.signals.focusGained.add(function() {
			if (FlxG.state is states.CustomStage)
			{
				var customStageCore:states.CustomStage = cast FlxG.state;
				customStageCore.callFunctions("onFocusGained", []);
			}
		});

		FlxG.signals.focusLost.add(function() {
			if (FlxG.state is states.CustomStage)
			{
				var customStageCore:states.CustomStage = cast FlxG.state;
				customStageCore.callFunctions("onFocusLost", []);
			}
		});

		FlxG.signals.preDraw.add(function() {
			if (FlxG.state is states.CustomStage)
			{
				var customStageCore:states.CustomStage = cast FlxG.state;
				customStageCore.callFunctions("onDraw", []);
			}
		});

		FlxG.signals.postDraw.add(function() {
			if (FlxG.state is states.CustomStage)
			{
				var customStageCore:states.CustomStage = cast FlxG.state;
				customStageCore.callFunctions("onDrawPost", []);
			}
		});
	}

	public function new()
	{
		super();

		#if (cpp && windows)
		backend.Native.fixScaling();
		#end

		#if mobile
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
		#end
		#if VIDEOS_ALLOWED
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0")  ['--no-lua'] #end);
		#end

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		Highscore.load();

		#if HSCRIPT_ALLOWED
		Iris.warn = function(x, ?pos:haxe.PosInfos) {
			Iris.logLevel(WARN, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';
			#if LUA_ALLOWED
			if (newPos.isLua == true) {
				msgInfo += 'HScript:';
				newPos.showLine = false;
			}
			#end
			if (newPos.showLine == true) {
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('WARNING: $msgInfo', FlxColor.YELLOW);
		}
		Iris.error = function(x, ?pos:haxe.PosInfos) {
			Iris.logLevel(ERROR, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';
			#if LUA_ALLOWED
			if (newPos.isLua == true) {
				msgInfo += 'HScript:';
				newPos.showLine = false;
			}
			#end
			if (newPos.showLine == true) {
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('ERROR: $msgInfo', FlxColor.RED);
		}
		Iris.fatal = function(x, ?pos:haxe.PosInfos) {
			Iris.logLevel(FATAL, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';
			#if LUA_ALLOWED
			if (newPos.isLua == true) {
				msgInfo += 'HScript:';
				newPos.showLine = false;
			}
			#end
			if (newPos.showLine == true) {
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('FATAL: $msgInfo', 0xFFBB0000);
		}

		if (EngineConfig.IS_DEVELOPER) {
			Iris.print = function(x, ?pos:haxe.PosInfos) {
				Iris.logLevel(NONE, x, pos);
				var newPos:HScriptInfos = cast pos;
				if (newPos.showLine == null) newPos.showLine = true;
				var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';
				#if LUA_ALLOWED
				if (newPos.isLua == true) {
					msgInfo += 'HScript:';
					newPos.showLine = false;
				}
				#end
				if (newPos.showLine == true) {
					msgInfo += '${newPos.lineNumber}:';
				}
				msgInfo += ' $x';
				if (PlayState.instance != null)
					PlayState.instance.addTextToDebug('PRINT: $msgInfo', FlxColor.BLUE);
			}
		}
		#end

		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end
		flxGame = new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen);
		addChild(flxGame);

		debugPop = new DebugPopup(10, 3, 0xFFFFFF);
		addChild(debugPop);

		#if !mobile
		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.data.showFPS;
		}
		#end

		#if (linux || mac) // fix the app icon not showing up on the Linux Panel / Mac Dock
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];
		Game.addDebugTools();
		
		#if windows
		WindowColorMode.setDarkMode();
		#end
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end

		// shader coords fix
		FlxG.signals.gameResized.add(function (w, h) {
		     if (FlxG.cameras != null) {
			   for (cam in FlxG.cameras.list) {
				if (cam != null && cam.filters != null)
					resetSpriteCache(cam.flashSprite);
			   }
			}

			if (FlxG.game != null)
			resetSpriteCache(FlxG.game);
		});

		_InitCustomStage();
	}

	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
		        sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	function saveCrashReport(content:String):String
		{
			var path = "./crash/HyperCodeEngine_" + Date.now().toString().replace(" ", "_").replace(":", "'") + ".txt";
			
			if (!FileSystem.exists("./crash/")) {
				FileSystem.createDirectory("./crash/");
			}
	
			File.saveContent(path, content + "\n");
			Sys.println(content);
			Sys.println("Crash dump saved in " + Path.normalize(path));
			
			return path;
		}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		// Basic system info
		errMsg += "==== CRASH REPORT ====\n";
		errMsg += "Engine Version: " + EngineConfig.VERSION + "\n";
		errMsg += "Platform: " + #if windows "Windows" #elseif linux "Linux" #elseif mac "Mac" #elseif android "Android" #elseif ios "iOS" #else "Unknown" #end + "\n";
		#if CompileTimeSupport
		errMsg += "Build Date: " + CompileTime.buildDateString() + "\n";
		errMsg += "Build Hash: " + CompileTime.buildGitCommitSha() + "\n\n";
		#else
		errMsg += "Build Date: Unknown\n";
		errMsg += "Build Hash: Unknown\n\n";
		#end
		errMsg += "Date: " + dateNow + "\n";

		// Exception stack trace
		errMsg += "==== STACK TRACE ====\n";
		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				case CFunction:
					errMsg += "C Function\n";
				case Module(m):
					errMsg += "Module: " + m + "\n";
				case Method(classname, method):
					errMsg += "Method: " + classname + "." + method + "\n";
				case LocalFunction(n):
					errMsg += "Local Function: " + n + "\n";
				default:
					errMsg += "Unknown: " + stackItem + "\n";
			}
		}

		// Error details
		errMsg += "\n==== ERROR DETAILS ====\n";
		errMsg += "Error: " + e.error + "\n";
		errMsg += "Error Type: " + Type.getClassName(Type.getClass(e.error)) + "\n";

		// Client preferences and settings
		try {
			errMsg += "\n==== CLIENT PREFERENCES ====\n";
			errMsg += "Framerate: " + ClientPrefs.data.framerate + "\n";
			errMsg += "Reduced Movements: " + ClientPrefs.data.lowQuality + "\n";
			errMsg += "Antialiasing: " + ClientPrefs.data.antialiasing + "\n";
			errMsg += "Note Skin: " + ClientPrefs.data.noteSkin + "\n";
		} catch(e:Dynamic) {
			errMsg += "Failed to get client preferences: " + e + "\n";
		}

		// Current game state info
		try {
			errMsg += "\n==== CURRENT STATE ====\n";
			if (FlxG.game != null) {
				errMsg += "Game State: " + Type.getClassName(Type.getClass(FlxG.state)) + "\n";

				if (FlxG.state is PlayState) {
					if (PlayState.instance != null) {
						errMsg += "Song: " + PlayState.SONG.song + "\n";
						errMsg += "Difficulty: " + Difficulty.getString(false) + "\n";
						errMsg += "Week: " + WeekData.weeksList[PlayState.storyWeek] + "\n";
					}
				}
			} else {
				errMsg += "Game not initialized\n";
			}
		} catch(e:Dynamic) {
			errMsg += "Failed to get current state: " + e + "\n";
		}

		// Memory info
		try {
			errMsg += "\n==== MEMORY INFO ====\n";
			errMsg += "Memory usage: " + FlxStringUtil.formatBytes(cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE)) + "\n"; // Used FlxStringUtil here
			#if cpp
			errMsg += "GC Memory: " + FlxStringUtil.formatBytes(cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_RESERVED)) + "\n"; // Used FlxStringUtil here
			#end
		} catch(e:Dynamic) {
			errMsg += "Failed to get memory info: " + e + "\n";
		}

		// Mod info
		try {
			#if LUA_ALLOWED
			errMsg += "\n==== MOD INFO ====\n";
			errMsg += "Current Mod: " + Mods.currentModDirectory + "\n";
			@:privateAccess errMsg += "Global Mods: " + Mods.globalMods.join(", ") + "\n";
			#end
		} catch(e:Dynamic) {
			errMsg += "Failed to get mod info: " + e + "\n";
		}

		// Closing message
		#if officialBuild
		errMsg += "\n==== PLEASE REPORT ====\n";
		errMsg += "Please report this error to the GitHub page: " + EngineConfig.ENGINE_URL + "\n";
		errMsg += "Include the crash log and steps to reproduce if possible.\n";
		#end

		errMsg += "\n> Crash Handler written by: sqirra-rng (Psych Engine Modified Crash Handler by Paopun20 for HyperCodeEngine)";

		// Show error message
        var displayMsg = "The game crashed!\n";
        displayMsg += "A crash report has been saved to:\n" + Path.normalize(saveCrashReport(errMsg)) + "\n\n";
        displayMsg += "Error: " + Std.string(e.error).split("\n")[0] + "\n";
        #if officialBuild
        displayMsg += "\nPlease report this issue on GitHub.";
        #end

        Application.current.window.alert(displayMsg, "Crash Report");

		#if DISCORD_ALLOWED
		DiscordClient.shutdown();
		#end

		Sys.exit(1);
	}
	#end
}
