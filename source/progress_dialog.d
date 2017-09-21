// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple progress dialog for the D programming language
// https://github.com/workhorsy/d-progress-dialog


module progress_dialog;



abstract class ProgressDialogBase {
	import std.process : ProcessPipes;

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

class ProgressDialog {
/*
	import progress_dialog_zenity : ProgressDialogZenity;
	import progress_dialog_kdialog : ProgressDialogKDialog;
	import progress_dialog_win32 : ProgressDialogWin32;
*/
	import progress_dialog_dlangui : ProgressDialogDlangUI;

	this(string title, string message) {
/*
		if (ProgressDialogWin32.isSupported()) {
			_dialog = new ProgressDialogWin32(title, message);
		} else if (ProgressDialogZenity.isSupported()) {
			_dialog = new ProgressDialogZenity(title, message);
		} else if (ProgressDialogKDialog.isSupported()) {
			_dialog = new ProgressDialogKDialog(title, message);
		} else if (ProgressDialogDlangUI.isSupported()) {
*/
			_dialog = new ProgressDialogDlangUI(title, message);
/*
		}
*/
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
