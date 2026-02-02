# frozen_string_literal: false
#
#  tkextlib/bwidget/arrowbutton.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tkextlib/bwidget.rb'
require 'tkextlib/bwidget/button'

module Tk
  module BWidget
    # Button widget displaying an arrow shape.
    #
    # ArrowButton displays directional arrows, useful for scroll buttons,
    # spinbox controls, or navigation. Supports repeat functionality.
    #
    # @example Arrow buttons for navigation
    #   require 'tkextlib/bwidget'
    #   up = Tk::BWidget::ArrowButton.new(root,
    #     dir: :top,
    #     command: proc { scroll_up })
    #   down = Tk::BWidget::ArrowButton.new(root,
    #     dir: :bottom,
    #     command: proc { scroll_down })
    #
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/ArrowButton.html
    class ArrowButton < Tk::BWidget::Button
    end
  end
end

class Tk::BWidget::ArrowButton
  TkCommandNames = ['ArrowButton'.freeze].freeze
  WidgetClassName = 'ArrowButton'.freeze
  WidgetClassNames[WidgetClassName] ||= self
end
