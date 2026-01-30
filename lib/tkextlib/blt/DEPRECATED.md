# BLT Extension - Deprecated

**Status:** Removed from Ruby Tk bindings (January 2025)

## Reason

BLT provided plotting widgets (graph, barchart, stripchart), vectors, drag-and-drop, busy command, and other utilities.

The project has some ongoing development at [SourceForge](https://sourceforge.net/p/blt/src/ci/master/tree/), but the official website still lists Tcl/Tk 8.4 as the supported version. Community forks exist ([apnadkarni/blt](https://github.com/apnadkarni/blt), [TkBLT](https://github.com/wjoye/tkblt)) with varying levels of 8.6 support.

## Alternatives

- **Graphing:** TkBLT fork includes Graph and Barchart widgets
- **Vectors:** Consider native Ruby arrays or specialized gems
- **General widgets:** ttk provides modern replacements

## If You Need BLT

If you have a working BLT installation with one of the forks, the Ruby bindings have been removed. You would need to:
1. Use `Tk.tk_call` directly to interact with BLT commands
2. Or create custom Ruby wrappers for the specific BLT features you need
