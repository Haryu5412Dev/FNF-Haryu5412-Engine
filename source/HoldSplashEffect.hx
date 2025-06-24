// HoldSplashEffect.hx

package;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import Note;
import StringTools;
import Paths;

class HoldSplashEffect extends FlxGroup {
    public var holdSplashMap:Map<String, FlxSprite> = new Map();
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
        return splash;
    }

    function getStrumIndex(isOpponent:Bool, noteData:Int):Int {
        return isOpponent ? noteData : noteData + 4;
    }

    function setSplashPosition(splash:FlxSprite, strum:FlxSprite, isOpponent:Bool, noteData:Int):Void {
        if (isOpponent) {
            if (ClientPrefs.middleScroll) {
                splash.x = strum.x + [-50, -50, 50, 50][noteData];
            } else {
                splash.x = strum.x - 105;
            }
            var baseAlpha = PlayState.instance.strumLineNotes.members[0].alpha;
            splash.alpha = (baseAlpha <= 0.01) ? 1 : baseAlpha;
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

        if (PlayState.instance.strumLineNotes.members.length > strumIndex) {
            var strum = PlayState.instance.strumLineNotes.members[strumIndex];
            if (strum != null) {
                setSplashPosition(splash, strum, isOpponent, noteData);
            }
        }

        splash.alpha = isOpponent ? alphaDAD : alphaBF;
        splash.visible = true;

        var note = PlayState.instance.notes.members[noteIndex];
        var animName = (note != null && StringTools.endsWith(note.animation.curAnim.name, 'end')) ? 'end' : 'hold';
        if (splash.animation.curAnim == null || splash.animation.curAnim.name != animName) {
            splash.animation.play(animName, true);
        }
    }

    public function hideSplash(noteData:Int, isOpponent:Bool):Void
        {
            var color = colors[noteData];
            var id = 'hold' + color + (isOpponent ? 'DAD' : 'BF');
            var splash = holdSplashMap.get(id);
        
            if (splash == null) return;
        
            if (isOpponent) {
                splash.visible = false;
                splash.animation.play('hold', true);
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

                    if (splash.animation.curAnim.name == 'end' && splash.animation.finished) {
                        splash.visible = false;
                        splash.animation.play('hold', true);
                    }
                }
            }
        }
    }
}
