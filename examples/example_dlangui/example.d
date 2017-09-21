
module app;

// reset && dub run --arch=x86_64 --build=debug
import dlangui;

mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
	import dlangui.widgets.progressbar : ProgressBarWidget;

	// create window
	auto flags = WindowFlag.Modal;
	Window window = Platform.instance.createWindow("Wating ...", null, flags);

	auto vlayout = new VerticalLayout();
	vlayout.margins = 20;
	vlayout.padding = 10;
	vlayout.backgroundColor = 0xFFFFC0;

	auto text = new TextWidget(null, "Loading ..."d);

	auto progress_bar = new ProgressBarWidget();
	// set progress
	progress_bar.progress = 300; // 0 .. 1000
	// set animation interval
	progress_bar.animationInterval = 50; // 50 milliseconds

	vlayout.addChild(text);
	vlayout.addChild(progress_bar);
	window.mainWidget = vlayout;

	// show window
	window.show();

	// run message loop
	return Platform.instance.enterMessageLoop();
}
