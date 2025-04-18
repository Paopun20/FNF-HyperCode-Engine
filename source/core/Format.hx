package core;

class FormatHelper {
    private static final SUFFIXES = ["","K", "M", "B", "T", "Q"];

    public static function format(value:Float):String {
        var index = 0;
        while (value >= 1000 && index < SUFFIXES.length - 1) {
            value /= 1000;
            index++;
        }

        var formatted = CoolUtil.floorDecimal(value, 2);
        return '${formatted}${SUFFIXES[index]}';
    }

    public static function formatTime(seconds:Float):String {
        var hours = Math.floor(seconds / 3600);
        var minutes = Math.floor((seconds % 3600) / 60);
        var remainingSeconds = Math.floor(seconds % 60);

        var formattedHours = (hours < 10) ? '0${hours}' : '$hours';
        var formattedMinutes = (minutes < 10) ? '0${minutes}' : '$minutes';
        var formattedSeconds = (remainingSeconds < 10) ? '0${remainingSeconds}' : '$remainingSeconds';

        if (hours > 0) {
            return '${formattedHours}:${formattedMinutes}:${formattedSeconds}';
        } else {
            return '${formattedMinutes}:${formattedSeconds}';
        }
    }
}
