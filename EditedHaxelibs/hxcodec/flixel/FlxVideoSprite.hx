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
	/**
	 * Relative volume for this video, 0.0 to 1.0.
	 * Final output = FlxG.sound.volume * this.volume (and obeys global mute).
	 */
	public var volume:Float = 1.0;
	private var _disposed:Bool = false;

	public function new(x:Float = 0, y:Float = 0):Void
	{
		super(x, y);

		makeGraphic(1, 1, FlxColor.TRANSPARENT);
	private var _textureHandler:Void->Void = null;

		bitmap = new FlxVideo();
		bitmap.alpha = 0;
		bitmap.autoResize = false; // we'll manage scaling/positioning via this FlxSprite

		bitmap.onOpening.add(function()
		{
			#if FLX_SOUND_SYSTEM
			var rel:Float = FlxG.sound.volume * volume;
			if (rel < 0) rel = 0; else if (rel > 1) rel = 1;
		bitmap.followGlobalVolume = false;
			bitmap.volume = Std.int((FlxG.sound.muted ? 0 : 1) * (rel * 100));
			#end
		});


		// Dispose safely after playback ends: stop first, then dispose slightly later, then notify user
		bitmap.onEndReached.add(function() {
			if (bitmap != null) {
				bitmap.stop();
				new FlxTimer().start(0.05, function(_) {
		_textureHandler = function()
		{
			if (_disposed) return;
			if (bitmap == null) return;
			try {
				if (bitmap.bitmapData != null)
					loadGraphic(bitmap.bitmapData);
			} catch (e:Dynamic) {
				// ignore late texture callbacks after dispose
			}
		};

					if (bitmap != null && !_disposed) {
		bitmap.onEndReached.add(function()
		{
			if (_disposed)
			{
				if (onEndReached != null) onEndReached();
				return;
			}
			if (bitmap != null)
			{
				bitmap.stop();
				new FlxTimer().start(0.05, function(_)
				{
					disposeBitmap();
					if (onEndReached != null) onEndReached();
				});
			}
			else
			{
				if (onEndReached != null) onEndReached();
			}
		});

		bitmap.onTextureSetup.add(_textureHandler);
	{
		if (FlxG.autoPause)
		{
			if (!FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.add(resume);
		if (_disposed) return;
		if (bitmap == null) {
			_disposed = true;
			return;
		}
		// Prevent late callbacks from touching this sprite
		if (_textureHandler != null)
			bitmap.onTextureSetup.remove(_textureHandler);
		_disposed = true;
		try {
			bitmap.dispose();
		} catch (e:Dynamic) {
			// ignore dispose races
		}
		if (FlxG.game.contains(bitmap))
			FlxG.game.removeChild(bitmap);
		bitmap = null;
	}

			if (!FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.add(pause);
		if (bitmap != null && !_disposed)
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
		if (bitmap != null && !_disposed)
	}

	public function resume():Void
	{
		if (bitmap != null)
		if (bitmap != null && !_disposed)
	}

	public function togglePaused():Void
	{
		if (bitmap != null)
		if (bitmap != null && !_disposed)
	}

	// Overrides
	override public function update(elapsed:Float):Void
	{
		if (bitmap != null && !_disposed)
		var rel:Float = FlxG.sound.volume * volume;
		if (rel < 0) rel = 0; else if (rel > 1) rel = 1;
		bitmap.volume = Std.int((FlxG.sound.muted ? 0 : 1) * (rel * 100));
		#end

		super.update(elapsed);
		if (bitmap != null && !_disposed)
		{
			var rel:Float = FlxG.sound.volume * volume;
			if (rel < 0) rel = 0; else if (rel > 1) rel = 1;
			bitmap.volume = Std.int((FlxG.sound.muted ? 0 : 1) * (rel * 100));
		}
	{
		pause();
		super.kill();
	}

	override public function revive():Void
	{
		if (bitmap != null && !_disposed)
			bitmap.stop();
		disposeBitmap();
				bitmap.dispose();
			}

			if (FlxG.game.contains(bitmap))
				FlxG.game.removeChild(bitmap);
		}

		super.destroy();
	}
}
#end
