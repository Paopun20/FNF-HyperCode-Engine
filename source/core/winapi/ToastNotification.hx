package core.winapi;

import sys.io.Process;

class ToastNotification {
    #if (windows && desktop)
    public static function showToast(title:String, message:String, duration:Int):Void {
        var escapedTitle = title.replace("\"", "`\"");
        var escapedMessage = message.replace("\"", "`\"");

        var template = "$template";
        var xml = "$xml";
        var textNodes = "$textNodes";
        var toast = "$toast";
        var notifier = "$notifier";
        var nul = "$null";

        var psCommand = 'powershell -NoProfile -Command "' +
            '[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null; ' +
            '$template = [Windows.UI.Notifications.ToastTemplateType]::ToastText02; ' +
            '$xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($template); ' +
            '$textNodes = $xml.GetElementsByTagName(\'text\'); ' +
            '$textNodes.Item(0).AppendChild($xml.CreateTextNode(\\\"' + escapedTitle + '\\\")) > $nul; ' +
            '$textNodes.Item(1).AppendChild($xml.CreateTextNode(\\\"' + escapedMessage + '\\\")) > $nul; ' +
            '$toast = New-Object Windows.UI.Notifications.ToastNotification $xml; ' +
            '$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier(\\\"Haxe App\\\"); ' +
            '$notifier.Show($toast); ' +
            'Start-Sleep -Seconds ' + duration + '"';

        // Launch PowerShell via CMD
        var result = new Process("cmd", ["/C", psCommand]);
        result.exitCode();
    }
    #else
    public static function showToast(title:String, message:String, duration:Int):Void {
        trace("Toast notifications are not supported on this platform.");
    }
    #end
}
