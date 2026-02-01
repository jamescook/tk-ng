# frozen_string_literal: false
require 'tk/option_dsl'

# A container widget for grouping other widgets.
#
# Frames are invisible by default and used primarily for layout organization.
# Child widgets are placed inside using geometry managers (pack, grid, place).
#
# @example Basic container
#   frame = Tk::Frame.new
#   Tk::Label.new(frame, text: "Name:").pack(side: :left)
#   Tk::Entry.new(frame).pack(side: :left)
#   frame.pack
#
# @example Visible frame with border
#   Tk::Frame.new(
#     borderwidth: 2,
#     relief: :groove,
#     padx: 10,
#     pady: 10
#   ).pack
#
# @example Nested frames for complex layouts
#   main = Tk::Frame.new.pack(fill: :both, expand: true)
#   sidebar = Tk::Frame.new(main, width: 200).pack(side: :left, fill: :y)
#   content = Tk::Frame.new(main).pack(side: :left, fill: :both, expand: true)
#
# @note **width/height gotcha**: Explicit width/height are often overridden
#   by geometry managers (pack/grid). To enforce size, either disable
#   propagation (`frame.pack_propagate(false)`) or don't pack children.
#
# @see Tk::LabelFrame for a frame with a visible label/title
# @see https://www.tcl-lang.org/man/tcl/TkCmd/frame.html Tcl/Tk frame manual
#
class Tk::Frame<TkWindow
  include Tk::Generated::Frame
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
  #   :padx
  #   :pady
  #   :relief
  #   :takefocus
  #   :tile
  #   :visual
  #   :width
  # @generated:options:end



  TkCommandNames = ['frame'.freeze].freeze
  WidgetClassName = 'Frame'.freeze
  WidgetClassNames[WidgetClassName] ||= self

################# old version
#  def initialize(parent=nil, keys=nil)
#    if keys.kind_of? Hash
#      keys = keys.dup
#      @classname = keys.delete('classname') if keys.key?('classname')
#      @colormap  = keys.delete('colormap')  if keys.key?('colormap')
#      @container = keys.delete('container') if keys.key?('container')
#      @visual    = keys.delete('visual')    if keys.key?('visual')
#    end
#    super(parent, keys)
#  end
#
#  def create_self
#    s = []
#    s << "-class"     << @classname if @classname
#    s << "-colormap"  << @colormap  if @colormap
#    s << "-container" << @container if @container
#    s << "-visual"    << @visual    if @visual
#    tk_call 'frame', @path, *s
#  end
#################

  # NOTE: __boolval_optkeys override for 'container' removed - now declared via OptionDSL

  def initialize(parent=nil, keys=nil)
    my_class_name = nil
    if self.class < WidgetClassNames[self.class::WidgetClassName]
      my_class_name = self.class.name
      my_class_name = nil if my_class_name == ''
    end
    if parent.kind_of? Hash
      keys = _symbolkey2str(parent)
    else
      if keys
        keys = _symbolkey2str(keys)
        keys['parent'] = parent
      else
        keys = {'parent'=>parent}
      end
    end
    if keys.key?('classname')
       keys['class'] = keys.delete('classname')
    end
    @classname = keys['class']
    @colormap  = keys['colormap']
    @container = keys['container']
    @visual    = keys['visual']
    if !@classname && my_class_name
      keys['class'] = @classname = my_class_name
    end
    if @classname.kind_of? TkBindTag
      @db_class = @classname
      @classname = @classname.id
    elsif @classname
      @db_class = TkDatabaseClass.new(@classname)
    else
      @db_class = self.class
      @classname = @db_class::WidgetClassName
    end
    super(keys)
  end

  #def create_self(keys)
  #  if keys and keys != None
  #    tk_call_without_enc('frame', @path, *hash_kv(keys))
  #  else
  #    tk_call_without_enc( 'frame', @path)
  #  end
  #end
  #private :create_self

  def database_classname
    @classname
  end

  def self.database_class
    if self == WidgetClassNames[WidgetClassName] || self.name == ''
      self
    else
      TkDatabaseClass.new(self.name)
    end
  end
  def self.database_classname
    self.database_class.name
  end

  def self.bind(*args, &b)
    if self == WidgetClassNames[WidgetClassName] || self.name == ''
      super(*args, &b)
    else
      TkDatabaseClass.new(self.name).bind(*args, &b)
    end
  end
  def self.bind_append(*args, &b)
    if self == WidgetClassNames[WidgetClassName] || self.name == ''
      super(*args, &b)
    else
      TkDatabaseClass.new(self.name).bind_append(*args, &b)
    end
  end
  def self.bind_remove(*args)
    if self == WidgetClassNames[WidgetClassName] || self.name == ''
      super(*args)
    else
      TkDatabaseClass.new(self.name).bind_remove(*args)
    end
  end
  def self.bindinfo(*args)
    if self == WidgetClassNames[WidgetClassName] || self.name == ''
      super(*args)
    else
      TkDatabaseClass.new(self.name).bindinfo(*args)
    end
  end
end

#TkFrame = Tk::Frame unless Object.const_defined? :TkFrame
#Tk.__set_toplevel_aliases__(:Tk, Tk::Frame, :TkFrame)
Tk.__set_loaded_toplevel_aliases__('tk/frame.rb', :Tk, Tk::Frame, :TkFrame)
