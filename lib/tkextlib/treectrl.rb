# frozen_string_literal: true
#
# treectrl extension - REMOVED
#
# TkTreeCtrl was a tree widget, last release v2.2.10 (~2010).
# Use ttk::treeview instead (built into Tk 8.5+).
#
# SourceForge:
#   https://tktreectrl.sourceforge.net/
# GitHub mirror:
#   https://github.com/davidw/tktreectrl
# Tcl wiki:
#   https://wiki.tcl-lang.org/page/TkTreeCtrl
#
# See lib/tkextlib/treectrl/DEPRECATED.md for more details.

raise LoadError, <<~MSG
  tkextlib/treectrl has been removed (January 2025).

  TkTreeCtrl last release was v2.2.10 (~2010).
  Use ttk::treeview instead (built into Tk 8.5+).

  Sources:
    https://tktreectrl.sourceforge.net/
    https://wiki.tcl-lang.org/page/TkTreeCtrl

  See lib/tkextlib/treectrl/DEPRECATED.md for more details.
MSG
