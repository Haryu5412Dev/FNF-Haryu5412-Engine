package util;

import Paths;
import ClientPrefs;

#if hscript
import hscript.Parser;
import hscript.Interp;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

/**
 * Lightweight HScript (.hx) mod script loader/runner.
 *
 * Scope (by design): current mod only + safe execution (no crash on errors).
 */
class ScriptManager {
	public static var enabled:Bool = true;

	#if hscript
	static var _parser:Parser = new Parser();
	static var _loaded:Map<String, Bool> = new Map(); // absolutePath -> true
	static var _scripts:Array<HxScript> = [];
	static var _lastContextKey:String = '';
	static var _missingWarned:Map<String, Bool> = new Map(); // (context)|tag -> true

	static inline function modPrefix():String {
		var cur = Paths.currentModDirectory;
		if (cur == null) return '';
		cur = cur.trim();
		if (cur.length == 0) return '';
		return cur + '/';
	}
	#else
	public static function reset():Void {}
	public static function setContextKey(key:String):Void {}
	public static function loadGlobalScripts():Void {}
	public static function loadSongScripts(songId:String):Void {}
	public static function loadCustomEventScripts(eventsUsed:Iterable<String>):Void {}
	public static function loadCustomNoteTypeScripts(noteTypesUsed:Iterable<String>):Void {}
	public static function loadStageScript(stageName:String):Void {}
	public static function loadCharacterScript(characterName:String):Void {}
	public static function call(func:String, args:Array<Dynamic>):Void {}
	#end

	#if hscript
	public static function reset():Void {
		_loaded = new Map();
		_scripts = [];
		_lastContextKey = '';
		_missingWarned = new Map();
	}

	/**
	 * Changes in song/mod should reset per-play context.
	 * Pass a stable key like `${Paths.currentModDirectory}|${songId}`.
	 */
	public static function setContextKey(key:String):Void {
		if (key == null) key = '';
		if (_lastContextKey == key) return;
		_lastContextKey = key;
		reset();
	}

	public static function loadGlobalScripts():Void {
		if (!enabled) return;
		#if (MODS_ALLOWED && sys)
		var prefix = modPrefix();
		loadAllInDir(Paths.mods(prefix + 'scripts'), 'global');
		#end
	}

	public static function loadSongScripts(songId:String):Void {
		if (!enabled) return;
		#if (MODS_ALLOWED && sys)
		var prefix = modPrefix();
		var sid = Paths.formatToSongPath(songId);
		loadAllInDir(Paths.mods(prefix + 'data/' + sid), 'song');
		#end
	}

	public static function loadCustomEventScripts(eventsUsed:Iterable<String>):Void {
		if (!enabled) return;
		#if (MODS_ALLOWED && sys)
		var prefix = modPrefix();
		for (name in eventsUsed) {
			if (name == null) continue;
			var trimmed = Std.string(name).trim();
			if (trimmed.length == 0) continue;
			var p = Paths.mods(prefix + 'custom_events/' + trimmed + '.hx');
			if (!FileSystem.exists(p) || FileSystem.isDirectory(p)) {
				warnMissingOnce('event', trimmed, p);
				continue;
			}
			loadSingle(p, 'event:' + trimmed);
		}
		#end
	}

	public static function loadCustomNoteTypeScripts(noteTypesUsed:Iterable<String>):Void {
		if (!enabled) return;
		#if (MODS_ALLOWED && sys)
		var prefix = modPrefix();
		for (name in noteTypesUsed) {
			if (name == null) continue;
			var trimmed = Std.string(name).trim();
			if (trimmed.length == 0) continue;
			if (trimmed == 'null') continue;
			var p = Paths.mods(prefix + 'custom_notetypes/' + trimmed + '.hx');
			if (!FileSystem.exists(p) || FileSystem.isDirectory(p)) {
				warnMissingOnce('notetype', trimmed, p);
				continue;
			}
			loadSingle(p, 'notetype:' + trimmed);
		}
		#end
	}

	static function warnMissingOnce(kind:String, name:String, expectedPath:String):Void {
		try {
			// Keep it quiet unless debug is enabled, but if enabled, still only warn once per play context.
			if (!ClientPrefs.hscriptDebug) return;
			var key = _lastContextKey + '|' + kind + ':' + name;
			if (_missingWarned.exists(key)) return;
			_missingWarned.set(key, true);
			log('ScriptManager: missing ' + kind + ' script for "' + name + '" (expected: ' + expectedPath + ')');
		} catch (_:Dynamic) {}
	}

	public static function loadStageScript(stageName:String):Void {
		if (!enabled) return;
		#if (MODS_ALLOWED && sys)
		var prefix = modPrefix();
		if (stageName == null || stageName.length == 0) return;
		loadSingle(Paths.mods(prefix + 'stages/' + stageName + '.hx'), 'stage:' + stageName);
		#end
	}

	public static function loadCharacterScript(characterName:String):Void {
		if (!enabled) return;
		#if (MODS_ALLOWED && sys)
		var prefix = modPrefix();
		if (characterName == null || characterName.length == 0) return;
		loadSingle(Paths.mods(prefix + 'characters/' + characterName + '.hx'), 'char:' + characterName);
		#end
	}

	public static function call(func:String, args:Array<Dynamic>):Void {
		if (!enabled) return;
		if (func == null || func.length == 0) return;
		for (s in _scripts) {
			safeCall(s, func, args);
		}
	}

	static function loadAllInDir(dir:String, tag:String):Void {
		#if sys
		try {
			if (!FileSystem.exists(dir) || !FileSystem.isDirectory(dir)) return;
			var files:Array<String> = [];
			// Don't use Paths.cachedReadDirectory here: mods scripts can be edited while the game is running.
			for (name in FileSystem.readDirectory(dir)) {
				if (name == null) continue;
				if (!name.toLowerCase().endsWith('.hx')) continue;
				files.push(dir + '/' + name);
			}
			files.sort(function(a, b) return Reflect.compare(a, b));
			for (full in files) loadSingle(full, tag);
		} catch (e:Dynamic) {
			log('ScriptManager: failed to scan ' + dir + ' (' + tag + '): ' + Std.string(e));
		}
		#end
	}

	static function loadSingle(path:String, tag:String):Void {
		#if sys
		try {
			if (path == null || path.length == 0) return;
			if (_loaded.exists(path)) return;
			if (!FileSystem.exists(path) || FileSystem.isDirectory(path)) return;
			_loaded.set(path, true);
			var code = File.getContent(path);
			var script = new HxScript(path, tag);
			script.execute(code);
			_scripts.push(script);
			if (ClientPrefs.hscriptDebug) log('ScriptManager: loaded ' + path);
		} catch (e:Dynamic) {
			log('ScriptManager: failed to load ' + path + ' (' + tag + '): ' + Std.string(e));
		}
		#end
	}

	static function safeCall(script:HxScript, func:String, args:Array<Dynamic>):Void {
		if (script == null) return;
		try {
			script.syncGlobals();
			if (!script.has(func)) return;
			script.call(func, args);
		} catch (e:Dynamic) {
			// Retry with fewer args (keeps scripts resilient when signatures differ)
			var msg = Std.string(e);
			var didRetry = false;
			if (args != null && args.length > 0) {
				for (n in [args.length - 1, args.length - 2, args.length - 3]) {
					if (n <= 0) break;
					try {
						script.call(func, args.slice(0, n));
						didRetry = true;
						break;
					} catch (_:Dynamic) {}
				}
			}
			if (!didRetry) log('ScriptManager: call failed ' + script.path + '::' + func + ' - ' + msg);
		}
	}

	static inline function log(msg:String):Void {
		try {
			trace(msg);
		} catch (_:Dynamic) {}
	}
	#end
}

#if hscript
private class HxScript {
	static var _parser:Parser = new Parser();
	public var path:String;
	public var tag:String;
	public var interp:Interp;
	var _didBindPsychCompat:Bool = false;

	public function new(path:String, tag:String) {
		this.path = path;
		this.tag = tag;
		interp = new Interp();
		bindGlobals();
	}

	public function execute(code:String):Dynamic {
		code = preprocess(code);
		@:privateAccess
		_parser.line = 1;
		@:privateAccess
		_parser.allowTypes = true;
		return interp.execute(_parser.parseString(code));
	}

	public function syncGlobals():Void {
		var ps = PlayState.instance;
		interp.variables.set('game', ps);
		if (ps != null) {
			// Common Psych-style globals used in scripts
			interp.variables.set('dad', ps.dad);
			interp.variables.set('boyfriend', ps.boyfriend);
			interp.variables.set('gf', ps.gf);
			interp.variables.set('camGame', ps.camGame);
			interp.variables.set('camHUD', ps.camHUD);
			interp.variables.set('camOther', ps.camOther);
			interp.variables.set('defaultCamZoom', ps.defaultCamZoom);
			interp.variables.set('camZooming', ps.camZooming);
			interp.variables.set('camZoomingDecay', ps.camZoomingDecay);
			interp.variables.set('camZoomingMult', ps.camZoomingMult);
			interp.variables.set('playbackRate', ps.playbackRate);
			interp.variables.set('opponentCameraOffset', ps.opponentCameraOffset);
			interp.variables.set('boyfriendCameraOffset', ps.boyfriendCameraOffset);

			// Expose script-created split cameras back onto `game` for Psych-style scripts
			// (e.g. references like game.camLeft / game.camRight)
			var _camLeft = interp.variables.get('camLeft');
			if (_camLeft != null) Reflect.setField(ps, 'camLeft', _camLeft);
			var _camRight = interp.variables.get('camRight');
			if (_camRight != null) Reflect.setField(ps, 'camRight', _camRight);
			var _leftEdge = interp.variables.get('leftEdge');
			if (_leftEdge != null) Reflect.setField(ps, 'leftEdge', _leftEdge);
			var _rightEdge = interp.variables.get('rightEdge');
			if (_rightEdge != null) Reflect.setField(ps, 'rightEdge', _rightEdge);
			var _camFollowDad = interp.variables.get('camFollowDad');
			if (_camFollowDad != null) Reflect.setField(ps, 'camFollowDad', _camFollowDad);
			var _camFollowBf = interp.variables.get('camFollowBf');
			if (_camFollowBf != null) Reflect.setField(ps, 'camFollowBf', _camFollowBf);
		}
		if (!_didBindPsychCompat) {
			bindPsychCompat();
			_didBindPsychCompat = true;
		}
	}

	public inline function has(name:String):Bool {
		return interp.variables.exists(name);
	}

	public function call(name:String, args:Array<Dynamic>):Dynamic {
		var fn:Dynamic = interp.variables.get(name);
		if (fn == null) return null;
		return Reflect.callMethod(fn, fn, args == null ? [] : args);
	}

	function bindGlobals():Void {
		// Keep this minimal but compatible with existing engine patterns.
		interp.variables.set('trace', function(v:Dynamic) {
			try {
				trace(v);
			} catch (_:Dynamic) {}
		});
		interp.variables.set('Paths', Paths);
		interp.variables.set('ClientPrefs', ClientPrefs);
		interp.variables.set('Conductor', Conductor);
		interp.variables.set('PlayState', PlayState);
		interp.variables.set('game', PlayState.instance);
		interp.variables.set('FlxG', flixel.FlxG);
		interp.variables.set('FlxSprite', flixel.FlxSprite);
		interp.variables.set('FlxCamera', flixel.FlxCamera);
		interp.variables.set('FlxObject', flixel.FlxObject);
		interp.variables.set('FlxTimer', flixel.util.FlxTimer);
		interp.variables.set('FlxTween', flixel.tweens.FlxTween);
		interp.variables.set('FlxEase', flixel.tweens.FlxEase);
		interp.variables.set('FlxMath', flixel.math.FlxMath);
		interp.variables.set('Math', Math);
		interp.variables.set('Std', Std);
		interp.variables.set('Type', Type);
		interp.variables.set('StringTools', StringTools);
		interp.variables.set('Character', Character);
		interp.variables.set('Note', Note);

		// Color helpers (FlxColor is an abstract, can't be set directly)
		interp.variables.set('colorFromRGB', function(r:Int, g:Int, b:Int, ?a:Int = 255) {
			return flixel.util.FlxColor.fromRGB(r, g, b, a);
		});
		interp.variables.set('WHITE', flixel.util.FlxColor.WHITE);
		interp.variables.set('BLACK', flixel.util.FlxColor.BLACK);

		interp.variables.set('setVar', function(name:String, value:Dynamic) {
			if (PlayState.instance != null) PlayState.instance.variables.set(name, value);
		});
		interp.variables.set('getVar', function(name:String) {
			if (PlayState.instance != null && PlayState.instance.variables.exists(name)) return PlayState.instance.variables.get(name);
			return null;
		});
		interp.variables.set('removeVar', function(name:String) {
			if (PlayState.instance != null && PlayState.instance.variables.exists(name)) {
				PlayState.instance.variables.remove(name);
				return true;
			}
			return false;
		});
	}

	function bindPsychCompat():Void {
		// Helpers commonly expected by Psych-style scripts
		interp.variables.set('add', function(obj:Dynamic) {
			var ps = PlayState.instance;
			if (ps != null) ps.add(obj);
			return obj;
		});
		interp.variables.set('remove', function(obj:Dynamic, ?spare:Bool = false) {
			var ps = PlayState.instance;
			if (ps != null) ps.remove(obj, spare);
			return obj;
		});
		interp.variables.set('insert', function(pos:Int, obj:Dynamic) {
			var ps = PlayState.instance;
			if (ps != null) ps.insert(pos, obj);
			return obj;
		});

		// Provide a minimal LuaUtils proxy (no Lua dependency required)
		interp.variables.set('LuaUtils', {
			getTweenEaseByString: function(name:String) {
				var n = (name == null ? '' : name.trim().toLowerCase());
				return switch (n) {
					case 'linear': flixel.tweens.FlxEase.linear;
					case 'sinein': flixel.tweens.FlxEase.sineIn;
					case 'sineout': flixel.tweens.FlxEase.sineOut;
					case 'sineinout': flixel.tweens.FlxEase.sineInOut;
					case 'quadin': flixel.tweens.FlxEase.quadIn;
					case 'quadout': flixel.tweens.FlxEase.quadOut;
					case 'quadinout': flixel.tweens.FlxEase.quadInOut;
					case 'cubein': flixel.tweens.FlxEase.cubeIn;
					case 'cubeout': flixel.tweens.FlxEase.cubeOut;
					case 'cubeinout': flixel.tweens.FlxEase.cubeInOut;
					case 'quartin': flixel.tweens.FlxEase.quartIn;
					case 'quartout': flixel.tweens.FlxEase.quartOut;
					case 'quartinout': flixel.tweens.FlxEase.quartInOut;
					case 'quintin': flixel.tweens.FlxEase.quintIn;
					case 'quintout': flixel.tweens.FlxEase.quintOut;
					case 'quintinout': flixel.tweens.FlxEase.quintInOut;
					case 'circin': flixel.tweens.FlxEase.circIn;
					case 'circout': flixel.tweens.FlxEase.circOut;
					case 'circinout': flixel.tweens.FlxEase.circInOut;
					case 'expoin': flixel.tweens.FlxEase.expoIn;
					case 'expoout': flixel.tweens.FlxEase.expoOut;
					case 'expoinout': flixel.tweens.FlxEase.expoInOut;
					case 'backin': flixel.tweens.FlxEase.backIn;
					case 'backout': flixel.tweens.FlxEase.backOut;
					case 'backinout': flixel.tweens.FlxEase.backInOut;
					case 'bouncein': flixel.tweens.FlxEase.bounceIn;
					case 'bounceout': flixel.tweens.FlxEase.bounceOut;
					case 'bounceinout': flixel.tweens.FlxEase.bounceInOut;
					case 'elasticin': flixel.tweens.FlxEase.elasticIn;
					case 'elasticout': flixel.tweens.FlxEase.elasticOut;
					case 'elasticinout': flixel.tweens.FlxEase.elasticInOut;
					default: flixel.tweens.FlxEase.linear;
				}
			}
		});
	}

	static function preprocess(code:String):String {
		if (code == null || code.length == 0) return '';
		// Normalize common file encodings/line endings for more stable parsing.
		// (Some editors save UTF-8 BOM, and Windows files often use CRLF.)
		if (code.length > 0 && code.charCodeAt(0) == 0xFEFF) {
			code = code.substr(1);
		}
		code = code.replace("\r\n", "\n");
		code = code.replace("\r", "\n");
		// Standard hscript.Parser can't parse Haxe 'import/using' lines; ignore them.
		var out = new StringBuf();
		for (line in code.split('\n')) {
			var t = (line == null ? '' : line).trim();
			if (t.startsWith('import ') || t.startsWith('using ') || t.startsWith('package ')) {
				continue;
			}
			out.add(line);
			out.add('\n');
		}
		var cooked = out.toString();
		// Psych-style scripts often use ClientPrefs.data.*, but this engine exposes prefs as ClientPrefs.*
		cooked = cooked.replace('ClientPrefs.data.', 'ClientPrefs.');
		// Some scripts compare against game.camLeft / game.camRight even though they create camLeft/camRight locally.
		cooked = cooked.replace('game.camLeft', 'camLeft');
		cooked = cooked.replace('game.camRight', 'camRight');
		return cooked;
	}
}
#end
