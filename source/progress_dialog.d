// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple progress dialog for the D programming language
// https://github.com/workhorsy/d-progress-dialog

/++
A simple progress dialog for the D programming language

It should work without requiring any 3rd party GUI toolkits. But will work with what it can find on your OS at runtime.

Tries to make a progress dialog with:

* DlangUI (win32 on Windows or SDL2 on Linux)

* Zenity (Gtk/Gnome)

* Kdialog (KDE)

Home page:
$(LINK https://github.com/workhorsy/d-progress-dialog)

Version: 0.1.0

License:
Boost Software License - Version 1.0

Examples:
----
import std.stdio : stdout, stderr;
import progress_dialog : ProgressDialog, RUN_MAIN;

mixin RUN_MAIN;

extern (C) int UIAppMain(string[] args) {
	import core.thread;

	// Create the dialog
	auto dialog = new ProgressDialog("It's waitin' time!", "Waiting ...");

	// Set the error handler
	dialog.onError((Throwable err) {
		stderr.writefln("Failed to show progress dialog: %s", err);
		dialog.close();
	});

	// Show the progress dialog
	dialog.show({
		// Update the progress for 5 seconds
		int percent = 0;
		while (percent < 100) {
			dialog.setPercent(percent);
			percent += 20;
			Thread.sleep(1.seconds);
			stdout.writefln("percent: %s", percent);
			stdout.flush();
		}

		// Close the dialog
		dialog.close();
	});

	return 0;
}

----
+/

module progress_dialog;

bool is_sdl2_loadable = false;
bool use_log = true;

/++
This should be called once at the start of a program. It generates the proper
main function for your environment (win32/posix/dmain) and boot straps the
main loop for the GUI. This will call your UIAppMain function when ready.
+/
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

/++
If true will print output of external program to console.
Params:
 is_logging = If true will print to output
+/
public void setUseLog(bool is_logging) {
	use_log = is_logging;
}

/++
Returns if external program logging is on or off.
+/
public bool getUseLog() {
	return use_log;
}

abstract class ProgressDialogBase {
	this(string title, string message) {
		_title = title;
		_message = message;
	}

	void onError(void delegate(Throwable err) cb) {
		_on_error_cb = cb;
	}

	void fireOnError(Throwable err) {
		auto old_cb = _on_error_cb;
		_on_error_cb = null;

		if (old_cb) old_cb(err);
	}

	void show(void delegate() cb);
	void setPercent(int percent);
	void close();

	string _title;
	string _message;
	void delegate(Throwable err) _on_error_cb;
}

/++
The ProgressDialog class
+/
class ProgressDialog {
	import progress_dialog_zenity : ProgressDialogZenity;
	import progress_dialog_kdialog : ProgressDialogKDialog;
	//import progress_dialog_win32 : ProgressDialogWin32;
	import progress_dialog_dlangui : ProgressDialogDlangUI;

	/++
	Sets up the progress dialog with the desired title, and message. Does not
	show it until the show method is called.
	Params:
	 title = The string to show in the progress dialog title
	 message = The string to show in the progress dialog body
	Throws:
	 If it fails to find any programs or libraries to make a progress dialog with.
	+/
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

	/++
	This method is called if there is an error when showing the progress dialog.
	Params:
	 cb = The call back to fire when there is an error.
	+/
	void onError(void delegate(Throwable err) cb) {
		_dialog._on_error_cb = cb;
	}

	/++
	Shows the progress dialog. Will run the callback in a thread and
	block until it is closed or percent reaches 100.
	+/
	void show(void delegate() cb) {
		_dialog.show(cb);
	}

	/++
	Set the percent of the progess bar. Will close on 100.
	Params:
	 percent = from 0 to 100
	+/
	void setPercent(int percent) {
		_dialog.setPercent(percent);
	}

	/++
	Close the dialog.
	+/
	void close() {
		_dialog.close();
	}

	ProgressDialogBase _dialog;
}
