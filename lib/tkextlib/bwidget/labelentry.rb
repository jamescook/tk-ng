# frozen_string_literal: false
#
#  tkextlib/bwidget/labelentry.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tk/entry'
require 'tkextlib/bwidget.rb'
require 'tkextlib/bwidget/labelframe'
require 'tkextlib/bwidget/entry'

module Tk
  module BWidget
    # Entry widget with integrated label.
    #
    # LabelEntry combines a Label and Entry into a single widget,
    # simplifying form layouts. The label position is configurable.
    #
    # @example Simple labeled entry
    #   require 'tkextlib/bwidget'
    #   le = Tk::BWidget::LabelEntry.new(root,
    #     label: 'Username:',
    #     labelwidth: 10)
    #   le.pack(fill: :x, padx: 5, pady: 5)
    #
    # @example With help text
    #   le = Tk::BWidget::LabelEntry.new(root,
    #     label: 'Email:',
    #     helptext: 'Enter your email address')
    #
    # @see Tk::BWidget::LabelFrame The underlying labeled container
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/LabelEntry.html
    class LabelEntry < Tk::Entry
    end
  end
end

class Tk::BWidget::LabelEntry
  extend Tk::OptionDSL
  include Scrollable

  TkCommandNames = ['LabelEntry'.freeze].freeze
  WidgetClassName = 'LabelEntry'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  # BWidget LabelEntry options
  option :helpvar, type: :tkvariable

  def __font_optkeys
    super() << 'labelfont'
  end
  private :__font_optkeys

  def entrybind(context, *args, &block)
    # if args[0].kind_of?(Proc) || args[0].kind_of?(Method)
    if TkComm._callback_entry?(args[0]) || !block
      cmd = args.shift
    else
      cmd = block
    end
    _bind([path, 'bind'], context, cmd, *args)
    self
  end

  def entrybind_append(context, *args, &block)
    #if args[0].kind_of?(Proc) || args[0].kind_of?(Method)
    if TkComm._callback_entry?(args[0]) || !block
      cmd = args.shift
    else
      cmd = block
    end
    _bind_append([path, 'bind'], context, cmd, *args)
    self
  end

  def entrybind_remove(*args)
    _bind_remove([path, 'bind'], *args)
    self
  end

  def entrybindinfo(*args)
    _bindinfo([path, 'bind'], *args)
    self
  end
end
