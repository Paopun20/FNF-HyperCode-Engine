package states.customstage;

import backend.Mods;
import backend.Paths;
import sys.FileSystem;
import psychlua.HScript;

class CustomStageLoader {
	public static function haveCustomStage(stageName:String):Bool {
		Mods.loadTopMod();
		var stagePath = Paths.customStage(stageName);
		if (FileSystem.exists(stagePath) && FileSystem.isDirectory(stagePath)) {
			for (file in FileSystem.readDirectory(stagePath)) {
				#if HSCRIPT_ALLOWED
				if (file.endsWith(".hx")) return true;
				#end
			}
		}
		return false;
	}

    public static function haveModifiedStage(stageName:String):Bool {
		Mods.loadTopMod();
		var fileMod = Paths.vanillaModStage(stageName); // ex output path: "mod/yourmodname/customstage/vanillaModStages/TitleState.hx"
        // if file type == hx
		if (FileSystem.exists(fileMod) && !FileSystem.isDirectory(fileMod)) {
            #if HSCRIPT_ALLOWED
			if (fileMod.endsWith(".hx")) return true;
			#end
        }
		return false;
	}
}