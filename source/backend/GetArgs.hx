package backend;

import Sys;

class GetArgs {
    /**
     * Returns the raw command-line arguments.
     * Only works on supported desktop/cpp platforms.
     */
    public static function getArgs():Array<String> {
        #if (desktop && cpp)
        return Sys.args();
        #else
        trace("Sys.args() not supported on this platform.");
        return [];
        #end
    }

    /**
     * Parses arguments of the form --key=value into a map.
     * For example: ["--mode=debug", "--port=8080"] → {"mode":"debug", "port":"8080"}
     */
    public static function parseArgs():Map<String, String> {
        var raw = getArgs();
        var parsed = new Map<String, String>();
        for (arg in raw) {
            if (StringTools.startsWith(arg, "--")) {
                var parts = arg.substr(2).split("=");
                if (parts.length == 2) {
                    parsed.set(parts[0], parts[1]);
                } else {
                    trace("Invalid argument format: " + arg);
                }
            }
        }
        return parsed;
    }

    /**
     * Checks if a flag (e.g. --verbose) is present.
     * These are arguments without =value, such as "--debug".
     */
    public static function hasFlag(flag:String):Bool {
        var raw = getArgs();
        return raw.indexOf("--" + flag) != -1;
    }

    /**
     * Returns the value of a given argument key, or null if not present.
     */
    public static function getValue(key:String):Null<String> {
        var args = parseArgs();
        return args.exists(key) ? args.get(key) : null;
    }

    /**
     * Debug-print all parsed arguments.
     */
    public static function printParsedArgs():Void {
        var parsed = parseArgs();
        trace("Parsed Command-Line Arguments:");
        for (key in parsed.keys()) {
            trace("  " + key + " = " + parsed.get(key));
        }
    }
}
