# D Progress Dialog
A simple progress dialog for the D programming language

It should work without requiring any 3rd party GUI toolkits. But will work with what it can find on your OS at runtime.

Tries to make a progress dialog with:
* DlangUI (win32 on Windows or SDL2 on Linux)
* Zenity (Gtk/Gnome)
* Kdialog (KDE)

# Documentation

[https://workhorsy.github.io/d-progress-dialog/0.2.0/](https://workhorsy.github.io/d-progress-dialog/0.2.0/)

# Generate documentation

```
dub --build=docs
```


[![Dub version](https://img.shields.io/dub/v/d-progress-dialog.svg)](https://code.dlang.org/packages/d-progress-dialog)
[![Dub downloads](https://img.shields.io/dub/dt/d-progress-dialog.svg)](https://code.dlang.org/packages/d-progress-dialog)
[![License](https://img.shields.io/badge/license-BSL_1.0-blue.svg)](https://raw.githubusercontent.com/workhorsy/d-progress-dialog/master/LICENSE)
