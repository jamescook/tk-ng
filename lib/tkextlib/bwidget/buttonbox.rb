# frozen_string_literal: false
#
#  tkextlib/bwidget/buttonbox.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tkextlib/bwidget.rb'
require 'tkextlib/bwidget/button'

module Tk
  module BWidget
    # Container for arranging buttons horizontally or vertically.
    #
    # ButtonBox manages a set of buttons with consistent spacing and
    # alignment. Used internally by Dialog and other widgets.
    #
    # @example Horizontal button row
    #   require 'tkextlib/bwidget'
    #   bbox = Tk::BWidget::ButtonBox.new(root, orient: :horizontal)
    #   bbox.add(text: 'OK', command: proc { ok })
    #   bbox.add(text: 'Cancel', command: proc { cancel })
    #   bbox.pack(side: :bottom, fill: :x)
    #
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/ButtonBox.html
    class ButtonBox < TkWindow
    end
  end
end

class Tk::BWidget::ButtonBox
  TkCommandNames = ['ButtonBox'.freeze].freeze
  WidgetClassName = 'ButtonBox'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  extend Tk::ItemOptionDSL

  def tagid(tagOrId)
    if tagOrId.kind_of?(Tk::BWidget::Button)
      name = tagOrId[:name]
      return index(name) unless name.empty?
    end
    if tagOrId.kind_of?(Tk::Button)
      return index(tagOrId[:text])
    end
    # index(tagOrId.to_s)
    index(_get_eval_string(tagOrId))
  end

  def add(keys={}, &b)
    win = window(tk_send('add', *hash_kv(keys)))
    win.instance_exec(self, &b) if b
    win
  end

  def delete(idx)
    tk_send('delete', tagid(idx))
    self
  end

  def index(idx)
    if idx.kind_of?(Tk::BWidget::Button)
      name = idx[:name]
      idx = name unless name.empty?
    end
    if idx.kind_of?(Tk::Button)
      idx = idx[:text]
    end
    number(tk_send('index', idx.to_s))
  end

  def insert(idx, keys={}, &b)
    win = window(tk_send('insert', tagid(idx), *hash_kv(keys)))
    win.instance_exec(self, &b) if b
    win
  end

  def invoke(idx)
    tk_send('invoke', tagid(idx))
    self
  end

  def set_focus(idx)
    tk_send('setfocus', tagid(idx))
    self
  end
end
