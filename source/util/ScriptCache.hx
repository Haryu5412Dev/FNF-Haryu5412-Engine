package util;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

class ScriptCache {
	static var cache:Map<String, String> = new Map();

	public static function clear():Void {
		cache = new Map();
	}

	public static function get(path:String):String {
		return cache.get(path);
	}

	public static function preload(paths:Array<String>):Void {
		#if sys
		for (p in paths) {
			if (p == null) continue;
			if (cache.exists(p)) continue;
			try {
				if (sys.FileSystem.exists(p)) {
					var s = sys.io.File.getContent(p);
					cache.set(p, s);
				}
			} catch (e:Dynamic) {
				// ignore individual failures
			}
		}
		#end
	}
}
