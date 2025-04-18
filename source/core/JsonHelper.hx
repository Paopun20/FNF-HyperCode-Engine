package core;

import haxe.ds.Map;
import haxe.Json;
import Reflect;

class JsonHelper {
    public static function encode(table: Dynamic): String {
        try {
            return Json.stringify(table);
        } catch (e) {
            trace("JSON encoding error for " + Std.string(table) + " - Error: " + e);
            return "{}";
        }
    }

    public static function decode(json: String): Dynamic {
        var result = new Map<String, Dynamic>();
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
