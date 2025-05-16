package states;

import flixel.FlxG;
import backend.MusicBeatState;
import backend.Paths;
import backend.Mods;
import states.*;
import objects.Character;
import psychlua.CustomSubstate;
import backend.Subprocess;
#if HSCRIPT_ALLOWED
import psychlua.HScript;
import crowplexus.hscript.Expr.Error as IrisError;
#end

class CustomStage extends MusicBeatState {
	public var stagePath:String = null;
	public var stageName:String = null;

	public static var instance:CustomStage = null;

	public var errorlist:Array<Map<String, String>> = [];

	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];

	private function stageAPI(script:HScript) {
		var set = script.set;

		// Game States
		set("MusicBeatState", MusicBeatState);
		set("MainMenuState", MainMenuState);
		set("StoryMenuState", StoryMenuState);
		#if MODS_ALLOWED set("ModsMenuState", ModsMenuState); #end
		set("CreditsState", CreditsState);
		set("AchievementsMenuState", AchievementsMenuState);
		set("TitleState", TitleState);
		set("CustomStage", CustomStage);
		set("PlayState", PlayState);
		
		set("Main", Main);
		set("Game", Game);

		set("debugPop", Main.debugPop);
		set("fpsVar", Main.fpsVar);
		set("flxGame", Main.flxGame);

		trace("[CustomStage] Script API injected successfully for " + script.name + ".");
	}

	private function tryCall(script:HScript, func:String, args:Array<Dynamic> = null, threaded:Bool = false):Void {
		if (script.exists(func)) {
			if (threaded) {
				Subprocess.run(() -> {
					try {
						script.call(func, args);
					} catch (e:haxe.Exception) {
						trace('[${script.name}] Error in $func(): ${e.message}');
					}
				});
			} else {
				try {
					script.call(func, args);
				} catch (e:haxe.Exception) {
					trace('[${script.name}] Error in $func(): ${e.message}');
				}
			}
		}
	}
	public function initHScript(file:String) {
		var newScript:HScript = null;
		try {
			// Check if file exists first
        	if (!FileSystem.exists(file)) {
				trace('File does not exist: $file');
				return;
        	}

        	// Try to read file contents
        	var contents:String = null;
			try {
			    contents = sys.io.File.getContent(file);
			} catch (e) {
				trace('Error reading file: $file');
				trace('Error message: ' + e.message);
        	}

        	// Verify contents aren't empty
        	if (contents == null || StringTools.trim(contents).length == 0) {
				trace('File is empty or contains only whitespace: $file');
				return;
			}

			newScript = new HScript(null, file);
			stageAPI(newScript);
			tryCall(newScript, "onCreate", null, true);
			hscriptArray.push(newScript);
			trace('Initialized HScript successfully: $file');
		} catch (e:haxe.Exception)
		{
			trace("Error initializing HScript: " + e);
			trace("Error in file: " + file);
			trace("Error message: " + e.message);

			var map = new Map<String, String>();
			map.set("file", file);
			map.set("error", e.message);
			errorlist.push(map);
			return;
		}
	}
	#end

	public static function haveCustomStage(stateName:String):Bool {
		if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0) {
			Mods.loadTopMod();
		}
		var stagePath = Paths.customStage(stateName);
		if (FileSystem.exists(stagePath) && FileSystem.isDirectory(stagePath)) {
			#if HSCRIPT_ALLOWED
			for (file in FileSystem.readDirectory(stagePath)) {
				if (file.endsWith(".hx")) return true;
			}
			#end
		}
		return false;
	}

	public function new(stateName:String) {
		super();
		// Mods.loadTopMod();
		instance = this;
		stageName = stateName;
		stagePath = Paths.customStage(stateName);
		trace("Loading custom stage: " + stagePath);
		if (stagePath == null || stagePath.trim() == "") {
			throw new haxe.Exception("Invalid stage path: " + stagePath);
		}
	}

	public function getStagePath():String {
		return stagePath;
	}

	public function getStageName():String {
		return stageName;
	}

	public function callFunctions(funcName:String, args:Array<Dynamic> = null):Void {
		#if HSCRIPT_ALLOWED
		for (script in hscriptArray) {
			if (script.exists(funcName)) {
				tryCall(script, funcName, args);
			}
		}
		#end
	}

	public function reload() {
		MusicBeatState.switchState(new CustomStage(stageName));
	}

	override public function create():Void {
		super.create();
		if (FileSystem.exists(stagePath) && FileSystem.isDirectory(stagePath)) {
			for (file in FileSystem.readDirectory(stagePath)) {
				#if HSCRIPT_ALLOWED
				if (file.endsWith(".hx")) {
					trace('Found .hx file: $stagePath/$file');
					var scriptPath = Paths.join([stagePath, file]);
					trace('Attempting to read file at: ${FileSystem.absolutePath(scriptPath)}');

					initHScript(scriptPath);
				}
				#end

				#if LUA_ALLOWED
				if (file.endsWith(".lua")) {
					trace('Hey, This lua file not supported yet: $stagePath/$file');
				}
				#end
			}
		} else {
			trace('Stage path is invalid or not a directory: $stagePath');
		}

		if (errorlist.length > 0) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new states.CustomStageError(
				errorlist,
				function() reload(),
				function() Game.restartGame()
			));
		}

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray) {
			tryCall(script, "onCreatePost");
		}
		#end
	}

	var holding:Bool = false;
	var holdtime:Float = 0.0;

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		#if HSCRIPT_ALLOWED
		for (script in hscriptArray) {
			tryCall(script, "onUpdate", [elapsed]);
		}
		#end

		if (controls.pressed('debug_1') && controls.pressed("reset")) {
			holding = true;
			holdtime += elapsed;
		} else {
			holding = false;
			holdtime = 0.0;
		}

		if (holding && holdtime >= 0.5) {
			trace("Reloading stage: " + stagePath);
			reload();
			holding = false;
			holdtime = 0.0;
		}

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray) {
			tryCall(script, "onUpdatePost", [elapsed]);
		}
		#end
	}

	override public function destroy():Void {
		super.destroy();
		instance = null;
		#if HSCRIPT_ALLOWED
		for (script in hscriptArray) {
			tryCall(script, "onDestroy");
			script.destroy();
		}
		#end
		
		#if HSCRIPT_ALLOWED
		while (hscriptArray.length > 0) hscriptArray.pop(); // Fast
		#end
	}
}
