# frozen_string_literal: true
#
# itk ([incr Tk]) extension - REMOVED
#
# itk is a mega-widget framework built on itcl. Deprecated by vendors
# (Sept 2024) - not thread-safe, minimal development since ~2014.
#
# Deprecation source (Terma, Sept 2024):
#   https://tgss.terma.com/tcl-packages-itcl-itk-and-iwidgets-are-deprecated/
# Tcl wiki:
#   https://wiki.tcl-lang.org/page/incr+Tk
#
# See lib/tkextlib/itk/DEPRECATED.md for more details.

raise LoadError, <<~MSG
  tkextlib/itk has been removed (January 2025).

  [incr Tk] (itk) is deprecated by vendors (Sept 2024) - not thread-safe
  and has seen minimal development since ~2014. Use ttk instead.

  Sources:
    https://tgss.terma.com/tcl-packages-itcl-itk-and-iwidgets-are-deprecated/
    https://wiki.tcl-lang.org/page/incr+Tk

  See lib/tkextlib/itk/DEPRECATED.md for more details.
MSG
