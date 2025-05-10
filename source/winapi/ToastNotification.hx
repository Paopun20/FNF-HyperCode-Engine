#if (windows)
package winapi;

import sys.io.Process;
import sys.io.File;
import sys.FileSystem;
import backend.UUID;
import backend.Subprocess;

class ToastNotification
{
	public static function showToast(title:String, message:String):Void
	{
		try
		{
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
    $Toast.Tag = \"HyperCodeEngine\"
    $Toast.Group = \"HyperCodeEngine\"
    $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

    $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier(\"HyperCode Engine\")
    $Notifier.Show($Toast);
}
Show-Notification -ToastTitle \""
				+ title
				+ "\" -ToastText \""
				+ message
				+ "\"";

			var tempDir = Sys.systemName() == "Windows" ? Sys.getEnv("TEMP") + '\\HyperCode' : Sys.getEnv("TEMP") + '/HyperCode';
			if (!FileSystem.exists(tempDir))
				FileSystem.createDirectory(tempDir);
			var tempFile = tempDir + (Sys.systemName() == "Windows" ? ('\\toast_' + UUID.generate() + '.ps1') : ('/toast_' + UUID.generate() + '.ps1'));

			File.saveContent(tempFile, script);

			Subprocess.run(() ->
			{
				try
				{
					var powershell = new Process("cmd /c start /realtime /min powershell -ExecutionPolicy Bypass -NoProfile -File " + tempFile);
					haxe.Timer.delay(function()
					{
						try
						{
							if (FileSystem.exists(tempFile))
								FileSystem.deleteFile(tempFile);
						}
						catch (e)
						{
							trace("Error deleting toast script: " + e);
						}
					}, 10000);
				}
				catch (e)
				{
					trace("Error launching PowerShell toast script: " + e);
				}
			});
		}
		catch (e)
		{
			trace("Error showing toast notification: " + e);
		}
	}
}
#end
