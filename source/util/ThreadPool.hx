package util;

#if (sys && !html5)
import sys.thread.Thread;
import sys.thread.Deque;
import sys.thread.Lock;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

class ThreadPool {
	#if (sys && !html5)
	static var tasks:Deque<Void->Void>;
	static var workers:Array<Thread> = [];
	static var running:Bool = false;
	#end

	static var inited:Bool = false;
	static var workerCount:Int = 0;

	public static function init(desiredThreads:Int):Void {
		if (inited && desiredThreads == workerCount) return;
		#if (sys && !html5)
		shutdown();
		var count = desiredThreads;
		if (count <= 0) count = getDefaultThreadCount();
		count = Std.int(Math.max(1, Math.min(8, count)));
		tasks = new Deque();
		workers = [];
		running = true;
		for (i in 0...count) {
			var t = Thread.create(workerLoop);
			workers.push(t);
		}
		workerCount = count;
		inited = true;
		#else
		// Non-sys targets: no-op single-thread mode
		workerCount = 1;
		inited = true;
		#end
	}

	#if (sys && !html5)
	static function workerLoop():Void {
		while (running) {
			var job = tasks.pop(true);
			if (job != null) {
				try job() catch (e:Dynamic) trace(e);
			}
		}
	}
	#end

	public static function runAllBlocking(funcs:Array<Void->Void>):Void {
		#if (sys && !html5)
		if (!inited) init(0);
		var remaining = funcs.length;
		var lock = new Lock();
		for (fn in funcs) {
			var wrapped = function() {
				try fn() catch (e:Dynamic) trace(e);
				lock.release();
			};
			tasks.add(wrapped);
		}
		// Wait for N releases
		for (i in 0...remaining) lock.wait();
		#else
		for (fn in funcs) fn();
		#end
	}

	public static function getWorkerCount():Int {
		return workerCount <= 0 ? 1 : workerCount;
	}

	public static function shutdown():Void {
		#if (sys && !html5)
		if (!inited) return;
		running = false;
		// Wake all workers by pushing no-op tasks equal to worker count
		for (i in 0...workers.length) tasks.add(function(){});
		workers = [];
		inited = false;
		#end
	}

	static function getDefaultThreadCount():Int {
		#if (sys && !html5)
		return detectHardwareThreads();
		#else
		return 1;
		#end
	}

	#if (sys && !html5)
	static function detectHardwareThreads():Int {
		var n = 0;
		// 1) Windows: NUMBER_OF_PROCESSORS
		try {
			var env = Sys.getEnv("NUMBER_OF_PROCESSORS");
			if (env != null) n = Std.parseInt(env);
		} catch (e:Dynamic) {}

		// 2) Linux: /proc/cpuinfo
		if (n <= 0) {
			try {
				var path = "/proc/cpuinfo";
				if (FileSystem.exists(path)) {
					var content = File.getContent(path);
					var count = 0;
					for (line in content.split("\n")) {
						if (StringTools.startsWith(line, "processor")) count++;
					}
					if (count > 0) n = count;
				}
			} catch (e:Dynamic) {}
		}

		// 3) macOS/BSD: sysctl -n hw.ncpu
		if (n <= 0) {
			try {
				var p = new Process("sysctl", ["-n", "hw.ncpu"]);
				var out = p.stdout.readAll().toString();
				p.close();
				var parsed = Std.parseInt(StringTools.trim(out));
				if (parsed != null && parsed > 0) n = parsed;
			} catch (e:Dynamic) {}
		}

		if (n <= 0) n = 4; // conservative fallback
		return n;
	}
	#end

	public static function getHardwareThreadCount():Int {
		#if (sys && !html5)
		return detectHardwareThreads();
		#else
		return 1;
		#end
	}
}
