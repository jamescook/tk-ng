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
  TkCommandNames = ['place'.freeze].freeze

  NONE = TkUtil::None

  def configure(win, slot, value=NONE)
    win = _epath(win)
    if slot.kind_of? Hash
      params = []
      slot.each{|k, v|
        params.push("-#{k}")
        params.push(_epath(v))
      }
      _invoke('place', 'configure', win, *params)
    else
      _invoke('place', 'configure', win, "-#{slot}", _epath(value))
    end
  end
  alias place configure

  def configinfo(win, slot = nil)
    win = _epath(win)
    if slot
      conf = TclTkLib._split_tklist(_invoke('place', 'configure', win, "-#{slot}"))
      conf[0] = conf[0][1..-1]
      conf.map! { |v| _tcl2ruby(v) }
      conf
    else
      TclTkLib._split_tklist(_invoke('place', 'configure', win)).map do |conflist|
        conf = TclTkLib._split_tklist(conflist).map { |inf| _tcl2ruby(inf) }
        conf[0] = conf[0][1..-1]
        conf
      end
    end
  end

  def current_configinfo(win, slot = nil)
    win = _epath(win)
    if slot
      conf = TclTkLib._split_tklist(_invoke('place', 'configure', win, "-#{slot}"))
      { conf[0][1..-1] => _tcl2ruby(conf[4]) }
    else
      ret = {}
      TclTkLib._split_tklist(_invoke('place', 'configure', win)).each{|conf_list|
        conf = TclTkLib._split_tklist(conf_list)
        ret[conf[0][1..-1]] = _tcl2ruby(conf[4])
      }
      ret
    end
  end

  def forget(win)
    _invoke('place', 'forget', _epath(win))
  end

  def info(win)
    ilist = TclTkLib._split_tklist(_invoke('place', 'info', _epath(win)))
    info = {}
    while key = ilist.shift
      info[key[1..-1]] = _tcl2ruby(ilist.shift)
    end
    info
  end

  def slaves(master)
    TclTkLib._split_tklist(_invoke('place', 'slaves', _epath(master)))
  end

  private

  def _epath(win)
    win.respond_to?(:epath) ? win.epath :
      win.respond_to?(:path) ? win.path : win.to_s
  end

  def _invoke(*args)
    TkCore::INTERP._invoke(*args.map { |a|
      a.respond_to?(:epath) ? a.epath :
        a.respond_to?(:path) ? a.path : a.to_s
    })
  end

  # Convert a Tcl string to an appropriate Ruby value.
  def _tcl2ruby(val)
    return val unless val.is_a?(String)
    case val
    when '' then val
    when /\A-?\d+\z/ then val.to_i
    when /\A-?\d+\.\d+\z/ then val.to_f
    else
      # Check for widget path
      if val.start_with?('.')
        TkCore::INTERP.tk_windows[val] || val
      else
        val
      end
    end
  end

  module_function :place, :configure, :configinfo, :current_configinfo
  module_function :forget, :info, :slaves
  module_function :_epath, :_invoke, :_tcl2ruby
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
