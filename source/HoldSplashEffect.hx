package;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import Note;
import StringTools;
import Paths;
import ColorSwap;

class HoldSplashEffect extends FlxGroup {
    public var holdSplashMap:Map<String, FlxSprite> = new Map();
    public var holdSplashColorMap:Map<FlxSprite, ColorSwap> = new Map();
    public var splashNoteMap:Map<FlxSprite, Note> = new Map();
    public var colors:Array<String> = ['Purple', 'Blue', 'Green', 'Red'];
    public var alphaBF:Float = 1;
    public var alphaDAD:Float = 1;
    public var isPixel:Bool = false;

    public function new(isPixelStage:Bool) {
        super();
        isPixel = isPixelStage;
        for (color in colors) {
            add(createHoldSplash(color, "BF"));
            add(createHoldSplash(color, "DAD"));
        }
    }

    function createHoldSplash(color:String, suffix:String):FlxSprite {
        var id = 'hold' + color + suffix;
        var path = isPixel ? 'holdCover/holdCoverPixel' : 'holdCover/holdCover';
        var splash = new FlxSprite();
        splash.frames = Paths.getSparrowAtlas(path + color);
        splash.animation.addByPrefix('hold', 'holdCover' + color, 24, true);
        splash.animation.addByPrefix('end', 'holdCoverEnd' + color, 24, false);
        splash.visible = false;
        splash.alpha = (suffix == 'BF') ? alphaBF : alphaDAD;
        splash.cameras = [PlayState.instance.camHUD];
        splash.antialiasing = ClientPrefs.globalAntialiasing;
        splash.scrollFactor.set(0, 0);
        splash.animation.play('hold', true);
        holdSplashMap.set(id, splash);

        var colorSwap = new ColorSwap();
        splash.shader = colorSwap.shader;
        holdSplashColorMap.set(splash, colorSwap);

        return splash;
    }

    function getStrumIndex(isOpponent:Bool, noteData:Int):Int {
        return isOpponent ? noteData : noteData + 4;
    }

    function setSplashPosition(splash:FlxSprite, strum:FlxSprite, isOpponent:Bool, noteData:Int, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0, ?note:Note = null):Void {
        if (note != null && Std.isOfType(splash.shader, ColorSwap)) {
            var cs:ColorSwap = cast(splash.shader, ColorSwap);
            cs.hue = note.noteSplashHue;
            cs.saturation = note.noteSplashSat;
            cs.brightness = note.noteSplashBrt;
        }

        // for angle? ig
        if (note != null) {
            splash.angle = note.angle;
        } else {
            splash.angle = 0;
        }

        if (isOpponent) {
            if (ClientPrefs.middleScroll) {
                splash.x = strum.x + [-50, -50, 50, 50][noteData];
            } else {
                splash.x = strum.x - 105;
            }
            var strumIndex = getStrumIndex(isOpponent, noteData);
            if (PlayState.instance.strumLineNotes.members.length > strumIndex) {
                var baseAlpha = PlayState.instance.strumLineNotes.members[strumIndex].alpha;
                splash.alpha = baseAlpha;
            }
        } else {
            splash.x = strum.x - 105;
        }

        splash.y = strum.y - 100;
    }

    public function triggerSplash(isOpponent:Bool, noteIndex:Int, noteData:Int, isSustain:Bool):Void {
        if (!isSustain) return;
    
        var color = colors[noteData];
        var id = 'hold' + color + (isOpponent ? 'DAD' : 'BF');
        var splash = holdSplashMap.get(id);
        if (splash == null) return;
    
        var strumIndex = getStrumIndex(isOpponent, noteData);
        var note = PlayState.instance.notes.members[noteIndex];
    
        if (PlayState.instance.strumLineNotes.members.length > strumIndex) {
            var strum = PlayState.instance.strumLineNotes.members[strumIndex];
            if (strum != null) {
                setSplashPosition(splash, strum, isOpponent, noteData, 0, 0, 0, note);
            }
        }
    
        if (note != null) splashNoteMap.set(splash, note);
    
        var hue:Float = 0;
        var sat:Float = 0;
        var brt:Float = 0;
        if (note != null) {
            hue = note.noteSplashHue;
            sat = note.noteSplashSat;
            brt = note.noteSplashBrt;
        } else if (noteData > -1 && noteData < ClientPrefs.arrowHSV.length) {
            hue = ClientPrefs.arrowHSV[noteData][0] / 360;
            sat = ClientPrefs.arrowHSV[noteData][1] / 100;
            brt = ClientPrefs.arrowHSV[noteData][2] / 100;
        }
    
        if (holdSplashColorMap.exists(splash)) {
            var cs = holdSplashColorMap.get(splash);
            cs.hue = hue;
            cs.saturation = sat;
            cs.brightness = brt;
        }
    
        if (splash.animation.curAnim == null || splash.animation.curAnim.name != 'hold') {
            splash.animation.play('hold', true);
        }
        splash.visible = true;

        // if (holdSplashColorMap.exists(splash)) {
        //     var cs = holdSplashColorMap.get(splash);
        //     cs.hue = hue;
        //     cs.saturation = sat;
        //     cs.brightness = brt;
        //     trace('ColorSwap set: hue=$hue, sat=$sat, brt=$brt');
        //     trace('Shader uTime: ' + cs.shader.uTime.value);
        // }
    }
    

    public function hideSplash(noteData:Int, isOpponent:Bool):Void {
        var color = colors[noteData];
        var id = 'hold' + color + (isOpponent ? 'DAD' : 'BF');
        var splash = holdSplashMap.get(id);

        if (splash == null) return;

        if (isOpponent) {
            splash.visible = false;
            splash.animation.play('hold', true);
            splashNoteMap.remove(splash);
        } else {
            splash.animation.play('end', true);
        }
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        for (i in 0...4) {
            for (isOpponent in [false, true]) {
                var color = colors[i];
                var suffix = isOpponent ? 'DAD' : 'BF';
                var id = 'hold' + color + suffix;
                var splash = holdSplashMap.get(id);
                var strumIndex = getStrumIndex(isOpponent, i);

                if (splash != null && splash.visible) {
                    var strum = PlayState.instance.strumLineNotes.members[strumIndex];
                    if (strum != null) {
                        setSplashPosition(splash, strum, isOpponent, i);
                    }

                    if (splashNoteMap.exists(splash)) {
                        var linkedNote = splashNoteMap.get(splash);
                        if (linkedNote != null) {
                            splash.angle = linkedNote.angle;
                            splash.alpha = strum != null ? strum.alpha : 1;
                        }
                    }

                    if (splash.animation.curAnim.name == 'end' && splash.animation.finished) {
                        splash.visible = false;
                        splash.animation.play('hold', true);
                        splashNoteMap.remove(splash);
                    }
                }
            }
        }
    }
}
