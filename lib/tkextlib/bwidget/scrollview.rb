# frozen_string_literal: false
#
#  tkextlib/bwidget/scrollview.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
    # Miniature view showing visible area of scrolled content.
    #
    # ScrollView displays a small representation of a scrolled widget,
    # showing which portion is currently visible. Clicking in the
    # ScrollView scrolls to that position.
    #
    # @example With a scrolled canvas
    #   require 'tkextlib/bwidget'
    #   sv = Tk::BWidget::ScrollView.new(root)
    #   # Associate with a scrollable widget
    #   sv.pack
    #
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/ScrollView.html
    class ScrollView < TkWindow
    end
  end
end

class Tk::BWidget::ScrollView
  TkCommandNames = ['ScrollView'.freeze].freeze
  WidgetClassName = 'ScrollView'.freeze
  WidgetClassNames[WidgetClassName] ||= self
end
