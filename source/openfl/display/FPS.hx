package openfl.display;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.math.FlxMath;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

#if openfl
import openfl.system.System;
#end

/**
    The FPS class provides an easy-to-use monitor to display
    the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
    public static var fpsText:TextField;

    public var currentFPS(default, null):Int;

    @:noCompletion private var cacheCount:Int;
    @:noCompletion private var currentTime:Float;
    @:noCompletion private var times:Array<Float>;

    public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
    {
        super();

        this.x = x;
        this.y = y;

        currentFPS = 0;
        selectable = false;
        mouseEnabled = false;
        defaultTextFormat = new TextFormat("VCR OSD Mono", 15, color);
        autoSize = LEFT;
        multiline = true;

        cacheCount = 0;
        currentTime = 0;
        times = [];

        #if flash
        addEventListener(Event.ENTER_FRAME, function(e)
        {
            var time = Lib.getTimer();
            __enterFrame(time - currentTime);
        });
        #end

        FPS.createFPSText();
    }

    public static function createFPSText() {
            fpsText = new TextField();
            fpsText.defaultTextFormat = new TextFormat("VCR OSD Mono", 15, 0xFFFFFFFF);
            fpsText.text = " ";
            fpsText.x = 5;
            fpsText.y = 5;
            fpsText.width = 200;
            fpsText.height = 50; 
            fpsText.border = false;
            fpsText.background = false;
            fpsText.textColor = 0xA8FFFFFF;
            fpsText.autoSize = LEFT;
			fpsText.alpha = 0.8;
            Lib.current.addChild(fpsText);
    }

    @:noCompletion
    private #if !flash override #end function __enterFrame(deltaTime:Float):Void
    {
        if (!ClientPrefs.showFPS) {
            if (fpsText != null) {
                fpsText.visible = false;
            }
            return;
        }

        if (fpsText != null) {
            fpsText.visible = true;
        }

        currentTime += deltaTime;
        times.push(currentTime);

        while (times[0] < currentTime - 1000)
        {
            times.shift();
        }

        var currentCount = times.length;
        currentFPS = Math.round((currentCount + cacheCount) / 2);
        if (currentFPS > ClientPrefs.framerate) currentFPS = ClientPrefs.framerate;

        if (currentCount != cacheCount /*&& visible*/)
        {
            var maxFPS = ClientPrefs.framerate;
            var fpsString = "FPS: " + currentFPS + " / " + maxFPS;
            var memoryMegas:Float = 0;

            #if openfl
            memoryMegas = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 1));
            var memoryString = "";
            if (memoryMegas >= 1000) {
                var memoryGigas:Float = Math.abs(FlxMath.roundDecimal(memoryMegas / 1000, 2));
                memoryString = "\nRAM: " + memoryGigas + " GB";
            } else {
                memoryString = "\nRAM: " + memoryMegas + " MB";
            }
            #end
            
            if (ClientPrefs.showRAM) {
                fpsText.htmlText = "<font size='15'>" + fpsString + "</font>" + memoryString;
            } else {
                fpsText.htmlText = "<font size='15'>" + fpsString + "</font>";
            }

            fpsText.textColor = 0xA8FFFFFF;
            if (memoryMegas > 3000 || currentFPS <= ClientPrefs.framerate / 2)
            {
                fpsText.textColor = 0xFFFF0000;
            }

            #if (gl_stats && !disable_cffi && (!html5 || !canvas))
            fpsText.htmlText += "\ntotalDC: " + Context3DStats.totalDrawCalls();
            fpsText.htmlText += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
            fpsText.htmlText += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
            #end

            fpsText.htmlText += "\n";
        }

        cacheCount = currentCount;
    }

    public static function round(x:Float, n:Int):Float {
        var factor = Math.pow(10, n);
        return Math.round(x * factor) / factor;
    }

    public static function minCheck(min:Int):String {
        return (min < 10) ? "0" + min : Std.string(min);
    }
}