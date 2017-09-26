

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
