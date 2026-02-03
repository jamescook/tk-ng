# frozen_string_literal: false
require_relative 'core/callable'
require_relative 'core/configurable'
require_relative 'core/widget'
require_relative 'callback'

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
class Tk::Frame
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
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
end

#TkFrame = Tk::Frame unless Object.const_defined? :TkFrame
#Tk.__set_toplevel_aliases__(:Tk, Tk::Frame, :TkFrame)
Tk.__set_loaded_toplevel_aliases__('tk/frame.rb', :Tk, Tk::Frame, :TkFrame)
