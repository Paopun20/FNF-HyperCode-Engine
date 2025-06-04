package states.customstage;
import psychlua.HScript;
import states.*;

class API extends MusicBeatState {
    // This class is used to inject the API into the HScript
	public static function injectAPI(script:HScript):Void {
		var set = script.set;
		set("MusicBeatState", MusicBeatState);
		set("PlayState", PlayState);
		set("MainMenuState", MainMenuState);
		set("StoryMenuState", StoryMenuState);
		set("CreditsState", CreditsState);
		set("AchievementsMenuState", AchievementsMenuState);
		set("TitleState", TitleState);
		set("CustomStage", states.CustomStage);
		set("Main", Main);
		set("Game", Game);
		set("debugPop", Main.debugPop);
		set("fpsVar", Main.fpsVar);
		set("flxGame", Main.flxGame);
	}
}

class APIScriptHandler {
	#if HSCRIPT_ALLOWED
	public static function tryCall(script:HScript, func:String, args:Array<Dynamic> = null): Dynamic {
		if (script == null) {
			// trace('Script is null, cannot call function: $func');
			return null;
		}

		if (script.exists(func)) {
			try {
			    return script.call(func, args);
			} catch (e:haxe.Exception) {
			    trace('[${script.name}] Error calling $func(): ${e.message}');
				return null;
			}
		}
		return null;
	}
	public static function injectAPI(script:HScript):Void {
		API.injectAPI(script);
	}
	#else
	public static function injectAPI(script:HScript):Void {
		trace('HSCRIPT not allowed, cannot inject API');
	}

	public static function tryCall(script:Dynamic, func:String, args:Array<Dynamic> = null): Dynamic {
		trace('HSCRIPT not allowed, cannot call function: $func');
		return null;
	}
	#end
}