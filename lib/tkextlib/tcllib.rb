# frozen_string_literal: true
#
# tcllib/tklib extension - REMOVED
#
# Provided Ruby wrappers for tklib widgets: tooltip, tablelist,
# plotchart, ctext, calendar, autoscroll, cursor, and many more.
#
# Removed because:
#   - Ruby wrappers relied on removed __*_optkeys methods
#   - No tests meant breakage went undetected
#   - tklib requires manual installation (not in Homebrew)
#
# tklib itself is actively maintained (v0.9, December 2024):
#   https://core.tcl-lang.org/tklib/
#
# See lib/tkextlib/tcllib/DEPRECATED.md for more details.

raise LoadError, <<~MSG
  tkextlib/tcllib has been removed (January 2025).

  The Ruby wrappers for tklib widgets (tooltip, tablelist, plotchart,
  ctext, calendar, autoscroll, etc.) were removed because they relied
  on internal methods that no longer exist.

  tklib itself is actively maintained (v0.9, December 2024):
    https://core.tcl-lang.org/tklib/

  If you install tklib manually, you can use Tk.tk_call to interact
  with its widgets directly.

  See lib/tkextlib/tcllib/DEPRECATED.md for more details.
MSG
