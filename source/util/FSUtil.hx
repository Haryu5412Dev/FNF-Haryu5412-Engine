package util;

#if sys
import sys.FileSystem;
import Paths;
using StringTools;

class FSUtil {
	static var _cache:Map<String, Array<String>> = new Map();

	public static function clearCache():Void {
		_cache = new Map();
	}

	public static function listFilesWithExt(dir:String, ext:String):Array<String> {
		var out:Array<String> = [];
		try {
			if (!FileSystem.exists(dir) || !FileSystem.isDirectory(dir)) return out;
			var dot = '.' + ext.toLowerCase();
			var key = dir + '|' + dot;
			var cached = _cache.get(key);
			if (cached != null) return cached;
			for (name in Paths.cachedReadDirectory(dir)) {
				var full = dir + '/' + name;
				if (FileSystem.isDirectory(full)) continue;
				if (name.toLowerCase().endsWith(dot)) out.push(full);
			}
			_cache.set(key, out);
		} catch (_:Dynamic) {}
		return out;
	}
}
#else
class FSUtil {
	public static function listFilesWithExt(dir:String, ext:String):Array<String> {
		return [];
	}
}
#end
