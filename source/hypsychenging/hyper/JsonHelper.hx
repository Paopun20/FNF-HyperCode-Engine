package hypsychenging.hyper;

import haxe.ds.StringMap;
import haxe.Json;
import Reflect;

class JsonHelper {
    public static function Encode(table: StringMap<Dynamic>): String {
        try {
            return Json.stringify(table);
        } catch (e) {
            trace("StringMap to JSON encoding error for " + Std.string(table) + " - Error: " + e);
            return "{}"; // Return empty JSON on error
        }
    }

    public static function Decode(json): StringMap<Dynamic> {
        var result = new StringMap<Dynamic>();
        try {
            var decoded = Json.parse(json);
            if (Reflect.isObject(decoded)) {
                for (key in Reflect.fields(decoded)) {
                    result.set(key, Reflect.field(decoded, key));
                }
            } else {
                trace("Warning: JSON decoded into a non-object for input: " + json);
            }
        } catch (e) {
            trace("JSON decoding error for input: " + json + " - Error: " + e);
        }
        return result;
    }
}