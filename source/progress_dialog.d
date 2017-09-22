// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple progress dialog for the D programming language
// https://github.com/workhorsy/d-progress-dialog


module progress_dialog;

bool is_sdl2_loadable = false;

mixin template RUN_MAIN() {
	// On Windows use the normal dlangui main
	version (Windows) {
		import dlangui;
		mixin APP_ENTRY_POINT;
	// On Linux use a custom main that checks if SDL is installed
	} else {
		int main(string[] args) {
			// Figure out if the SDL2 libraries can be loaded
			version (Have_derelict_sdl2) {
				import derelict.sdl2.sdl : DerelictSDL2, SharedLibVersion, SharedLibLoadException;
				import progress_dialog : is_sdl2_loadable;
				try {
					DerelictSDL2.load(SharedLibVersion(2, 0, 2));
					is_sdl2_loadable = true;
					stdout.writefln("SDL was found ...");
				} catch (SharedLibLoadException) {
					stdout.writefln("SDL was NOT found ...");
				}
			}

			// If SDL2 can be loaded, start the SDL2 main
			if (is_sdl2_loadable) {
				import dlangui.platforms.sdl.sdlapp : sdlmain;
				return sdlmain(args);
			// If not, use the normal main provided by the user
			} else {
				return UIAppMain(args);
			}
		}
	}
}

abstract class ProgressDialogBase {
	this(string title, string message) {
		_title = title;
		_message = message;
	}

	void onError(void delegate(Throwable err) cb) {
		_on_error_cb = cb;
	}

	void show(void delegate() cb);
	void setPercent(ulong percent);
	void close();

	string _title;
	string _message;
	void delegate(Throwable err) _on_error_cb;
}

class ProgressDialog {
	import progress_dialog_zenity : ProgressDialogZenity;
	import progress_dialog_kdialog : ProgressDialogKDialog;
	//import progress_dialog_win32 : ProgressDialogWin32;
	import progress_dialog_dlangui : ProgressDialogDlangUI;

	this(string title, string message) {
		/*if (ProgressDialogWin32.isSupported()) {
			_dialog = new ProgressDialogWin32(title, message);
		} else */

		if (ProgressDialogDlangUI.isSupported()) {
			_dialog = new ProgressDialogDlangUI(title, message);
		} else if (ProgressDialogZenity.isSupported()) {
			_dialog = new ProgressDialogZenity(title, message);
		} else if (ProgressDialogKDialog.isSupported()) {
			_dialog = new ProgressDialogKDialog(title, message);
		} else {
			throw new Exception("Failed to find a way to make a progress dialog.");
		}
	}

	void onError(void delegate(Throwable err) cb) {
		_dialog._on_error_cb = cb;
	}

	void show(void delegate() cb) {
		_dialog.show(cb);
	}

	void setPercent(ulong percent) {
		_dialog.setPercent(percent);
	}

	void close() {
		_dialog.close();
	}

	ProgressDialogBase _dialog;
}
