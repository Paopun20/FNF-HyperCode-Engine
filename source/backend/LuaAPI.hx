package source.backend;

class LuaAPI {
    public var lua:State = null;
    
    public function new(lua:State) {
		lua = LuaL.newstate();
		LuaL.openlibs(lua);

		this.scriptName = scriptName.trim();
        
        var myFolder:Array<String> = this.scriptName.split('/');
		#if MODS_ALLOWED
		if(myFolder[0] + '/' == Paths.mods() && (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) //is inside mods folder
			this.modFolder = myFolder[1];
		#end
    }

    public function getState():LuaAPI {
        return this;
    }
    
    public function getVariables():Map<String, Dynamic> {
        return this.variables;
    }
}