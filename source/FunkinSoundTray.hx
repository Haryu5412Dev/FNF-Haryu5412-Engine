package;

import flixel.system.ui.FlxSoundTray;
import openfl.display.Bitmap;
import flixel.FlxG;
import openfl.Assets;
import Paths;

/**
 * Custom sound tray with volume bars.
 */
class FunkinSoundTray extends FlxSoundTray
{
	var graphicScale:Float = 0.30;
	var lerpYPos:Float = 0;
	var alphaTarget:Float = 0;

	var volumeMaxSound:String;

	public function new()
	{
		super();
		removeChildren();

		var bgPath = Paths.getPath("images/soundtray/volumebox.png", IMAGE);
		var bg:Bitmap = new Bitmap(Assets.getBitmapData(bgPath));
		bg.scaleX = graphicScale;
		bg.scaleY = graphicScale;
		bg.smoothing = true;
		addChild(bg);

		y = -height;
		visible = false;

		var backingBarPath = Paths.getPath("images/soundtray/bars_10.png", IMAGE);
		var backingBar:Bitmap = new Bitmap(Assets.getBitmapData(backingBarPath));
		backingBar.x = 9;
		backingBar.y = 5;
		backingBar.scaleX = graphicScale;
		backingBar.scaleY = graphicScale;
		backingBar.smoothing = true;
		backingBar.alpha = 0.4;
		addChild(backingBar);

		_bars = [];

		for (i in 1...11)
		{
			var barPath = Paths.getPath('images/soundtray/bars_' + i + '.png', IMAGE);
			var bar:Bitmap = new Bitmap(Assets.getBitmapData(barPath));
			bar.x = 9;
			bar.y = 5;
			bar.scaleX = graphicScale;
			bar.scaleY = graphicScale;
			bar.smoothing = true;
			addChild(bar);
			_bars.push(bar);
		}

		screenCenter();

		volumeUpSound = "soundtray/Volup";
		volumeDownSound = "soundtray/Voldown";
		volumeMaxSound = "soundtray/VolMAX";
	}

	override public function update(ms:Float):Void
	{
		y = lerp(y, lerpYPos, 0.1);
		alpha = lerp(alpha, alphaTarget, 0.25);

		var hasVolume:Bool = (!FlxG.sound.muted && FlxG.sound.volume > 0);

		if (hasVolume)
		{
			if (_timer > 0)
			{
				_timer -= (ms / 1000);
			}
			else if (y >= -height)
			{
				lerpYPos = -height - 10;
				alphaTarget = 0;
			}

			if (y <= -height)
			{
				visible = false;
				active = false;
			}
		}
		else if (!visible)
		{
			moveTrayMakeVisible();
		}
	}

	override public function show(up:Bool = false):Void
	{
		moveTrayMakeVisible(up);
		saveVolumePreferences();
	}

	function moveTrayMakeVisible(up:Bool = false):Void
	{
		_timer = 1;
		lerpYPos = 10;
		visible = true;
		active = true;
		alphaTarget = 1;

		var volume:Int = getGlobalVolume(up);
		for (i in 0..._bars.length)
			_bars[i].visible = i < volume;
	}

	function getGlobalVolume(up:Bool = false):Int
	{
		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

		if (FlxG.sound.muted || FlxG.sound.volume == 0)
			globalVolume = 0;

		if (!silent)
		{
			var sound:String = up ? volumeUpSound : volumeDownSound;
			if (globalVolume == 10) sound = volumeMaxSound;

			if (sound != null)
				FlxG.sound.play(Paths.sound(sound), 0.3);
		}

		return globalVolume;
	}

	function saveVolumePreferences():Void
	{
		#if FLX_SAVE
		if (FlxG.save.isBound)
		{
			FlxG.save.data.mute = FlxG.sound.muted;
			FlxG.save.data.volume = FlxG.sound.volume;
			FlxG.save.flush();
		}
		#end
	}

	inline function lerp(a:Float, b:Float, t:Float):Float
	{
		return a + (b - a) * t;
	}
}
