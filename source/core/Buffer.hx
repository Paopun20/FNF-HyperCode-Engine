package core;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import flash.geom.Rectangle;

class StringBuffer {
    /**
     * Converts a string into a Bytes object using BytesBuffer.
     * @param str The string to convert.
     * @return The Bytes object containing the string's data.
     */
    public static function fromString(str: String): Bytes {
        var buffer = new BytesBuffer();
        buffer.addString(str);
        return buffer.getBytes();
    }

    /**
     * Converts a Bytes object to a string.
     * @param bytes The Bytes object to convert.
     * @return The string representation of the Bytes object.
     */
    public static function toString(bytes: Bytes): String {
        return bytes.toString();
    }

    /**
     * Converts a string into a Bytes object.
     * @param str The string to convert.
     * @return The corresponding Bytes object.
     */
    public static function toBytes(str: String): Bytes {
        return fromString(str);
    }
}

class BitMapBuffer {
    /**
     * Converts a Bitmap to a Bytes representation of its pixels.
     * @param bitmap The source Bitmap.
     * @return A Bytes object containing pixel data.
     */
    public static function fromBitmap(bitmap:Bitmap):Bytes {
        var bitmapData = bitmap.bitmapData;
        var pixels = bitmapData.getPixels(bitmapData.rect);

        var buffer = new BytesBuffer();
        buffer.addBytes(pixels, 0, pixels.length);

        return buffer.getBytes();
    }

    /**
     * Converts pixel data Bytes to a Bitmap object.
     * @param bytes The pixel data.
     * @param width Optional width of the bitmap.
     * @param height Optional height of the bitmap.
     * @return A Bitmap created from the pixel data.
     */
    public static function toBitmap(bytes:Bytes, width:Int = 100, height:Int = 100):Bitmap {
        var rect = new Rectangle(0, 0, width, height);
        var bitmapData = new BitmapData(width, height, false, 0x000000);
        bitmapData.setPixels(rect, bytes);

        return new Bitmap(bitmapData);
    }
}