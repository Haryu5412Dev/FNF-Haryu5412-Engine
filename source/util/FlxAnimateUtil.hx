package util;

import flixel.graphics.frames.FlxFramesCollection;
import animateatlas.AtlasFrameMaker;

// Compile-time guarded helpers for FlxAnimate integration.
// This file is safe to keep even if flxanimate is not installed.
class FlxAnimateUtil {
	static var _framesCache:Map<String, FlxFramesCollection> = new Map();
	public static inline function isAvailable():Bool {
		#if flxanimate
		return true;
		#else
		return false;
		#end
	}

	// Heuristic: whether given image base likely has an Animate (2020+) export structure.
	// We reuse the same Animation.json check used by animateatlas; FlxAnimate-specific
	// checks can be added later (e.g., Sprites.json, Meta.json) without breaking callers.
	public static function likelyAnimateAtlas(image:String):Bool {
		#if sys
		try {
			var base1 = 'assets/images/' + image + '/Animation.json';
			var base2 = 'mods/images/' + image + '/Animation.json';
			if (sys.FileSystem.exists(base1) || sys.FileSystem.exists(base2)) return true;
		} catch (_:Dynamic) {}
		#end
		return false;
	}

	// Central construction point for frames when using the FlxAnimate path.
	// For now, returns AtlasFrameMaker frames as a safe placeholder so callers
	// have a single integration point to swap later without touching gameplay code.
    public static function constructFrames(image:String):FlxFramesCollection {
        // Fast-path: if we've already constructed frames for this base name, reuse
        var cached = _framesCache.get(image);
        if (cached != null) return cached;
		#if flxanimate
		// TODO: Replace with FlxAnimate-backed frames creation when migrating runtime.
		// This placeholder keeps behavior identical to animateatlas for now.
		var built = AtlasFrameMaker.construct(image);
		_framesCache.set(image, built);
		return built;
		#else
		// Without flxanimate, fall back to animateatlas construct.
		var built = AtlasFrameMaker.construct(image);
		_framesCache.set(image, built);
		return built;
		#end
	}
}
