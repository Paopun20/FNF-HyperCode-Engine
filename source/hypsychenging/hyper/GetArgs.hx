package hypsychenging.hyper;
import Sys;

class GetArgs {
    public static function getArgs():Array<String> {
        #if (desktop && cpp)
        return Sys.args();
        #else
        trace("⚠️ Sys.args() not supported on this platform.");
        return [];
        #end
    }
}
