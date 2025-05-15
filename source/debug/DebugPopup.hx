package debug;

import flixel.FlxG;
import openfl.text.TextField;
import flixel.text.FlxText;
import haxe.ds.Map;
import flixel.util.FlxStringUtil;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;


class DebugPopup extends TextField {
    public static var instance:DebugPopup;
    private var list:Array<FlxText>;

    public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000) {
        super();

        this.x = x;
        this.y = y;
        this.textColor = color;

        list = new Array<FlxText>();
        instance = this;
    }

    public function show(text:String):Void {
        var tf:FlxText = new FlxText(10, 10 + list.length * 20, 0, text);
        tf.setFormat(null, 12, 0xFFFFFF);
        list.push(tf);
            FlxTween.tween(tf, { alpha: 0 }, 1, {
                onComplete: function(twn:FlxTween) {
                    list.remove(tf);
                    tf.kill();
                },
                ease: FlxEase.quadOut
        });
    }

    override public function __enterFrame(elapsed:Float):Void {
        for (text in list) {
            text.update(elapsed);
        }
    }
}
