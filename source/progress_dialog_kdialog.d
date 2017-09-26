// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple progress dialog for the D programming language
// https://github.com/workhorsy/d-progress-dialog


module progress_dialog_kdialog;

import progress_dialog : ProgressDialogBase;


class ProgressDialogKDialog : ProgressDialogBase {
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
		import std.stdio : stdout;
		import progress_dialog_helpers : programPaths;

		string[] paths = programPaths(["kdialog"]);
		if (paths.length < 1) {
			if (_on_error_cb) _on_error_cb(new Exception("Failed to find kdialog"));
			return;
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
		} catch (ProcessException err) {
			if (_on_error_cb) _on_error_cb(err);
			return;
		}

		// Make sure the program did not terminate
		if (tryWait(pipes.pid).terminated) {
			if (_on_error_cb) _on_error_cb(new Exception("Failed to run kdialog"));
			return;
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

		try {
			cb();
		} catch (Throwable err) {
			if (_on_error_cb) _on_error_cb(err);
		}
	}

	override void setPercent(ulong percent) {
		import std.process : ProcessPipes, ProcessException, pipeProcess, Redirect, tryWait, wait;
		import std.algorithm : map;
		import std.array : array;
		import std.conv : to;
		import std.string : format;
		import std.stdio : stdout;
		import progress_dialog_helpers : programPaths;

		string[] paths = programPaths(["qdbus"]);
		if (paths.length < 1) {
			if (_on_error_cb) _on_error_cb(new Exception("Failed to find qdbus"));
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
		} catch (ProcessException err) {
			if (_on_error_cb) _on_error_cb(err);
			return;
		}

		if (wait(pipes.pid) != 0) {
			string[] output = pipes.stderr.byLine.map!(n => n.to!string).array();
			stdout.writefln("!!! setPercent output: %s", output);
			stdout.flush();
			output = pipes.stdout.byLine.map!(n => n.to!string).array();
			stdout.writefln("!!! setPercent output: %s", output);
			stdout.flush();
			if (_on_error_cb) _on_error_cb(new Exception("Failed to set kdialog percent"));
		}
	}

	override void close() {
		import std.process : ProcessPipes, ProcessException, pipeProcess, Redirect, tryWait, wait;
		import std.algorithm : map;
		import std.array : array;
		import std.conv : to;
		import std.string : format;
		import std.stdio : stdout;
		import progress_dialog_helpers : programPaths;

		this.setPercent(100);

		string[] paths = programPaths(["qdbus"]);
		if (paths.length < 1) {
			if (_on_error_cb) _on_error_cb(new Exception("Failed to find qdbus"));
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
		} catch (ProcessException err) {
			if (_on_error_cb) _on_error_cb(err);
			return;
		}

		if (wait(pipes.pid) != 0) {
			string[] output = pipes.stderr.byLine.map!(n => n.to!string).array();
			stdout.writefln("!!! setPercent output: %s", output);
			stdout.flush();
			output = pipes.stdout.byLine.map!(n => n.to!string).array();
			stdout.writefln("!!! setPercent output: %s", output);
			stdout.flush();
			if (_on_error_cb) _on_error_cb(new Exception("Failed to close kdialog"));
		}
	}

	static bool isSupported() {
		import progress_dialog_helpers : programPaths;
		return programPaths(["kdialog"]).length > 0 && programPaths(["qdbus"]).length > 0;
	}

	string _qdbus_id;
	ProcessPipes _pipes;
}
