

import std.stdio : stdout, stderr;
import progress_dialog : ProgressDialog;



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


version (Windows) {
	import dlangui;
	mixin APP_ENTRY_POINT;
} else {
	int main(string[] args) {
		import derelict.sdl2.sdl : DerelictSDL2, SharedLibVersion, SharedLibLoadException;

		version (Have_derelict_sdl2) {
			bool can_sdl = false;
			try {
				DerelictSDL2.load(SharedLibVersion(2, 0, 2));
				can_sdl = true;
				stdout.writefln("SDL was found ...");
			} catch (SharedLibLoadException) {
				stdout.writefln("SDL was NOT found ...");
			}

			if (can_sdl) {
				import dlangui.platforms.sdl.sdlapp : sdlmain;
				return sdlmain(args);
			} else {
				return UIAppMain(args);
			}
		} else {
			return 0;
		}
	}
}
