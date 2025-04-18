package core;

import core.BrainFuck;
import core.GetArgs;
import core.HttpClient;
import core.JsonHelper;
import core.ScreenInfo;
import core.UrlGen;
#if desktop import core.WindowManager; #end
#if windows import core.winapi.ToastNotification; #end

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
			return runSync(cb -> HttpClient.hasInternet(cb));
		});

		Lua_helper.add_callback(lua, "getRequest", function(url, ?headers, ?queryParams) {
			return runSync(cb -> HttpClient.getRequest(url, cb, headers, queryParams));
		});

		Lua_helper.add_callback(lua, "postRequest", function(url, data, ?headers, ?queryParams) {
			return runSync(cb -> HttpClient.postRequest(url, data, cb, headers, queryParams));
		});

		Lua_helper.add_callback(lua, "putRequest", function(url, data, ?headers, ?queryParams) {
			return runSync(cb -> HttpClient.putRequest(url, data, cb, headers, queryParams));
		});

		Lua_helper.add_callback(lua, "deleteRequest", function(url, ?headers, ?queryParams) {
			return runSync(cb -> HttpClient.deleteRequest(url, cb, headers, queryParams));
		});

		Lua_helper.add_callback(lua, "patchRequest", function(url, data, ?headers, ?queryParams) {
			return runSync(cb -> HttpClient.patchRequest(url, data, cb, headers, queryParams));
		});
    }
}

class JsonHelperLua {
    public function new(lua: State) {
		Lua_helper.add_callback(lua, "jsonParse", jsonString -> JsonHelper.decode(jsonString));
		Lua_helper.add_callback(lua, "jsonStringify", data -> JsonHelper.encode(data));
    }
}

class ScreenInfoLua {
    public function new(lua: State) {
		Lua_helper.add_callback(lua, "getScreensInfo", () -> ScreenInfo.getScreensResolutions());
		Lua_helper.add_callback(lua, "getMainScreenInfo", () -> ScreenInfo.getMainScreenResolution());
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

#if windows
class ToastNotificationLua {
    public function new(lua: State) {
        Lua_helper.add_callback(lua, "toastNotification", function(title:String, message:String, duration:Int, iconPath:String) {
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
        #if windows new ToastNotificationLua(lua); #end
    }
}
