# frozen_string_literal: false
#
#  tkextlib/bwidget/scrolledwindow.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk' unless defined?(Tk)
require 'tk/frame'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
    class ScrolledWindow < TkWindow
    end
  end
end

class Tk::BWidget::ScrolledWindow
  TkCommandNames = ['ScrolledWindow'.freeze].freeze
  WidgetClassName = 'ScrolledWindow'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  def __strval_optkeys
    super() << 'sides'
  end
  private :__strval_optkeys

  def __boolval_optkeys
    super() << 'managed'
  end
  private :__boolval_optkeys

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
