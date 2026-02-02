# frozen_string_literal: false
require 'tk/frame'

# A frame with a visible label, useful for grouping related widgets.
#
# LabelFrame is like {Tk::Frame} but displays a text label (or custom widget)
# as part of the border. Common for grouping form sections.
#
# @example Basic labeled group
#   group = Tk::LabelFrame.new(text: "Personal Info", padx: 10, pady: 10)
#   Tk::Label.new(group, text: "Name:").grid(row: 0, column: 0)
#   Tk::Entry.new(group).grid(row: 0, column: 1)
#   group.pack(fill: :x, padx: 10, pady: 10)
#
# @example Custom label position
#   Tk::LabelFrame.new(
#     text: "Options",
#     labelanchor: :n  # centered at top (default is :nw)
#   ).pack
#
# @example Using a widget as label
#   check = Tk::CheckButton.new(text: "Enable Section")
#   Tk::LabelFrame.new(labelwidget: check).pack
#
# @note The `:labelanchor` option positions the label: :nw (default),
#   :n, :ne, :e, :se, :s, :sw, :w.
#
# @see Tk::Frame for unlabeled containers
# @see https://www.tcl-lang.org/man/tcl/TkCmd/labelframe.html Tcl/Tk labelframe manual
#
class Tk::LabelFrame<Tk::Frame
  include Tk::Generated::Labelframe
  # @generated:options:start
  # Available options (auto-generated from Tk introspection):
  #
  #   :background
  #   :borderwidth
  #   :class
  #   :colormap
  #   :container
  #   :cursor
  #   :font
  #   :foreground
  #   :height
  #   :highlightbackground
  #   :highlightcolor
  #   :highlightthickness
  #   :labelanchor
  #   :labelwidget
  #   :padx
  #   :pady
  #   :relief
  #   :takefocus
  #   :text
  #   :visual
  #   :width
  # @generated:options:end

  TkCommandNames = ['labelframe'.freeze].freeze
  WidgetClassName = 'Labelframe'.freeze
  WidgetClassNames[WidgetClassName] ||= self
end

Tk::Labelframe = Tk::LabelFrame
#TkLabelFrame = Tk::LabelFrame unless Object.const_defined? :TkLabelFrame
#TkLabelframe = Tk::Labelframe unless Object.const_defined? :TkLabelframe
#Tk.__set_toplevel_aliases__(:Tk, Tk::LabelFrame, :TkLabelFrame, :TkLabelframe)
Tk.__set_loaded_toplevel_aliases__('tk/labelframe.rb', :Tk, Tk::LabelFrame,
                                   :TkLabelFrame, :TkLabelframe)
