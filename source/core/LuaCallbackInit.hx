package core;

import core.BrainFuck;
import core.GetArgs;
import core.HttpClient;
import core.JsonHelper;
import core.ScreenInfo;
import core.UrlGen;
#if desktop import core.WindowManager; #end
#if (windows && cpp) import core.winapi.ToastNotification; #end
import states.PlayState;

import haxe.ds.IntMap;

var tagUrlGen: Map<String, UrlGen> = new Map();
#if desktop var tagWindowManager:Map<String, WindowManager> = new Map(); #end

class BrainFuckLua {
    public function new(lua: State) {
		Lua_helper.add_callback(lua, "runBrainFuckCode", function(code: String, input = ""): String {
			var inputMap = new IntMap<Int>();
			try {
				if (input != "") {
					var inputValues = input.split(",").map(Std.parseInt);
					for (i in 0...inputValues.length) inputMap.set(i, inputValues[i]);
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
		Lua_helper.add_callback(lua, "appGetArgs", () -> GetArgs.getArgs());
    }
}

class HttpClientLua {
    /**
     * Converts async HTTP calls to synchronous ones for Lua
     * @param asyncFunc The async function that takes (Bool,Dynamic)->Void callback
     * @return Map<String, Dynamic> with success/result fields
     */
    private static function runSync(asyncFunc:((Bool, Dynamic)->Void)->Void):Map<String, Dynamic> {
        var result:Dynamic = null;
        var completed = false;
        var success = false;

        asyncFunc(function(s:Bool, res:Dynamic) {
            completed = true;
            success = s;
            result = res;
        });

        while (!completed) Sys.sleep(0.01);

        var response = new Map<String, Dynamic>();
        response.set("success", success);
        response.set("result", result);
        trace("Response: " + response);
        return response;
    }

    public function new(lua:State) {
        // Helper to convert Lua tables to Map
        function parseHeaders(headers:Dynamic):Map<String, Dynamic> {
            if (headers == null) return null;
            var map = new Map<String, Dynamic>();
            for (key in Reflect.fields(headers)) {
                map.set(key, Reflect.field(headers, key));
            }
            return map;
        }

        // Standard HTTP methods
        Lua_helper.add_callback(lua, "hasInternet", () -> 
            return runSync(function(cb:(Bool, Dynamic)->Void) {
                HttpClient.hasInternet(function(b:Bool) cb(b, null));
            })
        );

        Lua_helper.add_callback(lua, "getRequest", (url:String, ?headers:Dynamic, ?queryParams:Dynamic) -> 
            return runSync(function(cb:(Bool, Dynamic)->Void) {
                HttpClient.getRequest(url, cb, parseHeaders(headers), parseHeaders(queryParams));
            })
        );

        Lua_helper.add_callback(lua, "postRequest", (url:String, data:Dynamic, ?headers:Dynamic, ?queryParams:Dynamic) -> 
            return runSync(function(cb:(Bool, Dynamic)->Void) {
                HttpClient.postRequest(url, data, cb, parseHeaders(headers), parseHeaders(queryParams));
            })
        );

        Lua_helper.add_callback(lua, "putRequest", (url:String, data:Dynamic, ?headers:Dynamic, ?queryParams:Dynamic) -> 
            return runSync(function(cb:(Bool, Dynamic)->Void) {
                HttpClient.putRequest(url, data, cb, parseHeaders(headers), parseHeaders(queryParams));
            })
        );

        Lua_helper.add_callback(lua, "deleteRequest", (url:String, ?headers:Dynamic, ?queryParams:Dynamic) -> 
            return runSync(function(cb:(Bool, Dynamic)->Void) {
                HttpClient.deleteRequest(url, cb, parseHeaders(headers), parseHeaders(queryParams));
            })
        );

        Lua_helper.add_callback(lua, "patchRequest", (url:String, data:Dynamic, ?headers:Dynamic, ?queryParams:Dynamic) -> 
            return runSync(function(cb:(Bool, Dynamic)->Void) {
                HttpClient.patchRequest(url, data, cb, parseHeaders(headers), parseHeaders(queryParams));
            })
        );

        // Streaming implementation
        Lua_helper.add_callback(lua, "streamRequest", (tag:String, url:String, data:Dynamic, headers:Dynamic) -> {
            function notifyLua(success:Bool, finished:Bool, content:Dynamic) {
                if (content == null) content = "";
                if (tag == null) return;
                for (l in PlayState.instance.luaArray) {
                    if (l != null) {
                        l.call("onStreamEvent", [tag, success, finished, content]);
                    }
                }
            }

            HttpClient.streamRequest(
                url,
                data,
                function(success, finished, response) {
                    if (!success) {
                        notifyLua(false, true, response.error);
                        return;
                    }

                    if (finished) {
                        notifyLua(true, true, response.finish_reason);
                    } else {
                        notifyLua(true, false, response.chunk);
                    }
                },
                parseHeaders(headers)
            );
        });
    }
}

    

// hasInternet getRequest postRequest putRequest deleteRequest patchRequest

class JsonHelperLua {
    public function new(lua: State) {
		Lua_helper.add_callback(lua, "jsonParse", jsonString -> JsonHelper.decode(jsonString));
		Lua_helper.add_callback(lua, "jsonStringify", data -> JsonHelper.encode(data));
    }
}

class ScreenInfoLua {
    public function new(lua: State) {
		Lua_helper.add_callback(lua, "getScreensInfo", () -> ScreenInfo.getScreenResolutions(true));
		Lua_helper.add_callback(lua, "getMainScreenInfo", () -> ScreenInfo.getScreenResolutions(false));
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
                return tagUrlGen.get(tag).generate();
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

#if desktop
class WindowManagerLua {
    public function new(lua: State) {
        Lua_helper.add_callback(lua, "createWindow", function(tag: String, attributes: Dynamic) {
            if (!tagWindowManager.exists(tag)) {
                tagWindowManager.set(tag, new WindowManager(attributes));
                return true;
            }
            return false;
        });
        Lua_helper.add_callback(lua, "getWindow", function(tag: String) {
            if (tagWindowManager.exists(tag)) {
                return tagWindowManager.get(tag).getWindow();
            }
            return null;
        });
        Lua_helper.add_callback(lua, "removeWindow", function(tag: String) {
            if (tagWindowManager.exists(tag)) {
                tagWindowManager.get(tag).getWindow().close();
                tagWindowManager.remove(tag);
                return true;
            }
            return false;
        });

        Lua_helper.add_callback(lua, "clearWindow", function() {
            for (key in tagWindowManager.keys()) {
                tagWindowManager.get(key).getWindow().close();
            }

            tagWindowManager.clear();
        });
        
        Lua_helper.add_callback(lua, 'configWindow', (tag:String, variable:String, set:Dynamic) -> {
            if (!tagWindowManager.exists(tag)) {
                //trace('Error: No WindowManager found with the tag \'$tag\'.');
                return;
            }
            
            try {
                Reflect.setProperty(tagWindowManager.get(tag).getWindow(), variable, set);
                //trace('WindowManager with tag \'$tag\' updated property \'$variable\' to \'${set}\'.');
            } catch (e:Dynamic) {
                //trace('Error: Failed to update property \'$variable\' for tag \'$tag\'. Details: $e');
                
            }
        });
    }
}
#end

#if (windows && cpp)
class ToastNotificationLua {
    public function new(lua: State) {
        Lua_helper.add_callback(lua, "toastNotification", function(title:String, message:String, duration:Int) {
            ToastNotification.showToast(title, message, duration);
        });
    }
}
#end

class LuaCallbackInit {
    public static function addLuaCallbacks(funk:State) {
        loadcore(funk);
    }

    public static function loadcore(lua: State) {
        new BrainFuckLua(lua);
        new GetArgsLua(lua);
        new HttpClientLua(lua);
        new JsonHelperLua(lua);
        new ScreenInfoLua(lua);
        new UrlGenLua(lua);
        #if desktop new WindowManagerLua(lua); #end
        #if (windows && cpp) new ToastNotificationLua(lua); #end
    }
}
