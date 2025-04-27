package gui;

import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;
import flixel.util.FlxStringUtil;

/**
 * Displays real-time FPS and memory usage information.
 * 
 * Features:
 * - Current FPS counter
 * - Memory usage display
 * - Automatic color coding for performance issues
 * - Customizable position and text color
 * - HScript override support
 */
class FPSCounter extends TextField
{
    //======================================================
    // Configuration
    //======================================================
    static final UPDATE_INTERVAL:Int = 50; // Update interval in milliseconds
    
    //======================================================
    // Properties
    //======================================================
    /**
     * Current frames per second (read-only)
     */
    public var currentFPS(default, null):Int = 0;
    
    /**
     * Current memory usage in megabytes (read-only)
     * Note: This shows garbage collector memory, not total program memory
     */
    public var memoryMegas(get, never):Float;
    
    //======================================================
    // Internal State
    //======================================================
    private var times:Array<Float> = [];
    private var deltaTimeout:Float = 0.0;
    
    //======================================================
    // Initialization
    //======================================================
    /**
     * Create a new FPS counter display
     * 
     * @param x X position (default: 10)
     * @param y Y position (default: 10)
     * @param color Text color (default: 0x000000)
     */
    public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
    {
        super();
        
        // Position setup
        this.x = x;
        this.y = y;
        
        // Text field configuration
        selectable = false;
        mouseEnabled = false;
        defaultTextFormat = new TextFormat("_sans", 14, color);
        autoSize = LEFT;
        multiline = true;
        text = "FPS: ";
    }
    
    //======================================================
    // Frame Update
    //======================================================
    private override function __enterFrame(deltaTime:Float):Void
    {
        // Track frame timestamps
        final now:Float = haxe.Timer.stamp() * 1000;
        times.push(now);
        
        // Remove timestamps older than 1 second
        while (times[0] < now - 1000)
            times.shift();
        
        // Throttle updates to improve performance
        if (deltaTimeout < UPDATE_INTERVAL) {
            deltaTimeout += deltaTime;
            return;
        }
        
        // Calculate FPS (capped at engine's update framerate)
        currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
        
        updateText();
        deltaTimeout = 0.0;
    }
    
    //======================================================
    // Text Display
    //======================================================
    /**
     * Update the displayed text (can be overridden in HScript)
     */
    public dynamic function updateText():Void
    {
        text = 'FPS: $currentFPS\n'
             + 'Memory: ${format(memoryMegas)}';
        
        // Color coding for performance issues
        textColor = 0xFFFFFFFF;
        if (currentFPS < FlxG.drawFramerate * 0.5)
            textColor = 0xFFFF0000; // Red when below 50% target framerate
    }
    
    //======================================================
    // Memory Calculation
    //======================================================
    inline function get_memoryMegas():Float
    {
        return getMemInfo(cpp.vm.Gc.MEM_INFO_CURRENT);
    }

    private static function getMemInfo(inWhatInfo:Int):Float
    {
        return cpp.vm.Gc.memInfo64(inWhatInfo);
    }

    private static function format(bytes:Float) {
        return FlxStringUtil.formatBytes(bytes);
    }
}