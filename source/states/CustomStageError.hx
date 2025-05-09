package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.util.FlxAxes;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxGroup;

class CustomStageError extends MusicBeatState
{
	public var acceptCallback:Void->Void;
	public var backCallback:Void->Void;
	public var errorlist:Array<Map<String, String>>;
	public var minY = 0;

	public function new(errorlist:Array<Map<String, String>>, accept:Void->Void = null, back:Void->Void = null)
	{
		this.errorlist = errorlist;
		this.acceptCallback = accept;
		this.backCallback = back;

		super();
		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;
	}

	public var errorSine:Float = 0;
	public var errorText:FlxText;
	public var scrollOffset:Float = 0;

	override function create()
	{
		var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = FlxColor.GRAY;
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		var combinedError = "";
		for (error in errorlist)
		{
			trace("Error in file: " + error.get("file") + " | Error message: " + error.get("error"));
			combinedError += "[" + error.get("file") + "]\n" + error.get("error") + "\n\n";
		}

		var errorMsg = "HMM, you got some error in your code:\n\n"
			+ combinedError
			+ "\n\nPress ACCEPT to reload CustomStage.\nPress ESC to restart game (Not recommended).\nUse UP/DOWN arrows to scroll.";

		this.minY = ClientPrefs.data.showFPS ? 35 : 0;
		errorText = new FlxText(0, this.minY, FlxG.width, errorMsg, 8);
		errorText.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		errorText.autoSize = false;
		errorText.scrollFactor.set();
		errorText.borderSize = 2;
		errorText.wordWrap = true;
		add(errorText);

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// Base scroll speed
		var scrollSpeed = 200;
		if (FlxG.keys.pressed.SHIFT)
			scrollSpeed *= 2; // Double speed when Shift is held

		// W / S key scroll
		if (FlxG.keys.pressed.W) errorText.y -= scrollSpeed * elapsed;
		else if (FlxG.keys.pressed.S) errorText.y += scrollSpeed * elapsed;

		// Mouse wheel scroll
		if (FlxG.mouse.wheel != 0) errorText.y -= FlxG.mouse.wheel * 30;

		if (errorText.y < this.minY) errorText.y = this.minY;

		// Accept or back
		if (controls.ACCEPT && acceptCallback != null)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			acceptCallback();
		}
		else if (controls.BACK && backCallback != null)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			backCallback();
		}
	}
}
