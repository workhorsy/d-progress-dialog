
module app;

// reset && dub run --arch=x86_64 --build=debug
import dlangui;
import dlangui.widgets.progressbar;

mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // create window
    Window window = Platform.instance.createWindow("DlangUI example - HelloWorld", null);

		auto vlayout = new VerticalLayout();
		vlayout.margins = 20; // distance from window frame to vlayout background
		vlayout.padding = 10; // distance from vlayout background bound to child widgets
		vlayout.backgroundColor = 0xFFFFC0;

				auto pb = new ProgressBarWidget();
				// set progress
				pb.progress = 300; // 0 .. 1000
				// set animation interval
				pb.animationInterval = 50; // 50 milliseconds

			vlayout.addChild(pb);
				window.mainWidget = vlayout;

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}
