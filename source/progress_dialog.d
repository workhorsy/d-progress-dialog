// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple progress dialog for the D programming language
// https://github.com/workhorsy/d-progress-dialog


module progress_dialog;

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

abstract class ProgressDialogBase {
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

class ProgressDialogKDialog : ProgressDialogBase {
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

	static bool isSupported() {
		return programPaths(["kdialog"]).length > 0 && programPaths(["qdbus"]).length > 0;
	}

	string _qdbus_id;
}

class ProgressDialogZenity : ProgressDialogBase {
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

	static bool isSupported() {
		return programPaths(["zenity"]).length > 0;
	}
}

/*
private bool showProgressDialogWindows(string title, string message) {
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

class ProgressDialog {
	this(string title, string message) {
		if (ProgressDialogZenity.isSupported()) {
			_dialog = new ProgressDialogZenity(title, message);
		} else if (ProgressDialogKDialog.isSupported()) {
			_dialog = new ProgressDialogKDialog(title, message);
		}
	}

	bool show() {
		return _dialog.show();
	}

	void setPercent(ulong percent) {
		_dialog.setPercent(percent);
	}

	void close() {
		_dialog.close();
	}

	ProgressDialogBase _dialog;
}
