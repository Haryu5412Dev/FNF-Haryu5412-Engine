package util;

#if sys
import sys.FileSystem;
using StringTools;

class FSUtil {
	public static function listFilesWithExt(dir:String, ext:String):Array<String> {
		var out:Array<String> = [];
		try {
			if (!FileSystem.exists(dir) || !FileSystem.isDirectory(dir)) return out;
			var dot = '.' + ext.toLowerCase();
			for (name in FileSystem.readDirectory(dir)) {
				var full = dir + '/' + name;
				if (FileSystem.isDirectory(full)) continue;
				if (name.toLowerCase().endsWith(dot)) out.push(full);
			}
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
