package backend;

import states.PlayState;
import objects.HealthIcon;
import flixel.math.FlxMath;

typedef IconAnimationDataID = Map<String, IconAnimationDataType>;
typedef IconAnimationDataType = Map<String, (HealthIcon, Float) -> Void>;

class HealthIconAnimation
{
	public static var playbackRate:Float = 1;
	public static var animationMap:IconAnimationDataID = [
		"Psych" => [
			"Dance" => (icon:HealthIcon, elapsed:Float) ->
			{
				var mult:Float = FlxMath.lerp(1, icon.scale.x, Math.exp(-elapsed * 9 * playbackRate));
				icon.scale.set(mult, mult);
			},
			"Reset" => (icon:HealthIcon, elapsed:Float) ->
			{
				icon.scale.set(1.2, 1.2);
			}
		],
		// Add More Here
	];

	public static function animation(icon:HealthIcon, elapsed:Float = 0, animationID:String, typeID:String)
	{
		if (PlayState.instance != null) {
			playbackRate = PlayState.instance.playbackRate;
		} else {
			playbackRate = 1;
		}
		if (animationMap.exists(animationID))
		{
			var animationType:IconAnimationDataType = animationMap.get(animationID);
			if (animationType.exists(typeID))
			{
				var animationFunction:((HealthIcon, Float) -> Void) = animationType.get(typeID);
				animationFunction(icon, elapsed);
			}
		}
	}
}
