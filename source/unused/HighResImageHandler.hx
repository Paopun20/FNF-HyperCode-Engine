package backend;

import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import flixel.FlxG;

/**
 * Handles loading and processing of high resolution images (6K+ pixels)
 */
class HighResImageHandler
{
    public static inline var MAX_TEXTURE_SIZE:Int = 8192; // Default max texture size
    private static var ORIGIN:Point = new Point(0, 0);

    /**
     * Loads a high resolution image and splits it into smaller textures if needed
     * @param path The path to the image
     * @param key The key to store the image under
     * @return Array of FlxGraphic objects representing the image segments
     */
    public static function loadHighResImage(path:String, key:String):Array<FlxGraphic>
    {
        var bitmap:BitmapData = BitmapData.fromFile(path);
        if (bitmap == null) return [];

        // If the image is within texture size limits, process normally
        if (bitmap.width <= MAX_TEXTURE_SIZE && bitmap.height <= MAX_TEXTURE_SIZE)
        {
            return [processNormalImage(bitmap, key)];
        }

        // Calculate number of segments needed
        var segmentsX:Int = Math.ceil(bitmap.width / MAX_TEXTURE_SIZE);
        var segmentsY:Int = Math.ceil(bitmap.height / MAX_TEXTURE_SIZE);
        var graphics:Array<FlxGraphic> = [];

        // Split the image into segments
        for (y in 0...segmentsY)
        {
            for (x in 0...segmentsX)
            {
                var segmentWidth:Int = (x == segmentsX - 1) ? bitmap.width - (x * MAX_TEXTURE_SIZE) : MAX_TEXTURE_SIZE;
                var segmentHeight:Int = (y == segmentsY - 1) ? bitmap.height - (y * MAX_TEXTURE_SIZE) : MAX_TEXTURE_SIZE;

                var segment:BitmapData = new BitmapData(segmentWidth, segmentHeight, true, 0);
                var sourceRect:Rectangle = new Rectangle(x * MAX_TEXTURE_SIZE, y * MAX_TEXTURE_SIZE, segmentWidth, segmentHeight);
                segment.copyPixels(bitmap, sourceRect, ORIGIN);

                var segmentKey:String = '${key}_segment_${x}_${y}';
                graphics.push(processNormalImage(segment, segmentKey));
            }
        }

        // Clean up original bitmap
        bitmap.dispose();
        bitmap = null;

        return graphics;
    }

    /**
     * Process a normal-sized image through the regular pipeline
     */
    @:privateAccess private static function processNormalImage(bitmap:BitmapData, key:String):FlxGraphic
    {
        if (ClientPrefs.data.cacheOnGPU)
        {
            bitmap.lock();
            if (bitmap.__texture == null)
            {
                bitmap.image.premultiplied = true;
                bitmap.getTexture(FlxG.stage.context3D);
            }
            bitmap.getSurface();
            bitmap.disposeImage();
            bitmap.image.data = null;
            bitmap.image = null;
        }

        var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, key);
        graphic.persist = true;
        graphic.destroyOnNoUse = false;

        CacheManager.instance.addGraphic(key, graphic, CachePriority.HIGH);
        return graphic;
    }

    /**
     * Creates a composite view of split image segments
     * @param segments Array of image segments
     * @param originalWidth Original image width
     * @param originalHeight Original image height
     * @return Composite BitmapData of the full image
     */
    public static function createCompositeView(segments:Array<FlxGraphic>, originalWidth:Int, originalHeight:Int):BitmapData
    {
        var composite:BitmapData = new BitmapData(originalWidth, originalHeight, true, 0);
        var segmentsX:Int = Math.ceil(originalWidth / MAX_TEXTURE_SIZE);

        for (i in 0...segments.length)
        {
            var x:Int = (i % segmentsX) * MAX_TEXTURE_SIZE;
            var y:Int = Std.int(i / segmentsX) * MAX_TEXTURE_SIZE;
            composite.copyPixels(segments[i].bitmap, segments[i].bitmap.rect, new Point(x, y));
        }

        return composite;
    }
}
