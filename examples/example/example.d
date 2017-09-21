

import dlangui;
mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
	import progress_dialog : ProgressDialog;
	import std.stdio : stdout, stderr;
	import core.thread;

	// Create the dialog
	auto dialog = new ProgressDialog("It's waitin' time!", "Waiting ...");

	// Show the progress dialog
	if (! dialog.show()) {
		stderr.writefln("Failed to show progress dialog.");
	}

	// Run the window events in a thread
	try {
		auto composed = new Thread({
			Platform.instance.enterMessageLoop();
		});
		composed.start();
	} catch (Throwable) {
		return false;
	}

	// Update the progress for 5 seconds
	ulong percent = 0;
	while (percent < 100) {
		dialog.setPercent(percent);
		percent += 20;
		Thread.sleep(1.seconds);
		stdout.writefln("percent: %s", percent);
		stdout.flush();
	}

	// Close the dialog
	dialog.close();

	return 0;
}
