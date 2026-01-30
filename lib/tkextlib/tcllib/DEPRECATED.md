# tcllib/tklib Extension - Removed

**Status:** Removed (January 2025)

## Reason

The Ruby wrappers for Tcl's tklib widgets have been removed:

1. **Broken code** - The wrappers relied on `__*_optkeys` methods that were removed during internal cleanup
2. **Known bugs** - Some wrappers had issues (e.g., `WidgetClassNames` not accessible in modules that `extend TkCore`)
3. **No tests** - Could never be tested, so breakage went undetected
4. **Manual install** - tklib is not in Homebrew, requires manual installation

## tklib Status

tklib itself is actively maintained (v0.9, December 2024):
- https://core.tcl-lang.org/tklib/
- https://github.com/tcltk/tklib

## Widgets Removed

All Ruby wrappers from this directory: tooltip, tablelist, ctext, plotchart, calendar, autoscroll, cursor, datefield, getstring, history, ico, ip_entry, khim, ntext, ruler, screenruler, scrollwin, statusbar, style, swaplist, tkpiechart, toolbar, validator, widget, etc.

## Alternative

If you install tklib manually, you can use `Tk.tk_call` to interact with its widgets directly.
