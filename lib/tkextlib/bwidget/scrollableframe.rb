# frozen_string_literal: false
#
#  tkextlib/bwidget/scrollableframe.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tk/frame'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
    # Scrollable frame container for large content.
    #
    # ScrollableFrame provides a frame that can be scrolled when its
    # content exceeds the visible area. Use with ScrolledWindow.
    #
    # @example Scrollable form
    #   require 'tkextlib/bwidget'
    #   sw = Tk::BWidget::ScrolledWindow.new(root)
    #   sf = Tk::BWidget::ScrollableFrame.new(sw)
    #   sw.set_widget(sf)
    #   sw.pack(fill: :both, expand: true)
    #
    #   frame = sf.get_frame
    #   10.times { |i| TkLabel.new(frame, text: "Item #{i}").pack }
    #
    # @see Tk::BWidget::ScrolledWindow For adding scrollbars
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/ScrollableFrame.html
    class ScrollableFrame < TkWindow
    end
  end
end

class Tk::BWidget::ScrollableFrame
  include Scrollable

  TkCommandNames = ['ScrollableFrame'.freeze].freeze
  WidgetClassName = 'ScrollableFrame'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  def get_frame(&b)
    win = window(tk_send_without_enc('getframe'))
    win.instance_exec(self, &b) if b
    win
  end

  def see(win, vert=None, horiz=None)
    tk_send_without_enc('see', win, vert, horiz)
    self
  end
end
