// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple progress bar for the D programming language
// https://github.com/workhorsy/d-progress-bar

// FIXME: Rename to progress_dialog
module progress_bar;

import std.process : Pid, ProcessPipes, ProcessException, spawnProcess, pipeProcess, Redirect, wait;
import std.stdio;

private bool isExecutable(string path) {
	version (Windows) {
		return true;
	} else {
		import std.file : getAttributes;
		import core.sys.posix.sys.stat : S_IXUSR;
		return (getAttributes(path) & S_IXUSR) > 0;
	}
}

private string[] programPaths(string[] program_names) {
	import std.process : environment;
	import std.path : pathSeparator, buildPath;
	import std.file : isDir;
	import std.string : split;
	import glob : glob;

	string[] paths;
	string[] exts;
	if (environment.get("PATHEXT")) {
		exts = environment["PATHEXT"].split(pathSeparator);
	}

	// Each path
	foreach (p ; environment["PATH"].split(pathSeparator)) {
		//stdout.writefln("p: %s", p);
		// Each program name
		foreach (program_name ; program_names) {
			string full_name = buildPath(p, program_name);
			//stdout.writefln("full_name: %s", full_name);
			string[] full_names = glob(full_name);
			//stdout.writefln("full_names: %s", full_names);

			// Each program name that exists in a path
			foreach (name ; full_names) {
				// Save the path if it is executable
				if (name && isExecutable(name) && ! isDir(name)) {
					paths ~= name;
				}
				// Save the path if we found one with a common extension like .exe
				foreach (e; exts) {
					string full_name_ext = name ~ e;

					if (isExecutable(full_name_ext) && ! isDir(full_name_ext)) {
						paths ~= full_name_ext;
					}
				}
			}
		}
	}

	return paths;
}
/*
private bool showProgressBarWindows(string title, string message) {
	version (Windows) {
		import core.runtime;
		import core.sys.windows.windows;
		import std.utf : toUTFz;

		int flags = 0;

		int status = MessageBox(NULL, message.toUTFz!(const(wchar)*), title.toUTFz!(const(wchar)*), MB_OK | flags);
		if (status == 0) {
			return false;
		}

		return false;
	} else {
		return false;
	}
}
*/
private ProcessPipes showProgressBarZenity(string title, string message) {
	string[] paths = programPaths(["zenity"]);
	if (paths.length < 1) {
		return ProcessPipes.init;
	}

	string[] args = [
		paths[0],
		"--progress",
		"--title=" ~ title,
		"--text=" ~ message,
		"--percentage=0",
		"--auto-close",
		"--no-cancel",
		"--modal",
	];
	ProcessPipes pipes;
	//try {
		pipes = pipeProcess(args, Redirect.stdin | Redirect.stdout | Redirect.stderr);
	//} catch (ProcessException) {
	//}

	return pipes;
}

class ProgressBar {
	this(string title, string message) {
		_title = title;
		_message = message;
	}

	bool show() {
		import std.stdio : stderr;

		bool did_show = false;

		//if (! did_show) {
			//did_show = showProgressBarWindows(_title, _message);
		//}

		if (! did_show) {
			_pipes = showProgressBarZenity(_title, _message);
		}

		return _pipes !is ProcessPipes.init;
	}

	void setPercent(ulong percent) {
		import std.string : format;
		_pipes.stdin.writef("%s\n".format(percent));
		_pipes.stdin.flush();
	}

	void close() {
		import std.algorithm : map;
		import std.array : array;
		import std.conv : to;

		this.setPercent(100);

		stdout.writefln("!!! called close");

		if (wait(_pipes.pid) != 0) {
			throw new Exception("Failed to close dialog");
		}

		string[] output = _pipes.stderr.byLine.map!(n => n.to!string).array();
		stdout.writefln("!!! output: %s", output);
		output = _pipes.stdout.byLine.map!(n => n.to!string).array();
		stdout.writefln("!!! output: %s", output);
	}

	string _title;
	string _message;
	ProcessPipes _pipes;
}
