package objects;

import flixel.FlxSprite;
import haxe.ds.StringMap;

class ParticleData {
    public var time:Float;
    public var life:Float;
    public var dx:Float;
    public var dy:Float;
    public var accelRad:Float;
    public var accelTan:Float;

    public function new() {
        time = 0;
        life = 0;
        dx = 0;
        dy = 0;
        accelRad = 0;
        accelTan = 0;
    }
}

class ParticleSprite extends FlxSprite {
    public var userData:ParticleData;

    public function new(x:Float = 0, y:Float = 0, ?graphic:Dynamic = null) {
        super(x, y, graphic);
        this.userData = new ParticleData();
    }
}
