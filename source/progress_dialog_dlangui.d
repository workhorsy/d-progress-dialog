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

	override bool show() {
//		import core.thread : Thread;

		// create window
		auto flags = WindowFlag.Modal;
		_window = Platform.instance.createWindow("FIXME: Title here"d, null, flags);

		auto vlayout = new VerticalLayout();
		vlayout.margins = 20;
		vlayout.padding = 10;
		vlayout.backgroundColor = 0xFFFFC0;

		auto text = new TextWidget(null, "FIXME: Message here"d);

		_progress_bar = new ProgressBarWidget();
		_progress_bar.progress = 300;
		_progress_bar.animationInterval = 50;

		vlayout.addChild(text);
		vlayout.addChild(_progress_bar);
		_window.mainWidget = vlayout;

		// show window
		_window.show();
//		Platform.instance.enterMessageLoop();
/*
		// Run the window events in a thread
		try {
			auto composed = new Thread({
				_retval = Platform.instance.enterMessageLoop();
			});
			composed.start();
		} catch (Throwable) {
			return false;
		}
*/
		return true;
	}

	override void run(void delegate() cb) {
		import core.thread : Thread;

		auto composed = new Thread(cb);
		composed.start();

		Platform.instance.enterMessageLoop();
	}

	override void setPercent(ulong percent) { // FIXME: Change from ulong to int
		_percent = percent;
		_progress_bar.progress = cast(int) (_percent * 10);
	}

	override void close() {
		this.setPercent(100);
		_window.close();
	}

	static bool isSupported() {
		version (Windows) {
			return true;
		} else version (Have_derelict_sdl2) {
			return true;
		} else {
			return false;
		}
	}

	int _retval;
	ulong _percent;
	ProgressBarWidget _progress_bar;
	Window _window;
}
