// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple progress dialog for the D programming language
// https://github.com/workhorsy/d-progress-dialog


module progress_dialog_win32;

import progress_dialog : ProgressDialogBase;
//import core.runtime;
import std.stdio;
import core.sys.windows.windows;
//import std.process : ProcessPipes;

auto toUTF16z(S)(S s) {
	import std.utf : toUTFz;
	return toUTFz!(const(wchar)*)(s);
}

class ProgressDialogWin32 : ProgressDialogBase {
	this(string title, string message) {
		super(title, message);
	}

	override bool show() {
		import core.thread : Thread;

		try {
			auto composed = new Thread({
				this.showInThread();
			});
			composed.start();
		} catch (Throwable) {
			return false;
		}

		return true;
	}

	override void setPercent(ulong percent) {

	}

	override void close() {

	}

	static bool isSupported() {
		version (Windows) {
			return true;
		} else {
			return false;
		}
	}

	private void showInThread() {
		//void exceptionHandler(Throwable e) { throw e; }
		HINSTANCE hInstance;
		HINSTANCE hPrevInstance;
		LPSTR lpCmdLine;
		int iCmdShow = 10;
		//stdout.writefln("iCmdShow: %s", iCmdShow);

		try {
			//Runtime.initialize();
			// result = myWinMain(hInstance, hPrevInstance, lpCmdLine, iCmdShow);
			int result = myWinMain(_title, _message, hInstance, hInstance, lpCmdLine, iCmdShow);
			stderr.writefln("result: %s", result);
			//Runtime.terminate();
		} catch (Throwable err) {
			stderr.writefln("%s", err);
		}
	}
}

int myWinMain(string title, string message, HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow) {
	string appName = "ProgressDialog";
	HWND hwnd;
	MSG  msg;
	WNDCLASS wndclass;

	wndclass.style         = CS_HREDRAW | CS_VREDRAW;
	wndclass.lpfnWndProc   = &WndProc;
	wndclass.cbClsExtra    = 0;
	wndclass.cbWndExtra    = 0;
	wndclass.hInstance     = hInstance;
	wndclass.hIcon         = LoadIcon(NULL, IDI_APPLICATION);
	wndclass.hCursor       = LoadCursor(NULL, IDC_ARROW);
	//wndclass.hbrBackground = cast(HBRUSH)GetStockObject(WHITE_BRUSH);
	wndclass.lpszMenuName  = NULL;
	wndclass.lpszClassName = appName.toUTF16z;

	if (! RegisterClass(&wndclass)) {
		throw new Exception("This program requires Windows NT!");
	}

	hwnd = CreateWindow(
		appName.toUTF16z,      // window class name
		message.toUTF16z,     // window caption
		// WS_OVERLAPPEDWINDOW
		WS_OVERLAPPED | WS_SYSMENU  | WS_DLGFRAME,  // window style
		CW_USEDEFAULT,        // initial x position
		CW_USEDEFAULT,        // initial y position
		CW_USEDEFAULT,        // initial x size
		CW_USEDEFAULT,        // initial y size
		NULL,                 // parent window handle
		NULL,                 // window menu handle
		hInstance,            // program instance handle
		NULL
	);

	ShowWindow(hwnd, iCmdShow);
	UpdateWindow(hwnd);

	while (GetMessage(&msg, NULL, 0, 0)) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

	return msg.wParam;
}

extern(Windows) nothrow LRESULT WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) {
	HDC hdc;
	PAINTSTRUCT ps;
	RECT rect;
	try {
		//stdout.writefln("!!! message: %s", message);
		//stdout.flush();
	} catch (Throwable) {
	}

	switch (message) {
		case WM_CREATE:
			return 0;
		case WM_PAINT:
			hdc = BeginPaint(hwnd, &ps);
			scope(exit) EndPaint(hwnd, &ps);

			GetClientRect(hwnd, &rect);
			DrawText(hdc, "FIXME: Put progress bar here", -1, &rect, DT_SINGLELINE | DT_CENTER | DT_VCENTER);
			return 0;
		case WM_DESTROY:
			PostQuitMessage(0);
			return 0;
		default:
	}

	return DefWindowProc(hwnd, message, wParam, lParam);
}
