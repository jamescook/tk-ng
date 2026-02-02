# frozen_string_literal: false
#
#  tkextlib/bwidget/separator.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
    # 3D separator line widget.
    #
    # Separator draws a horizontal or vertical groove line for
    # visually dividing sections of a UI.
    #
    # @example Horizontal separator
    #   require 'tkextlib/bwidget'
    #   sep = Tk::BWidget::Separator.new(root, orient: :horizontal)
    #   sep.pack(fill: :x, pady: 10)
    #
    # @example Vertical separator
    #   sep = Tk::BWidget::Separator.new(root, orient: :vertical)
    #   sep.pack(side: :left, fill: :y, padx: 10)
    #
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/Separator.html
    class Separator < TkWindow
    end
  end
end

class Tk::BWidget::Separator
  TkCommandNames = ['Separator'.freeze].freeze
  WidgetClassName = 'Separator'.freeze
  WidgetClassNames[WidgetClassName] ||= self
end
