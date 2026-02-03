# frozen_string_literal: false
require 'tk/canvastag'
require 'tk/scrollable'
require 'tk/option_dsl'
require 'tk/item_option_dsl'
require_relative 'core/callable'
require_relative 'core/configurable'
require_relative 'core/widget'
require_relative 'callback'

# @!visibility private
module TkCanvasItemConfig
  include Tk::ItemOptionDSL::InstanceMethods
end

# A widget for drawing graphics and embedding other widgets.
#
# Canvas supports structured graphics: rectangles, ovals, lines, polygons,
# text, images, and embedded windows. Items can be moved, scaled, and
# bound to events.
#
# == Item Types
# - `TkcRectangle`, `TkcOval` - basic shapes
# - `TkcLine` - connected line segments, optional arrows
# - `TkcPolygon` - filled multi-point shapes
# - `TkcText` - text strings
# - `TkcImage` - display images
# - `TkcWindow` - embed other Tk widgets
# - `TkcArc` - pie slices, chords, arcs
#
# == Coordinates
# All coordinates are in pixels (floats allowed). Origin is upper-left.
# Use `scrollregion` for canvases larger than the visible area.
#
# @example Draw shapes
#   canvas = Tk::Canvas.new(width: 400, height: 300, bg: 'white')
#   canvas.pack
#
#   TkcRectangle.new(canvas, 10, 10, 100, 80, fill: 'blue')
#   TkcOval.new(canvas, 50, 50, 150, 120, fill: 'red', outline: 'black')
#   TkcLine.new(canvas, 0, 0, 200, 150, arrow: :last, width: 2)
#
# @example Interactive items with tags
#   rect = TkcRectangle.new(canvas, 50, 50, 100, 100, fill: 'green', tags: 'draggable')
#   canvas.bind('draggable', 'Button-1') { |e| start_drag(e) }
#   canvas.bind('draggable', 'B1-Motion') { |e| do_drag(e) }
#
# @note The special tag `"all"` refers to all items. `"current"` is the
#   topmost item under the mouse.
#
# @note Embedded window items always appear on top regardless of stacking order.
#
# @see TkcRectangle, TkcOval, TkcLine, TkcText, etc. for item classes
# @see https://www.tcl-lang.org/man/tcl/TkCmd/canvas.html Tcl/Tk canvas manual
#
class Tk::Canvas
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include TkCanvasItemConfig
  include Tk::Scrollable
  include Tk::Generated::Canvas
  include Tk::Generated::CanvasItems
  # @generated:options:start
  # Available options (auto-generated from Tk introspection):
  #
  #   :background
  #   :bd
  #   :bg
  #   :borderwidth
  #   :closeenough
  #   :confine
  #   :cursor
  #   :height
  #   :highlightbackground
  #   :highlightcolor
  #   :highlightthickness
  #   :insertbackground
  #   :insertborderwidth
  #   :insertofftime
  #   :insertontime
  #   :insertwidth
  #   :offset
  #   :relief
  #   :scrollregion
  #   :selectbackground
  #   :selectborderwidth
  #   :selectforeground
  #   :state
  #   :takefocus
  #   :width
  #   :xscrollcommand
  #   :xscrollincrement
  #   :yscrollcommand
  #   :yscrollincrement
  # @generated:options:end



  None = TkUtil::None
  TkCommandNames = ['canvas'.freeze].freeze
  WidgetClassName = 'Canvas'.freeze
  Tk::Core::Widget.registry[WidgetClassName] ||= self

  def initialize(parent = nil, keys = {}, &block)
    @items = {}
    @canvas_tags = {}
    super
  end

  # @!visibility private
  def _additem(id, obj)
    @items ||= {}
    @items[id] = obj
  end

  # @!visibility private
  def _addtag(id, obj)
    @canvas_tags ||= {}
    @canvas_tags[id] = obj
  end

  # Looks up a TkcItem object by its numeric ID.
  # @param id [Integer] Canvas item ID
  # @return [TkcItem, Integer] The item object, or the ID if not found
  def itemid2obj(id)
    return id unless @items
    @items[id] || id
  end

  # Looks up a TkcTag object by its string ID.
  # @param id [String] Tag string
  # @return [TkcTag, String] The tag object, or the string if not found
  def canvastagid2obj(id)
    return id unless @canvas_tags
    @canvas_tags[id] || id
  end

  def tagid(tag)
    if tag.kind_of?(TkcItem) || tag.kind_of?(TkcTag)
      tag.id
    else
      tag  # maybe an Array of configure parameters
    end
  end
  private :tagid


  # Creates a canvas item without creating a TkcItem Ruby object.
  #
  # Returns the numeric item ID. Use this for low-level operations where
  # you don't need the convenience of TkcItem wrapper objects.
  #
  # @param type [Class, String] Item type class (e.g., TkcRectangle) or type name ("rectangle")
  # @param args [Array] Coordinates and options passed to the item
  # @return [Integer] The numeric canvas item ID
  # @example
  #   id = canvas.create(TkcRectangle, 10, 10, 50, 50, fill: 'blue')
  #   id = canvas.create('oval', 0, 0, 100, 100)
  def create(type, *args)
    if type.kind_of?(Class) && type < TkcItem
      # do nothing
    elsif TkcItem.type2class(type.to_s)
      type = TkcItem.type2class(type.to_s)
    else
      fail ArgumentError, "type must a subclass of TkcItem class, or a string in CItemTypeToClass"
    end
    type.create(self, *args)
  end

  # Adds a tag to items matching the given search specification.
  #
  # @param tag [String, TkcTag] Tag to add
  # @param mode [String, Symbol] Search mode ('above', 'all', 'below', 'closest', 'enclosed', 'overlapping', 'withtag')
  # @param args [Array] Mode-specific arguments
  # @return [self]
  # @see #addtag_above, #addtag_all, etc. for convenient wrappers
  def addtag(tag, mode, *args)
    mode = mode.to_s
    if args[0] && mode =~ /^(above|below|with(tag)?)$/
      args[0] = tagid(args[0])
    end
    tk_send('addtag', tagid(tag), mode, *args)
    self
  end

  # Adds a tag to the item just above the given item in stacking order.
  # @param tagOrId [String, TkcTag] Tag to add
  # @param target [TkcItem, Integer, String] Reference item
  # @return [self]
  def addtag_above(tagOrId, target)
    addtag(tagOrId, 'above', tagid(target))
  end

  # Adds a tag to all items on the canvas.
  # @param tagOrId [String, TkcTag] Tag to add
  # @return [self]
  def addtag_all(tagOrId)
    addtag(tagOrId, 'all')
  end

  # Adds a tag to the item just below the given item in stacking order.
  # @param tagOrId [String, TkcTag] Tag to add
  # @param target [TkcItem, Integer, String] Reference item
  # @return [self]
  def addtag_below(tagOrId, target)
    addtag(tagOrId, 'below', tagid(target))
  end

  # Adds a tag to the item closest to the given point.
  # @param tagOrId [String, TkcTag] Tag to add
  # @param x [Numeric] X coordinate
  # @param y [Numeric] Y coordinate
  # @param halo [Numeric] Distance outside item that still counts as "closest"
  # @param start [TkcItem, Integer] Start searching below this item
  # @return [self]
  def addtag_closest(tagOrId, x, y, halo=None, start=None)
    addtag(tagOrId, 'closest', x, y, halo, start)
  end

  # Adds a tag to all items completely enclosed by the rectangle.
  # @param tagOrId [String, TkcTag] Tag to add
  # @param x1 [Numeric] Left edge
  # @param y1 [Numeric] Top edge
  # @param x2 [Numeric] Right edge
  # @param y2 [Numeric] Bottom edge
  # @return [self]
  def addtag_enclosed(tagOrId, x1, y1, x2, y2)
    addtag(tagOrId, 'enclosed', x1, y1, x2, y2)
  end

  # Adds a tag to all items overlapping the rectangle.
  # @param tagOrId [String, TkcTag] Tag to add
  # @param x1 [Numeric] Left edge
  # @param y1 [Numeric] Top edge
  # @param x2 [Numeric] Right edge
  # @param y2 [Numeric] Bottom edge
  # @return [self]
  def addtag_overlapping(tagOrId, x1, y1, x2, y2)
    addtag(tagOrId, 'overlapping', x1, y1, x2, y2)
  end

  # Adds a tag to all items with the specified tag.
  # @param tagOrId [String, TkcTag] Tag to add
  # @param tag [String, TkcTag] Existing tag to search for
  # @return [self]
  def addtag_withtag(tagOrId, tag)
    addtag(tagOrId, 'withtag', tagid(tag))
  end

  # Returns the bounding box enclosing the specified items.
  #
  # @param tagOrId [TkcItem, Integer, String] First item or tag
  # @param tags [Array<TkcItem, Integer, String>] Additional items or tags
  # @return [Array<Integer>] [x1, y1, x2, y2] bounding coordinates, or empty if no items
  # @example
  #   x1, y1, x2, y2 = canvas.bbox('all')
  #   x1, y1, x2, y2 = canvas.bbox(rect1, rect2, 'mygroup')
  def bbox(tagOrId, *tags)
    TclTkLib._split_tklist(tk_send('bbox', tagid(tagOrId),
                             *tags.collect{|t| tagid(t)})).map(&:to_i)
  end

  # Binds an event to canvas items matching the tag.
  #
  # Associates a command with events on items. When the event occurs
  # over a matching item, the command is executed.
  #
  # @param tag [String, TkcTag, TkcItem] Tag or item to bind
  # @param context [String] Event sequence (e.g., '<Button-1>', '<Enter>')
  # @param args [Array] Additional bind arguments (substitution patterns)
  # @yield Block to execute when event occurs
  # @return [self]
  # @example
  #   canvas.itembind('draggable', '<Button-1>') { |e| start_drag(e) }
  #   canvas.itembind(rect, '<Enter>') { rect.configure(fill: 'red') }
  def itembind(tag, context, cmd = nil, *args, &block)
    cmd = block if block
    context = context.to_s
    context = "<#{context}>" unless context.start_with?('<')
    cb = install_cmd(cmd)
    script = args.empty? ? cb : "#{cb} #{args.join(' ')}"
    tk_call(path, 'bind', tagid(tag), context, script)
    self
  end

  # Appends a binding to existing bindings for an event.
  #
  # Unlike {#itembind}, which replaces existing bindings, this method
  # adds to them so multiple callbacks can fire for one event.
  #
  # @param tag [String, TkcTag, TkcItem] Tag or item to bind
  # @param context [String] Event sequence
  # @param args [Array] Additional bind arguments
  # @yield Block to execute when event occurs
  # @return [self]
  def itembind_append(tag, context, cmd = nil, *args, &block)
    cmd = block if block
    context = context.to_s
    context = "<#{context}>" unless context.start_with?('<')
    cb = install_cmd(cmd)
    script = args.empty? ? cb : "#{cb} #{args.join(' ')}"
    tk_call(path, 'bind', tagid(tag), context, "+#{script}")
    self
  end

  # Removes a binding from canvas items.
  #
  # @param tag [String, TkcTag, TkcItem] Tag or item
  # @param context [String] Event sequence to unbind
  # @return [self]
  def itembind_remove(tag, context)
    context = context.to_s
    context = "<#{context}>" unless context.start_with?('<')
    tk_call(path, 'bind', tagid(tag), context, '')
    self
  end

  # Returns binding information for canvas items.
  #
  # @param tag [String, TkcTag, TkcItem] Tag or item to query
  # @param context [String, nil] Event sequence, or nil for all sequences
  # @return [Array<String>, String] List of bound sequences, or the command for a specific sequence
  def itembindinfo(tag, context=nil)
    if context
      context = context.to_s
      context = "<#{context}>" unless context.start_with?('<')
      tk_call(path, 'bind', tagid(tag), context)
    else
      TclTkLib._split_tklist(tk_call(path, 'bind', tagid(tag)))
    end
  end

  # Converts a window X coordinate to canvas coordinate.
  #
  # Accounts for scrolling to convert screen position to canvas position.
  # Essential for handling mouse events on scrolled canvases.
  #
  # @param screen_x [Numeric] X coordinate in window
  # @param args [Array<Numeric>] Optional gridspacing; if specified, rounds to nearest multiple
  # @return [Float] X coordinate in canvas space
  # @example Getting canvas coordinates from mouse event
  #   canvas.bind('<Button-1>') do |e|
  #     cx = canvas.canvasx(e.x)
  #     cy = canvas.canvasy(e.y)
  #     TkcOval.new(canvas, cx-5, cy-5, cx+5, cy+5, fill: 'red')
  #   end
  def canvasx(screen_x, *args)
    #tk_tcl2ruby(tk_send('canvasx', screen_x, *args))
    tk_send('canvasx', screen_x, *args).to_f
  end

  # Converts a window Y coordinate to canvas coordinate.
  #
  # Accounts for scrolling to convert screen position to canvas position.
  #
  # @param screen_y [Numeric] Y coordinate in window
  # @param args [Array<Numeric>] Optional gridspacing; if specified, rounds to nearest multiple
  # @return [Float] Y coordinate in canvas space
  # @see #canvasx
  def canvasy(screen_y, *args)
    #tk_tcl2ruby(tk_send('canvasy', screen_y, *args))
    tk_send('canvasy', screen_y, *args).to_f
  end
  alias canvas_x canvasx
  alias canvas_y canvasy

  # Gets or sets the coordinates of a canvas item.
  #
  # Without arguments, returns the item's current coordinates.
  # With arguments, replaces the item's coordinates.
  #
  # @overload coords(tag)
  #   @param tag [TkcItem, Integer, String] Item or tag to query
  #   @return [Array<Float>] Current coordinates
  # @overload coords(tag, *new_coords)
  #   @param tag [TkcItem, Integer, String] Item or tag to modify
  #   @param new_coords [Array<Numeric>] New coordinate values
  #   @return [self]
  # @example
  #   coords = canvas.coords(rect)  # => [10.0, 10.0, 50.0, 50.0]
  #   canvas.coords(rect, 0, 0, 100, 100)  # move and resize
  def coords(tag, *args)
    if args.empty?
      TclTkLib._split_tklist(tk_send('coords', tagid(tag))).map(&:to_f)
    else
      tk_send('coords', tagid(tag), *(args.flatten))
      self
    end
  end

  # Deletes characters or coordinates from an item.
  #
  # For text items, deletes characters in the range [first, last].
  # For line/polygon items, deletes coordinates in the range.
  #
  # @param tag [TkcItem, Integer, String] Item to modify
  # @param first [Integer, String] Start index
  # @param last [Integer, String] End index (defaults to first if omitted)
  # @return [self]
  def dchars(tag, first, last=None)
    tk_send('dchars', tagid(tag), first, last)
    self
  end

  # Deletes items from the canvas.
  #
  # Removes items matching the specified tags or IDs. Also removes
  # the items from Ruby's internal tracking.
  #
  # @param args [Array<TkcItem, Integer, String>] Items or tags to delete
  # @return [self]
  # @example
  #   canvas.delete(rect)
  #   canvas.delete('temporary', 'markers')
  #   canvas.delete('all')  # delete everything
  def delete(*args)
    args.each{|tag|
      find('withtag', tag).each{|item|
        @items.delete(item.id) if item.respond_to?(:id)
      }
    }
    tk_send('delete', *args.collect{|t| tagid(t)})
    self
  end
  alias remove delete

  # Removes a tag from items.
  #
  # Removes the specified tag from all items matching the search tag.
  # If tag_to_del is omitted, removes the search tag itself.
  #
  # @param tag [TkcItem, Integer, String] Items to modify (search tag)
  # @param tag_to_del [String, TkcTag] Tag to remove (defaults to tag)
  # @return [self]
  # @example
  #   canvas.dtag(rect, 'highlighted')  # remove 'highlighted' from rect
  #   canvas.dtag('temporary')  # remove 'temporary' tag from items that have it
  def dtag(tag, tag_to_del=None)
    tk_send('dtag', tagid(tag), tagid(tag_to_del))
    self
  end
  alias deltag dtag

  # Finds items matching the search specification.
  #
  # Returns items in stacking order (lowest first).
  #
  # @param mode [String, Symbol] Search mode ('above', 'all', 'below', 'closest', 'enclosed', 'overlapping', 'withtag')
  # @param args [Array] Mode-specific arguments
  # @return [Array<TkcItem>] Matching items
  # @see #find_above, #find_all, etc. for convenient wrappers
  def find(mode, *args)
    TclTkLib._split_tklist(tk_send('find', mode, *args)).collect{|id|
      TkcItem.id2obj(self, id.to_i)
    }
  end

  # Finds the item just above the given item in stacking order.
  # @param target [TkcItem, Integer, String] Reference item
  # @return [Array<TkcItem>] Single-element array with item above, or empty
  def find_above(target)
    find('above', tagid(target))
  end

  # Returns all items on the canvas.
  # @return [Array<TkcItem>] All items in stacking order
  def find_all
    find('all')
  end

  # Finds the item just below the given item in stacking order.
  # @param target [TkcItem, Integer, String] Reference item
  # @return [Array<TkcItem>] Single-element array with item below, or empty
  def find_below(target)
    find('below', tagid(target))
  end

  # Finds the item closest to the given point.
  #
  # @param x [Numeric] X coordinate
  # @param y [Numeric] Y coordinate
  # @param halo [Numeric] Distance outside item that counts as "closest"
  # @param start [TkcItem, Integer] Start searching below this item
  # @return [Array<TkcItem>] Single-element array with closest item, or empty
  def find_closest(x, y, halo=None, start=None)
    find('closest', x, y, halo, start)
  end

  # Finds all items completely enclosed by the rectangle.
  #
  # An item is enclosed if its entire bounding box is within the rectangle.
  #
  # @param x1 [Numeric] Left edge
  # @param y1 [Numeric] Top edge
  # @param x2 [Numeric] Right edge
  # @param y2 [Numeric] Bottom edge
  # @return [Array<TkcItem>] Enclosed items
  def find_enclosed(x1, y1, x2, y2)
    find('enclosed', x1, y1, x2, y2)
  end

  # Finds all items overlapping the rectangle.
  #
  # An item overlaps if any part of it intersects the rectangle.
  #
  # @param x1 [Numeric] Left edge
  # @param y1 [Numeric] Top edge
  # @param x2 [Numeric] Right edge
  # @param y2 [Numeric] Bottom edge
  # @return [Array<TkcItem>] Overlapping items
  def find_overlapping(x1, y1, x2, y2)
    find('overlapping', x1, y1, x2, y2)
  end

  # Finds all items with the specified tag.
  # @param tag [String, TkcTag] Tag to search for
  # @return [Array<TkcItem>] Items with the tag
  def find_withtag(tag)
    find('withtag', tag)
  end

  # Gets or sets the keyboard focus item.
  #
  # Only one item can have focus at a time. Text items with focus
  # display an insertion cursor and receive keyboard events.
  #
  # @overload itemfocus
  #   @return [TkcItem, nil] The focused item, or nil if none
  # @overload itemfocus(tagOrId)
  #   @param tagOrId [TkcItem, Integer, String] Item to focus
  #   @return [self]
  # @example
  #   canvas.itemfocus(text_item)  # give focus to text item
  #   focused = canvas.itemfocus  # get currently focused item
  def itemfocus(tagOrId=nil)
    if tagOrId
      tk_send('focus', tagid(tagOrId))
      self
    else
      ret = tk_send('focus')
      if ret == ""
        nil
      else
        TkcItem.id2obj(self, ret)
      end
    end
  end

  # Returns the tags associated with an item.
  #
  # @param tagOrId [TkcItem, Integer, String] Item to query
  # @return [Array<TkcTag>] Tags on the item
  def gettags(tagOrId)
    TclTkLib._split_tklist(tk_send('gettags', tagid(tagOrId))).collect{|tag|
      TkcTag.id2obj(self, tag)
    }
  end

  # Sets the insertion cursor position in a text item.
  #
  # @param tagOrId [TkcItem, Integer, String] Text item
  # @param index [Integer, String] Position for cursor ('end', 'insert', or number)
  # @return [self]
  def icursor(tagOrId, index)
    tk_send('icursor', tagid(tagOrId), index)
    self
  end

  # Moves a coordinate point within a line or polygon item.
  #
  # Relocates the index-th coordinate to the new (x, y) position.
  # Only works on line and polygon items.
  #
  # @param tagOrId [TkcItem, Integer, String] Line or polygon item
  # @param idx [Integer] Coordinate index (0-based)
  # @param x [Numeric] New X coordinate
  # @param y [Numeric] New Y coordinate
  # @return [self]
  # @note Requires Tcl/Tk 8.6 or later
  def imove(tagOrId, idx, x, y)
    tk_send('imove', tagid(tagOrId), idx, x, y)
    self
  end
  alias i_move imove

  # Returns the numeric index for an index specification.
  #
  # Converts textual index descriptions ('end', 'insert', '@x,y') to numbers.
  # For text items, returns character index. For line/polygon, coordinate index.
  #
  # @param tagOrId [TkcItem, Integer, String] Item to query
  # @param idx [String, Integer] Index specification
  # @return [Integer] Numeric index
  def index(tagOrId, idx)
    tk_send('index', tagid(tagOrId), idx).to_i
  end

  # Inserts text or coordinates into an item.
  #
  # For text items, inserts the string before the specified index.
  # For line/polygon items, inserts coordinate pairs.
  #
  # @param tagOrId [TkcItem, Integer, String] Item to modify
  # @param index [Integer, String] Position to insert before
  # @param string [String] Text or coordinate values to insert
  # @return [self]
  def insert(tagOrId, index, string)
    tk_send('insert', tagid(tagOrId), index, string)
    self
  end

  # Moves items lower in the stacking order.
  #
  # Moves matching items to appear below the reference item, or to
  # the bottom if no reference given. Items maintain relative order.
  #
  # @param tag [TkcItem, Integer, String] Items to move
  # @param below [TkcItem, Integer, String, nil] Reference item (items go below this)
  # @return [self]
  # @note Has no effect on window items; they always appear on top
  def lower(tag, below=nil)
    if below
      tk_send('lower', tagid(tag), tagid(below))
    else
      tk_send('lower', tagid(tag))
    end
    self
  end

  # Moves items by a delta amount.
  #
  # Adds the x and y amounts to each coordinate of matching items.
  #
  # @param tag [TkcItem, Integer, String] Items to move
  # @param dx [Numeric] Amount to add to X coordinates
  # @param dy [Numeric] Amount to add to Y coordinates
  # @return [self]
  def move(tag, dx, dy)
    tk_send('move', tagid(tag), dx, dy)
    self
  end

  # Moves items to an absolute position.
  #
  # Positions the first matching item's upper-left corner at (x, y).
  # Other matching items maintain their relative positions.
  #
  # @param tag [TkcItem, Integer, String] Items to move
  # @param x [Numeric] New X position for upper-left corner
  # @param y [Numeric] New Y position for upper-left corner
  # @return [self]
  # @note Requires Tcl/Tk 8.6 or later
  def moveto(tag, x, y)
    # Tcl/Tk 8.6 or later
    tk_send('moveto', tagid(tag), x, y)
    self
  end
  alias move_to moveto

  # Generates Encapsulated PostScript for the canvas.
  #
  # @param keys [Hash] PostScript options
  # @option keys [String] :file Write to file instead of returning string
  # @option keys [String] :colormode 'color', 'gray', or 'mono'
  # @option keys [Numeric] :height Height of area to print
  # @option keys [Numeric] :width Width of area to print
  # @option keys [Numeric] :x Left edge of area to print
  # @option keys [Numeric] :y Top edge of area to print
  # @option keys [Boolean] :rotate Rotate output 90 degrees
  # @option keys [Numeric] :pagewidth Scale to this width on page
  # @option keys [Numeric] :pageheight Scale to this height on page
  # @return [String, nil] PostScript data, or nil if written to file
  def postscript(keys)
    args = []
    keys.each { |k, v| args << "-#{k}" << v.to_s }
    tk_send("postscript", *args)
  end

  # Moves items higher in the stacking order.
  #
  # Moves matching items to appear above the reference item, or to
  # the top if no reference given. Items maintain relative order.
  #
  # @param tag [TkcItem, Integer, String] Items to move
  # @param above [TkcItem, Integer, String, nil] Reference item (items go above this)
  # @return [self]
  # @note Has no effect on window items; they always appear on top
  def raise(tag, above=nil)
    if above
      tk_send('raise', tagid(tag), tagid(above))
    else
      tk_send('raise', tagid(tag))
    end
    self
  end

  # Replaces characters or coordinates in an item.
  #
  # For text items, replaces text between first and last indices.
  # For line/polygon items, replaces coordinates between those indices.
  #
  # @param tag [TkcItem, Integer, String] Item to modify
  # @param first [Integer, String] Start index
  # @param last [Integer, String] End index
  # @param str_or_coords [String, Array] Replacement text or coordinates
  # @return [self]
  # @note Requires Tcl/Tk 8.6 or later
  def rchars(tag, first, last, str_or_coords)
    # Tcl/Tk 8.6 or later
    str_or_coords = str_or_coords.flatten if str_or_coords.kind_of? Array
    tk_send('rchars', tagid(tag), first, last, str_or_coords)
    self
  end
  alias replace_chars rchars
  alias replace_coords rchars

  # Scales item coordinates around an origin point.
  #
  # Each coordinate is adjusted: new = origin + (old - origin) * scale
  #
  # @param tag [TkcItem, Integer, String] Items to scale
  # @param x [Numeric] X coordinate of scale origin
  # @param y [Numeric] Y coordinate of scale origin
  # @param xs [Numeric] X scale factor (1.0 = no change)
  # @param ys [Numeric] Y scale factor (1.0 = no change)
  # @return [self]
  # @note Single-coordinate items (text, image, bitmap) only move; they don't change size
  def scale(tag, x, y, xs, ys)
    tk_send('scale', tagid(tag), x, y, xs, ys)
    self
  end

  # Records a position for canvas scanning (fast scrolling).
  #
  # Use with {#scan_dragto} for click-and-drag scrolling.
  #
  # @param x [Integer] X coordinate of mark position
  # @param y [Integer] Y coordinate of mark position
  # @return [self]
  # @see #scan_dragto
  # @example Implementing drag-to-scroll
  #   canvas.bind('<Button-2>') { |e| canvas.scan_mark(e.x, e.y) }
  #   canvas.bind('<B2-Motion>') { |e| canvas.scan_dragto(e.x, e.y) }
  def scan_mark(x, y)
    tk_send('scan', 'mark', x, y)
    self
  end

  # Scrolls the canvas based on distance from scan mark.
  #
  # Scrolls by (gain * distance) from the position set by {#scan_mark}.
  # The gain defaults to 10, making scrolling feel fast.
  #
  # @param x [Integer] Current X coordinate
  # @param y [Integer] Current Y coordinate
  # @param gain [Numeric] Scroll multiplier (default: 10)
  # @return [self]
  # @see #scan_mark
  def scan_dragto(x, y, gain=None)
    tk_send('scan', 'dragto', x, y, gain)
    self
  end

  # Manipulates text selection in canvas items.
  #
  # @param mode [String] Selection operation ('adjust', 'clear', 'from', 'item', 'to')
  # @param args [Array] Mode-specific arguments
  # @return [TkcItem, self] The selected item for 'item' mode, self otherwise
  # @see #select_adjust, #select_clear, #select_from, #select_item, #select_to
  def select(mode, *args)
    r = tk_send('select', mode, *args)
    (mode == 'item')? TkcItem.id2obj(self, r): self
  end

  # Adjusts the selection to include the specified index.
  #
  # Moves the end of the selection nearest to the index to that index.
  #
  # @param tagOrId [TkcItem, Integer, String] Text item
  # @param index [Integer, String] Index to adjust to
  # @return [self]
  def select_adjust(tagOrId, index)
    select('adjust', tagid(tagOrId), index)
  end

  # Clears the current text selection.
  # @return [self]
  def select_clear
    select('clear')
  end

  # Sets the selection anchor.
  #
  # Sets one end of the selection; use {#select_to} to set the other end.
  #
  # @param tagOrId [TkcItem, Integer, String] Text item
  # @param index [Integer, String] Anchor index
  # @return [self]
  def select_from(tagOrId, index)
    select('from', tagid(tagOrId), index)
  end

  # Returns the item containing the current selection.
  # @return [TkcItem, nil] Item with selection, or nil if none
  def select_item
    select('item')
  end

  # Extends the selection to the specified index.
  #
  # Sets the other end of the selection from the anchor set by {#select_from}.
  #
  # @param tagOrId [TkcItem, Integer, String] Text item
  # @param index [Integer, String] End index
  # @return [self]
  def select_to(tagOrId, index)
    select('to', tagid(tagOrId), index)
  end

  # Returns the type of a canvas item.
  #
  # @param tag [TkcItem, Integer, String] Item to query
  # @return [Class] The TkcItem subclass (TkcRectangle, TkcLine, etc.)
  def itemtype(tag)
    TkcItem.type2class(tk_send('type', tagid(tag)))
  end

  # Creates a Ruby wrapper object for an existing canvas item ID.
  #
  # Useful when you have a numeric item ID (e.g., from Tcl code) and
  # need a TkcItem object to work with it in Ruby.
  #
  # @param idnum [Integer, String] Numeric canvas item ID
  # @return [TkcItem] A TkcItem subclass instance wrapping the item
  # @example
  #   # If you have an item ID from elsewhere
  #   item = canvas.create_itemobj_from_id(42)
  #   item.configure(fill: 'red')
  def create_itemobj_from_id(idnum)
    id = TkcItem.id2obj(self, idnum.to_i)
    return id if id.kind_of?(TkcItem)

    typename = tk_send('type', id)
    unless type = TkcItem.type2class(typename)
      (itemclass = typename.dup)[0,1] = typename[0,1].upcase
      type = TkcItem.const_set(itemclass, Class.new(TkcItem))
      type.const_set("CItemTypeName", typename.freeze)
      TkcItem::CItemTypeToClass[typename] = type
    end

    canvas = self
    (obj = type.allocate).instance_eval{
      @parent = @c = canvas
      @path = canvas.path
      @id = id
      canvas._additem(@id, self)
    }
  end
end

#TkCanvas = Tk::Canvas unless Object.const_defined? :TkCanvas
#Tk.__set_toplevel_aliases__(:Tk, Tk::Canvas, :TkCanvas)
Tk.__set_loaded_toplevel_aliases__('tk/canvas.rb', :Tk, Tk::Canvas, :TkCanvas)


# Base class for all canvas items.
#
# Canvas items are graphical objects displayed on a {Tk::Canvas} widget.
# Each item has:
# - A numeric ID (unique within its canvas)
# - Coordinates defining its shape and position
# - Configuration options for appearance
# - Optional tags for grouping
#
# Items can be manipulated after creation via methods inherited from
# {TkcTagAccess}: configure, move, scale, bind events, etc.
#
# ## Coordinate Systems
#
# Item coordinates are in canvas units (pixels by default). Use the canvas's
# `canvasx` and `canvasy` methods to convert window coordinates to canvas
# coordinates, accounting for scrolling.
#
# ## Creating Items
#
# Items are created by instantiating subclasses with a canvas and coordinates:
#
#     rect = TkcRectangle.new(canvas, 10, 10, 100, 50, fill: 'blue')
#     line = TkcLine.new(canvas, 0, 0, 100, 100, 200, 50, arrow: :last)
#
# Or with explicit coords array:
#
#     TkcPolygon.new(canvas, coords: [0, 0, 50, 100, 100, 0], fill: 'green')
#
# ## Common Options
#
# Most items support these options:
# - `:fill` - Interior color (empty string for transparent)
# - `:outline` - Border color
# - `:width` - Border width in pixels
# - `:dash` - Dash pattern for borders
# - `:stipple` - Fill pattern (bitmap name)
# - `:state` - :normal, :disabled, or :hidden
# - `:tags` - Array of tag names for grouping
#
# ## Stacking Order
#
# Items are drawn in creation order (later items on top). Use {#raise} and
# {#lower} to adjust stacking. Note: {TkcWindow} items always appear above
# all other items regardless of stacking order.
#
# @abstract Subclasses must define CItemTypeName constant.
#
# @see TkcTag For grouping items with tags
# @see Tk::Canvas The parent canvas widget
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/canvas.htm Tcl/Tk canvas manual
class TkcItem
  include TkcTagAccess
  include Tk::Generated::CanvasItems

  def self.new(*args, &block)
    obj = super(*args)
    obj.instance_exec(obj, &block) if block
    obj
  end

  CItemTypeName = nil
  CItemTypeToClass = {}

  def TkcItem.type2class(type)
    CItemTypeToClass[type]
  end

  # Look up an item by ID. Delegates to the canvas widget's itemid2obj.
  def TkcItem.id2obj(canvas, id)
    canvas.itemid2obj(id)
  end

  ########################################
  def self._parse_create_args(args)
    if args[-1].kind_of? Hash
      keys = args.pop.transform_keys(&:to_s)
      if args.size == 0
        args = keys.delete('coords')
        unless args.kind_of?(Array)
          fail "coords parameter must be given by an Array"
        end
      end

      # Resolve aliases (e.g., :tag -> :tags)
      declared_item_optkey_aliases.each do |alias_name, real_name|
        alias_name = alias_name.to_s
        keys[real_name.to_s] = keys.delete(alias_name) if keys.key?(alias_name)
      end

      args = args.flatten.concat(_keys_to_args(keys))
    else
      args = args.flatten
    end

    args
  end
  private_class_method :_parse_create_args

  def self.create(canvas, *args)
    unless self::CItemTypeName
      fail RuntimeError, "#{self} is an abstract class"
    end
    args = _parse_create_args(args).map(&:to_s)
    idnum = TkCore::INTERP._invoke(canvas.path, 'create',
                                    self::CItemTypeName, *args)
    idnum.to_i  # 'canvas item id' is an integer number
  end

  # Convert a hash of options to a flat array of -key value Tcl args.
  def self._keys_to_args(hash)
    return [] unless hash
    result = []
    hash.each do |k, v|
      next if v.equal?(TkUtil::None)
      result << "-#{k}"
      if v.respond_to?(:path)
        result << v.path
      elsif v.is_a?(Array)
        result << TclTkLib._merge_tklist(*v.map { |el|
          el.respond_to?(:path) ? el.path : el.to_s
        })
      else
        result << v.to_s
      end
    end
    result
  end
  private_class_method :_keys_to_args
  ########################################

  def initialize(parent, *args)
    #unless parent.kind_of?(Tk::Canvas)
    #  fail ArgumentError, "expect Tk::Canvas for 1st argument"
    #end
    @parent = @c = parent
    @path = parent.path

    @id = create_self(*args) # an integer number as 'canvas item id'
    @c._additem(@id, self)
  end
  def create_self(*args)
    self.class.create(@c, *args) # return an integer number as 'canvas item id'
  end
  private :create_self

  def id
    @id
  end

  # Override TkObject methods - canvas items use numeric @id as their
  # Tcl identifier, not @path (which holds the canvas widget path).
  # This is needed for:
  # - Passing items to Tcl commands (to_eval)
  # - Logical tag operators which use .path (e.g., tag & item)
  def to_eval
    @id.to_s
  end

  def path
    @id.to_s
  end

  def epath
    @id.to_s
  end

  def [](option)
    cget(option)
  end

  def []=(option, value)
    configure(option, value)
    value
  end

  def exist?
    # find_withtag returns array - empty array [] is truthy in Ruby
    !@c.find_withtag(@id).empty?
  end

  def delete
    @c.delete @id
    self
  end
  alias remove  delete
  alias destroy delete
end

# An arc, pie slice, or chord shape on a canvas.
#
# Arcs are sections of an ellipse defined by a bounding rectangle and
# angular range. The style determines how the arc is drawn:
# - `:pieslice` (default) - Filled wedge with lines to center
# - `:chord` - Filled area with straight line connecting endpoints
# - `:arc` - Just the curved edge, no fill
#
# @example Drawing a pie chart slice
#   TkcArc.new(canvas, 50, 50, 150, 150,
#     start: 0, extent: 90,
#     style: :pieslice,
#     fill: 'red', outline: 'black')
#
# @example Drawing a curved line (arc style)
#   TkcArc.new(canvas, 0, 0, 100, 100,
#     start: 45, extent: 180,
#     style: :arc,
#     outline: 'blue', width: 3)
#
# ## Coordinates
#
# Four values (x1, y1, x2, y2) defining the bounding rectangle of the
# ellipse from which the arc is cut.
#
# ## Key Options
#
# - `:start` - Starting angle in degrees (0 = 3 o'clock, counterclockwise)
# - `:extent` - Size of arc in degrees (positive = counterclockwise)
# - `:style` - :pieslice, :chord, or :arc
# - `:fill`, `:outline` - Colors (fill ignored for :arc style)
#
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/canvas.htm#M21 Arc item docs
class TkcArc<TkcItem
  CItemTypeName = 'arc'.freeze
  CItemTypeToClass[CItemTypeName] = self
end

# A monochrome bitmap image on a canvas.
#
# Bitmaps display two-color images using the classic X11 bitmap format.
# For full-color images, use {TkcImage} instead.
#
# @example Displaying a built-in bitmap
#   TkcBitmap.new(canvas, 50, 50,
#     bitmap: 'warning',
#     foreground: 'red')
#
# @example Using a custom bitmap file
#   TkcBitmap.new(canvas, 100, 100,
#     bitmap: '@/path/to/custom.xbm',
#     foreground: 'blue',
#     background: 'white')
#
# ## Coordinates
#
# Single point (x, y) for positioning. Use `:anchor` to control which
# part of the bitmap is placed at this point.
#
# ## Key Options
#
# - `:bitmap` - Bitmap name (built-in or @filename for custom)
# - `:foreground` - Color for "1" bits (default: black)
# - `:background` - Color for "0" bits (default: transparent)
# - `:anchor` - Position relative to coordinates (:center, :n, :ne, etc.)
#
# ## Built-in Bitmaps
#
# error, gray12, gray25, gray50, gray75, hourglass, info, questhead, question, warning
#
# @see TkcImage For full-color images
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/canvas.htm#M28 Bitmap item docs
class TkcBitmap<TkcItem
  CItemTypeName = 'bitmap'.freeze
  CItemTypeToClass[CItemTypeName] = self
end

# A full-color image on a canvas.
#
# Displays a TkPhotoImage or TkBitmapImage on the canvas. The image
# must be created first using the image classes.
#
# @example Displaying a photo
#   photo = TkPhotoImage.new(file: 'picture.png')
#   TkcImage.new(canvas, 100, 100, image: photo)
#
# @example With active state (hover effect)
#   normal = TkPhotoImage.new(file: 'button.png')
#   hover = TkPhotoImage.new(file: 'button_hover.png')
#   img = TkcImage.new(canvas, 50, 50,
#     image: normal,
#     activeimage: hover)
#
# ## Coordinates
#
# Single point (x, y) for positioning. Use `:anchor` to control which
# part of the image is placed at this point.
#
# ## Key Options
#
# - `:image` - TkPhotoImage or TkBitmapImage to display
# - `:activeimage` - Image to show when mouse hovers
# - `:disabledimage` - Image to show when state is :disabled
# - `:anchor` - Position relative to coordinates (:center default)
#
# @note The image object must remain in scope; if garbage collected,
#   the canvas item becomes blank.
#
# @see TkPhotoImage For creating images
# @see TkcBitmap For monochrome X11 bitmaps
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/canvas.htm#M35 Image item docs
class TkcImage<TkcItem
  CItemTypeName = 'image'.freeze
  CItemTypeToClass[CItemTypeName] = self
end

# A line or polyline on a canvas.
#
# Lines connect two or more points with straight or curved segments.
# Supports arrowheads, dashes, and smooth curves.
#
# @example Simple line
#   TkcLine.new(canvas, 0, 0, 100, 100, fill: 'black', width: 2)
#
# @example Polyline with arrow
#   TkcLine.new(canvas, 10, 10, 50, 80, 90, 10,
#     arrow: :last,
#     fill: 'blue', width: 3)
#
# @example Smooth curve through points
#   TkcLine.new(canvas, 0, 50, 25, 0, 50, 50, 75, 0, 100, 50,
#     smooth: true,
#     splinesteps: 20)
#
# ## Coordinates
#
# Two or more points (x1, y1, x2, y2, ...) defining the line path.
#
# ## Key Options
#
# - `:arrow` - Arrowheads: :none (default), :first, :last, :both
# - `:arrowshape` - [d1, d2, d3] controlling arrowhead size
# - `:smooth` - true for Bezier curves, false for straight segments
# - `:splinesteps` - Curve smoothness (higher = smoother, default 12)
# - `:capstyle` - Line ends: :butt, :projecting, :round
# - `:joinstyle` - Vertex corners: :miter, :bevel, :round
# - `:dash` - Dash pattern (e.g., "5 3" for 5-pixel dash, 3-pixel gap)
#
# @note Lines have no fill option; use `:fill` for the line color itself.
#
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/canvas.htm#M41 Line item docs
class TkcLine<TkcItem
  CItemTypeName = 'line'.freeze
  CItemTypeToClass[CItemTypeName] = self
end

# An oval (ellipse or circle) on a canvas.
#
# Ovals are defined by their bounding rectangle. For a circle,
# make the bounding rectangle square.
#
# @example Drawing a circle
#   TkcOval.new(canvas, 50, 50, 100, 100,
#     fill: 'red', outline: 'black')
#
# @example Drawing an ellipse
#   TkcOval.new(canvas, 10, 30, 110, 70,
#     fill: 'blue', width: 2)
#
# ## Coordinates
#
# Four values (x1, y1, x2, y2) defining diagonally opposite corners
# of the bounding rectangle.
#
# ## Key Options
#
# - `:fill` - Interior color (empty string for transparent)
# - `:outline` - Border color
# - `:width` - Border width in pixels
# - `:stipple` - Fill pattern (bitmap name)
#
# @note The oval includes its top and left edges but not its bottom
#   or right edges. This matters at the pixel level.
#
# @see TkcArc For partial ellipses
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/canvas.htm#M49 Oval item docs
class TkcOval<TkcItem
  CItemTypeName = 'oval'.freeze
  CItemTypeToClass[CItemTypeName] = self
end

# A filled polygon on a canvas.
#
# Polygons are closed shapes defined by three or more vertices.
# The shape closes automatically (last point connects to first).
# Supports smooth curves through vertices.
#
# @example Triangle
#   TkcPolygon.new(canvas, 50, 10, 10, 90, 90, 90,
#     fill: 'yellow', outline: 'black')
#
# @example Star shape
#   TkcPolygon.new(canvas,
#     50, 0, 60, 35, 100, 35, 70, 55, 80, 90, 50, 70, 20, 90, 30, 55, 0, 35, 40, 35,
#     fill: 'gold', outline: 'orange', width: 2)
#
# @example Smooth blob
#   TkcPolygon.new(canvas, 50, 0, 100, 50, 50, 100, 0, 50,
#     smooth: true, fill: 'green')
#
# ## Coordinates
#
# Three or more points (x1, y1, x2, y2, x3, y3, ...) defining vertices.
#
# ## Key Options
#
# - `:fill` - Interior color
# - `:outline` - Border color
# - `:smooth` - true for curved edges through vertices
# - `:splinesteps` - Curve smoothness (higher = smoother)
# - `:joinstyle` - Vertex corners: :miter, :bevel, :round
#
# @note Unlike most items, a polygon's interior is considered "inside"
#   even when unfilled. Mouse events trigger over the whole area.
#
# @see TkcLine For open polylines
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/canvas.htm#M55 Polygon item docs
class TkcPolygon<TkcItem
  CItemTypeName = 'polygon'.freeze
  CItemTypeToClass[CItemTypeName] = self
end

# A rectangle on a canvas.
#
# Rectangles are axis-aligned boxes defined by two diagonal corners.
#
# @example Simple filled rectangle
#   TkcRectangle.new(canvas, 10, 10, 100, 50,
#     fill: 'blue', outline: 'black')
#
# @example Outlined box with dash pattern
#   TkcRectangle.new(canvas, 20, 20, 80, 80,
#     fill: '',
#     outline: 'red',
#     dash: '5 3',
#     width: 2)
#
# ## Coordinates
#
# Four values (x1, y1, x2, y2) defining diagonally opposite corners.
# The corners can be specified in any order.
#
# ## Key Options
#
# - `:fill` - Interior color (empty string for transparent)
# - `:outline` - Border color
# - `:width` - Border width in pixels
# - `:dash` - Dash pattern for border
# - `:stipple` - Fill pattern (bitmap name)
#
# @note The rectangle includes its top and left edges but not its
#   bottom or right edges. This matters at the pixel level.
#
# @see TkcOval For ellipses
# @see TkcPolygon For arbitrary shapes
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/canvas.htm#M63 Rectangle item docs
class TkcRectangle<TkcItem
  CItemTypeName = 'rectangle'.freeze
  CItemTypeToClass[CItemTypeName] = self
end

# A text string on a canvas.
#
# Text items display one or more lines of text, with optional rotation
# and editing support. Supports the full range of canvas bindings and
# can receive keyboard focus.
#
# @example Simple label
#   TkcText.new(canvas, 100, 50,
#     text: "Hello World",
#     font: "Helvetica 14 bold",
#     fill: 'black')
#
# @example Multi-line centered text
#   TkcText.new(canvas, 200, 100,
#     text: "Line 1\nLine 2\nLine 3",
#     justify: :center,
#     anchor: :center)
#
# @example Rotated text (Tk 8.6+)
#   TkcText.new(canvas, 150, 150,
#     text: "Rotated!",
#     angle: 45)
#
# ## Coordinates
#
# Single point (x, y) for text positioning. The `:anchor` option
# controls which part of the text bounding box aligns to this point.
#
# ## Key Options
#
# - `:text` - String to display
# - `:font` - Font specification
# - `:fill` - Text color
# - `:justify` - Multi-line alignment: :left, :center, :right
# - `:anchor` - Position relative to coordinates (:center, :n, :nw, etc.)
# - `:width` - Maximum line width (0 = no wrapping)
# - `:angle` - Rotation in degrees (counterclockwise, Tk 8.6+)
# - `:underline` - Character index to underline (for keyboard shortcuts)
#
# ## Text Editing
#
# Canvas text items support in-place editing via canvas focus and
# insertion cursor methods. See {Tk::Canvas#focus} and {#icursor}.
#
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/canvas.htm#M69 Text item docs
class TkcText<TkcItem
  CItemTypeName = 'text'.freeze
  CItemTypeToClass[CItemTypeName] = self
  def self.create(canvas, *args)
    if args[-1].kind_of?(Hash)
      keys = args.pop.transform_keys(&:to_s)
      txt = keys['text']
      keys['text'] = txt.to_s if txt
      args.push(keys)
    end
    super(canvas, *args)
  end
end

# An embedded widget on a canvas.
#
# Window items place Tk widgets on the canvas, allowing buttons, entries,
# or any widget to be positioned and scrolled with canvas content.
#
# @example Button on canvas
#   btn = TkButton.new(canvas, text: "Click Me") { puts "clicked!" }
#   TkcWindow.new(canvas, 100, 50, window: btn)
#
# @example Entry field with explicit size
#   entry = TkEntry.new(canvas)
#   TkcWindow.new(canvas, 200, 100,
#     window: entry,
#     width: 150,
#     height: 25)
#
# ## Coordinates
#
# Single point (x, y) for widget positioning. The `:anchor` option
# controls which part of the widget aligns to this point.
#
# ## Key Options
#
# - `:window` - The widget to embed (must be child of canvas or toplevel)
# - `:width` - Override widget's natural width (0 = use natural)
# - `:height` - Override widget's natural height (0 = use natural)
# - `:anchor` - Position relative to coordinates (:center default)
#
# ## Quirks
#
# - Window items always appear above all other canvas items, regardless
#   of stacking order set by raise/lower
# - Windows are not clipped by the canvas border; they may extend outside
# - Embedded windows scroll with the canvas view
# - The widget must be a descendant of the canvas or its toplevel
#
# @note Unlike {TkTextWindow} in Text widgets, canvas windows don't
#   support lazy creation via a `:create` callback.
#
# @see TkTextWindow For embedding widgets in Text widgets
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/canvas.htm#M76 Window item docs
class TkcWindow<TkcItem
  CItemTypeName = 'window'.freeze
  CItemTypeToClass[CItemTypeName] = self

  # Override window option to return widget objects, not path strings
  extend Tk::ItemOptionDSL
  item_option :window, type: :widget

  def self.create(canvas, *args)
    if args[-1].kind_of?(Hash)
      keys = args.pop.transform_keys(&:to_s)
      win = keys['window']
      if win
        keys['window'] = win.respond_to?(:epath) ? win.epath :
                         win.respond_to?(:path)  ? win.path  : win.to_s
      end
      args.push(keys)
    end
    super(canvas, *args)
  end
end

# Add deprecation warning for removed CItemID_TBL constant
TkcItem.extend(TkcItemCompat)
