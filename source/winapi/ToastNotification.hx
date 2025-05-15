#if (windows)
package winapi;

import sys.io.Process;
import sys.io.File;
import sys.FileSystem;
import backend.UUID;
import backend.Subprocess;

// from https://discord.com/channels/922849922175340586/1295416358430838845
@:cppFileCode('
#include <stdlib.h>
#include <stdio.h>
#include <windows.h>
#include <winuser.h>
#include <dwmapi.h>
#include <strsafe.h>
#include <shellapi.h>
#include <iostream>
#include <string>
// Link the required libraries
#pragma comment(lib, "Shell32.lib")
// Function prototype for SetCurrentProcessExplicitAppUserModelID
extern "C" HRESULT WINAPI SetCurrentProcessExplicitAppUserModelID(PCWSTR AppID);
NOTIFYICONDATA m_NID;
// Constants for notification
const int NOTIFICATION_ID = 1001;
const wchar_t* APP_ID = L"com.psychengine.custommod";
// Set a custom AppUserModelID for the game process
void SetAppID() {
    HRESULT hr = SetCurrentProcessExplicitAppUserModelID(APP_ID);
    if (FAILED(hr)) {
        std::cerr << "Error: Failed to set AppUserModelID." << std::endl;
    }
}
// Initialize NOTIFYICONDATA structure
void InitNotifyIconData(HWND hWnd) {
    memset(&m_NID, 0, sizeof(m_NID));
    m_NID.cbSize = sizeof(NOTIFYICONDATA);
    m_NID.hWnd = hWnd;
    m_NID.uID = NOTIFICATION_ID;
    m_NID.uFlags = NIF_MESSAGE | NIF_INFO | NIF_TIP;
    m_NID.uCallbackMessage = WM_USER + 1;
    m_NID.dwInfoFlags = NIIF_INFO;
    m_NID.uVersion = NOTIFYICON_VERSION_4;
    StringCchCopy(m_NID.szTip, sizeof(m_NID.szTip) / sizeof(TCHAR), "Psych Engine Notification");
}
// Show the notification
bool ShowNotification(const std::string& title, const std::string& desc) {
    SetAppID(); // Ensure the custom AppUser ModelID is set
    HWND hWnd = GetForegroundWindow(); // Use the current game window
    InitNotifyIconData(hWnd);
    StringCchCopy(m_NID.szInfoTitle, sizeof(m_NID.szInfoTitle) / sizeof(TCHAR), title.c_str());
    StringCchCopy(m_NID.szInfo, sizeof(m_NID.szInfo) / sizeof(TCHAR), desc.c_str());
    if (!Shell_NotifyIcon(NIM_ADD, &m_NID)) {
        std::cerr << "Error: Failed to add notification icon." << std::endl;
        return false;
    }
    // Modify the notification
    if (!Shell_NotifyIcon(NIM_MODIFY, &m_NID)) {
        std::cerr << "Error: Failed to modify notification." << std::endl;
        return false;
    }
    // Clean up after showing the notification
return Shell_NotifyIcon(NIM_DELETE, &m_NID);
}
')
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
	
	@:functionCode('
        return ShowNotification(title.c_str(), message.c_str());
    ')
	public static function showToastButCpp(title:String, message:String) {
		return true;
		// Call the C++ function to show the notification
	}
}
#end
