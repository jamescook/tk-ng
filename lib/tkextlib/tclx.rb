# frozen_string_literal: true
#
# tclx (Extended Tcl) extension - REMOVED
#
# TclX provides POSIX system APIs to Tcl. Last release 8.4.1 (Nov 2012),
# no longer actively maintained. For Ruby apps, use Ruby's built-in
# facilities instead.
#
# GitHub (flightaware):
#   https://github.com/flightaware/tclx
# Tcl wiki:
#   https://wiki.tcl-lang.org/page/TclX
#
# See lib/tkextlib/tclx/DEPRECATED.md for more details.

raise LoadError, <<~MSG
  tkextlib/tclx has been removed (January 2025).

  TclX (last release 8.4.1, Nov 2012) provides POSIX APIs to Tcl.
  For Ruby applications, use Ruby's built-in facilities:
    - Signals: Signal.trap
    - System info: RbConfig, RUBY_PLATFORM
    - Message catalogs: i18n gems

  Sources:
    https://github.com/flightaware/tclx
    https://wiki.tcl-lang.org/page/TclX

  See lib/tkextlib/tclx/DEPRECATED.md for more details.
MSG
