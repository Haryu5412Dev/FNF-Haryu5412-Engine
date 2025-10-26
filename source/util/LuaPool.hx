package util;

#if LUA_ALLOWED
import llua.Lua;
import llua.LuaL;
import llua.State;
#end

class LuaPool {
	#if LUA_ALLOWED
	static var pool:Array<Dynamic> = [];
	#end

	public static function prewarm(count:Int):Void {
		#if LUA_ALLOWED
		if (count <= 0) return;
		var target = Std.int(Math.min(8, Math.max(0, count)));
		while (pool.length < target) {
			var s:State = LuaL.newstate();
			LuaL.openlibs(s);
			Lua.init_callbacks(s);
			pool.push(s);
		}
		#end
	}

	public static function get():Dynamic {
		#if LUA_ALLOWED
		return pool.length > 0 ? pool.pop() : null;
		#else
		return null;
		#end
	}

	public static function clear():Void {
		#if LUA_ALLOWED
		// Optionally close states; Lua.close is not exposed here, but pooled states will be GC'ed on exit
		pool = [];
		#end
	}
}
