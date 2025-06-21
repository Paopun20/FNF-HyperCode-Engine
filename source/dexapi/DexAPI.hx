package dexapi;

import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import Sys;

import backend.UUID;

/**
 * DexAPI provides utility functions to interact with the operating system (some os not supported).
 * All features are safe and focus on creating fun, low-level OS interactions.
 */
class DexAPI {
    /**
     * Creates a file with the given contents on the user's desktop.
     */
    public static function createDesktopFile(filename:String="temp.txt", contents:Null<String>=null):Void {
        #if windows
        var desktopPath = getDesktopPath();
        if (desktopPath == null) {
            throw "Could not find desktop path.";
        }

        var fullPath = Path.join([desktopPath, filename]);
        File.saveContent(fullPath, contents);
        #else
        throw "createDesktopFile is only supported on Windows.";
        #end
    }

    /**
     * Opens a URL in the default web browser.
     */
    public static function openWebsite(url:String):Void {
        #if windows
        Sys.command('start "" "$url"');
        #else
        throw "openWebsite is only supported on Windows.";
        #end
    }

    /**
     * Returns the current Windows username.
     */
    public static function getUsername():String {
        #if windows
        return Sys.getEnv("USERNAME");
        #else
        throw "getUsername is only supported on Windows.";
        #end
    }
    /**
     * Lists the files on the user's desktop.
     */
    public static function listDesktopFiles():Array<String> {
        #if windows
        var desktopPath = getDesktopPath();
        return (desktopPath != null && FileSystem.exists(desktopPath)) ? FileSystem.readDirectory(desktopPath) : [];
        #else
        throw "listDesktopFiles is only supported on Windows.";
        return [];
        #end
    }

    /**
     * Creates a hidden file on the user's desktop.
     */
    public static function makeHiddenFileOnDesktop(filename:String, contents:Null<String>=null):Void {
        #if windows
        var desktopPath = getDesktopPath();
        if (desktopPath == null) {
            throw "Could not find desktop path.";
        }

        var fullPath = Path.join([desktopPath, filename]);
        File.saveContent(fullPath, contents);
        Sys.command('attrib +h "$fullPath"');
        #else
        throw "makeHiddenFileOnDesktop is only supported on Windows.";
        #end
    }

    /**
     * Opens a temporary file in Notepad with the given contents.
     */
    public static function openInNotepad(contents:String, filename:Null<String> = null):Void {
        #if windows
        var desktopPath = getDesktopPath();
        if (desktopPath == null) {
            throw "Could not find desktop path.";
        }

        var tempPath = Path.join([desktopPath, filename != null ? filename : 'temp_${UUID.generate()}.txt']);
        if (FileSystem.exists(tempPath)) FileSystem.deleteFile(tempPath);
        File.saveContent(tempPath, contents);
        Sys.command('start notepad "${tempPath}"');
        haxe.Timer.delay(function() {
            if (FileSystem.exists(tempPath))
                FileSystem.deleteFile(tempPath);
        }, 10000);
        #else
        throw "openInNotepad is only supported on Windows.";
        #end
    }

    /**
     * Returns the current operating system name.
     */
    public static function getOSVersion():String {
        return Sys.systemName();
    }

    /**
     * Shuts down the computer.
     * Note: This command may require elevated permissions and is not supported on all platforms.
     */
    public static function shutdownComputer():Void {
        #if desktop
            #if windows
            Sys.command('shutdown /s /t 0');
            #end
            #if linux
            Sys.command('shutdown -h now');
            #end
            #if mac
            Sys.command('sudo shutdown -h now');
            #end
            return;
        #end
        throw "Shutdown command executed. Is not supported on this platform or requires elevated permissions.";
    }

    /**
     * Internal helper to get the Windows Desktop path.
     */
    private static function getDesktopPath():String {
        var userProfile = Sys.getEnv("USERPROFILE");
        if (userProfile == null) return null;
        return Path.join([userProfile, "Desktop"]);
    }

    /**
     * Internal helper to get the Windows Documents path.
     */
    private static function getDocumentsPath():String {
        var userProfile = Sys.getEnv("USERPROFILE");
        if (userProfile == null) return null;
        return Path.join([userProfile, "Documents"]);
    }
    /**
     * Internal helper to get the Windows Downloads path.
     */
    private static function getDownloadsPath():String {
        var userProfile = Sys.getEnv("USERPROFILE");
        if (userProfile == null) return null;
        return Path.join([userProfile, "Downloads"]);
    }
    /**
     * Internal helper to get the Windows Pictures path.
     */
    private static function getPicturesPath():String {
        var userProfile = Sys.getEnv("USERPROFILE");
        if (userProfile == null) return null;
        return Path.join([userProfile, "Pictures"]);
    }
    /**
     * Internal helper to get the Windows Music path.
     */
    private static function getMusicPath():String {
        var userProfile = Sys.getEnv("USERPROFILE");
        if (userProfile == null) return null;
        return Path.join([userProfile, "Music"]);
    }
    /**
     * Internal helper to get the Windows Videos path.
     */
    private static function getVideosPath():String {
        var userProfile = Sys.getEnv("USERPROFILE");
        if (userProfile == null) return null;
        return Path.join([userProfile, "Videos"]);
    }
}