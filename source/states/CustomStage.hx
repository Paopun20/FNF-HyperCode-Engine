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
		set("ModsMenuState", ModsMenuState);
		set("CreditsState", CreditsState);
		set("AchievementsMenuState", AchievementsMenuState);
		set("TitleState", TitleState);
		set("CustomStage", CustomStage);

		trace("[CustomStage] Script API injected successfully for " + script.name + ".");
	}

	private function tryCall(script:HScript, func:String, args:Array<Dynamic> = null):Void {
		if (script.exists(func)) {
			Subprocess.run(() -> {
				try {
					script.call(func, args);
				} catch (e:haxe.Exception) {
					trace('[${script.name}] Error in $func(): ${e.message}');
				}
			});
		}
	}

	public function initHScript(file:String) {
		var newScript:HScript = null;
		try {
			newScript = new HScript(null, file);
			stageAPI(newScript);
			tryCall(newScript, "onCreate");
			hscriptArray.push(newScript);
			trace('Initialized HScript successfully: $file');
		} catch (e:IrisError) {
			var map = new Map<String, String>();
			map.set("file", file);
			map.set("error", e.toString());
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
			for (file in FileSystem.readDirectory(stagePath)) {
				if (file.endsWith(".hx")) return true;
			}
		}
		return false;
	}

	public function new(stateName:String) {
		super();
		Mods.loadTopMod();
		instance = this;
		stageName = stateName;
		stagePath = Paths.customStage(stateName);
		trace("Loading custom stage: " + stagePath);
		if (stagePath == null || stagePath.trim() == "") {
			throw new haxe.Exception("Invalid stage path: " + stagePath);
		}
	}

	public function reload() {
		MusicBeatState.switchState(new CustomStage(stageName));
	}

	override public function create():Void {
		super.create();
		if (FileSystem.exists(stagePath) && FileSystem.isDirectory(stagePath)) {
			for (file in FileSystem.readDirectory(stagePath)) {
				if (file.endsWith(".hx")) {
					trace('Found .hx file: $stagePath/$file');
					Subprocess.run(() -> {
						initHScript(Sys.systemName() == "Windows" ? stagePath + "\\" + file : stagePath + "/" + file);
					});
				}
			}
		} else {
			trace('Stage path is invalid or not a directory: $stagePath');
		}

		if (errorlist.length > 0) {
			var combinedError = "";
			for (e in errorlist) {
				trace("Error in file: " + e.get("file"));
				trace("Error message: " + e.get("error"));
				combinedError += e.get("error") + "\n";
			}
			if (combinedError != "") {
				MusicBeatState.switchState(new states.ErrorState(
					"HMM, you got some error in your code:\n" + combinedError + "\n\nPress ACCEPT to reload CustomStage.",
					function() reload()
				));
			}
		}

		for (script in hscriptArray) {
			tryCall(script, "onCreatePost");
		}
	}

	var holding:Bool = false;
	var holdtime:Float = 0.0;

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		for (script in hscriptArray) {
			tryCall(script, "onUpdate", [elapsed]);
		}

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

		for (script in hscriptArray) {
			tryCall(script, "onUpdatePost", [elapsed]);
		}
	}

	override public function destroy():Void {
		super.destroy();
		for (script in hscriptArray) {
			tryCall(script, "onDestroy");
			script.destroy();
		}
		
		while (hscriptArray.length > 0) hscriptArray.pop(); // Fast
	}
}
