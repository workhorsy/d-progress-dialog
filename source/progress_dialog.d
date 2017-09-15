// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple progress dialog for the D programming language
// https://github.com/workhorsy/d-progress-dialog


module progress_dialog;

import std.process : ProcessPipes;
import std.stdio;
import progress_dialog_zenity : ProgressDialogZenity;
import progress_dialog_kdialog : ProgressDialogKDialog;
import helpers;


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
