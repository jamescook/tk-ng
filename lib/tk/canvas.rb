# frozen_string_literal: false
require 'tk/canvastag'
require 'tk/scrollable'
require 'tk/option_dsl'
require 'tk/item_option_dsl'

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
class Tk::Canvas<TkWindow
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



  TkCommandNames = ['canvas'.freeze].freeze
  WidgetClassName = 'Canvas'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  def self.new(*args, &block)
    obj = super(*args){}
    obj.init_instance_variable
    obj.instance_exec(obj, &block) if block_given?
    obj
  end

  def init_instance_variable
    @items ||= {}
    @canvas_tags ||= {}
  end

  def _additem(id, obj)
    @items ||= {}
    @items[id] = obj
  end

  def _addtag(id, obj)
    @canvas_tags ||= {}
    @canvas_tags[id] = obj
  end

  def itemid2obj(id)
    return id unless @items
    @items[id] || id
  end

  def canvastagid2obj(id)
    return id unless @canvas_tags
    @canvas_tags[id] || id
  end

  #def create_self(keys)
  #  if keys and keys != None
  #    tk_call_without_enc('canvas', @path, *hash_kv(keys, true))
  #  else
  #    tk_call_without_enc('canvas', @path)
  #  end
  #end
  #private :create_self

  # NOTE: __numval_optkeys override for 'closeenough' removed - now declared via OptionDSL
  # NOTE: __boolval_optkeys override for 'confine' removed - now declared via OptionDSL

  def tagid(tag)
    if tag.kind_of?(TkcItem) || tag.kind_of?(TkcTag)
      tag.id
    else
      tag  # maybe an Array of configure parameters
    end
  end
  private :tagid


  # create a canvas item without creating a TkcItem object
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

  def addtag(tag, mode, *args)
    mode = mode.to_s
    if args[0] && mode =~ /^(above|below|with(tag)?)$/
      args[0] = tagid(args[0])
    end
    tk_send_without_enc('addtag', tagid(tag), mode, *args)
    self
  end
  def addtag_above(tagOrId, target)
    addtag(tagOrId, 'above', tagid(target))
  end
  def addtag_all(tagOrId)
    addtag(tagOrId, 'all')
  end
  def addtag_below(tagOrId, target)
    addtag(tagOrId, 'below', tagid(target))
  end
  def addtag_closest(tagOrId, x, y, halo=None, start=None)
    addtag(tagOrId, 'closest', x, y, halo, start)
  end
  def addtag_enclosed(tagOrId, x1, y1, x2, y2)
    addtag(tagOrId, 'enclosed', x1, y1, x2, y2)
  end
  def addtag_overlapping(tagOrId, x1, y1, x2, y2)
    addtag(tagOrId, 'overlapping', x1, y1, x2, y2)
  end
  def addtag_withtag(tagOrId, tag)
    addtag(tagOrId, 'withtag', tagid(tag))
  end

  def bbox(tagOrId, *tags)
    list(tk_send_without_enc('bbox', tagid(tagOrId),
                             *tags.collect{|t| tagid(t)}))
  end

  def itembind(tag, context, *args, &block)
    # if args[0].kind_of?(Proc) || args[0].kind_of?(Method)
    if TkComm._callback_entry?(args[0]) || !block
      cmd = args.shift
    else
      cmd = block
    end
    _bind([path, "bind", tagid(tag)], context, cmd, *args)
    self
  end

  def itembind_append(tag, context, *args, &block)
    # if args[0].kind_of?(Proc) || args[0].kind_of?(Method)
    if TkComm._callback_entry?(args[0]) || !block
      cmd = args.shift
    else
      cmd = block
    end
    _bind_append([path, "bind", tagid(tag)], context, cmd, *args)
    self
  end

  def itembind_remove(tag, context)
    _bind_remove([path, "bind", tagid(tag)], context)
    self
  end

  def itembindinfo(tag, context=nil)
    _bindinfo([path, "bind", tagid(tag)], context)
  end

  def canvasx(screen_x, *args)
    #tk_tcl2ruby(tk_send_without_enc('canvasx', screen_x, *args))
    number(tk_send_without_enc('canvasx', screen_x, *args))
  end
  def canvasy(screen_y, *args)
    #tk_tcl2ruby(tk_send_without_enc('canvasy', screen_y, *args))
    number(tk_send_without_enc('canvasy', screen_y, *args))
  end
  alias canvas_x canvasx
  alias canvas_y canvasy

  def coords(tag, *args)
    if args.empty?
      tk_split_list(tk_send_without_enc('coords', tagid(tag)))
    else
      tk_send_without_enc('coords', tagid(tag), *(args.flatten))
      self
    end
  end

  def dchars(tag, first, last=None)
    tk_send_without_enc('dchars', tagid(tag),
                        _get_eval_enc_str(first), _get_eval_enc_str(last))
    self
  end

  def delete(*args)
    args.each{|tag|
      find('withtag', tag).each{|item|
        @items.delete(item.id) if item.respond_to?(:id)
      }
    }
    tk_send_without_enc('delete', *args.collect{|t| tagid(t)})
    self
  end
  alias remove delete

  def dtag(tag, tag_to_del=None)
    tk_send_without_enc('dtag', tagid(tag), tagid(tag_to_del))
    self
  end
  alias deltag dtag

  def find(mode, *args)
    list(tk_send_without_enc('find', mode, *args)).collect!{|id|
      TkcItem.id2obj(self, id)
    }
  end
  def find_above(target)
    find('above', tagid(target))
  end
  def find_all
    find('all')
  end
  def find_below(target)
    find('below', tagid(target))
  end
  def find_closest(x, y, halo=None, start=None)
    find('closest', x, y, halo, start)
  end
  def find_enclosed(x1, y1, x2, y2)
    find('enclosed', x1, y1, x2, y2)
  end
  def find_overlapping(x1, y1, x2, y2)
    find('overlapping', x1, y1, x2, y2)
  end
  def find_withtag(tag)
    find('withtag', tag)
  end

  def itemfocus(tagOrId=nil)
    if tagOrId
      tk_send_without_enc('focus', tagid(tagOrId))
      self
    else
      ret = tk_send_without_enc('focus')
      if ret == ""
        nil
      else
        TkcItem.id2obj(self, ret)
      end
    end
  end

  def gettags(tagOrId)
    list(tk_send_without_enc('gettags', tagid(tagOrId))).collect{|tag|
      TkcTag.id2obj(self, tag)
    }
  end

  def icursor(tagOrId, index)
    tk_send_without_enc('icursor', tagid(tagOrId), index)
    self
  end

  def imove(tagOrId, idx, x, y)
    tk_send_without_enc('imove', tagid(tagOrId), idx, x, y)
    self
  end
  alias i_move imove

  def index(tagOrId, idx)
    number(tk_send_without_enc('index', tagid(tagOrId), idx))
  end

  def insert(tagOrId, index, string)
    tk_send_without_enc('insert', tagid(tagOrId), index,
                        _get_eval_enc_str(string))
    self
  end

  def lower(tag, below=nil)
    if below
      tk_send_without_enc('lower', tagid(tag), tagid(below))
    else
      tk_send_without_enc('lower', tagid(tag))
    end
    self
  end

  def move(tag, dx, dy)
    tk_send_without_enc('move', tagid(tag), dx, dy)
    self
  end

  def moveto(tag, x, y)
    # Tcl/Tk 8.6 or later
    tk_send_without_enc('moveto', tagid(tag), x, y)
    self
  end
  alias move_to moveto

  def postscript(keys)
    tk_send("postscript", *hash_kv(keys))
  end

  def raise(tag, above=nil)
    if above
      tk_send_without_enc('raise', tagid(tag), tagid(above))
    else
      tk_send_without_enc('raise', tagid(tag))
    end
    self
  end

  def rchars(tag, first, last, str_or_coords)
    # Tcl/Tk 8.6 or later
    str_or_coords = str_or_coords.flatten if str_or_coords.kind_of? Array
    tk_send_without_enc('rchars', tagid(tag), first, last, str_or_coords)
    self
  end
  alias replace_chars rchars
  alias replace_coords rchars

  def scale(tag, x, y, xs, ys)
    tk_send_without_enc('scale', tagid(tag), x, y, xs, ys)
    self
  end

  def scan_mark(x, y)
    tk_send_without_enc('scan', 'mark', x, y)
    self
  end
  def scan_dragto(x, y, gain=None)
    tk_send_without_enc('scan', 'dragto', x, y, gain)
    self
  end

  def select(mode, *args)
    r = tk_send_without_enc('select', mode, *args)
    (mode == 'item')? TkcItem.id2obj(self, r): self
  end
  def select_adjust(tagOrId, index)
    select('adjust', tagid(tagOrId), index)
  end
  def select_clear
    select('clear')
  end
  def select_from(tagOrId, index)
    select('from', tagid(tagOrId), index)
  end
  def select_item
    select('item')
  end
  def select_to(tagOrId, index)
    select('to', tagid(tagOrId), index)
  end

  def itemtype(tag)
    TkcItem.type2class(tk_send('type', tagid(tag)))
  end

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
class TkcItem<TkObject
  extend Tk
  include TkcTagAccess
  include Tk::Generated::CanvasItems

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
      keys = _symbolkey2str(args.pop)
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

      args = args.flatten.concat(hash_kv(keys))
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
    args = _parse_create_args(args)
    idnum = tk_call_without_enc(canvas.path, 'create',
                                self::CItemTypeName, *args)
    idnum.to_i  # 'canvas item id' is an integer number
  end
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
      keys = _symbolkey2str(args.pop)
      txt = keys['text']
      keys['text'] = _get_eval_enc_str(txt) if txt
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
      keys = _symbolkey2str(args.pop)
      win = keys['window']
      # keys['window'] = win.epath if win.kind_of?(TkWindow)
      keys['window'] = _epath(win) if win
      args.push(keys)
    end
    super(canvas, *args)
  end
end

# Add deprecation warning for removed CItemID_TBL constant
TkcItem.extend(TkcItemCompat)
