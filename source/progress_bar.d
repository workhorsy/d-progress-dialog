// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple progress bar for the D programming language
// https://github.com/workhorsy/d-progress-bar

// FIXME: Rename to progress_dialog
module progress_bar;

import std.process : ProcessPipes;
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

abstract class ProgressBarBase {
	this(string title, string message) {
		_title = title;
		_message = message;
	}

	bool show();
	void setPercent(ulong percent);
	void close();

	string _title;
	string _message;
	ProcessPipes _pipes;
}

class ProgressBarKDialog : ProgressBarBase {
	this(string title, string message) {
		super(title, message);
	}

	override bool show() {
		import std.process : ProcessPipes, ProcessException, pipeProcess, Redirect, tryWait;
		import std.algorithm : map;
		import std.array : array;
		import std.conv : to;
		import std.string : format, split, strip;

		string[] paths = programPaths(["kdialog"]);
		if (paths.length < 1) {
			return false;
		}

		string[] args = [
			paths[0],
			"--title",
			_title,
			"100",
			"--progressbar",
			_message,
		];
		ProcessPipes pipes;
		try {
			pipes = pipeProcess(args, Redirect.stdin | Redirect.stdout | Redirect.stderr);
		} catch (ProcessException) {
			return false;
		}

		// Make sure the program did not terminate
		if (tryWait(pipes.pid).terminated) {
			return false;
		}

	///*
		//string[] output = pipes.stderr.byLine.map!(n => n.to!string).array();
		//stdout.writefln("!!! output: %s", output);
		//stdout.flush();
		string[] output = pipes.stdout.byLine.map!(n => n.to!string).array();
		stdout.writefln("!!! show output: %s", output);
		stdout.flush();
		_qdbus_id = output[0].split("/ProgressDialog")[0].strip();
		stdout.writefln("!!! _qdbus_id: %s", _qdbus_id);
		stdout.flush();
	//*/

		_pipes = pipes;
		return true;
	}

	override void setPercent(ulong percent) {
		import std.process : ProcessPipes, ProcessException, pipeProcess, Redirect, tryWait, wait;
		import std.algorithm : map;
		import std.array : array;
		import std.conv : to;
		import std.string : format;

		string[] paths = programPaths(["qdbus"]);
		if (paths.length < 1) {
			return;
		}

		string[] args = [
			paths[0],
			_qdbus_id,
			"/ProgressDialog",
			"Set",
			"",
			"value",
			"%s".format(percent),
		];

		ProcessPipes pipes;
		try {
			pipes = pipeProcess(args, Redirect.stdin | Redirect.stdout | Redirect.stderr);
		} catch (ProcessException) {
			return;
		}

		if (wait(pipes.pid) != 0) {
			string[] output = pipes.stderr.byLine.map!(n => n.to!string).array();
			stdout.writefln("!!! setPercent output: %s", output);
			stdout.flush();
			output = pipes.stdout.byLine.map!(n => n.to!string).array();
			stdout.writefln("!!! setPercent output: %s", output);
			stdout.flush();
			throw new Exception("Failed to set kdialog percent");
		}
	}

	override void close() {
		import std.process : ProcessPipes, ProcessException, pipeProcess, Redirect, tryWait, wait;
		import std.algorithm : map;
		import std.array : array;
		import std.conv : to;
		import std.string : format;

		this.setPercent(100);

		string[] paths = programPaths(["qdbus"]);
		if (paths.length < 1) {
			return;
		}

		string[] args = [
			paths[0],
			_qdbus_id,
			"/ProgressDialog",
			"close",
		];

		ProcessPipes pipes;
		try {
			pipes = pipeProcess(args, Redirect.stdin | Redirect.stdout | Redirect.stderr);
		} catch (ProcessException) {
			return;
		}

		if (wait(pipes.pid) != 0) {
			string[] output = pipes.stderr.byLine.map!(n => n.to!string).array();
			stdout.writefln("!!! setPercent output: %s", output);
			stdout.flush();
			output = pipes.stdout.byLine.map!(n => n.to!string).array();
			stdout.writefln("!!! setPercent output: %s", output);
			stdout.flush();
			throw new Exception("Failed to close kdialog");
		}
	}

	string _qdbus_id;
}

class ProgressBarZenity : ProgressBarBase {
	this(string title, string message) {
		super(title, message);
	}

	override bool show() {
		import std.process : ProcessPipes, ProcessException, pipeProcess, Redirect, tryWait;
		import std.algorithm : map;
		import std.array : array;
		import std.conv : to;
		import std.string : format, split, strip;

		string[] paths = programPaths(["zenity"]);
		if (paths.length < 1) {
			return false;
		}

		string[] args = [
			paths[0],
			"--progress",
			"--title=" ~ _title,
			"--text=" ~ _message,
			"--percentage=0",
			"--auto-close",
			"--no-cancel",
			"--modal",
		];
		ProcessPipes pipes;
		try {
			pipes = pipeProcess(args, Redirect.stdin | Redirect.stdout | Redirect.stderr);
		} catch (ProcessException) {
			return false;
		}

		// Make sure the program did not terminate
		//if (tryWait(pipes.pid).terminated) {
		//	return false;
		//}
/*
		string[] output = pipes.stderr.byLine.map!(n => n.to!string).array();
		stdout.writefln("!!! show stderr: %s", output);
		stdout.flush();
		output = pipes.stdout.byLine.map!(n => n.to!string).array();
		stdout.writefln("!!! show stdout: %s", output);
		stdout.flush();
*/
		_pipes = pipes;
		return true;
	}

	override void setPercent(ulong percent) {
		import std.string : format;
		_pipes.stdin.writef("%s\n".format(percent));
		_pipes.stdin.flush();
	}

	override void close() {
		import std.process : wait;
		import std.algorithm : map;
		import std.array : array;
		import std.conv : to;

		this.setPercent(100);

		//stdout.writefln("!!! called close");

		if (wait(_pipes.pid) != 0) {
			throw new Exception("Failed to close dialog");
		}

		string[] output = _pipes.stderr.byLine.map!(n => n.to!string).array();
		stdout.writefln("!!! output: %s", output);
		output = _pipes.stdout.byLine.map!(n => n.to!string).array();
		stdout.writefln("!!! output: %s", output);
	}
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

class ProgressBar {
	this(string title, string message) {
		_title = title;
		_message = message;
	}

	bool show() {
		import std.process : ProcessPipes;
		import std.stdio : stderr;

		bool did_show = false;
/*
		if (! did_show) {
			_pipes = showProgressBarWindows(_title, _message);
		}
	*/
/*
		if (! did_show) {
			_pipes = showProgressBarZenity(_title, _message);
		}
*/
/*
	if (! did_show) {
		_pipes = showProgressBarKDialog(_title, _message);
	}
*/
		return _pipes !is ProcessPipes.init;
	}

	void setPercent(ulong percent) {

	}

	void close() {

	}

	string _title;
	string _message;
	ProcessPipes _pipes;
}
