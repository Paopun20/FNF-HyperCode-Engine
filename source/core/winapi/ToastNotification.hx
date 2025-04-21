#if (windows && desktop)
package core.winapi;

import sys.io.Process;

class ToastNotification {
    /**
     * Shows a Windows toast notification
     * @param title Notification title
     * @param message Notification message
     * @param duration Duration in seconds (1-3600)
     */
    public static function showToast(title:String, message:String, duration:Int = 5):Void {
        // Validate duration
        if (duration < 1) duration = 1;
        if (duration > 3600) duration = 3600;

        // Escape special characters
        var escapedTitle = escapeForPowerShell(title);
        var escapedMessage = escapeForPowerShell(message);
        
        var template = "$template";
        var xml = "$xml";
        var textNodes = "$textNodes";
        var toast = "$toast";
        var notifier = "$notifier";
        var nul = "$null";

        // Create PowerShell script
        var psScript = '
            Add-Type -AssemblyName System.Runtime.WindowsRuntime
            $null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
            
            $template = [Windows.UI.Notifications.ToastTemplateType]::ToastText02
            $xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($template)
            
            $textNodes = $xml.GetElementsByTagName("text")
            $null = $textNodes.Item(0).AppendChild($xml.CreateTextNode("$escapedTitle"))
            $null = $textNodes.Item(1).AppendChild($xml.CreateTextNode("$escapedMessage"))
            
            $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
            $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Haxe App")
            $notifier.Show($toast)
            
            Start-Sleep -Seconds $duration
        ';

        // Execute PowerShell safely
        try {
            var process = new Process("cmd", [
                "/C",
                "Start",
                "powershell",
                "-NoProfile",
                "-ExecutionPolicy", "Bypass",
                "-Command", psScript
            ]);
            
            var exitCode = process.exitCode();
            if (exitCode != 0) {
                trace('Toast notification failed with exit code: $exitCode');
            }
            process.close();
        } catch (e:Dynamic) {
            trace('Failed to show toast notification: $e');
        }
    }

    /**
     * Escapes text for PowerShell string literals
     */
    private static function escapeForPowerShell(text:String):String {
        if (text == null) return "";
        return text
            .replace("\\", "\\\\")
            .replace("`", "``")
            .replace("$", "`$")
            .replace("\"", "`\"")
            .replace("'", "`'");
    }
}
#end