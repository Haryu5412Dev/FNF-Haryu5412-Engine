package hxcodec.flixel;

#if flixel
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import sys.FileSystem;
import hxcodec.openfl.Video;

/**
 * This class allows you to play videos using sprites (FlxSprite).
 */
class FlxVideoSprite extends FlxSprite
{
	// Variables
	public var bitmap(default, null):FlxVideo;
	public var onEndReached:Void->Void = null;
	private var _disposed:Bool = false;

	public function new(x:Float = 0, y:Float = 0):Void
	{
		super(x, y);

		makeGraphic(1, 1, FlxColor.TRANSPARENT);

		bitmap = new FlxVideo();
		bitmap.alpha = 0;
		bitmap.autoResize = false; // we'll manage scaling/positioning via this FlxSprite

		bitmap.onOpening.add(function()
		{
			#if FLX_SOUND_SYSTEM
			bitmap.volume = Std.int((FlxG.sound.muted ? 0 : 1) * (FlxG.sound.volume * 100));
			#end
		});


		// Dispose safely after playback ends: stop first, then dispose slightly later, then notify user
		bitmap.onEndReached.add(function() {
			if (bitmap != null) {
				bitmap.stop();
				new FlxTimer().start(0.05, function(_) {
					if (bitmap != null && !_disposed) {
						_disposed = true;
						bitmap.dispose();
						if (FlxG.game.contains(bitmap)) {
							FlxG.game.removeChild(bitmap);
						}
					}
					if (onEndReached != null) {
						onEndReached();
					}
				});
			} else {
				if (onEndReached != null) onEndReached();
			}
		});

		bitmap.onTextureSetup.add(() -> loadGraphic(bitmap.bitmapData));
		FlxG.game.addChild(bitmap);
	}

	// Methods
	public function play(location:String, shouldLoop:Bool = false):Int
	{
		if (FlxG.autoPause)
		{
			if (!FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.add(resume);

			if (!FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.add(pause);
		}

		if (bitmap != null)
		{
			if (FileSystem.exists(Sys.getCwd() + location))
				return bitmap.play(Sys.getCwd() + location, shouldLoop);
			else
				return bitmap.play(location, shouldLoop);
		}
		else
			return -1;
	}

	public function stop():Void
	{
		if (bitmap != null)
			bitmap.stop();
	}

	public function pause():Void
	{
		if (bitmap != null)
			bitmap.pause();
	}

	public function resume():Void
	{
		if (bitmap != null)
			bitmap.resume();
	}

	public function togglePaused():Void
	{
		if (bitmap != null)
			bitmap.togglePaused();
	}

	// Overrides
	override public function update(elapsed:Float):Void
	{
		#if FLX_SOUND_SYSTEM
		bitmap.volume = Std.int((FlxG.sound.muted ? 0 : 1) * (FlxG.sound.volume * 100));
		#end

		super.update(elapsed);
	}

	override public function kill():Void
	{
		pause();
		super.kill();
	}

	override public function revive():Void
	{
		super.revive();
		resume();
	}

	override public function destroy():Void
	{
		if (FlxG.autoPause)
		{
			if (FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.remove(resume);

			if (FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.remove(pause);
		}

		if (bitmap != null)
		{
			bitmap.stop();
			if (!_disposed) {
				_disposed = true;
				bitmap.dispose();
			}

			if (FlxG.game.contains(bitmap))
				FlxG.game.removeChild(bitmap);
		}

		super.destroy();
	}
}
#end
