# frozen_string_literal: false
#
# tk/grid.rb : control grid geometry manager
#

# Grid geometry manager for table-like widget layouts.
#
# Grid arranges widgets in rows and columns, similar to an HTML table.
# It's the most flexible geometry manager for complex forms and dialogs.
#
# ## Basic Usage
#
# Widgets call `.grid` with row/column options:
#
#     label.grid(row: 0, column: 0)
#     entry.grid(row: 0, column: 1)
#
# Or use the module directly:
#
#     TkGrid.configure(label, row: 0, column: 0)
#
# ## Key Options
#
# - `:row`, `:column` - Cell position (0-indexed)
# - `:rowspan`, `:columnspan` - Span multiple cells (default: 1)
# - `:sticky` - Anchor/stretch: "n", "s", "e", "w" or combinations like "nsew"
# - `:padx`, `:pady` - External padding (pixels or [left, right])
# - `:ipadx`, `:ipady` - Internal padding
#
# ## Relative Placement Symbols
#
# Use these instead of explicit row/column for compact layouts:
#
# - `-` - Extend previous widget's columnspan
# - `x` - Empty column (placeholder)
# - `^` - Extend widget above's rowspan
#
# @example Form layout
#   TkLabel.new(root, text: "Name:").grid(row: 0, column: 0, sticky: "e")
#   TkEntry.new(root).grid(row: 0, column: 1, sticky: "ew")
#   TkLabel.new(root, text: "Email:").grid(row: 1, column: 0, sticky: "e")
#   TkEntry.new(root).grid(row: 1, column: 1, sticky: "ew")
#   # Make column 1 expand with window
#   TkGrid.columnconfigure(root, 1, weight: 1)
#
# @example Relative placement
#   TkGrid.configure(btn1, btn2, btn3)           # Same row, columns 0,1,2
#   TkGrid.configure(wide_widget, '-', '-')      # Spans 3 columns
#   TkGrid.configure('x', centered, 'x')         # Empty, widget, empty
#
# @example Row/column configuration
#   TkGrid.columnconfigure(root, 0, weight: 0, minsize: 100)  # Fixed width
#   TkGrid.columnconfigure(root, 1, weight: 1)                # Expandable
#   TkGrid.rowconfigure(root, 0, weight: 1)                   # Expandable row
#
# @note **Propagation**: By default, containers resize to fit their grid
#   contents. Use `TkGrid.propagate(container, false)` for fixed-size containers.
#
# @see TkPack For simpler stacking layouts
# @see TkPlace For absolute positioning
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/grid.htm Tcl/Tk grid manual
module TkGrid
  TkCommandNames = ['grid'.freeze].freeze

  NONE = TkUtil::None

  def anchor(master, anchor=NONE)
    if anchor.equal?(NONE)
      _invoke('grid', 'anchor', _epath(master))
    else
      _invoke('grid', 'anchor', _epath(master), anchor.to_s)
    end
  end

  def bbox(master, *args)
    result = _invoke('grid', 'bbox', _epath(master), *args.map(&:to_s))
    result.split.map(&:to_i)
  end

  def configure(*args)
    if args[-1].kind_of?(Hash)
      opts = args.pop
    else
      opts = {}
    end
    fail ArgumentError, 'no widget is given' if args.empty?
    params = []
    args.flatten(1).each{|win|
      case win
      when '-', ?-.ord              # RELATIVE PLACEMENT (increase columnspan)
        params.push('-')
      when /^-+$/             # RELATIVE PLACEMENT (increase columnspan)
        params.concat(win.to_s.split(//))
      when '^', ?^.ord              # RELATIVE PLACEMENT (increase rowspan)
        params.push('^')
      when /^\^+$/             # RELATIVE PLACEMENT (increase rowspan)
        params.concat(win.to_s.split(//))
      when 'x', :x, ?x.ord, nil, '' # RELATIVE PLACEMENT (empty column)
        params.push('x')
      when /^x+$/             # RELATIVE PLACEMENT (empty column)
        params.concat(win.to_s.split(//))
      else
        params.push(_epath(win))
      end
    }
    opts.each{|k, v|
      params.push("-#{k}")
      params.push(_epath(v))
    }
    _invoke('grid', 'configure', *params)
  end
  alias grid configure

  # Configures column properties.
  # @param master [TkWindow] Container window
  # @param index [Integer] Column index (0-based)
  # @param args [Hash] Column options
  # @option args [Integer] :weight Growth ratio for extra space (0 = fixed)
  # @option args [Integer] :minsize Minimum column width in pixels
  # @option args [String] :uniform Group name for proportional sizing
  # @option args [Integer] :pad Extra padding added to largest widget
  # @return [void]
  def columnconfigure(master, index, args)
    _invoke("grid", 'columnconfigure', _epath(master), index.to_s, *_hash_to_args(args))
  end

  # Configures row properties.
  # @param master [TkWindow] Container window
  # @param index [Integer] Row index (0-based)
  # @param args [Hash] Row options (same as columnconfigure)
  # @return [void]
  def rowconfigure(master, index, args)
    _invoke("grid", 'rowconfigure', _epath(master), index.to_s, *_hash_to_args(args))
  end

  def columnconfiginfo(master, index, slot=nil)
    master = _epath(master)
    if slot
      case slot
      when 'uniform', :uniform
        _invoke('grid', 'columnconfigure', master, index.to_s, "-#{slot}")
      else
        _num_or_str(_invoke('grid', 'columnconfigure', master, index.to_s, "-#{slot}"))
      end
    else
      ilist = TclTkLib._split_tklist(
        _invoke('grid', 'columnconfigure', master, index.to_s))
      info = {}
      while key = ilist.shift
        case key
        when '-uniform'
          info[key[1..-1]] = ilist.shift
        else
          info[key[1..-1]] = _num_or_str(ilist.shift)
        end
      end
      info
    end
  end

  def rowconfiginfo(master, index, slot=nil)
    master = _epath(master)
    if slot
      case slot
      when 'uniform', :uniform
        _invoke('grid', 'rowconfigure', master, index.to_s, "-#{slot}")
      else
        _num_or_str(_invoke('grid', 'rowconfigure', master, index.to_s, "-#{slot}"))
      end
    else
      ilist = TclTkLib._split_tklist(
        _invoke('grid', 'rowconfigure', master, index.to_s))
      info = {}
      while key = ilist.shift
        case key
        when '-uniform'
          info[key[1..-1]] = ilist.shift
        else
          info[key[1..-1]] = _num_or_str(ilist.shift)
        end
      end
      info
    end
  end

  def column(master, index, keys=nil)
    if keys.kind_of?(Hash)
      columnconfigure(master, index, keys)
    else
      columnconfiginfo(master, index, keys)
    end
  end

  def row(master, index, keys=nil)
    if keys.kind_of?(Hash)
      rowconfigure(master, index, keys)
    else
      rowconfiginfo(master, index, keys)
    end
  end

  def add(widget, *args)
    configure(widget, *args)
  end

  def forget(*args)
    return '' if args.size == 0
    wins = args.collect{|win| _epath(win) }
    _invoke('grid', 'forget', *wins)
  end

  def info(slave)
    ilist = TclTkLib._split_tklist(_invoke('grid', 'info', _epath(slave)))
    info = {}
    while key = ilist.shift
      val = ilist.shift
      info[key[1..-1]] = val =~ /\A-?\d+\z/ ? val.to_i : val
    end
    info
  end

  def location(master, x, y)
    result = _invoke('grid', 'location', _epath(master), x.to_s, y.to_s)
    result.split.map(&:to_i)
  end

  # Gets or sets geometry propagation.
  #
  # When enabled (default), the container resizes to fit its grid contents.
  # Disable for fixed-size containers.
  #
  # @param master [TkWindow] Container window
  # @param mode [Boolean, nil] true/false to set, nil to query
  # @return [Boolean, void] Current state if querying
  def propagate(master, mode=NONE)
    if mode.equal?(NONE)
      _invoke('grid', 'propagate', _epath(master)) == '1'
    else
      _invoke('grid', 'propagate', _epath(master), mode.to_s)
    end
  end

  def remove(*args)
    return '' if args.size == 0
    wins = args.collect{|win| _epath(win) }
    _invoke('grid', 'remove', *wins)
  end

  def size(master)
    result = _invoke('grid', 'size', _epath(master))
    result.split.map(&:to_i)
  end

  def slaves(master, args=nil)
    cmd = ['grid', 'slaves', _epath(master)]
    cmd.concat(_hash_to_args(args)) if args
    TclTkLib._split_tklist(_invoke(*cmd))
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

  def _hash_to_args(hash)
    return [] unless hash
    result = []
    hash.each do |k, v|
      result << "-#{k}" << v.to_s
    end
    result
  end

  def _num_or_str(val)
    return val unless val.is_a?(String)
    val =~ /\A-?\d+\z/ ? val.to_i : val
  end

  module_function :anchor, :bbox, :add, :forget, :propagate, :info
  module_function :remove, :size, :slaves, :location
  module_function :grid, :configure, :columnconfigure, :rowconfigure
  module_function :column, :row, :columnconfiginfo, :rowconfiginfo
  module_function :_epath, :_invoke, :_hash_to_args, :_num_or_str
end
=begin
def TkGrid(win, *args)
  if args[-1].kind_of?(Hash)
    opts = args.pop
  else
    opts = {}
  end
  params = []
  params.push((win.kind_of?(TkObject))? win.epath: win)
  args.each{|win|
    case win
    when '-', 'x', '^'  # RELATIVE PLACEMENT
      params.push(win)
    else
      params.push((win.kind_of?(TkObject))? win.epath: win)
    end
  }
  opts.each{|k, v|
    params.push("-#{k}")
    params.push((v.kind_of?(TkObject))? v.epath: v)
  }
  tk_call_without_enc("grid", *params)
end
=end
