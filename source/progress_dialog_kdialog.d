// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple progress dialog for the D programming language
// https://github.com/workhorsy/d-progress-dialog


module progress_dialog_kdialog;

import progress_dialog : ProgressDialogBase, use_log;


class ProgressDialogKDialog : ProgressDialogBase {
	import std.process : ProcessPipes;

	this(string title, string message) {
		super(title, message);
	}

	override void show(void delegate() cb) {
		import std.process : ProcessPipes, ProcessException, pipeProcess, Redirect, tryWait;
		import progress_dialog_helpers : programPaths, logProgramOutput;

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

		_pipes = pipes;

		try {
			cb();
			if (use_log) {
				logProgramOutput(_pipes, true);
			}
		} catch (Throwable err) {
			if (_on_error_cb) _on_error_cb(err);
		}
	}

	override void setPercent(int percent) {
		import std.process : ProcessPipes, ProcessException, pipeProcess, Redirect, tryWait, wait;
		import std.string : format;
		import progress_dialog_helpers : programPaths, logProgramOutput;

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
			if (_on_error_cb) _on_error_cb(new Exception("Failed to set kdialog percent"));
		}

		if (use_log) {
			logProgramOutput(pipes, false);
		}
	}

	override void close() {
		import std.process : ProcessPipes, ProcessException, pipeProcess, Redirect, tryWait, wait;
		import progress_dialog_helpers : programPaths, logProgramOutput;

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
			if (_on_error_cb) _on_error_cb(new Exception("Failed to close kdialog"));
		}

		if (use_log) {
			logProgramOutput(pipes, true);
		}
	}

	static bool isSupported() {
		import progress_dialog_helpers : programPaths;
		return programPaths(["kdialog"]).length > 0 && programPaths(["qdbus"]).length > 0;
	}

	string _qdbus_id;
	ProcessPipes _pipes;
}
