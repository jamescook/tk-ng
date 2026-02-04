# frozen_string_literal: false
#
#   tk/mngfocus.rb : methods for Tcl/Tk standard library 'focus.tcl'
#                           by Hidetoshi Nagai <nagai@ai.kyutech.ac.jp>
#
require_relative 'core/callable'

# Focus traversal utilities.
#
# Wraps the Tcl/Tk focus traversal procedures:
#
# - `tk_focusNext window` — Returns the next window after +window+ in
#   focus order. The order follows the stacking order of siblings (lowest
#   first), visiting each window before its children (depth-first).
#   Windows with `-takefocus 0` are skipped. Never crosses top-level
#   boundaries. Used by the default Tab binding.
#
# - `tk_focusPrev window` — Like tk_focusNext but returns the previous
#   window in focus order. Used by the default Shift-Tab binding.
#
# - `tk_focusFollowsMouse` — Switches the application to an implicit
#   focus model where the window under the mouse automatically receives
#   focus. There is no built-in way to revert to explicit focus.
#
# @see https://www.tcl.tk/man/tcl8.6/TkCmd/focusNext.htm Tcl/Tk focusNext manual
# @see https://www.tcl.tk/man/tcl8.6/TkCmd/focus.htm Tcl/Tk focus manual
module TkManageFocus
  extend Tk::Core::Callable

  TkCommandNames = [
    'tk_focusFollowMouse'.freeze,
    'tk_focusNext'.freeze,
    'tk_focusPrev'.freeze
  ].freeze

  def TkManageFocus.followsMouse
    tk_call('tk_focusFollowsMouse')
  end

  def TkManageFocus.next(win)
    id = tk_call('tk_focusNext', win)
    TkCore::INTERP.tk_windows[id] || id
  end
  def focusNext
    TkManageFocus.next(self)
  end

  def TkManageFocus.prev(win)
    id = tk_call('tk_focusPrev', win)
    TkCore::INTERP.tk_windows[id] || id
  end
  def focusPrev
    TkManageFocus.prev(self)
  end
end
