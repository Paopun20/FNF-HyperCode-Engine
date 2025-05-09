#if (windows)
package winapi;

import sys.io.Process;
import sys.io.File;
import sys.FileSystem;
import backend.UUID;
import backend.Subprocess;

class ToastNotification {
    public static function showToast(title:String, message:String, duration:Int):Void {
        // Escape special characters
        title = title.replace('"', '`"').replace('`', '``');
        message = message.replace('"', '`"').replace('`', '``');

        var script = "
function Show-Notification {
    [cmdletbinding()]
    Param (
        [string]
        $ToastTitle,
        [string]
        [parameter(ValueFromPipeline)]
        $ToastText
    )

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    $RawXml = [xml] $Template.GetXml()
    ($RawXml.toast.visual.binding.text|where {$_.id -eq \"1\"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
    ($RawXml.toast.visual.binding.text|where {$_.id -eq \"2\"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null

    $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $SerializedXml.LoadXml($RawXml.OuterXml)

    $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
    $Toast.Tag = \"PowerShell\"
    $Toast.Group = \"PowerShell\"
    $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

    $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier(\"PowerShell\")
    $Notifier.Show($Toast);
}
Show-Notification -ToastTitle " + title + " -ToastText " + message;
        // Use GUID
        var tempFile = Sys.getEnv("TEMP") + '/Hy/toast_' + UUID.generate() + '.ps1';
        File.saveContent(tempFile, script);

        // Run PowerShell
        try {
            new Process('powershell', ['-ExecutionPolicy', 'Bypass', '-NoProfile', '-File', tempFile]);
        } catch(e) {
            trace('Failed to show toast: ' + e);
        }
    }
}
#end
