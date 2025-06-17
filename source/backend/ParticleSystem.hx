package backend;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import haxe.ds.StringMap;

class ParticleSystem extends FlxTypedGroup<ParticleSprite> {
    // Particle system properties
    public var maxParticles(get, never):Int;
    public var duration(get, set):Float;
    public var lifetime(get, set):Float;
    public var lifetimeVar(get, set):Float;
    public var emissionRate(get, set):Float;
    public var angle(get, set):Float;
    public var angleVar(get, set):Float;
    public var speed(get, set):Float;
    public var posVarX(get, set):Float;
    public var posVarY(get, set):Float;
    public var gravityX(get, set):Float;
    public var gravityY(get, set):Float;
    public var accelRad(get, set):Float;
    public var accelRadVar(get, set):Float;
    public var accelTan(get, set):Float;
    public var accelTanVar(get, set):Float;

    // Private backing fields
    private var _maxParticles:Int;
    private var _duration:Float;
    private var _lifetime:Float;
    private var _lifetimeVar:Float;
    private var _emissionRate:Float;
    private var _angle:Float;
    private var _angleVar:Float;
    private var _speed:Float;
    private var _posVarX:Float;
    private var _posVarY:Float;
    private var _gravityX:Float;
    private var _gravityY:Float;
    private var _accelRad:Float;
    private var _accelRadVar:Float;
    private var _accelTan:Float;
    private var _accelTanVar:Float;

    private var _elapsed:Float = 0;
    private var _timer:Float = 0;
    private var _particleTexture:String;

    public function new(texture:String, max:Int = 100) {
        super(max);
        _maxParticles = max;
        _particleTexture = texture;

        // Defaults
        _duration = 2;
        _lifetime = 1.0;
        _lifetimeVar = 0.5;
        _emissionRate = 50;
        _angle = 0;
        _angleVar = 45;
        _speed = 100;
        _posVarX = 0;
        _posVarY = 0;
        _gravityX = 0;
        _gravityY = 200;
        _accelRad = 0;
        _accelRadVar = 0;
        _accelTan = 0;
        _accelTanVar = 0;
    }

    // Accessors
    inline function get_maxParticles():Int return _maxParticles;

    inline function get_duration():Float return _duration;
    inline function set_duration(v:Float):Float return _duration = v;

    inline function get_lifetime():Float return _lifetime;
    inline function set_lifetime(v:Float):Float return _lifetime = v;

    inline function get_lifetimeVar():Float return _lifetimeVar;
    inline function set_lifetimeVar(v:Float):Float return _lifetimeVar = v;

    inline function get_emissionRate():Float return _emissionRate;
    inline function set_emissionRate(v:Float):Float return _emissionRate = v;

    inline function get_angle():Float return _angle;
    inline function set_angle(v:Float):Float return _angle = v;

    inline function get_angleVar():Float return _angleVar;
    inline function set_angleVar(v:Float):Float return _angleVar = v;

    inline function get_speed():Float return _speed;
    inline function set_speed(v:Float):Float return _speed = v;

    inline function get_posVarX():Float return _posVarX;
    inline function set_posVarX(v:Float):Float return _posVarX = v;

    inline function get_posVarY():Float return _posVarY;
    inline function set_posVarY(v:Float):Float return _posVarY = v;

    inline function get_gravityX():Float return _gravityX;
    inline function set_gravityX(v:Float):Float return _gravityX = v;

    inline function get_gravityY():Float return _gravityY;
    inline function set_gravityY(v:Float):Float return _gravityY = v;

    inline function get_accelRad():Float return _accelRad;
    inline function set_accelRad(v:Float):Float return _accelRad = v;

    inline function get_accelRadVar():Float return _accelRadVar;
    inline function set_accelRadVar(v:Float):Float return _accelRadVar = v;

    inline function get_accelTan():Float return _accelTan;
    inline function set_accelTan(v:Float):Float return _accelTan = v;

    inline function get_accelTanVar():Float return _accelTanVar;
    inline function set_accelTanVar(v:Float):Float return _accelTanVar = v;

    // Emit a single particle
    public function emit(x:Float = 0, y:Float = 0):Void {
        var p = new ParticleSprite();
        p.loadGraphic(_particleTexture);
        p.setPosition(
            x + (Math.random() * 2 - 1) * _posVarX,
            y + (Math.random() * 2 - 1) * _posVarY
        );

        var a = FlxAngle.asRadians(_angle + (Math.random() * 2 - 1) * _angleVar);
        var vx = Math.cos(a) * _speed;
        var vy = Math.sin(a) * _speed;
        p.velocity.set(vx, vy);

        var life = _lifetime + (Math.random() * 2 - 1) * _lifetimeVar;
        p.exists = true;
        p.alpha = 1;
        p.acceleration.set(_gravityX, _gravityY);

        var d = new StringMap<Dynamic>();
        d.set("life", life);
        d.set("time", 0.0);
        d.set("dx", p.x);
        d.set("dy", p.y);
        d.set("accelRad", _accelRad + (Math.random() * 2 - 1) * _accelRadVar);
        d.set("accelTan", _accelTan + (Math.random() * 2 - 1) * _accelTanVar);
        p.userData = d;

        add(p);
    }

    // Update logic
    public function postUpdate(elapsed:Float):Void {
        for (p in members) {
            if (p == null || !p.exists) continue;
            var d = p.userData;
            if (d == null) continue;

            d.set("time", d.get("time") + elapsed);
            if (d.get("time") >= d.get("life")) {
                p.kill();
                continue;
            }

            var dx = p.x - d.get("dx");
            var dy = p.y - d.get("dy");
            var dist = Math.sqrt(dx * dx + dy * dy);
            var ax = 0.0;
            var ay = 0.0;

            if (dist != 0) {
                var accRad = d.get("accelRad");
                ax += dx / dist * accRad;
                ay += dy / dist * accRad;

                var accTan = d.get("accelTan");
                ax += -dy / dist * accTan;
                ay += dx / dist * accTan;
            }

            p.acceleration.x += ax;
            p.acceleration.y += ay;

            p.alpha = 1 - (d.get("time") / d.get("life"));
        }
    }

    public function restart():Void {
        _elapsed = 0;
        _timer = 0;
    }
}
