



int main() {
	import progress_bar;
	import std.stdio : stdout, stderr;
	import core.thread;

	// Create the dialog
	auto dialog = new ProgressBarZenity("It's waitin' time!", "Waiting ...");

	// Show the progress bar
	if (! dialog.show()) {
		stderr.writefln("Failed to show progress bar.");
	}

	// Update the progress for 10 seconds
	ulong percent = 0;
	while (percent < 100) {
		dialog.setPercent(percent);
		percent += 20;
		Thread.sleep(1.seconds);
		//stdout.writefln("percent: %s", percent);
	}

	// Close the dialog
	dialog.close();

	return 0;
}
