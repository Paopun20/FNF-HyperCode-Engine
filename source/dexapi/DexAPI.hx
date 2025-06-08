package dexapi;

import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import Sys;

import backend.UUID;

/**
 * DexAPI provides utility functions to interact with the Windows operating system.
 * All features are safe and focus on creating fun, low-level OS interactions.
 */
class DexAPI {
    /**
     * Creates a file with the given contents on the user's desktop.
     */
    public static function createDesktopFile(filename:String="temp.txt", contents:Null<String>=null):Void {
        var desktopPath = getDesktopPath();
        if (desktopPath == null) {
            throw "Could not find desktop path.";
        }

        var fullPath = Path.join([desktopPath, filename]);
        File.saveContent(fullPath, contents);
    }

    /**
     * Opens a URL in the default web browser.
     */
    public static function openWebsite(url:String):Void {
        Sys.command('start "" "$url"');
    }

    /**
     * Returns the current Windows username.
     */
    public static function getUsername():String {
        return Sys.getEnv("USERNAME");
    }
    /**
     * Lists the files on the user's desktop.
     */
    public static function listDesktopFiles():Array<String> {
        var desktopPath = getDesktopPath();
        return (desktopPath != null && FileSystem.exists(desktopPath)) ? FileSystem.readDirectory(desktopPath) : [];
    }

    /**
     * Creates a hidden file on the user's desktop.
     */
    public static function makeHiddenFileOnDesktop(filename:String, contents:Null<String>=null):Void {
        var desktopPath = getDesktopPath();
        if (desktopPath == null) {
            throw "Could not find desktop path.";
        }

        var fullPath = Path.join([desktopPath, filename]);
        File.saveContent(fullPath, contents);
        Sys.command('attrib +h "$fullPath"');
    }

    /**
     * Opens a temporary file in Notepad with the given contents.
     */
    public static function openInNotepad(contents:String, filename:Null<String> = null):Void {
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
    }

    /**
     * Returns the current operating system name.
     */
    public static function getOSVersion():String {
        return Sys.systemName();
    }

    /**
     * Internal helper to get the Windows Desktop path.
     */
    private static function getDesktopPath():String {
        var userProfile = Sys.getEnv("USERPROFILE");
        if (userProfile == null) return null;
        return Path.join([userProfile, "Desktop"]);
    }
}