// Copyright (c) 2017-2018 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple progress dialog for the D programming language
// https://github.com/workhorsy/d-progress-dialog

/*
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

	// FIXME: This passes the percent to the WndProc, but it does not display
	// unless a repaint is triggered.
	override void setPercent(int percent) {
		static int _percent;
		_percent = percent;
		WPARAM param = cast(WPARAM)&_percent;
		PostMessage(_hwnd, WM_USER, param, LPARAM.init);
		//PostMessage(_hwnd, WM_PAINT, WPARAM.init, LPARAM.init);
	}

	override void close() {
		this.setPercent(100);
		PostMessage(_hwnd, WM_QUIT, WPARAM.init, LPARAM.init);
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
			int result = myWinMain(this, hInstance, hInstance, lpCmdLine, iCmdShow);
			stderr.writefln("result: %s", result);
			//Runtime.terminate();
		} catch (Throwable err) {
			stderr.writefln("%s", err);
		}
	}

	HWND _hwnd;
}

int myWinMain(ProgressDialogWin32 self, HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow) {
	string appName = "ProgressDialog";
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

	self._hwnd = CreateWindow(
		appName.toUTF16z,      // window class name
		self._message.toUTF16z,     // window caption
		WS_OVERLAPPEDWINDOW,
		//WS_OVERLAPPED | WS_SYSMENU  | WS_DLGFRAME,  // window style
		CW_USEDEFAULT,        // initial x position
		CW_USEDEFAULT,        // initial y position
		CW_USEDEFAULT,        // initial x size
		CW_USEDEFAULT,        // initial y size
		NULL,                 // parent window handle
		NULL,                 // window menu handle
		hInstance,            // program instance handle
		NULL
	);

	ShowWindow(self._hwnd, iCmdShow);
	UpdateWindow(self._hwnd);

	while (GetMessage(&msg, NULL, 0, 0)) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

	return 0;//msg.wParam;
}

extern(Windows) nothrow LRESULT WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) {
	import std.conv : to;

	HDC hdc;
	PAINTSTRUCT ps;
	RECT rect;
	const(wchar)* str_percent = "0";
	ulong* data;
	static ulong ulong_percent;

	switch (message) {
		case WM_USER:
			printf("WM_USER\n");
			try {
				data = cast(ulong*) wParam;
				ulong_percent = *data;
				stdout.writefln("!!! message: %s", message);
				stdout.writefln("!!! wParam: %s", wParam);
				stdout.writefln("!!! data: %s", *data);
				stdout.writefln("!!! ulong_percent: %s", ulong_percent);
				stdout.flush();
			} catch (Throwable) {
			}
			return 0;
		case WM_PAINT:
			hdc = BeginPaint(hwnd, &ps);
			scope(exit) EndPaint(hwnd, &ps);

			GetClientRect(hwnd, &rect);
			try {
				str_percent = ulong_percent.to!string.toUTF16z;
			} catch (Throwable) {
			}
			DrawText(hdc, str_percent, -1, &rect, DT_SINGLELINE | DT_CENTER | DT_VCENTER);
			return 0;
		case WM_CREATE:
			printf("WM_CREATE\n");
			return 0;
		case WM_DESTROY:
			printf("WM_DESTROY\n");
			PostQuitMessage(0);
			return 0;
		case WM_QUIT:
			printf("WM_QUIT\n");
			return 0;
		case WM_CLOSE:
			printf("WM_CLOSE\n");
			DestroyWindow(hwnd);
			return 0;
		default:
	}

	return DefWindowProc(hwnd, message, wParam, lParam);
}
*/
