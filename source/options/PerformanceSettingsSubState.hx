package options;

import flixel.FlxG;

class PerformanceSettingsSubState extends BaseOptionsMenu {
	public function new() {
		title = 'Performance';
		rpcTitle = 'Performance Settings';

		var hw = #if sys util.ThreadPool.getHardwareThreadCount() #else 1 #end;

		// Worker threads (0 = Auto)
		var optThreads:Option = new Option('Worker Threads',
			'Sets background worker threads for file parsing/loading. 0 = Auto (recommended).',
			'workerThreads',
			'int',
			0);
		optThreads.minValue = 0;
		optThreads.maxValue = Math.max(1, hw);
		optThreads.displayFormat = '%v';
		optThreads.onChange = function() {
			#if sys
			util.ThreadPool.init(ClientPrefs.workerThreads);
			#end
		};
		addOption(optThreads);

		// GPU precache toggle
		var optGPU:Option = new Option('GPU Precache',
			'Keeps common graphics persisted to reduce stutter. Disable to save memory.',
			'gpuPrecache',
			'bool',
			true);
		optGPU.onChange = function() {
			Paths.setPersistGraphics(ClientPrefs.gpuPrecache);
		};
		addOption(optGPU);

		// Aggressive memory cleanup
		var optMem:Option = new Option('Aggressive Memory Cleanup',
			'Frees more caches between screens. Reduces memory, may add small delays on transitions.',
			'aggressiveMemory',
			'bool',
			false);
		addOption(optMem);

		// Text cache size
		var optTextCache:Option = new Option('Text Cache Size (KB)',
			'Caches Lua/JSON text to reduce disk reads. Set to 0 to disable.',
			'textCacheKB',
			'int',
			1024);
		optTextCache.minValue = 0;
		optTextCache.maxValue = 8192;
		optTextCache.displayFormat = '%v KB';
		optTextCache.onChange = function() {
			Paths.setTextCacheMaxKB(ClientPrefs.textCacheKB);
		};
		addOption(optTextCache);

		// Mods directory cache
		var optDirCache:Option = new Option('Mods Dir Cache',
			'Caches mods/ directory listings to speed up Lua discovery. Disable if frequently editing files.',
			'modsDirCache',
			'bool',
			true);
		optDirCache.onChange = function() {
			Paths.setDirCacheEnabled(ClientPrefs.modsDirCache);
		};
		addOption(optDirCache);

		super();
	}
}
