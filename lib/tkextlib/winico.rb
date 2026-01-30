# frozen_string_literal: true
#
# winico extension - REMOVED
#
# Windows Icon extension - Windows-only. Core icon functionality was
# merged into Tk 8.4+ (wm iconbitmap, wm iconphoto). For taskbar/tray,
# consider TWAPI (actively maintained).
#
# winico:
#   https://tktable.sourceforge.net/winico/winico.html
#   https://wiki.tcl-lang.org/page/winico
# TWAPI (modern alternative for Windows APIs):
#   https://twapi.magicsplat.com/
#
# See lib/tkextlib/winico/DEPRECATED.md for more details.

raise LoadError, <<~MSG
  tkextlib/winico has been removed (January 2025).

  winico is Windows-only. Core icon functionality was merged into
  Tk 8.4+ (use wm iconbitmap, wm iconphoto). For taskbar/tray,
  consider TWAPI (https://twapi.magicsplat.com/).

  Sources:
    https://wiki.tcl-lang.org/page/winico

  See lib/tkextlib/winico/DEPRECATED.md for more details.
MSG
