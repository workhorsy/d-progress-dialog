



int main() {
	import progress_bar : ProgressBar;
	import std.stdio : stdout, stderr;
	import core.thread;

	auto dialog = new ProgressBar("It's waitin' time!", "Waiting ...");

	// Show the progress bar
	if (! dialog.show()) {
		stderr.writefln("Failed to show progress bar.");
	}

	ulong percent = 0;
	while (percent < 100) {
		dialog.setPercent(percent);
		percent += 20;
		Thread.sleep(1.seconds);
		stdout.writefln("percent: %s", percent);
	}

	dialog.close();

	return 0;
}
