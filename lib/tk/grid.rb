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
  include Tk
  extend Tk

  TkCommandNames = ['grid'.freeze].freeze

  def anchor(master, anchor=None)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    tk_call_without_enc('grid', 'anchor', master, anchor)
  end

  def bbox(master, *args)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    args.unshift(master)
    list(tk_call_without_enc('grid', 'bbox', *args))
  end

=begin
  def configure(win, *args)
    if args[-1].kind_of?(Hash)
      opts = args.pop
    else
      opts = {}
    end
    params = []
    params.push(_epath(win))
    args.each{|win|
      case win
      when '-', 'x', '^'  # RELATIVE PLACEMENT
        params.push(win)
      else
        params.push(_epath(win))
      end
    }
    opts.each{|k, v|
      params.push("-#{k}")
      params.push((v.kind_of?(TkObject))? v.epath: v)
    }
    tk_call_without_enc('grid', 'configure', *params)
  end
=end
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
      params.push(_epath(v))  # have to use 'epath' (hash_kv() is unavailable)
    }
    tk_call_without_enc('grid', 'configure', *params)
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
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    tk_call_without_enc("grid", 'columnconfigure',
                        master, index, *hash_kv(args))
  end

  # Configures row properties.
  # @param master [TkWindow] Container window
  # @param index [Integer] Row index (0-based)
  # @param args [Hash] Row options (same as columnconfigure)
  # @return [void]
  def rowconfigure(master, index, args)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    tk_call_without_enc("grid", 'rowconfigure', master, index, *hash_kv(args))
  end

  def columnconfiginfo(master, index, slot=nil)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    if slot
      case slot
      when 'uniform', :uniform
        tk_call_without_enc('grid', 'columnconfigure',
                            master, index, "-#{slot}")
      else
        num_or_str(tk_call_without_enc('grid', 'columnconfigure',
                                       master, index, "-#{slot}"))
      end
    else
      #ilist = list(tk_call_without_enc('grid','columnconfigure',master,index))
      ilist = simplelist(tk_call_without_enc('grid', 'columnconfigure',
                                             master, index))
      info = {}
      while key = ilist.shift
        case key
        when 'uniform'
          info[key[1..-1]] = ilist.shift
        else
          info[key[1..-1]] = tk_tcl2ruby(ilist.shift)
        end
      end
      info
    end
  end

  def rowconfiginfo(master, index, slot=nil)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    if slot
      case slot
      when 'uniform', :uniform
        tk_call_without_enc('grid', 'rowconfigure',
                            master, index, "-#{slot}")
      else
        num_or_str(tk_call_without_enc('grid', 'rowconfigure',
                                       master, index, "-#{slot}"))
      end
    else
      #ilist = list(tk_call_without_enc('grid', 'rowconfigure', master, index))
      ilist = simplelist(tk_call_without_enc('grid', 'rowconfigure',
                                             master, index))
      info = {}
      while key = ilist.shift
        case key
        when 'uniform'
          info[key[1..-1]] = ilist.shift
        else
          info[key[1..-1]] = tk_tcl2ruby(ilist.shift)
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
    wins = args.collect{|win|
      # (win.kind_of?(TkObject))? win.epath: win
      _epath(win)
    }
    tk_call_without_enc('grid', 'forget', *wins)
  end

  def info(slave)
    # slave = slave.epath if slave.kind_of?(TkObject)
    slave = _epath(slave)
    #ilist = list(tk_call_without_enc('grid', 'info', slave))
    ilist = simplelist(tk_call_without_enc('grid', 'info', slave))
    info = {}
    while key = ilist.shift
      #info[key[1..-1]] = ilist.shift
      info[key[1..-1]] = tk_tcl2ruby(ilist.shift)
    end
    return info
  end

  def location(master, x, y)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    list(tk_call_without_enc('grid', 'location', master, x, y))
  end

  # Gets or sets geometry propagation.
  #
  # When enabled (default), the container resizes to fit its grid contents.
  # Disable for fixed-size containers.
  #
  # @param master [TkWindow] Container window
  # @param mode [Boolean, nil] true/false to set, nil to query
  # @return [Boolean, void] Current state if querying
  def propagate(master, mode=None)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    if mode == None
      bool(tk_call_without_enc('grid', 'propagate', master))
    else
      tk_call_without_enc('grid', 'propagate', master, mode)
    end
  end

  def remove(*args)
    return '' if args.size == 0
    wins = args.collect{|win|
      # (win.kind_of?(TkObject))? win.epath: win
      _epath(win)
    }
    tk_call_without_enc('grid', 'remove', *wins)
  end

  def size(master)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    list(tk_call_without_enc('grid', 'size', master))
  end

  def slaves(master, args=nil)
    # master = master.epath if master.kind_of?(TkObject)
    master = _epath(master)
    list(tk_call_without_enc('grid', 'slaves', master, *hash_kv(args)))
  end

  module_function :anchor, :bbox, :add, :forget, :propagate, :info
  module_function :remove, :size, :slaves, :location
  module_function :grid, :configure, :columnconfigure, :rowconfigure
  module_function :column, :row, :columnconfiginfo, :rowconfiginfo
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
