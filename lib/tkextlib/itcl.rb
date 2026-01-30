# frozen_string_literal: true
#
# itcl ([incr Tcl]) extension - REMOVED
#
# itcl is still in Tcl 8.6+ but deprecated by some vendors (Sept 2024)
# due to thread-safety issues. Ruby wrappers removed because they
# relied on internal methods that no longer exist.
#
# Deprecation source (Terma, Sept 2024):
#   https://tgss.terma.com/tcl-packages-itcl-itk-and-iwidgets-are-deprecated/
# Tcl wiki (still maintained):
#   https://wiki.tcl-lang.org/page/incr+Tcl
#
# See lib/tkextlib/itcl/DEPRECATED.md for more details.

raise LoadError, <<~MSG
  tkextlib/itcl has been removed (January 2025).

  The Ruby wrappers for [incr Tcl] were removed because they relied
  on internal methods that no longer exist.

  itcl is still in Tcl 8.6+ but deprecated by some vendors due to
  thread-safety concerns. For new code, consider TclOO.

  Sources:
    https://tgss.terma.com/tcl-packages-itcl-itk-and-iwidgets-are-deprecated/
    https://wiki.tcl-lang.org/page/incr+Tcl

  See lib/tkextlib/itcl/DEPRECATED.md for more details.
MSG
