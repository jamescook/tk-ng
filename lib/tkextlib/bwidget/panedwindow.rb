# frozen_string_literal: false
#
#  tkextlib/bwidget/panedwindow.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tk/frame'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
    # Resizable paned container with draggable sash dividers.
    #
    # PanedWindow arranges child panes in a horizontal or vertical layout.
    # Users can drag the sash between panes to resize them.
    #
    # @example Horizontal split
    #   require 'tkextlib/bwidget'
    #   pw = Tk::BWidget::PanedWindow.new(root)
    #   pw.pack(fill: :both, expand: true)
    #
    #   left = pw.add(weight: 1)
    #   right = pw.add(weight: 2)
    #
    #   TkLabel.new(left, text: 'Left pane').pack
    #   TkLabel.new(right, text: 'Right pane').pack
    #
    # @example Vertical split
    #   pw = Tk::BWidget::PanedWindow.new(root, side: :top)
    #   top = pw.add(minsize: 100)
    #   bottom = pw.add
    #
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/PanedWindow.html
    class PanedWindow < TkWindow
    end
  end
end

class Tk::BWidget::PanedWindow
  TkCommandNames = ['PanedWindow'.freeze].freeze
  WidgetClassName = 'PanedWindow'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  def add(keys={})
    window(tk_send('add', *hash_kv(keys)))
  end

  def get_frame(idx, &b)
    win = window(tk_send_without_enc('getframe', idx))
    win.instance_exec(self, &b) if b
    win
  end
end
