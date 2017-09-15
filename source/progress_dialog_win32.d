// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple progress dialog for the D programming language
// https://github.com/workhorsy/d-progress-dialog


module progress_dialog_win32;

import progress_dialog : ProgressDialogBase;


class ProgressDialogWin32 : ProgressDialogBase {
	import std.process : ProcessPipes;

	this(string title, string message) {
		super(title, message);
	}

	override bool show() {

		return true;
	}

	override void setPercent(ulong percent) {

	}

	override void close() {

	}

	static bool isSupported() {
		version (Windows) {
			return true;
		} else {
			return false;
		}
	}
}

