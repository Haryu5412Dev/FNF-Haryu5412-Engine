package util;

#if sys
import openfl.Lib;
#end

#if (windows && cpp)
@:cppFileCode('#include <windows.h>\n#include <wingdi.h>\n#include <cstring>\n')
#end

class DisplayUtil
{
	#if (windows && cpp)
	static inline function getWindowsRefreshRateNative():Int
	{
		// EnumDisplaySettings(NULL, ENUM_CURRENT_SETTINGS, ...) returns the primary display's current refresh rate.
		return untyped __cpp__('(int)([]()->int{ DEVMODE dm; std::memset(&dm, 0, sizeof(dm)); dm.dmSize = sizeof(dm); if (EnumDisplaySettings(NULL, ENUM_CURRENT_SETTINGS, &dm)) return (int)dm.dmDisplayFrequency; return 0; }())');
	}
	#end

	public static function getRefreshRate(defaultRate:Int = 60):Int
	{
		#if sys
		try
		{
			var win:Dynamic = Lib.application.window;
			if (win != null)
			{
				// Common lime/openfl shape: window.displayMode.refreshRate
				var dm:Dynamic = Reflect.field(win, "displayMode");
				if (dm != null)
				{
					var rr:Dynamic = Reflect.field(dm, "refreshRate");
					if (rr != null)
					{
						var value:Int = Std.int(rr);
						if (value > 0) return value;
					}
				}

				// Alternate shape: window.display.currentMode.refreshRate
				var display:Dynamic = Reflect.field(win, "display");
				if (display != null)
				{
					var mode:Dynamic = Reflect.field(display, "currentMode");
					if (mode != null)
					{
						var rr2:Dynamic = Reflect.field(mode, "refreshRate");
						if (rr2 != null)
						{
							var value2:Int = Std.int(rr2);
							if (value2 > 0) return value2;
						}
					}
				}
			}
		}
		catch (_:Dynamic) {}

		#if (windows && cpp)
		var nativeRR:Int = getWindowsRefreshRateNative();
		if (nativeRR > 0) return nativeRR;
		#end
		#end

		return defaultRate;
	}
}
