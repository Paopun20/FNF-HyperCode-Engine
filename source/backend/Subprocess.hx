package backend;

import sys.thread.Thread;

class Subprocess {
    public static function startThread(haxefunc:() -> Void):Thread {
        if (haxefunc == null) {
            throw "Provided function is null!";
        }

        try {
            var thread = Thread.create(() -> {
                try {
                    return haxefunc();
                } catch (e) {
                    trace("Exception inside thread: " + e);
                }
            });

            if (thread == null) {
                throw "Failed to create thread!";
            }

            return thread;
        } catch (e) {
            trace("Exception while creating thread: " + e);
            return null;
        }
    }
}
