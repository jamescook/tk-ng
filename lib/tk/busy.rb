# frozen_string_literal: false
#
# tk/busy.rb: support 'tk busy' command (Tcl/Tk8.6 or later)
#
require 'tk/item_option_dsl'

# Blocks mouse pointer events while displaying a busy cursor.
#
# The Tk::Busy module provides a way to prevent user interactions during
# long-running operations by placing a transparent "busy window" over
# widgets. This is useful for preventing double-clicks on buttons or
# accidental input during processing.
#
# @note **Keyboard events still pass through**: The busy window only blocks
#   mouse events. If a widget already has keyboard focus, it will continue
#   to receive keystrokes. Move focus explicitly if needed.
#
# @note **macOS limitation**: This command has no effect on macOS with
#   Aqua-based Tk builds (the native macOS Tk).
#
# @example Making a window busy during processing
#   root = TkRoot.new
#   Tk::Busy.hold(root, cursor: 'watch')
#   Tk.update  # Required for busy window to appear
#   # ... do processing ...
#   Tk::Busy.forget(root)
#
# @example Using instance methods on a window
#   my_frame.busy              # Make busy with default cursor
#   # ... processing ...
#   my_frame.busy_forget       # Restore normal interaction
#
# @example Checking busy status
#   if my_frame.busy_status
#     puts "Frame is currently busy"
#   end
#
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/busy.htm Tcl/Tk busy manual
module Tk::Busy
  include TkCore
  extend TkCore
  extend Tk::ItemOptionDSL

  # Declare item command structure for tk busy
  # The "id" is a window, and we need its path
  item_cget_cmd { |win| ['tk', 'busy', 'cget', win.path] }
  item_configure_cmd { |win| ['tk', 'busy', 'configure', win.path] }
end

class << Tk::Busy
  alias cget_tkstring itemcget_tkstring
  alias cget itemcget
  alias cget_strict itemcget_strict
  alias configure itemconfigure
  alias configinfo itemconfiginfo
  alias current_configinfo current_itemconfiginfo

  private :itemcget_tkstring, :itemcget, :itemcget_strict
  private :itemconfigure, :itemconfiginfo, :current_itemconfiginfo

  # Get the busy cursor for a window.
  # @param win [TkWindow] The busy window
  # @return [String] Cursor name
  def cursor(win)
    cget(win, 'cursor')
  end

  # Set the busy cursor for a window.
  # @param win [TkWindow] The busy window
  # @param cursor_name [String] Cursor to display (e.g., 'watch', 'wait')
  # @return [self]
  def set_cursor(win, cursor_name)
    configure(win, 'cursor', cursor_name)
    self
  end

  def method_missing(id, *args)
    name = id.id2name
    Tk::Warnings.warn_once(:"busy_method_missing_#{name}",
      "Tk::Busy.#{name} called via method_missing. " \
      "Use Tk::Busy.cget/configure or explicit accessors instead.")
    case args.length
    when 1
      if name[-1] == ?=
        configure name[0..-2], args[0]
        args[0]
      else
        configure name, args[0]
        self
      end
    when 0
      begin
        cget(name)
      rescue
        super(id, *args)
      end
    else
      super(id, *args)
    end
  end

  # Makes a widget and its descendants busy.
  #
  # Places a transparent window in front of the widget, blocking mouse events
  # and displaying a busy cursor.
  #
  # @param win [TkWindow] The window to make busy
  # @param keys [Hash] Options (primarily :cursor)
  # @option keys [String] :cursor Cursor to display (default: "wait" on Windows,
  #   "watch" on other platforms)
  # @return [TkWindow] The window that was made busy
  # @note You must call `Tk.update` after hold for the busy window to appear
  #   immediately.
  def hold(win, keys={})
    tk_call_without_enc('tk', 'busy', 'hold', win, *hash_kv(keys))
    win
  end

  # Releases busy status and restores normal event handling.
  # @param wins [Array<TkWindow>] Windows to release
  # @return [self]
  def forget(*wins)
    tk_call_without_enc('tk', 'busy', 'forget', *wins)
    self
  end

  # Returns pathnames of all currently busy widgets.
  # @param pat [String, nil] Optional glob pattern to filter results
  # @return [Array<String>] List of busy widget paths
  def current(pat=None)
    list(tk_call('tk', 'busy', 'current', pat))
  end

  # Checks if a widget is currently busy.
  # @param win [TkWindow] The window to check
  # @return [Boolean] true if the widget cannot receive user interactions
  def status(win)
    bool(tk_call_without_enc('tk', 'busy', 'status', win))
  end
end

# Instance methods mixed into TkWindow for convenient busy control.
# @see Tk::Busy Module-level documentation
module Tk::Busy
  # @!group Instance Methods (mixed into TkWindow)

  # Returns busy configuration info for this window.
  # @param option [String, nil] Specific option to query, or nil for all
  # @return [Hash, String] Configuration info
  def busy_configinfo(option=nil)
    Tk::Busy.configinfo(self, option)
  end

  # Returns current busy configuration for this window.
  # @param option [String, nil] Specific option to query, or nil for all
  # @return [Hash, String] Current configuration
  def busy_current_configinfo(option=nil)
    Tk::Busy.current_configinfo(self, option)
  end

  # Configures busy window options for this widget.
  # @param option [String] Option name
  # @param value [Object] Option value
  # @return [self]
  def busy_configure(option, value=None)
    Tk::Busy.configure(self, option, value)
    self
  end

  # Gets a busy configuration option.
  # @param option [String] Option name
  # @return [String] Option value
  def busy_cget(option)
    Tk::Busy.configure(self, option)
  end

  # Makes this window busy.
  # @param keys [Hash] Options (e.g., cursor: 'watch')
  # @return [self]
  # @see Tk::Busy.hold
  def busy(keys={})
    Tk::Busy.hold(self, keys)
    self
  end
  alias busy_hold busy

  # Releases busy status on this window.
  # @return [self]
  def busy_forget
    Tk::Busy.forget(self)
    self
  end

  # Checks if this window is in the current busy list.
  # @return [Boolean]
  def busy_current?
    ! Tk::Busy.current(self.path).empty?
  end

  # Checks if this window is currently busy.
  # @return [Boolean]
  def busy_status
    Tk::Busy.status(self)
  end

  # @!endgroup
end
