package customstage;

import psychlua.HScript;
import backend.Subprocess;
import backend.MusicBeatState;
import backend.Paths;
import customstage.API;
import states.*;
import sys.io.File;
import sys.FileSystem;

class CustomStageScriptHandler {
	public var hscriptArray:Array<HScript> = [];
	public var stagePath:String;
	public var errorlist:Array<Map<String, String>>;

	public function new(path:String, errors:Array<Map<String, String>>) {
		stagePath = path;
		errorlist = errors;
	}

	public function loadScripts() {
		if (!FileSystem.exists(stagePath) || !FileSystem.isDirectory(stagePath)) {
			trace('Stage path is invalid or not a directory: $stagePath');
			return;
		}

		for (file in FileSystem.readDirectory(stagePath)) {
			if (file.endsWith(".hx")) {
				var scriptPath = Paths.join([stagePath, file]);
				initHScript(scriptPath);
			}
		}
	}

	public function injectAPI(script:HScript):Void {
		API.injectAPI(script);
	}

	public function initHScript(file:String):Void {
		if (!FileSystem.exists(file)) {
			trace('File not found: $file');
			return;
		}

		var contents:String = try {
			sys.io.File.getContent(file);
		} catch (e) {
			trace('Could not read file: $file - ${e.message}');
			return;
		}

		if (contents == null || StringTools.trim(contents).length == 0) {
			trace('Empty or whitespace-only file: $file');
			return;
		}

		try {
			var script = new HScript(null, file);
			injectAPI(script);
			APIScriptHandler.tryCall(script, "onCreate", null);
			hscriptArray.push(script);
			trace('Loaded script: $file');
		} catch (e:haxe.Exception) {
			trace('HScript error: ' + e.message);
			var map = new Map<String, String>();
			map.set("file", file);
			map.set("error", e.message);
			errorlist.push(map);
		}
	}

	public function call(func:String, args:Array<Dynamic> = null) {
		for (script in hscriptArray) {
			APIScriptHandler.tryCall(script, func, args);
		}
	}

	public function destroy() {
		for (script in hscriptArray) {
			APIScriptHandler.tryCall(script, "onDestroy");
			script.destroy();
		}
		hscriptArray.resize(0);
	}
}
