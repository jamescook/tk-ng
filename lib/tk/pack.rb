# frozen_string_literal: false
#
# tk/pack.rb : control pack geometry manager
#

# Pack geometry manager for simple stacking layouts.
#
# Pack arranges widgets by stacking them against container edges.
# It's the simplest geometry manager, ideal for toolbars, button rows,
# and basic layouts.
#
# ## Basic Usage
#
# Widgets call `.pack` with side/fill options:
#
#     button1.pack(side: :left)
#     button2.pack(side: :left)
#     text_area.pack(side: :top, fill: :both, expand: true)
#
# Or use the module directly:
#
#     TkPack.configure(button, side: :left, padx: 5)
#
# ## Key Options
#
# - `:side` - Which edge to pack against: :top, :bottom, :left, :right
# - `:fill` - Stretch widget: :none, :x, :y, :both
# - `:expand` - Claim extra space when container grows (true/false)
# - `:anchor` - Position within allocated space: :n, :s, :e, :w, :center, etc.
# - `:padx`, `:pady` - External padding
# - `:ipadx`, `:ipady` - Internal padding (increases widget size)
#
# ## How Pack Works
#
# Pack processes widgets in order. Each widget claims a "parcel" from
# the remaining "cavity":
#
# 1. Widget gets a rectangular parcel along the specified side
# 2. Widget is sized/positioned within its parcel
# 3. Parcel is removed from cavity
# 4. Next widget uses remaining cavity
#
# @example Toolbar with buttons
#   btn1.pack(side: :left, padx: 2)
#   btn2.pack(side: :left, padx: 2)
#   btn3.pack(side: :left, padx: 2)
#
# @example Main content with sidebar
#   sidebar.pack(side: :left, fill: :y)
#   content.pack(side: :left, fill: :both, expand: true)
#
# @example Centered button row
#   frame = TkFrame.new(root)
#   frame.pack(side: :bottom)
#   ok_btn.pack(side: :left, padx: 5, in: frame)
#   cancel_btn.pack(side: :left, padx: 5, in: frame)
#
# @note **Propagation**: By default, containers shrink-wrap their contents.
#   Use `TkPack.propagate(container, false)` for fixed-size containers.
#
# @note **Order matters**: Widgets packed first get space first. If space
#   runs out, later widgets may not be visible until the container grows.
#
# @see TkGrid For table-like layouts with rows and columns
# @see TkPlace For absolute positioning
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/pack.htm Tcl/Tk pack manual
module TkPack
  TkCommandNames = ['pack'.freeze].freeze

  NONE = TkUtil::None

  def configure(*args)
    if args[-1].kind_of?(Hash)
      opts = args.pop
    else
      opts = {}
    end
    fail ArgumentError, 'no widget is given' if args.empty?
    params = []
    args.flatten(1).each{|win| params.push(_epath(win))}
    opts.each{|k, v|
      params.push("-#{k}")
      params.push(_epath(v))
    }
    _invoke('pack', 'configure', *params)
  end
  alias pack configure

  def forget(*args)
    return '' if args.size == 0
    wins = args.collect{|win| _epath(win) }
    _invoke('pack', 'forget', *wins)
  end

  def info(slave)
    ilist = TclTkLib._split_tklist(_invoke('pack', 'info', _epath(slave)))
    info = {}
    while key = ilist.shift
      info[key[1..-1]] = ilist.shift
    end
    info
  end

  # Gets or sets geometry propagation.
  #
  # When enabled (default), the container shrink-wraps its packed contents.
  # Disable for fixed-size containers.
  #
  # @param master [TkWindow] Container window
  # @param mode [Boolean, nil] true/false to set, nil to query
  # @return [Boolean, void] Current state if querying
  def propagate(master, mode=NONE)
    if mode.equal?(NONE)
      _invoke('pack', 'propagate', _epath(master)) == '1'
    else
      _invoke('pack', 'propagate', _epath(master), mode.to_s)
    end
  end

  def slaves(master)
    TclTkLib._split_tklist(_invoke('pack', 'slaves', _epath(master)))
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

  module_function :pack, :configure, :forget, :info, :propagate, :slaves
  module_function :_epath, :_invoke
end
=begin
def TkPack(win, *args)
  if args[-1].kind_of?(Hash)
    opts = args.pop
  else
    opts = {}
  end
  params = []
  params.push((win.kind_of?(TkObject))? win.epath: win)
  args.each{|win|
    params.push((win.kind_of?(TkObject))? win.epath: win)
  }
  opts.each{|k, v|
    params.push("-#{k}")
    params.push((v.kind_of?(TkObject))? v.epath: v)
  }
  tk_call_without_enc("pack", *params)
end
=end
