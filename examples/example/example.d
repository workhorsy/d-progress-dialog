

import std.stdio : stdout, stderr;
import progress_dialog : ProgressDialog, RUN_MAIN;



extern (C) int UIAppMain(string[] args) {
	import core.thread;

	// Create the dialog
	auto dialog = new ProgressDialog("It's waitin' time!", "Waiting ...");

	// Show the progress dialog
	if (! dialog.show()) {
		stderr.writefln("Failed to show progress dialog.");
	}

	dialog.run({
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
	});

	return 0;
}


mixin RUN_MAIN;
