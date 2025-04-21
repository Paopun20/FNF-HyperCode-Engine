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
import flixel.util.FlxColor;

import backend.MusicBeatState;
import backend.PsychCamera;
import backend.Paths;

import states.AchievementsMenuState;
import states.CreditsState;
import states.MainMenuState;
import states.PlayState;
import states.ErrorState;
import states.FlashingState;
import states.LoadingState;
import states.LuaStages;
import states.MainMenuState;
import states.ModsMenuState;
import states.PlayState;
import states.StoryMenuState;
import states.TitleState;

class StagesAPI {
    public var lua:State;
    public var camTarget:FlxCamera;
    public var scriptName:String;
    public var modFolder:String;
    public var closed:Bool;

    public function new(lua:State, camTarget:FlxCamera) {
        this.lua = lua;
        this.camTarget = camTarget;
        this.scriptName = '';
        this.modFolder = null;
        this.closed = false;

		this.lua = LuaL.newstate();
		LuaL.openlibs(lua);

		this.scriptName = this.scriptName.trim();
        
        var myFolder:Array<String> = this.scriptName.split('/');
		#if MODS_ALLOWED
		if(myFolder[0] + '/' == Paths.mods() && (Mods.currentModDirectory == myFolder[0] || Mods.getGlobalMods().contains(myFolder[0]))) //is inside mods folder
			this.modFolder = myFolder[0];
		#end

        if(this.modFolder == null) {
            this.modFolder = Paths.mods() + myFolder[0] + '/';
        } else {
            this.modFolder = Paths.mods() + myFolder[0] + '/';
        }
        this.scriptName = myFolder[1];
    }
}

class LuaStages extends MusicBeatState {
    
}
