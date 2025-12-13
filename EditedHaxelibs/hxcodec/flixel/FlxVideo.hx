package hxcodec.flixel;

#if flixel
import flixel.FlxG;
import hxcodec.openfl.Video;
import openfl.events.Event;
import sys.FileSystem;

class FlxVideo extends Video
{
	// Variables
	public var autoResize:Bool = true;
	/**
	 * If true, this instance will follow FlxG.sound.volume/mute.
	 * If false, caller owns `volume` (0..100).
	 */
	public var followGlobalVolume:Bool = true;
	/**
	 * If true and FlxG.autoPause is enabled, video will pause/resume on focus lost/gained.
	 */
	public var useAutoPause:Bool = true;
	private var _enterFrameHooked:Bool = false;
	private var _autoPauseHooked:Bool = false;

	public function new():Void
	{
		super();

		onOpening.add(function()
		{
			#if FLX_SOUND_SYSTEM
			if (followGlobalVolume)
				volume = Std.int((FlxG.sound.muted ? 0 : 1) * (FlxG.sound.volume * 100));
			#end
		});

		// Don't dispose immediately on end; let owner decide and ensure decode thread stops first.

		FlxG.addChildBelowMouse(this);
	}

	private function hookAutoPause():Void
	{
		if (!useAutoPause) return;
		if (!FlxG.autoPause) return;
		if (_autoPauseHooked) return;
		if (!FlxG.signals.focusGained.has(resume))
			FlxG.signals.focusGained.add(resume);
		if (!FlxG.signals.focusLost.has(pause))
			FlxG.signals.focusLost.add(pause);
		_autoPauseHooked = true;
	}

	private function unhookAutoPause():Void
	{
		if (!_autoPauseHooked) return;
		if (FlxG.signals.focusGained.has(resume))
			FlxG.signals.focusGained.remove(resume);
		if (FlxG.signals.focusLost.has(pause))
			FlxG.signals.focusLost.remove(pause);
		_autoPauseHooked = false;
	}

	private function hookEnterFrame():Void
	{
		if (_enterFrameHooked) return;
		FlxG.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		_enterFrameHooked = true;
	}

	private function unhookEnterFrame():Void
	{
		if (!_enterFrameHooked) return;
		FlxG.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		_enterFrameHooked = false;
	}

	public function enableAutoPause():Void
	{
		hookAutoPause();
	}

	public function disableAutoPause():Void
	{
		unhookAutoPause();
	}

	override public function play(location:String, shouldLoop:Bool = false):Int
	{
		hookAutoPause();
		hookEnterFrame();

		if (FileSystem.exists(Sys.getCwd() + location))
			return super.play(Sys.getCwd() + location, shouldLoop);
		else
			return super.play(location, shouldLoop);
	}

	override public function stop():Void
	{
		// Keep pause hooks; fully stop per-frame work.
		unhookEnterFrame();
		super.stop();
	}

	override public function dispose():Void
	{
		unhookAutoPause();
		unhookEnterFrame();

		super.dispose();

		FlxG.removeChild(this);
	}

	@:noCompletion private function onEnterFrame(e:Event):Void
	{
		if (autoResize)
		{
			var aspectRatio:Float = FlxG.width / FlxG.height;

			if (FlxG.stage.stageWidth / FlxG.stage.stageHeight > aspectRatio)
			{
				// stage is wider than video
				width = FlxG.stage.stageHeight * aspectRatio;
				height = FlxG.stage.stageHeight;
			}
			else
			{
				// stage is taller than video
				width = FlxG.stage.stageWidth;
				height = FlxG.stage.stageWidth * (1 / aspectRatio);
			}
		}

		#if FLX_SOUND_SYSTEM
		if (followGlobalVolume)
			volume = Std.int((FlxG.sound.muted ? 0 : 1) * (FlxG.sound.volume * 100));
		#end
	}
}
#end
