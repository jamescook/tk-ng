# frozen_string_literal: false
#
#  tkextlib/bwidget/titleframe.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tk/frame'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
    # Frame with a centered title in a groove border.
    #
    # TitleFrame displays a labeled container with a groove border
    # and the title text embedded in the top border line.
    #
    # @example Settings group
    #   require 'tkextlib/bwidget'
    #   tf = Tk::BWidget::TitleFrame.new(root, text: 'Options')
    #   tf.pack(fill: :both, expand: true, padx: 5, pady: 5)
    #
    #   frame = tf.get_frame
    #   TkCheckbutton.new(frame, text: 'Enable feature').pack(anchor: :w)
    #   TkCheckbutton.new(frame, text: 'Show warnings').pack(anchor: :w)
    #
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/TitleFrame.html
    class TitleFrame < TkWindow
    end
  end
end

class Tk::BWidget::TitleFrame
  TkCommandNames = ['TitleFrame'.freeze].freeze
  WidgetClassName = 'TitleFrame'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  def get_frame(&b)
    win = window(tk_send_without_enc('getframe'))
    win.instance_exec(self, &b) if b
    win
  end
end
