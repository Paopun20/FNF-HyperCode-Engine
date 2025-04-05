package hypsychenging;
import hypsychenging.hyper.BrainFuck;
import hypsychenging.hyper.GetArgs;
import hypsychenging.hyper.HttpClient;
import hypsychenging.hyper.JsonHelper;
import hypsychenging.hyper.ScreenInfo;
import hypsychenging.hyper.UrlGen;
import hypsychenging.hyper.WindowManager;
import haxe.ds.IntMap;

#if LUA_ALLOWED
import psychlua.FunkinLua;
#end

var tagUrlGen: Map<String, UrlGen> = new Map();
var windowManagerMap:Map<String, WindowManager> = new Map();

class BrainFuckLua {
    public function new(lua: State) {
        Lua_helper.add_callback(lua, "runBrainFuckCode", function(code: String, input = ""): String {
            var inputMap = new IntMap<Int>();
            try {
                if (input != "") {
                    var inputValues = input.split(",").map(Std.parseInt);
                    for (i in 0...inputValues.length) {
                        inputMap.set(i, inputValues[i]);
                    }
                }
                return BrainFuck.runBrainfuck(code, inputMap);
            } catch (e: BrainfuckError) {
                return "Error: " + e.message;
            } catch (e: haxe.Exception) {
                return "Error: " + e.message;
            }
        });
    }
}

class GetArgsLua {
    public function new(lua: State) {
        Lua_helper.add_callback(lua, "appGetArgs", function() {
            return GetArgs.getArgs();
        });
    }
}

class HttpClientLua {
    private static function runSync(asyncFunc: Dynamic): Dynamic {
        var result: Dynamic = null;
        var completed = false;

        // Execute the asynchronous function
        asyncFunc(function(res: Dynamic) {
            result = res;
            completed = true;
        });

        // Wait for the asynchronous operation to complete
        while (!completed) {
            Sys.sleep(0);  // Slight delay to prevent busy-waiting
        }

        return result;
    }

    public function new(lua: State) {
        Lua_helper.add_callback(lua, "hasInternet", function() {
            return runSync(function(callback) {
                HttpClient.hasInternet(callback);
            });
        });
        Lua_helper.add_callback(lua, "getRequest", function(url: String, ?headers: Map<String, String>, ?queryParams: Map<String, String>) {
            return runSync(function(callback) {
                HttpClient.getRequest(url, callback, headers, queryParams);
            });
        });
        Lua_helper.add_callback(lua, "postRequest", function(url: String, data: Dynamic, ?headers: Map<String, String>, ?queryParams: Map<String, String>) {
            return runSync(function(callback) {
                HttpClient.postRequest(url, data, callback, headers, queryParams);
            });
        });
        Lua_helper.add_callback(lua, "putRequest", function(url: String, data: Dynamic, ?headers: Map<String, String>, ?queryParams: Map<String, String>) {
            return runSync(function(callback) {
                HttpClient.putRequest(url, data, callback, headers, queryParams);
            });
        });
        Lua_helper.add_callback(lua, "deleteRequest", function(url: String, ?headers: Map<String, String>, ?queryParams: Map<String, String>) {
            return runSync(function(callback) {
                HttpClient.deleteRequest(url, callback, headers, queryParams);
            });
        });
        Lua_helper.add_callback(lua, "patchRequest", function(url: String, data: Dynamic, ?headers: Map<String, String>, ?queryParams: Map<String, String>) {
            return runSync(function(callback) {
                HttpClient.patchRequest(url, data, callback, headers, queryParams);
            });
        });
    }
}

class JsonHelperLua {
    public function new(lua: State) {
        Lua_helper.add_callback(lua, "jsonParse", function(jsonString: String) {
            return JsonHelper.Decode(jsonString);
        });
        Lua_helper.add_callback(lua, "jsonStringify", function(data: Dynamic) {
            return JsonHelper.Encode(data);
        });
    }
}

class ScreenInfoLua {
    public function new(lua: State) {
        Lua_helper.add_callback(lua, "getScreenInfo", function() {
            return ScreenInfo.getScreenInfo();
        });
    }
}

class UrlGenLua {
    public function new(lua: State) {
        Lua_helper.add_callback(lua, "createUrlGen", function(tag: String, url: String) {
            if (!tagUrlGen.exists(tag)) {
                tagUrlGen.set(tag, new UrlGen(url));
                return true;
            }
            return false;
        });
        Lua_helper.add_callback(lua, "getUrlGen", function(tag: String) {
            if (tagUrlGen.exists(tag)) {
                return tagUrlGen.get(tag);
            }
            return null;
        });
        Lua_helper.add_callback(lua, "removeUrlGen", function(tag: String) {
            if (tagUrlGen.exists(tag)) {
                tagUrlGen.remove(tag);
                return true;
            }
            return false;
        });
        Lua_helper.add_callback(lua, "clearUrlGen", function() {
            tagUrlGen.clear();
        });
        Lua_helper.add_callback(lua, "appendQueryUrlGen", function(tag: String, query: String, value: String) {
            if (tagUrlGen.exists(tag)) {
                tagUrlGen.get(tag).addQueryParam(query, value);
                return true;
            }
            return false;
        });
        Lua_helper.add_callback(lua, "appendPathUrlGen", function(tag: String, path: String) {
            if (tagUrlGen.exists(tag)) {
                tagUrlGen.get(tag).addPathSegment(path);
                return true;
            }
            return false;
        });
    }
}

class WindowManagerLua {
    public function new(lua: State) {
        Lua_helper.add_callback(lua, "createWindow", function(tag: String, attributes: Dynamic) {
            if (!windowManagerMap.exists(tag)) {
                windowManagerMap.set(tag, new WindowManager(attributes));
                return true;
            }
            return false;
        });
        Lua_helper.add_callback(lua, "getWindow", function(tag: String) {
            if (windowManagerMap.exists(tag)) {
                return windowManagerMap.get(tag).getWindow();
            }
            return null;
        });
        Lua_helper.add_callback(lua, "removeWindow", function(tag: String) {
            if (windowManagerMap.exists(tag)) {
                windowManagerMap.get(tag).getWindow().close();
                
                windowManagerMap.remove(tag);
                return true;
            }
            return false;
        });

        Lua_helper.add_callback(lua, "clearWindow", function() {
            // loop

            for (key in windowManagerMap.keys()) {
                windowManagerMap.get(key).getWindow().close();
                windowManagerMap.remove(key);
            }
        });
        
        Lua_helper.add_callback(lua, 'configWindow', (tag:String, variable:String, set:Dynamic) -> {
            if (!windowManagerMap.exists(tag)) {
                trace('Error: No WindowManager found with the tag \'$tag\'.');
                return;
            }

            var manager = windowManagerMap.get(tag);
            var window = manager.getWindow();

            try {
                Reflect.setProperty(window, variable, set);
                trace('WindowManager with tag \'$tag\' updated property \'$variable\' to \'${set}\'.');
            } catch (e:Dynamic) {
                trace('Error: Failed to update property \'$variable\' for tag \'$tag\'. Details: $e');
            }
        });
    }
}

class Init {
    public static function addLuaCallbacks(funk:State) {
        LoadHyPsychEnging(funk);
    }

    public static function LoadHyPsychEnging(lua: State) {
        new BrainFuckLua(lua);
        new GetArgsLua(lua);
        new HttpClientLua(lua);
        new JsonHelperLua(lua);
        new ScreenInfoLua(lua);
        new UrlGenLua(lua);
        new WindowManagerLua(lua);
    }
}
