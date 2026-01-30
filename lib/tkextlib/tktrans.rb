# frozen_string_literal: true
#
# tktrans extension - REMOVED
#
# TkTrans was a Windows-only transparency extension (~2003-2005),
# obsolete since Tk 8.4.16 added built-in transparency.
#
# Tcl wiki:
#   https://wiki.tcl-lang.org/page/TkTrans
#
# See lib/tkextlib/tktrans/DEPRECATED.md for more details.

raise LoadError, <<~MSG
  tkextlib/tktrans has been removed (January 2025).

  TkTrans (Windows-only, ~2003-2005) is obsolete.
  Use built-in Tk transparency instead:
    wm attributes $window -alpha 0.5
    wm attributes $window -transparentcolor $color

  Source:
    https://wiki.tcl-lang.org/page/TkTrans

  See lib/tkextlib/tktrans/DEPRECATED.md for more details.
MSG
