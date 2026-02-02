# frozen_string_literal: false
#
#  tkextlib/bwidget/labelframe.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tk/frame'
require 'tkextlib/bwidget.rb'
require 'tkextlib/bwidget/label'

module Tk
  module BWidget
    # Frame with an attached label on any side.
    #
    # LabelFrame creates a container with a label positioned at top,
    # bottom, left, or right. Used as a building block for ComboBox,
    # SpinBox, and similar widgets.
    #
    # @example Labeled input group
    #   require 'tkextlib/bwidget'
    #   lf = Tk::BWidget::LabelFrame.new(root,
    #     text: 'User Name:',
    #     side: :left)
    #   lf.pack(fill: :x, padx: 5, pady: 5)
    #
    #   entry = TkEntry.new(lf.get_frame)
    #   entry.pack(fill: :x, expand: true)
    #
    # @example Aligning multiple LabelFrames
    #   Tk::BWidget::LabelFrame.align(lf1, lf2, lf3)
    #
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/LabelFrame.html
    class LabelFrame < TkWindow
    end
  end
end

class Tk::BWidget::LabelFrame
  extend Tk::OptionDSL

  TkCommandNames = ['LabelFrame'.freeze].freeze
  WidgetClassName = 'LabelFrame'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  # BWidget LabelFrame options
  option :helpvar, type: :tkvariable

  def self.align(*args)
    tk_call('LabelFrame::align', *args)
  end
  def get_frame(&b)
    win = window(tk_send_without_enc('getframe'))
    win.instance_exec(self, &b) if b
    win
  end
end
