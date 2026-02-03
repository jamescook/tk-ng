# frozen_string_literal: true

require 'tk/option_dsl'

# Base class for all visible Tk widgets (windows, buttons, labels, etc.).
#
# TkWindow extends TkObject with functionality specific to visible widgets:
# - Geometry management (pack, grid, place)
# - Focus and keyboard grab
# - Window stacking (raise/lower)
# - Destruction and cleanup
#
# == Creating Widgets
#
#   # Widgets take an optional parent and options hash
#   frame = TkFrame.new
#   button = TkButton.new(frame, text: "Click me")
#
#   # Or pass parent in the options
#   button = TkButton.new(parent: frame, text: "Click me")
#
# == Geometry Management
#
# Widgets must be placed using a geometry manager to become visible:
#
#   # pack - simple top-to-bottom or side-by-side layout
#   button.pack(side: :left, padx: 5)
#
#   # grid - row/column table layout
#   button.grid(row: 0, column: 0, sticky: "ew")
#
#   # place - absolute or relative positioning
#   button.place(x: 100, y: 50)
#
# == See Also
# - TkObject for option configuration
# - TkPack, TkGrid, TkPlace for geometry management details
# - https://www.tcl.tk/man/tcl/TkCmd/pack.html
# - https://www.tcl.tk/man/tcl/TkCmd/grid.html
# - https://www.tcl.tk/man/tcl/TkCmd/place.html
#
class TkWindow<TkObject
  include TkWinfo
  extend TkBindCore
  extend Tk::OptionDSL
  include Tk::Wm_for_General
  include Tk::Busy

  # Widget options are now auto-generated from Tk introspection.
  # Each widget class includes its generated module (e.g., Tk::Generated::Button).
  # See: rake tk:generate_options

  @@WIDGET_INSPECT_FULL = false
  def TkWindow._widget_inspect_full_?
    @@WIDGET_INSPECT_FULL
  end
  def TkWindow._widget_inspect_full_=(mode)
    @@WIDGET_INSPECT_FULL = (mode && true) || false
  end

  TkCommandNames = [].freeze
  ## ==> If TkCommandNames[0] is a string (not a null string),
  ##     assume the string is a Tcl/Tk's create command of the widget class.
  WidgetClassName = ''.freeze
  # WidgetClassNames[WidgetClassName] = self
  ## ==> If self is a widget class, entry to the WidgetClassNames table.
  def self.to_eval
    self::WidgetClassName
  end

  def initialize(parent=nil, keys=nil)
    if parent.kind_of? Hash
      keys = _symbolkey2str(parent)
      parent = keys.delete('parent')
      widgetname = keys.delete('widgetname')
      install_win(if parent then parent.path end, widgetname)
      without_creating = keys.delete('without_creating')
      # if without_creating && !widgetname
      #   fail ArgumentError,
      #        "if set 'without_creating' to true, need to define 'widgetname'"
      # end
    elsif keys
      keys = _symbolkey2str(keys)
      widgetname = keys.delete('widgetname')
      install_win(if parent then parent.path end, widgetname)
      without_creating = keys.delete('without_creating')
      # if without_creating && !widgetname
      #   fail ArgumentError,
      #        "if set 'without_creating' to true, need to define 'widgetname'"
      # end
    else
      install_win(if parent then parent.path end)
    end
    if self.method(:create_self).arity == 0
      p 'create_self has no arg' if $DEBUG
      create_self unless without_creating
      if keys
        # tk_call @path, 'configure', *hash_kv(keys)
        configure(keys)
      end
    else
      p 'create_self has args' if $DEBUG
      if keys
        # Resolve aliases via OptionDSL
        if self.class.respond_to?(:declared_optkey_aliases)
          self.class.declared_optkey_aliases.each do |alias_name, real_name|
            alias_name = alias_name.to_s
            if keys.has_key?(alias_name)
              keys[real_name.to_s] = keys.delete(alias_name)
            end
          end
        end
      end
      if without_creating && keys
        configure(keys)
      else
        create_self(keys)
      end
    end
  end

  def create_self(keys)
    # may need to override
    begin
      cmd = self.class::TkCommandNames[0]
      fail unless (cmd.kind_of?(String) && cmd.length > 0)
    rescue
      fail RuntimeError, "class #{self.class} may be an abstract class"
    end

    if keys and keys != None
      # Filter out options unavailable in current Tcl/Tk version
      keys = __filter_unavailable_options(keys)
      tk_call_without_enc(cmd, @path, *hash_kv(keys, true))
    else
      tk_call_without_enc(cmd, @path)
    end
  end
  private :create_self

  # Filter out options that require a newer Tcl/Tk version than currently running.
  # Checks both regular options with min_version and future_options.
  # Behavior controlled by Tk.version_mismatch (:warn, :ignore, :raise)
  def __filter_unavailable_options(keys)
    return keys unless keys.is_a?(Hash)

    keys.reject do |key, _value|
      # Check regular options with min_version
      opt = self.class.resolve_option(key)
      if opt && !opt.available?
        _handle_version_mismatch(key, opt.min_version_str)
        next true
      end

      # Check future_options (options from newer Tk versions)
      info = self.class.future_option_info(key.to_sym)
      if info
        _handle_version_mismatch(key, info[:min_version])
        next true
      end

      false
    end
  end
  private :__filter_unavailable_options

  def inspect
    if @@WIDGET_INSPECT_FULL
      super
    else
      str = super
      str[0..(str.index(' '))] << '@path=' << @path.inspect << '>'
    end
  end

  def exist?
    return false if @destroyed
    TkWinfo.exist?(self)
  end

  def destroyed?
    @destroyed || false
  end

  # Returns true for all Tk widgets.
  # Use this instead of kind_of?(TkWindow) for widget type checks.
  def tk_widget?
    true
  end

  alias subcommand tk_send

  def bind_class
    @db_class || self.class()
  end

  def database_classname
    TkWinfo.classname(self)
  end
  def database_class
    name = database_classname()
    if WidgetClassNames[name]
      WidgetClassNames[name]
    else
      TkDatabaseClass.new(name)
    end
  end
  def self.database_classname
    self::WidgetClassName
  end
  def self.database_class
    WidgetClassNames[self::WidgetClassName]
  end

  # Arrange this widget using the pack geometry manager.
  #
  # Pack is the simplest geometry manager - it places widgets along
  # the edges of their parent (top, bottom, left, right).
  #
  # @param keys [Hash] pack options
  # @option keys :side [:top, :bottom, :left, :right] which edge to pack against
  # @option keys :fill [:none, :x, :y, :both] stretch to fill space
  # @option keys :expand [Boolean] claim extra space when parent grows
  # @option keys :padx [Integer] horizontal padding (pixels)
  # @option keys :pady [Integer] vertical padding (pixels)
  # @option keys :anchor [:n, :s, :e, :w, :center, etc.] position within allocated space
  # @return [self]
  #
  # @example Stack buttons vertically
  #   button1.pack(side: :top, fill: :x)
  #   button2.pack(side: :top, fill: :x)
  #
  # @example Side-by-side with padding
  #   btn1.pack(side: :left, padx: 5)
  #   btn2.pack(side: :left, padx: 5)
  #
  # @see #pack_forget to remove from pack management
  # @see https://www.tcl.tk/man/tcl/TkCmd/pack.html
  #
  def pack(keys = nil)
    #tk_call_without_enc('pack', epath, *hash_kv(keys, true))
    if keys
      TkPack.configure(self, keys)
    else
      TkPack.configure(self)
    end
    self
  end

  def pack_in(target, keys = nil)
    if keys
      keys = keys.dup
      keys['in'] = target
    else
      keys = {'in'=>target}
    end
    #tk_call 'pack', epath, *hash_kv(keys)
    TkPack.configure(self, keys)
    self
  end

  def pack_forget
    #tk_call_without_enc('pack', 'forget', epath)
    TkPack.forget(self)
    self
  end
  alias unpack pack_forget

  def pack_config(slot, value=None)
    #if slot.kind_of? Hash
    #  tk_call 'pack', 'configure', epath, *hash_kv(slot)
    #else
    #  tk_call 'pack', 'configure', epath, "-#{slot}", value
    #end
    if slot.kind_of? Hash
      TkPack.configure(self, slot)
    else
      TkPack.configure(self, slot=>value)
    end
  end
  alias pack_configure pack_config

  def pack_info()
    #ilist = list(tk_call('pack', 'info', epath))
    #info = {}
    #while key = ilist.shift
    #  info[key[1..-1]] = ilist.shift
    #end
    #return info
    TkPack.info(self)
  end

  def pack_propagate(mode=None)
    #if mode == None
    #  bool(tk_call('pack', 'propagate', epath))
    #else
    #  tk_call('pack', 'propagate', epath, mode)
    #  self
    #end
    if mode == None
      TkPack.propagate(self)
    else
      TkPack.propagate(self, mode)
      self
    end
  end

  def pack_slaves()
    #list(tk_call('pack', 'slaves', epath))
    TkPack.slaves(self)
  end

  # Arrange this widget using the grid geometry manager.
  #
  # Grid places widgets in a table of rows and columns, offering precise
  # control over layout. It's the most flexible geometry manager.
  #
  # @param keys [Hash] grid options
  # @option keys :row [Integer] row number (0-based)
  # @option keys :column [Integer] column number (0-based)
  # @option keys :rowspan [Integer] how many rows to span
  # @option keys :columnspan [Integer] how many columns to span
  # @option keys :sticky [String] edges to stick to ("n", "s", "e", "w", "nsew", etc.)
  # @option keys :padx [Integer] horizontal padding
  # @option keys :pady [Integer] vertical padding
  # @return [self]
  #
  # @example Simple form layout
  #   label.grid(row: 0, column: 0, sticky: "e")
  #   entry.grid(row: 0, column: 1, sticky: "ew")
  #
  # @example Spanning multiple columns
  #   button.grid(row: 1, column: 0, columnspan: 2, sticky: "ew")
  #
  # @see #grid_forget to remove from grid management
  # @see #grid_columnconfigure to configure column weights
  # @see https://www.tcl.tk/man/tcl/TkCmd/grid.html
  #
  def grid(keys = nil)
    #tk_call 'grid', epath, *hash_kv(keys)
    if keys
      TkGrid.configure(self, keys)
    else
      TkGrid.configure(self)
    end
    self
  end

  def grid_in(target, keys = nil)
    if keys
      keys = keys.dup
      keys['in'] = target
    else
      keys = {'in'=>target}
    end
    #tk_call 'grid', epath, *hash_kv(keys)
    TkGrid.configure(self, keys)
    self
  end

  def grid_anchor(anchor=None)
    if anchor == None
      TkGrid.anchor(self)
    else
      TkGrid.anchor(self, anchor)
      self
    end
  end

  def grid_forget
    #tk_call('grid', 'forget', epath)
    TkGrid.forget(self)
    self
  end
  alias ungrid grid_forget

  def grid_bbox(*args)
    #list(tk_call('grid', 'bbox', epath, *args))
    TkGrid.bbox(self, *args)
  end

  def grid_config(slot, value=None)
    #if slot.kind_of? Hash
    #  tk_call 'grid', 'configure', epath, *hash_kv(slot)
    #else
    #  tk_call 'grid', 'configure', epath, "-#{slot}", value
    #end
    if slot.kind_of? Hash
      TkGrid.configure(self, slot)
    else
      TkGrid.configure(self, slot=>value)
    end
  end
  alias grid_configure grid_config

  def grid_columnconfig(index, keys)
    #tk_call('grid', 'columnconfigure', epath, index, *hash_kv(keys))
    TkGrid.columnconfigure(self, index, keys)
  end
  alias grid_columnconfigure grid_columnconfig

  def grid_rowconfig(index, keys)
    #tk_call('grid', 'rowconfigure', epath, index, *hash_kv(keys))
    TkGrid.rowconfigure(self, index, keys)
  end
  alias grid_rowconfigure grid_rowconfig

  def grid_columnconfiginfo(index, slot=nil)
    #if slot
    #  tk_call('grid', 'columnconfigure', epath, index, "-#{slot}").to_i
    #else
    #  ilist = list(tk_call('grid', 'columnconfigure', epath, index))
    #  info = {}
    #  while key = ilist.shift
    #   info[key[1..-1]] = ilist.shift
    #  end
    #  info
    #end
    TkGrid.columnconfiginfo(self, index, slot)
  end

  def grid_rowconfiginfo(index, slot=nil)
    #if slot
    #  tk_call('grid', 'rowconfigure', epath, index, "-#{slot}").to_i
    #else
    #  ilist = list(tk_call('grid', 'rowconfigure', epath, index))
    #  info = {}
    #  while key = ilist.shift
    #   info[key[1..-1]] = ilist.shift
    #  end
    #  info
    #end
    TkGrid.rowconfiginfo(self, index, slot)
  end

  def grid_column(index, keys=nil)
    if keys.kind_of?(Hash)
      grid_columnconfigure(index, keys)
    else
      grid_columnconfiginfo(index, keys)
    end
  end

  def grid_row(index, keys=nil)
    if keys.kind_of?(Hash)
      grid_rowconfigure(index, keys)
    else
      grid_rowconfiginfo(index, keys)
    end
  end

  def grid_info()
    #list(tk_call('grid', 'info', epath))
    TkGrid.info(self)
  end

  def grid_location(x, y)
    #list(tk_call('grid', 'location', epath, x, y))
    TkGrid.location(self, x, y)
  end

  def grid_propagate(mode=None)
    #if mode == None
    #  bool(tk_call('grid', 'propagate', epath))
    #else
    #  tk_call('grid', 'propagate', epath, mode)
    #  self
    #end
    if mode == None
      TkGrid.propagate(self)
    else
      TkGrid.propagate(self, mode)
      self
    end
  end

  def grid_remove()
    #tk_call 'grid', 'remove', epath
    TkGrid.remove(self)
    self
  end

  def grid_size()
    #list(tk_call('grid', 'size', epath))
    TkGrid.size(self)
  end

  def grid_slaves(keys = nil)
    #list(tk_call('grid', 'slaves', epath, *hash_kv(args)))
    TkGrid.slaves(self, keys)
  end

  # Arrange this widget using the place geometry manager.
  #
  # Place allows absolute positioning (x, y coordinates) or relative
  # positioning (percentage of parent). Use sparingly - grid and pack
  # are usually better for responsive layouts.
  #
  # @param keys [Hash] place options
  # @option keys :x [Integer] absolute x coordinate (pixels)
  # @option keys :y [Integer] absolute y coordinate (pixels)
  # @option keys :relx [Float] relative x (0.0 to 1.0, fraction of parent width)
  # @option keys :rely [Float] relative y (0.0 to 1.0, fraction of parent height)
  # @option keys :anchor [:n, :s, :e, :w, :center, etc.] which point of widget to position
  # @option keys :width [Integer] explicit width
  # @option keys :height [Integer] explicit height
  # @return [self]
  #
  # @example Absolute positioning
  #   button.place(x: 100, y: 50)
  #
  # @example Centered in parent
  #   button.place(relx: 0.5, rely: 0.5, anchor: :center)
  #
  # @see #place_forget to remove from place management
  # @see https://www.tcl.tk/man/tcl/TkCmd/place.html
  #
  def place(keys)
    #tk_call 'place', epath, *hash_kv(keys)
    TkPlace.configure(self, keys)
    self
  end

  def place_in(target, keys = nil)
    if keys
      keys = keys.dup
      keys['in'] = target
    else
      keys = {'in'=>target}
    end
    #tk_call 'place', epath, *hash_kv(keys)
    TkPlace.configure(self, keys)
    self
  end

  def  place_forget
    #tk_call 'place', 'forget', epath
    TkPlace.forget(self)
    self
  end
  alias unplace place_forget

  def place_config(slot, value=None)
    #if slot.kind_of? Hash
    #  tk_call 'place', 'configure', epath, *hash_kv(slot)
    #else
    #  tk_call 'place', 'configure', epath, "-#{slot}", value
    #end
    TkPlace.configure(self, slot, value)
  end
  alias place_configure place_config

  def place_configinfo(slot = nil)
    # for >= Tk8.4a2 ?
    #if slot
    #  conf = tk_split_list(tk_call('place', 'configure', epath, "-#{slot}") )
    #  conf[0] = conf[0][1..-1]
    #  conf
    #else
    #  tk_split_simplelist(tk_call('place',
    #                             'configure', epath)).collect{|conflist|
    #   conf = tk_split_simplelist(conflist)
    #   conf[0] = conf[0][1..-1]
    #   conf
    #  }
    #end
    TkPlace.configinfo(self, slot)
  end

  def place_info()
    #ilist = list(tk_call('place', 'info', epath))
    #info = {}
    #while key = ilist.shift
    #  info[key[1..-1]] = ilist.shift
    #end
    #return info
    TkPlace.info(self)
  end

  def place_slaves()
    #list(tk_call('place', 'slaves', epath))
    TkPlace.slaves(self)
  end

  # Give keyboard focus to this widget.
  #
  # @param force [Boolean] if true, steal focus even from other applications
  # @return [self]
  #
  # @example
  #   entry.focus           # normal focus
  #   entry.focus(true)     # force focus (use sparingly)
  #
  # @see https://www.tcl.tk/man/tcl/TkCmd/focus.html
  #
  def set_focus(force=false)
    if force
      tk_call_without_enc('focus', '-force', path)
    else
      tk_call_without_enc('focus', path)
    end
    self
  end
  alias focus set_focus

  # Manage pointer/keyboard grab for modal dialogs.
  #
  # A "grab" redirects all pointer and keyboard events to this widget,
  # preventing interaction with other windows. Used for modal dialogs.
  #
  # @param opt [Symbol, String, nil] grab operation
  # @option opt :set acquire a local grab (default when opt is nil)
  # @option opt :global acquire a global grab (all applications)
  # @option opt :release release the grab
  # @option opt :current return the window with the current grab
  # @option opt :status return grab status ("none", "local", or "global")
  # @return [self, TkWindow, String] depends on operation
  #
  # @example Modal dialog pattern
  #   dialog = TkToplevel.new
  #   dialog.grab              # acquire grab
  #   dialog.wait_window       # block until closed
  #   dialog.grab(:release)    # release grab (or destroyed automatically)
  #
  # @see https://www.tcl.tk/man/tcl/TkCmd/grab.html
  #
  def grab(opt = nil)
    unless opt
      tk_call_without_enc('grab', 'set', path)
      return self
    end

    case opt
    when 'set', :set
      tk_call_without_enc('grab', 'set', path)
      return self
    when 'global', :global
      #return(tk_call('grab', 'set', '-global', path))
      tk_call_without_enc('grab', 'set', '-global', path)
      return self
    when 'release', :release
      #return tk_call('grab', 'release', path)
      tk_call_without_enc('grab', 'release', path)
      return self
    when 'current', :current
      return window(tk_call_without_enc('grab', 'current', path))
    when 'status', :status
      return tk_call_without_enc('grab', 'status', path)
    else
      return tk_call_without_enc('grab', opt, path)
    end
  end

  def grab_current
    grab('current')
  end
  alias current_grab grab_current
  def grab_release
    grab('release')
  end
  alias release_grab grab_release
  def grab_set
    grab('set')
  end
  alias set_grab grab_set
  def grab_set_global
    grab('global')
  end
  alias set_global_grab grab_set_global
  def grab_status
    grab('status')
  end

  # Lower this window in the stacking order (move toward back).
  #
  # @param below [TkWindow, nil] place this window below the specified sibling
  # @return [self]
  #
  # @example Send window to back
  #   window.lower
  #
  # @example Place below a specific sibling
  #   window.lower(other_window)
  #
  # @see #raise to bring window forward
  # @see https://www.tcl.tk/man/tcl/TkCmd/lower.html
  #
  def lower(below=None)
    # below = below.epath if below.kind_of?(TkObject)
    below = _epath(below)
    tk_call 'lower', epath, below
    self
  end
  alias lower_window lower

  # Raise this window in the stacking order (move toward front).
  #
  # @param above [TkWindow, nil] place this window above the specified sibling
  # @return [self]
  #
  # @example Bring window to front
  #   window.raise
  #
  # @example Place above a specific sibling
  #   window.raise(other_window)
  #
  # @see #lower to send window backward
  # @see https://www.tcl.tk/man/tcl/TkCmd/raise.html
  #
  def raise(above=None)
    #above = above.epath if above.kind_of?(TkObject)
    above = _epath(above)
    tk_call 'raise', epath, above
    self
  end
  alias raise_window raise

  def command(cmd=nil, &b)
    if cmd
      configure_cmd('command', cmd)
    elsif b
      configure_cmd('command', b)
    else
      cget('command')
    end
  end

  def colormodel(model=None)
    tk_call('tk', 'colormodel', path, model)
    self
  end

  def caret(keys=nil)
    TkXIM.caret(path, keys)
  end

  # Destroy this widget and all its children.
  #
  # This removes the widget from the screen, cleans up all registered
  # callbacks, and releases resources. After calling destroy, the widget
  # object should not be used.
  #
  # @return [void]
  #
  # @example
  #   dialog.destroy  # close and clean up a dialog
  #
  # @note Destroying a parent destroys all its children automatically
  # @see https://www.tcl.tk/man/tcl/TkCmd/destroy.html
  #
  def destroy
    # Guard against double-destroy which can cause segfaults in Tk
    return if @destroyed
    @destroyed = true

    super

    # Find all descendants (not just direct children)
    # Tk's destroy command destroys all descendants, so we need to mark them all
    descendants = []
    prefix = self.path + "."
    TkCore::INTERP.tk_windows.each{|path, obj|
      descendants << [path, obj] if path.start_with?(prefix)
    }

    if defined?(@cmdtbl)
      for id in @cmdtbl
        uninstall_cmd id
      end
    end

    descendants.each{|path, obj|
      obj.instance_eval{
        @destroyed = true  # Mark all descendants as destroyed
        if defined?(@cmdtbl)
          for id in @cmdtbl
            uninstall_cmd id
          end
        end
      }
      TkCore::INTERP.tk_windows.delete(path)
    }

    begin
      tk_call_without_enc('destroy', epath)
    rescue
    end
    uninstall_win
  end

  # Block until this widget becomes visible.
  #
  # Waits for the widget to be mapped (displayed) on screen. Useful when
  # you need to query geometry after creating a widget.
  #
  # @param on_thread [Boolean] if true, yield to other Ruby threads while waiting
  # @return [void]
  #
  # @example Wait for window to appear before querying size
  #   toplevel = TkToplevel.new
  #   toplevel.wait_visibility
  #   puts toplevel.winfo_width  # now has real dimensions
  #
  # @see https://www.tcl.tk/man/tcl/TkCmd/tkwait.html
  #
  def wait_visibility(on_thread = true)
    on_thread &= (Thread.list.size != 1)
    if on_thread
      TkCore::INTERP._thread_tkwait('visibility', path)
    else
      TkCore::INTERP._invoke('tkwait', 'visibility', path)
    end
  end
  def eventloop_wait_visibility
    wait_visibility(false)
  end
  def thread_wait_visibility
    wait_visibility(true)
  end
  alias wait wait_visibility
  alias tkwait wait_visibility
  alias eventloop_wait eventloop_wait_visibility
  alias eventloop_tkwait eventloop_wait_visibility
  alias eventloop_tkwait_visibility eventloop_wait_visibility
  alias thread_wait thread_wait_visibility
  alias thread_tkwait thread_wait_visibility
  alias thread_tkwait_visibility thread_wait_visibility

  # Block until this widget is destroyed.
  #
  # Commonly used for modal dialogs - the calling code waits until the
  # user closes the dialog.
  #
  # @param on_thread [Boolean] if true, yield to other Ruby threads while waiting
  # @return [void]
  #
  # @example Modal dialog pattern
  #   dialog = TkToplevel.new
  #   # ... set up dialog contents ...
  #   dialog.grab               # make modal
  #   dialog.wait_destroy       # block here until user closes it
  #   # dialog is now closed, continue...
  #
  # @see #grab for making the dialog modal
  # @see https://www.tcl.tk/man/tcl/TkCmd/tkwait.html
  #
  def wait_destroy(on_thread = true)
    on_thread &= (Thread.list.size != 1)
    if on_thread
      TkCore::INTERP._thread_tkwait('window', epath)
    else
      TkCore::INTERP._invoke('tkwait', 'window', epath)
    end
  end
  alias wait_window wait_destroy
  def eventloop_wait_destroy
    wait_destroy(false)
  end
  alias eventloop_wait_window eventloop_wait_destroy
  def thread_wait_destroy
    wait_destroy(true)
  end
  alias thread_wait_window thread_wait_destroy

  alias tkwait_destroy wait_destroy
  alias tkwait_window wait_destroy

  alias eventloop_tkwait_destroy eventloop_wait_destroy
  alias eventloop_tkwait_window eventloop_wait_destroy

  alias thread_tkwait_destroy thread_wait_destroy
  alias thread_tkwait_window thread_wait_destroy

  def bindtags(taglist=nil)
    if taglist
      fail ArgumentError, "taglist must be Array" unless taglist.kind_of? Array
      tk_call('bindtags', path, taglist)
      taglist
    else
      list(tk_call('bindtags', path)).collect{|tag|
        if tag.kind_of?(String)
          if cls = WidgetClassNames[tag]
            cls
          elsif btag = TkBindTag.id2obj(tag)
            btag
          else
            tag
          end
        else
          tag
        end
      }
    end
  end

  def bindtags=(taglist)
    bindtags(taglist)
    taglist
  end

  def bindtags_shift
    taglist = bindtags
    tag = taglist.shift
    bindtags(taglist)
    tag
  end

  def bindtags_unshift(tag)
    bindtags(bindtags().unshift(tag))
  end
end
