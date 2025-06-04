package backend;

import states.PlayState;
import objects.HealthIcon;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

typedef IconAnimationDataID = Map<String, IconAnimationDataType>;
typedef IconAnimationDataType = Map<String, (HealthIcon, Float) -> Void>;

class HealthIconAnimation
{
    public var icon:HealthIcon;
    public var animationID:String = "Psych";
    public var playbackRate:Float = 1;

    private var currentAnimationType:IconAnimationDataType; // Cache current animation type

    public static var animationMap:IconAnimationDataID = [
        "Psych" => [
            "Dance" => (icon:HealthIcon, elapsed:Float) ->
            {
                if (icon == null) return;
                // Optimize by calculating exp(-elapsed * 9 * rate) only once
                var rate = getPlaybackRate();
                var exp = Math.exp(-elapsed * 9 * rate);
                var mult = FlxMath.lerp(1, icon.scale.x, exp);
                // Only update scale if it would make a visible difference
                if (Math.abs(icon.scale.x - mult) > 0.001) 
                    icon.scale.set(mult, mult);
            },
            "Reset" => (icon:HealthIcon, elapsed:Float) ->
            {
                if (icon == null) return;
                icon.scale.set(1.2, 1.2);
            }
        ],

        "None" => [
            "Dance" => (icon:HealthIcon, elapsed:Float) -> {},
            "Reset" => (icon:HealthIcon, elapsed:Float) -> {}
        ]
    ];

    public function new(icon:HealthIcon) 
    {
        this.icon = icon;
        updateAnimationType();
    }

    public function set(animationID:String, typeID:String = "Reset"):Void 
    {
        if (this.animationID != animationID)
        {
            this.animationID = animationID;
            updateAnimationType();
        }
        apply(typeID, 0);
    }

    public inline function animation(elapsed:Float, typeID:String):Void 
    {
        playbackRate = getPlaybackRate();
        apply(typeID, elapsed);
    }

    public inline function stop():Void 
    {
        apply("Reset", 0);
        this.icon = null;
        this.animationID = "None";
    }

    private function updateAnimationType():Void
    {
        currentAnimationType = animationMap.exists(animationID) ? animationMap.get(animationID) : animationMap.get("None");
    }

    private inline function apply(typeID:String, elapsed:Float):Void 
    {
        if (currentAnimationType != null && currentAnimationType.exists(typeID)) 
        {
            currentAnimationType.get(typeID)(icon, elapsed);
        }
    }

    private static inline function getPlaybackRate():Float
    {
        return (PlayState.instance != null) ? PlayState.instance.playbackRate : 1;
    }
}
