// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// A simple progress dialog for the D programming language
// https://github.com/workhorsy/d-progress-dialog


module progress_dialog_helpers;

import std.process : ProcessPipes;


void logProgramOutput(ProcessPipes pipes) {
	import std.algorithm : map;
	import std.conv : to;
	import std.stdio : stderr, stdout;
	import std.array : array;
	string[] output;

	if (! pipes.stderr.eof) {
		output = pipes.stderr.byLine.map!(n => n.to!string).array();
		stderr.writefln("!!! show stderr: %s", output);
		stderr.flush();
	}

	if (! pipes.stdout.eof) {
		output = pipes.stdout.byLine.map!(n => n.to!string).array();
		stdout.writefln("!!! show stdout: %s", output);
		stdout.flush();
	}
}

bool isExecutable(string path) {
	version (Windows) {
		return true;
	} else {
		import std.file : getAttributes;
		import core.sys.posix.sys.stat : S_IXUSR;
		return (getAttributes(path) & S_IXUSR) > 0;
	}
}

string[] programPaths(string[] program_names) {
	import std.process : environment;
	import std.path : pathSeparator, buildPath;
	import std.file : isDir;
	import std.string : split;
	import glob : glob;

	string[] paths;
	string[] exts;
	if (environment.get("PATHEXT")) {
		exts = environment["PATHEXT"].split(pathSeparator);
	}

	// Each path
	foreach (p ; environment["PATH"].split(pathSeparator)) {
		//stdout.writefln("p: %s", p);
		// Each program name
		foreach (program_name ; program_names) {
			string full_name = buildPath(p, program_name);
			//stdout.writefln("full_name: %s", full_name);
			string[] full_names = glob(full_name);
			//stdout.writefln("full_names: %s", full_names);

			// Each program name that exists in a path
			foreach (name ; full_names) {
				// Save the path if it is executable
				if (name && isExecutable(name) && ! isDir(name)) {
					paths ~= name;
				}
				// Save the path if we found one with a common extension like .exe
				foreach (e; exts) {
					string full_name_ext = name ~ e;

					if (isExecutable(full_name_ext) && ! isDir(full_name_ext)) {
						paths ~= full_name_ext;
					}
				}
			}
		}
	}

	return paths;
}
