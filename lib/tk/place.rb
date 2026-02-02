# frozen_string_literal: false
#
# tk/place.rb : control place geometry manager
#

# Place geometry manager for absolute and relative positioning.
#
# Place positions widgets using exact coordinates or relative positions
# within their container. Unlike pack and grid, place gives you complete
# control over widget placement.
#
# ## Basic Usage
#
# Widgets call `.place` with position options:
#
#     button.place(x: 100, y: 50)                    # Absolute
#     button.place(relx: 0.5, rely: 0.5, anchor: :center)  # Centered
#
# Or use the module directly:
#
#     TkPlace.configure(button, x: 100, y: 50)
#
# ## Key Options
#
# **Absolute positioning:**
# - `:x`, `:y` - Pixel coordinates for anchor point
# - `:width`, `:height` - Fixed size in pixels
#
# **Relative positioning (0.0 to 1.0):**
# - `:relx`, `:rely` - Position as fraction of container (0.5 = center)
# - `:relwidth`, `:relheight` - Size as fraction of container
#
# **Anchor and container:**
# - `:anchor` - Which point of widget aligns with (x,y): :nw, :center, etc.
# - `:in` - Container window (defaults to parent)
# - `:bordermode` - How borders affect placement: :inside, :outside, :ignore
#
# ## Combining Absolute and Relative
#
# Absolute and relative values are **added together**:
#
#     # Position at center minus 50 pixels
#     widget.place(relx: 0.5, x: -50, rely: 0.5, y: -25)
#
#     # Full width minus 10 pixels on each side
#     widget.place(relwidth: 1.0, width: -20, x: 10)
#
# @example Centered widget
#   label.place(relx: 0.5, rely: 0.5, anchor: :center)
#
# @example Bottom-right corner with margin
#   button.place(relx: 1.0, rely: 1.0, anchor: :se, x: -10, y: -10)
#
# @example Fill container with margins
#   content.place(x: 10, y: 10, relwidth: 1.0, relheight: 1.0,
#                 width: -20, height: -20)
#
# @example Overlay on top of another widget
#   overlay.place(in: base_widget, relwidth: 1.0, relheight: 1.0)
#
# @note **No propagation**: Unlike pack and grid, place does NOT affect
#   container sizing. You must set container dimensions explicitly.
#
# @note **Stacking order**: When placing in a non-parent container, ensure
#   the widget is higher in stacking order or it may be obscured.
#
# @see TkPack For simple stacking layouts
# @see TkGrid For table-like layouts
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/place.htm Tcl/Tk place manual
module TkPlace
  include Tk
  extend Tk

  TkCommandNames = ['place'.freeze].freeze

  def configure(win, slot, value=None)
    # for >= Tk8.4a2 ?
    # win = win.epath if win.kind_of?(TkObject)
    win = _epath(win)
    if slot.kind_of? Hash
      params = []
      slot.each{|k, v|
        params.push("-#{k}")
        # params.push((v.kind_of?(TkObject))? v.epath: v)
        params.push(_epath(v))
      }
      tk_call_without_enc('place', 'configure', win, *params)
    else
      # value = value.epath if value.kind_of?(TkObject)
      value = _epath(value)
      tk_call_without_enc('place', 'configure', win, "-#{slot}", value)
    end
  end
  alias place configure

  def configinfo(win, slot = nil)
    win = _epath(win)
    if slot
      conf = tk_split_simplelist(tk_call_without_enc('place', 'configure', win, "-#{slot}"))
      conf[0] = conf[0][1..-1]
      conf.map! { |v| tk_tcl2ruby(v) }
      conf
    else
      tk_split_simplelist(tk_call_without_enc('place', 'configure', win)).map do |conflist|
        conf = simplelist(conflist).map { |inf| tk_tcl2ruby(inf) }
        conf[0] = conf[0][1..-1]
        conf
      end
    end
  end

  def current_configinfo(win, slot = nil)
    # win = win.epath if win.kind_of?(TkObject)
    win = _epath(win)
    if slot
      #conf = tk_split_list(tk_call_without_enc('place', 'configure',
      #                                         win, "-#{slot}") )
      conf = tk_split_simplelist(tk_call_without_enc('place', 'configure',
                                                     win, "-#{slot}") )
      # { conf[0][1..-1] => conf[1] }
      { conf[0][1..-1] => tk_tcl2ruby(conf[4]) }
    else
      ret = {}
      #tk_split_list(tk_call_without_enc('place','configure',win)).each{|conf|
      tk_split_simplelist(tk_call_without_enc('place', 'configure',
                                              win)).each{|conf_list|
        #ret[conf[0][1..-1]] = conf[1]
        conf = simplelist(conf_list)
        ret[conf[0][1..-1]] = tk_tcl2ruby(conf[4])
      }
      ret
    end
  end

  def forget(win)
    # win = win.epath if win.kind_of?(TkObject)
    win = _epath(win)
    tk_call_without_enc('place', 'forget', win)
  end

  def info(win)
    # win = win.epath if win.kind_of?(TkObject)
    win = _epath(win)
    #ilist = list(tk_call_without_enc('place', 'info', win))
    ilist = simplelist(tk_call_without_enc('place', 'info', win))
    info = {}
    while key = ilist.shift
      #info[key[1..-1]] = ilist.shift
      info[key[1..-1]] = tk_tcl2ruby(ilist.shift)
    end
    return info
  end

  def slaves(master)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    list(tk_call('place', 'slaves', master))
  end

  module_function :place, :configure, :configinfo, :current_configinfo
  module_function :forget, :info, :slaves
end
=begin
def TkPlace(win, slot, value=None)
  win = win.epath if win.kind_of?(TkObject)
  if slot.kind_of? Hash
    params = []
    slot.each{|k, v|
      params.push("-#{k}")
      params.push((v.kind_of?(TkObject))? v.epath: v)
    }
    tk_call_without_enc('place', win, *params)
  else
    value = value.epath if value.kind_of?(TkObject)
    tk_call_without_enc('place', win, "-#{slot}", value)
  end
end
=end
