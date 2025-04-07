package hypsychenging.hyper;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

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
     * Converts a Bitmap object to a Bytes object.
     * @param bitmap The Bitmap to convert.
     * @return The Bytes object containing the Bitmap data.
     */
    public static function fromBitmap(bitmap: Bitmap): Bytes {
        var buffer = new BytesBuffer();
        var bitmapData = bitmap.bitmapData;
        var pixels = bitmapData.getPixels(bitmapData.rect);

        // Ensure we add the byte array (pixels) to the buffer correctly
        buffer.addBytes(pixels, 0, pixels.length);
        
        return buffer.getBytes();
    }

    /**
     * Converts a Bytes object to a Bitmap object.
     * @param bytes The Bytes object to convert.
     * @return The Bitmap object created from the Bytes.
     */
    public static function toBitmap(bytes: Bytes): Bitmap {
        // You may need to know the image dimensions to properly decode the bytes
        var width = 100; // Placeholder width, adjust based on your use case
        var height = 100; // Placeholder height, adjust based on your use case

        // Create a BitmapData object and set the pixel data from bytes
        var bitmapData = new BitmapData(width, height); 
        bitmapData.setPixels(bitmapData.rect, bytes);
        
        return new Bitmap(bitmapData);
    }
}