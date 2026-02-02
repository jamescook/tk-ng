# frozen_string_literal: false
#
#  tkextlib/bwidget/pagesmanager.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tk/frame'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
    # Page container without visible tabs (for custom tab controls).
    #
    # PagesManager provides NoteBook-like page management but without
    # the tab bar, allowing custom navigation controls.
    #
    # @example With custom navigation
    #   require 'tkextlib/bwidget'
    #   pm = Tk::BWidget::PagesManager.new(root)
    #   pm.pack(fill: :both, expand: true)
    #
    #   page1 = pm.add('page1')
    #   page2 = pm.add('page2')
    #   TkLabel.new(page1, text: 'Page 1').pack
    #   TkLabel.new(page2, text: 'Page 2').pack
    #
    #   pm.raise('page1')  # Show page1
    #
    # @see Tk::BWidget::NoteBook For tabbed interface
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/PagesManager.html
    class PagesManager < TkWindow
    end
  end
end

class Tk::BWidget::PagesManager
  TkCommandNames = ['PagesManager'.freeze].freeze
  WidgetClassName = 'PagesManager'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  def tagid(id)
    # id.to_s
    _get_eval_string(id)
  end

  def add(page, &b)
    win = window(tk_send('add', tagid(page)))
    win.instance_exec(self, &b) if b
    win
  end

  def compute_size
    tk_send('compute_size')
    self
  end

  def delete(page)
    tk_send('delete', tagid(page))
    self
  end

  def get_frame(page, &b)
    win = window(tk_send('getframe', tagid(page)))
    win.instance_exec(self, &b) if b
    win
  end

  def get_page(page)
    tk_send('pages', page)
  end

  def pages(first=None, last=None)
    list(tk_send('pages', first, last))
  end

  def raise(page=None)
    tk_send('raise', page)
    self
  end
end
