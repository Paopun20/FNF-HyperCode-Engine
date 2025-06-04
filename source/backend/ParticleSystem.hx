package backend;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.ds.StringMap;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;

class ParticleSprite extends FlxSprite {
    public var userData:StringMap<Dynamic>;
    public function new() {
        super();
        userData = new StringMap<Dynamic>();
    }
}

class ParticleSystem extends FlxTypedGroup<ParticleSprite> {
    public var maxParticles:Int;
    public var duration:Float;
    public var lifetime:Float;
    public var lifetimeVar:Float;
    public var emissionRate:Float;
    public var angle:Float;
    public var angleVar:Float;
    public var speed:Float;
    public var posVarX:Float;
    public var posVarY:Float;
    public var gravityX:Float;
    public var gravityY:Float;
    public var accelRad:Float;
    public var accelRadVar:Float;
    public var accelTan:Float;
    public var accelTanVar:Float;    

    private var _elapsed:Float = 0;
    private var _timer:Float = 0;
    private var _particleTexture:String;
    private var _particleData:haxe.ds.StringMap<Dynamic>;


    public function new(texture:String, max:Int = 100) {
        super(max);
        maxParticles = max;
        _particleTexture = texture;

        // Default values
        duration = 2;
        lifetime = 1.0;
        lifetimeVar = 0.5;
        emissionRate = 50;
        angle = 0;
        angleVar = 45;
        speed = 100;
        posVarX = 0;
        posVarY = 0;
        gravityX = 0;
        gravityY = 200;
        accelRad = 0;
        accelRadVar = 0;
        accelTan = 0;
        accelTanVar = 0;
    }

    public function emit(x:Float = 0, y:Float = 0):Void {
        var p = new ParticleSprite();

        p.loadGraphic(_particleTexture);
        p.setPosition(
            x + (Math.random() * 2 - 1) * posVarX,
            y + (Math.random() * 2 - 1) * posVarY
        );

        var a = FlxAngle.asRadians(angle + (Math.random() * 2 - 1) * angleVar);
        var spd = speed;

        var vx = Math.cos(a) * spd;
        var vy = Math.sin(a) * spd;
        p.velocity.set(vx, vy);

        var life = lifetime + (Math.random() * 2 - 1) * lifetimeVar;
        p.exists = true;
        p.alpha = 1;
        p.acceleration.set(gravityX, gravityY);

        var dx = p.x;
        var dy = p.y;

        // Store custom data in the userData property
        var particleData = new haxe.ds.StringMap<Dynamic>();
        particleData.set("life", life);
        particleData.set("time", 0.0);
        particleData.set("dx", dx);
        particleData.set("dy", dy);
        particleData.set("accelRad", accelRad + (Math.random() * 2 - 1) * accelRadVar);
        particleData.set("accelTan", accelTan + (Math.random() * 2 - 1) * accelTanVar);
        p.userData = particleData;

        add(p);
    }
    public function postUpdate(elapsed:Float):Void {
        for (p in members) {
            if (p == null || !p.exists) continue;

            var d:Null<haxe.ds.StringMap<Dynamic>> = p.userData;
            if (d == null) continue;
            d.set("time", d.get("time") + elapsed);

            // Kill when lifetime expires
            if (d.get("time") >= d.get("life")) {
                p.kill();
                continue;
            }

            // Radial acceleration
            var dx = p.x - d.get("dx");
            var dy = p.y - d.get("dy");
            var dist = Math.sqrt(dx * dx + dy * dy);
            var ax = 0.0;
            var ay = 0.0;

            if (dist != 0) {
                ax += dx / dist * d.get("accelRad");
                ay += dy / dist * d.get("accelRad");
            }

            // Tangential acceleration
            var tx = -dy / dist * d.get("accelTan");
            var ty = dx / dist * d.get("accelTan");
            if (dist != 0) {
                ax += tx;
                ay += ty;
            }

            p.acceleration.x += ax;
            p.acceleration.y += ay;

            // Fade out
            p.alpha = 1 - (d.get("time") / d.get("life"));
        }
    }

    public function restart():Void {
        _elapsed = 0;
        _timer = 0;
    }
}
