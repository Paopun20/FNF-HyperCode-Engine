package;

/**
 * Centralized configuration for the game engine.
 * Contains version info, URLs, and development flags.
 */
class EngineConfig {
    //======================
    // Version Information
    //======================
    
    public static inline final ENGINR_NAME:String = "HyPsych";
    public static inline final VERSION:String = "Indev 23042025";
    public static inline final ENGINE_URL:String = "https://github.com/Paopun20/FNF-HyPsych-Engine";
    public static inline final GITVERSION:String = "https://raw.githubusercontent.com/Paopun20/FNF-HyPsych-Engine/main/gitVersion.txt";

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