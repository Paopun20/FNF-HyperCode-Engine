package states; 

import flixel.system.FlxBasePreloader;
import flash.display.BitmapData;
import flash.display.Sprite;
import openfl.display.Bitmap;
import openfl.text.TextField;
import backend.Paths;

@:bitmap(Paths.image("loading_screen/icon"))
class LogoBitmapData extends BitmapData {}

class PreloaderState extends FlxBasePreloader {
  private var logo:Bitmap;
  private var text:TextField;
  
  override public function new() {
    super(2); // keeps preloader visible at least 2s
  }

  override public function create():Void {
    super.create();

    // Add a logo
    logo = new Bitmap(new LogoBitmapData(0,0));
    logo.x = stage.stageWidth / 2;
    logo.y = stage.stageHeight / 2;
    addChild(logo);

    // Loading text
    text = new TextField();
    text.text = "Loading... 0%";
    text.x = logo.x;
    text.y = logo.y + logo.height + 20;
    addChild(text);
  }

  override public function update(Percent:Float):Void {
    super.update(Percent);
    // update text or graphics here
    text.text = "Loading... " + Std.int(Percent * 100) + "%";
  }
}