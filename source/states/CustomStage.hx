package states;

import backend.MusicBeatState;
import backend.Paths;
import backend.Mods;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;

import states.*;
import objects.Character;
import psychlua.CustomSubstate;

#if HSCRIPT_ALLOWED
import crowplexus.hscript.Expr.Error as IrisError;
import psychlua.HScript;
import customstage.CustomStageScriptHandler;
import customstage.CustomStageLoader;
#end

class CustomStage extends MusicBeatState {
	public var stagePath:String;
	public var stageName:String;

	public static var instance:CustomStage = null;

	public var errorlist:Array<Map<String, String>> = [];

	#if HSCRIPT_ALLOWED
	public var scriptHandler:CustomStageScriptHandler;
	#end

	public function new(stateName:String) {
		super();
		instance = this;
		stageName = stateName;
		stagePath = Paths.customStage(stageName);
		trace("Loading custom stage: " + stagePath);
		if (stagePath == null || stagePath.trim() == "") {
			throw new haxe.Exception("Invalid stage path: " + stagePath);
		}
	}

	override public function create():Void {
		super.create();

		#if HSCRIPT_ALLOWED
		scriptHandler = new CustomStageScriptHandler(stagePath, errorlist);
		scriptHandler.loadScripts();
		#end

		if (errorlist.length > 0) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new CustomStageError(
				errorlist,
				function() reload(),
				function() Game.restartGame()
			));
		}

		#if HSCRIPT_ALLOWED
		scriptHandler.call("onCreatePost");
		#end
	}

	var holding:Bool = false;
	var holdtime:Float = 0.0;

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		#if HSCRIPT_ALLOWED
		scriptHandler.call("onUpdate", [elapsed]);
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
		scriptHandler.call("onUpdatePost", [elapsed]);
		#end
	}

	override public function destroy():Void {
		super.destroy();
		instance = null;
		#if HSCRIPT_ALLOWED
		scriptHandler.call("onDestroy");
		scriptHandler.destroy();
		#end
	}

	public function reload() {
		MusicBeatState.switchState(new CustomStage(stageName));
	}

	public function getStagePath():String {
		return stagePath;
	}

	public function getStageName():String {
		return stageName;
	}

	public static function haveCustomStage(stateName:String):Bool {
		#if HSCRIPT_ALLOWED
		return CustomStageLoader.haveCustomStage(stateName);
		#else
		return false;
		#end
	}

	public function callFunctions(funcName:String, args:Array<Dynamic> = null):Void {
		#if HSCRIPT_ALLOWED
		if (scriptHandler != null) {
			scriptHandler.call(funcName, args);
		}
		#end
	}
}
