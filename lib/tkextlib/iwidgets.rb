# frozen_string_literal: true
#
# iwidgets extension - REMOVED
#
# iwidgets is a mega-widget set built on itcl/itk. Deprecated by vendors
# (Sept 2024) - not thread-safe. Consider ttk instead.
#
# Deprecation source (Terma, Sept 2024):
#   https://tgss.terma.com/tcl-packages-itcl-itk-and-iwidgets-are-deprecated/
# Tcl wiki:
#   https://wiki.tcl-lang.org/page/Iwidgets
#
# See lib/tkextlib/iwidgets/DEPRECATED.md for more details.

raise LoadError, <<~MSG
  tkextlib/iwidgets has been removed (January 2025).

  Iwidgets is deprecated by vendors (Sept 2024) - not thread-safe.
  Use ttk (Tk themed widgets) instead.

  Sources:
    https://tgss.terma.com/tcl-packages-itcl-itk-and-iwidgets-are-deprecated/
    https://wiki.tcl-lang.org/page/Iwidgets

  See lib/tkextlib/iwidgets/DEPRECATED.md for more details.
MSG
