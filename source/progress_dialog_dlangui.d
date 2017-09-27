// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple progress dialog for the D programming language
// https://github.com/workhorsy/d-progress-dialog


module progress_dialog_dlangui;

import progress_dialog : ProgressDialogBase;
import std.stdio;
import dlangui;


class ProgressDialogDlangUI : ProgressDialogBase {
	import dlangui.widgets.progressbar : ProgressBarWidget;

	this(string title, string message) {
		super(title, message);
	}

	override void show(void delegate() cb) {
		import std.conv : to;
		import core.thread : Thread;

		// create window
		auto flags = WindowFlag.Modal;
		_window = Platform.instance.createWindow(_title.to!dstring, null, flags, 300, 150);

		auto vlayout = new VerticalLayout();
		vlayout.margins = 20;
		vlayout.padding = 10;

		auto text = new TextWidget(null, _message.to!dstring);

		_progress_bar = new ProgressBarWidget();
		_progress_bar.progress = 300;
		_progress_bar.animationInterval = 50;

		vlayout.addChild(text);
		vlayout.addChild(_progress_bar);
		_window.mainWidget = vlayout;

		// show window
		_window.show();

		auto composed = new Thread({
			try {
				cb();
			} catch (Throwable err) {
				this.fireOnError(err);
			}
		});
		composed.start();

		Platform.instance.enterMessageLoop();
	}

	override void setPercent(int percent) {
		_percent = percent;
		_progress_bar.progress = _percent * 10;
	}

	override void close() {
		this.setPercent(100);
		_window.close();
	}

	static bool isSupported() {
		version (Windows) {
			return true;
		} else version (Have_derelict_sdl2) {
			import progress_dialog : is_sdl2_loadable;
			return is_sdl2_loadable;
		} else {
			return false;
		}
	}

	int _retval;
	int _percent;
	ProgressBarWidget _progress_bar;
	Window _window;
}
