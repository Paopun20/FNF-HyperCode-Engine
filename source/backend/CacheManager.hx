package backend;

import flixel.graphics.FlxGraphic;
import openfl.media.Sound;
import haxe.ds.StringMap;

class CacheManager
{
    private var cachedGraphics:StringMap<FlxGraphic>;
    private var cachedSounds:StringMap<Sound>;

    public function new()
    {
        cachedGraphics = new StringMap();
        cachedSounds = new StringMap();
    }

    public function getGraphic(key:String):FlxGraphic
    {
        return cachedGraphics.get(key);
    }

    public function addGraphic(key:String, graphic:FlxGraphic):Void
    {
        cachedGraphics.set(key, graphic);
    }

    public function removeGraphic(key:String):Void
    {
        var graphic = cachedGraphics.get(key);
        if (graphic != null)
        {
            @:privateAccess if (graphic.bitmap != null && graphic.bitmap.__texture != null) graphic.bitmap.__texture.dispose();
        }
        cachedGraphics.remove(key);
    }

    public function getSound(key:String):Sound
    {
        return cachedSounds.get(key);
    }

    public function addSound(key:String, sound:Sound):Void
    {
        cachedSounds.set(key, sound);
    }

    public function removeSound(key:String):Void
    {
        cachedSounds.remove(key);
    }

    public function clearUnused(usedKeys:Array<String>):Void
    {
        for (key in cachedGraphics.keys())
        {
            if (!usedKeys.contains(key))
                removeGraphic(key);
        }
        for (key in cachedSounds.keys())
        {
            if (!usedKeys.contains(key))
                removeSound(key);
        }
    }
}
