// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple progress dialog for the D programming language
// https://github.com/workhorsy/d-progress-dialog


module progress_dialog_zenity;

import progress_dialog : ProgressDialogBase;


class ProgressDialogZenity : ProgressDialogBase {
	import std.process : ProcessPipes;

	this(string title, string message) {
		super(title, message);
	}

	override void show(void delegate() cb) {
		import std.process : ProcessPipes, ProcessException, pipeProcess, Redirect, tryWait;
		import std.algorithm : map;
		import std.array : array;
		import std.conv : to;
		import std.string : format, split, strip;
		import progress_dialog_helpers : programPaths;

		string[] paths = programPaths(["zenity"]);
		if (paths.length < 1) {
			if (_on_error_cb) _on_error_cb(new Exception("Failed to find zenity"));
			return;
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
		} catch (ProcessException err) {
			if (_on_error_cb) _on_error_cb(err);
			return;
		}

		// Make sure the program did not terminate
		if (tryWait(pipes.pid).terminated) {
			if (_on_error_cb) _on_error_cb(new Exception("Failed to run zenity"));
			return;
		}

/*
		string[] output = pipes.stderr.byLine.map!(n => n.to!string).array();
		stdout.writefln("!!! show stderr: %s", output);
		stdout.flush();
		output = pipes.stdout.byLine.map!(n => n.to!string).array();
		stdout.writefln("!!! show stdout: %s", output);
		stdout.flush();
*/
		_pipes = pipes;

		try {
			cb();
		} catch (Throwable err) {
			if (_on_error_cb) _on_error_cb(err);
		}
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
		import std.stdio : stdout;

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
		import progress_dialog_helpers : programPaths;
		return programPaths(["zenity"]).length > 0;
	}

	ProcessPipes _pipes;
}
