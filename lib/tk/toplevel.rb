# frozen_string_literal: false
require_relative 'core/callable'
require_relative 'core/configurable'
require_relative 'core/widget'
require_relative 'core/wm'
require 'tk/callback'
require 'tk/menuspec'
require 'tk/option_dsl'

# A top-level window (separate from the main application window).
#
# Toplevels are used for dialogs, secondary windows, and popups.
# They include the {Wm} mixin for window manager control (title,
# geometry, minimize, etc.).
#
# @example Simple dialog window
#   dialog = Tk::Toplevel.new(title: "Settings")
#   Tk::Label.new(dialog, text: "Options here").pack
#   Tk::Button.new(dialog, text: "Close") { dialog.destroy }.pack
#
# @example Modal dialog pattern
#   dialog = Tk::Toplevel.new
#   dialog.title("Confirm")
#   dialog.grab           # capture all input
#   dialog.transient(root)  # stay on top of parent
#   # ... add widgets ...
#   dialog.wait_window    # block until closed
#
# @example Window positioning
#   top = Tk::Toplevel.new
#   top.geometry("400x300+100+50")  # WxH+X+Y
#   top.minsize(200, 150)
#   top.resizable(true, false)  # width resizable, height fixed
#
# @note Options like `:class`, `:screen`, `:colormap`, and `:use` can only
#   be set at creation time, not changed afterward.
#
# @see Wm for window manager methods (title, geometry, iconify, etc.)
# @see https://www.tcl-lang.org/man/tcl/TkCmd/toplevel.html Tcl/Tk toplevel manual
# @see https://www.tcl-lang.org/man/tcl/TkCmd/wm.html Tcl/Tk wm manual
#
class Tk::Toplevel
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include Tk::Core::Wm
  include TkMenuSpec
  include Tk::Generated::Toplevel
  # @generated:options:start
  # Available options (auto-generated from Tk introspection):
  #
  #   :background
  #   :backgroundimage
  #   :borderwidth
  #   :class
  #   :colormap
  #   :container
  #   :cursor
  #   :height
  #   :highlightbackground
  #   :highlightcolor
  #   :highlightthickness
  #   :menu
  #   :padx
  #   :pady
  #   :relief
  #   :screen
  #   :takefocus
  #   :tile
  #   :use
  #   :visual
  #   :width
  # @generated:options:end

  None = TkUtil::None

  TkCommandNames = ['toplevel'.freeze].freeze
  WidgetClassName = 'Toplevel'.freeze
  Tk::Core::Widget.registry[WidgetClassName] ||= self

  # Wm module calls epath — for toplevel it's the same as path
  alias epath path

  # Window manager properties - these are NOT real Tcl configure options.
  # They are wm commands that the original ruby-tk exposed via cget/configure.
  # This shim maintains backwards compatibility by routing them to tk_call('wm', ...).
  WM_PROPERTIES = %w[
    aspect attributes client colormapwindows wm_command focusmodel
    geometry wm_grid group iconbitmap iconphoto iconmask iconname
    iconposition iconwindow maxsize minsize overrideredirect
    positionfrom protocols resizable sizefrom state title transient
  ].freeze

  def initialize(parent = nil, keys = {}, &block)
    if parent.is_a?(Hash)
      keys = parent
      parent = keys.delete(:parent)
    end

    # Remap classname -> class (Tcl only knows -class)
    keys[:class] = keys.delete(:classname) if keys.key?(:classname)
    @classname = keys[:class]

    # Separate wm commands from real widget options
    keys, wm_cmds = _split_wm_keys(keys)

    super(parent, keys)

    @classname ||= WidgetClassName

    # Apply wm commands after widget creation
    wm_cmds.each do |k, v|
      if v.is_a?(Array)
        tk_call('wm', k, path, *v)
      else
        tk_call('wm', k, path, v)
      end
    end

    instance_eval(&block) if block
  end

  # Backwards-compat shim: intercept wm properties and route to tk_call('wm', ...)
  def cget(slot)
    slot_s = slot.to_s
    if WM_PROPERTIES.include?(slot_s)
      tk_call('wm', slot_s.sub(/^wm_/, ''), path)
    else
      super
    end
  end

  # Backwards-compat shim: intercept wm properties in configinfo
  def configinfo(slot = nil)
    if slot
      slot_s = slot.to_s
      if WM_PROPERTIES.include?(slot_s)
        wm_cmd = slot_s.sub(/^wm_/, '')
        val = tk_call('wm', wm_cmd, path)
        [slot_s, '', '', '', val]
      else
        super
      end
    else
      result = super
      WM_PROPERTIES.each do |prop|
        begin
          val = tk_call('wm', prop.sub(/^wm_/, ''), path)
          result << [prop, '', '', '', val]
        rescue
          # Some wm commands may not be available, skip them
        end
      end
      result
    end
  end

  # Backwards-compat shim: intercept wm properties and route to tk_call('wm', ...)
  def configure(slot, value = None)
    if slot.is_a?(Hash)
      wm_opts, real_opts = slot.partition { |k, _| WM_PROPERTIES.include?(k.to_s) }
      wm_opts.each do |k, v|
        wm_cmd = k.to_s.sub(/^wm_/, '')
        if v.is_a?(Array)
          tk_call('wm', wm_cmd, path, *v)
        else
          tk_call('wm', wm_cmd, path, v)
        end
      end
      super(real_opts.to_h) unless real_opts.empty?
      self
    elsif WM_PROPERTIES.include?(slot.to_s)
      wm_cmd = slot.to_s.sub(/^wm_/, '')
      if value.is_a?(Array)
        tk_call('wm', wm_cmd, path, *value)
      else
        tk_call('wm', wm_cmd, path, value)
      end
      self
    else
      super
    end
  end

  def self.database_class
    self
  end

  def self.database_classname
    self.name
  end

  def specific_class
    @classname
  end

  def add_menu(menu_info, tearoff=false, opts=nil)
    if tearoff.kind_of?(Hash)
      opts = tearoff
      tearoff = false
    end
    _create_menubutton(self, menu_info, tearoff, opts)
  end

  def add_menubar(menu_spec, tearoff=false, opts=nil)
    menu_spec.each{|info| add_menu(info, tearoff, opts)}
    self.menu
  end

  private

  def _split_wm_keys(keys)
    return [{}, {}] unless keys
    new_keys = {}
    wm_cmds = {}
    keys.each do |k, v|
      k_s = k.to_s
      wm_cmd = k_s.sub(/^wm_/, '')
      if WM_PROPERTIES.include?(k_s) || WM_PROPERTIES.include?(wm_cmd)
        wm_cmds[wm_cmd] = v
      else
        new_keys[k] = v
      end
    end
    [new_keys, wm_cmds]
  end
end

#TkToplevel = Tk::Toplevel unless Object.const_defined? :TkToplevel
#Tk.__set_toplevel_aliases__(:Tk, Tk::Toplevel, :TkToplevel)
Tk.__set_loaded_toplevel_aliases__('tk/toplevel.rb', :Tk, Tk::Toplevel,
                                   :TkToplevel)
