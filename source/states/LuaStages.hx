package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxTextBorderStyle;
import flixel.util.FlxColor;
import flixel.util.FlxAtlasFrames;

import backend.MusicBeatState;
import backend.PsychCamera;
import backend.Paths;

import states.AchievementsMenuState;
import states.CreditsState;
import states.MainMenuState;
import states.OptionsMenuState;
import states.PlayState;
import states.ErrorState;
import states.FlashingState;
import states.LoadingState;
import states.MusicBeatState;
import states.LuaStages;
import states.MainMenuState;
import states.ModsMenuState;
import states.PlayState;
import states.StoryMenuState;
import states.TitleState;

class StagesAPI {
    
    public function new(lua:State, camTarget:FlxCamera) {
        this.lua:State = null;
        this.camTarget:FlxCamera;
        this.scriptName:String = '';
        this.modFolder:String = null;
        this.closed:Bool = false;

		this.lua = LuaL.newstate();
		LuaL.openlibs(lua);

		this.scriptName = this.scriptName.trim();
        
        var myFolder:Array<String> = this.scriptName.split('/');
		#if MODS_ALLOWED
		if(myFolder[0] + '/' == Paths.mods() && (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) //is inside mods folder
			this.modFolder = myFolder[1];
		#end
    }
}

class LuaStages extends MusicBeatState {
    
}
