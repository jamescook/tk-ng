# frozen_string_literal: false
#
#  tkextlib/bwidget/panelframe.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tk/frame'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
    # Frame with a boxed title area.
    #
    # PanelFrame provides a container with a visible title section
    # at the top containing widget content.
    #
    # @example Panel with title
    #   require 'tkextlib/bwidget'
    #   pf = Tk::BWidget::PanelFrame.new(root)
    #   pf.pack(fill: :both, expand: true)
    #
    #   frame = pf.get_frame
    #   TkLabel.new(frame, text: 'Content here').pack
    #
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/PanelFrame.html
    class PanelFrame < TkWindow
    end
  end
end

class Tk::BWidget::PanelFrame
  TkCommandNames = ['PanelFrame'.freeze].freeze
  WidgetClassName = 'PanelFrame'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  def add(win, keys={})
    tk_send('add', win, keys)
    self
  end

  def delete(*wins)
    tk_send('delete', *wins)
    self
  end

  def get_frame(&b)
    win = window(tk_send_without_enc('getframe'))
    win.instance_exec(self, &b) if b
    win
  end

  def items
    simplelist(tk_send('items')).map{|w| window(w)}
  end

  def remove(*wins)
    tk_send('remove', *wins)
    self
  end

  def remove_with_destroy(*wins)
    tk_send('remove', '-destroy', *wins)
    self
  end

  def delete(*wins) # same to 'remove_with_destroy'
    tk_send('delete', *wins)
    self
  end
end
