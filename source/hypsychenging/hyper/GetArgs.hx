package hypsychenging.hyper;

class GetArgs {
    public static function getArgs(): Map<Int, String> {
        var args = Sys.args();
        var argsMap = new Map<Int, String>();
        for (i in 0...args.length) argsMap.set(i + 1, args[i]);
        return argsMap;
    }
}