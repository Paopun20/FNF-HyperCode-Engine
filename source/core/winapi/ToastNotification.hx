#if (windows)
package core.winapi;

import sys.io.Process;
import sys.io.File;
import sys.FileSystem;
import core.UUID;
import backend.Subprocess;

class ToastNotification {
    public static function showToast(title:String, message:String, duration:Int):Void {
        // Escape special characters
        title = title.replace('"', '`"').replace('`', '``');
        message = message.replace('"', '`"').replace('`', '``');

        var script = "
            [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null;
            $template = [Windows.UI.Notifications.ToastTemplateType]::ToastText02;
            $xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($template);
            $xml.GetElementsByTagName(\"text\")[0].AppendChild($xml.CreateTextNode(\"" + title + "\"));
            $xml.GetElementsByTagName(\"text\")[1].AppendChild($xml.CreateTextNode(\"" + message + "\"));
            $toast = [Windows.UI.Notifications.ToastNotification]::new($xml);
            $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier(\"HaxeApp\");
            $notifier.Show($toast);
        ";

        // Use GUID
        var tempFile = 'toast_' + UUID.generate() + '.ps1';
        File.saveContent(tempFile, script);

        // Run PowerShell
        try {
            Subprocess.run(() -> {
                var p = new Process('powershell', ['-ExecutionPolicy', 'Bypass', '-NoProfile', '-File', tempFile]);
                p.close();
            });
        } catch(e) {
            trace('Failed to show toast: ' + e);
        }

        // Clean up
        try {
            FileSystem.deleteFile(tempFile);
        } catch(e) {}
    }
}
#end
