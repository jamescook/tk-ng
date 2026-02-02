# frozen_string_literal: false
#
#  tkextlib/bwidget/scrolledwindow.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tk/frame'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
    # Container that adds scrollbars to any scrollable widget.
    #
    # ScrolledWindow automatically creates and manages scrollbars for
    # widgets like Text, Canvas, or Listbox. Scrollbars can be configured
    # to appear always, never, or only when needed.
    #
    # @example Scrolled text widget
    #   require 'tkextlib/bwidget'
    #   sw = Tk::BWidget::ScrolledWindow.new(root, auto: :both)
    #   sw.pack(fill: :both, expand: true)
    #
    #   text = TkText.new(sw)
    #   sw.set_widget(text)
    #
    # @example Scrolled canvas
    #   sw = Tk::BWidget::ScrolledWindow.new(root)
    #   canvas = Tk::Canvas.new(sw, scrollregion: [0, 0, 1000, 1000])
    #   sw.set_widget(canvas)
    #   sw.pack(fill: :both, expand: true)
    #
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/ScrolledWindow.html
    class ScrolledWindow < TkWindow
    end
  end
end

class Tk::BWidget::ScrolledWindow
  TkCommandNames = ['ScrolledWindow'.freeze].freeze
  WidgetClassName = 'ScrolledWindow'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  def get_frame(&b)
    win = window(tk_send_without_enc('getframe'))
    win.instance_exec(self, &b) if b
    win
  end

  def set_widget(win)
    tk_send_without_enc('setwidget', win)
    self
  end
end
