package;

/**
 * Centralized configuration for the game engine.
 * Contains version info, URLs, and development flags.
 */
class EngineConfig {
    //======================
    // Version Information
    //======================
    
    public static inline final ENGINR_NAME:String = "HyperCode";
    public static inline final VERSION:String = "Indev 27042025";
    public static inline final ENGINE_URL:String = "https://github.com/Paopun20/FNF-HyperCode-Engine";
    public static inline final GITVERSION:String = "https://raw.githubusercontent.com/Paopun20/FNF-HyperCode-Engine/main/gitVersion.txt";

    //======================
    // Integration IDs
    //======================
    public static inline final DC_CLIENTID:String = "1358806783442817155";

    //======================
    // Build Flags
    //======================
    #if NotDeveloper
        public static inline final IS_DEVELOPER:Bool = false;
    #else
        public static inline final IS_DEVELOPER:Bool = true;
    #end
}