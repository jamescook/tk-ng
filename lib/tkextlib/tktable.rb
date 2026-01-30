# frozen_string_literal: true
#
# tktable extension - REMOVED
#
# TkTable is a spreadsheet-like widget. Original SourceForge project
# inactive, but active forks exist on GitHub (wjoye/tktable v2.10.7).
# Ruby wrappers removed - relied on internal methods that no longer exist.
#
# Original project:
#   https://tktable.sourceforge.net/
# Active fork:
#   https://github.com/wjoye/tktable
# Tcl wiki:
#   https://wiki.tcl-lang.org/page/Tktable
#
# See lib/tkextlib/tktable/DEPRECATED.md for more details.

raise LoadError, <<~MSG
  tkextlib/tktable has been removed (January 2025).

  Ruby wrappers removed - relied on internal methods that no longer exist.
  TkTable itself has active forks on GitHub (wjoye/tktable).

  If you install tktable, use Tk.tk_call to interact with it directly.

  Sources:
    https://github.com/wjoye/tktable
    https://wiki.tcl-lang.org/page/Tktable

  See lib/tkextlib/tktable/DEPRECATED.md for more details.
MSG
