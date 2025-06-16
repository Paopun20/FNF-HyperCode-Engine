package;

import backend.GetArgs;
import states.TitleState;
import states.FreeplayState;
import debug.DebugTool;
import flixel.FlxState;

class Game extends MusicBeatState {
	public static var stageFlxMap:Map<String, Class<FlxState>> = [
		"MainMenuState" => states.MainMenuState,
		"TitleState" => states.TitleState,
		"StoryMenuState" => states.StoryMenuState,
		"AchievementsMenuState" => states.AchievementsMenuState,
		"CreditsState" => states.CreditsState,
		#if modsAllowed "ModsMenuState" => states.ModsMenuState, #end
		"OptionsState" => options.OptionsState,
		"FreeplayState" => states.FreeplayState,
		"PlayState" => states.PlayState,
		"LoadingState" => states.LoadingState,
		#if HSCRIPT_ALLOWED "CustomStage" => states.CustomStage #end
	];

	public static function restartGame() {
		// MusicBeatState.switchCustomStage("TitleState");
		TitleState.initialized = false;
		TitleState.closedState = false;
		FlxG.sound.music.fadeOut(0.3);
		if (FreeplayState.vocals != null)
		{
			FreeplayState.vocals.fadeOut(0.3);
			FreeplayState.vocals = null;
		}
		FlxG.camera.fade(FlxColor.BLACK, 0.5, false, FlxG.resetGame, false);
	}

	public static function addDebugTools() {
		DebugTool.registerFunction("restartGame", Game.restartGame);
		DebugTool.registerFunction("showConsole", DebugTool.showConsole);
		DebugTool.registerFunction("hideConsole", DebugTool.hideConsole);
		DebugTool.registerClass(MusicBeatState);

		for (key in stageFlxMap.keys()) {
			DebugTool.registerClass(stageFlxMap.get(key));
		}
	}
}
