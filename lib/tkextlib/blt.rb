# frozen_string_literal: true
#
# BLT extension - REMOVED
#
# BLT provided plotting widgets (graph, barchart, stripchart), vectors,
# drag-and-drop, busy command, and other utilities.
#
# The project has some ongoing development but the official website still
# lists Tcl/Tk 8.4 as the supported version. Not currently supported here.
#
# References:
#   https://wiki.tcl-lang.org/page/BLT
#   https://sourceforge.net/p/blt/src/ci/master/tree/
#
# See lib/tkextlib/blt/DEPRECATED.md for more details.

raise LoadError, <<~MSG
  tkextlib/blt has been removed (January 2025).

  BLT provided plotting widgets, vectors, drag-and-drop, and more.
  The project has some ongoing development, but the official website
  still lists Tcl/Tk 8.4 as the supported version.

  If you have a working BLT installation, you can use Tk.tk_call
  directly to interact with BLT commands.

  References:
    https://wiki.tcl-lang.org/page/BLT
    https://sourceforge.net/p/blt/src/ci/master/tree/

  See lib/tkextlib/blt/DEPRECATED.md for more details.
MSG
