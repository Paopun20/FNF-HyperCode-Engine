package;

import states.TitleState;
import states.FreeplayState;

class Game extends MusicBeatState {
    public static function restartGame() {
        //MusicBeatState.switchCustomStage("TitleState");
        TitleState.initialized = false;
        TitleState.closedState = false;
        FlxG.sound.music.fadeOut(0.3);
        if(FreeplayState.vocals != null)
        {
        	FreeplayState.vocals.fadeOut(0.3);
        	FreeplayState.vocals = null;
        }
        FlxG.camera.fade(FlxColor.BLACK, 0.5, false, FlxG.resetGame, false);
    }
}