# frozen_string_literal: false
#
#  tkextlib/bwidget/combobox.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tk/entry'
require 'tkextlib/bwidget.rb'
require 'tkextlib/bwidget/listbox'
require 'tkextlib/bwidget/spinbox'

module Tk
  module BWidget
    # Dropdown selection widget combining entry and listbox.
    #
    # ComboBox allows users to select from a predefined list of values
    # or (when editable) type custom values. Supports auto-completion
    # and auto-posting as the user types.
    #
    # @example Basic dropdown selection
    #   require 'tkextlib/bwidget'
    #   combo = Tk::BWidget::ComboBox.new(root,
    #     values: ['Red', 'Green', 'Blue'],
    #     editable: false)
    #   combo.pack
    #
    # @example Editable with auto-complete
    #   combo = Tk::BWidget::ComboBox.new(root,
    #     values: ['Apple', 'Apricot', 'Banana', 'Cherry'],
    #     editable: true,
    #     autocomplete: true)
    #
    # @example Getting the selected value
    #   value = combo.get
    #   index = combo.getvalue  # -1 if not in list
    #
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/ComboBox.html
    class ComboBox < Tk::BWidget::SpinBox
    end
  end
end

class Tk::BWidget::ComboBox
  extend Tk::OptionDSL
  include Scrollable

  TkCommandNames = ['ComboBox'.freeze].freeze
  WidgetClassName = 'ComboBox'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  # BWidget ComboBox-specific options
  option :autocomplete, type: :boolean
  option :autopost, type: :boolean

  def get_listbox(&b)
    win = window(tk_send_without_enc('getlistbox'))
    win.instance_exec(self, &b) if b
    win
  end

  def clear_value
    tk_send_without_enc('clearvalue')
    self
  end
  alias clearvalue clear_value

  def icursor(idx)
    tk_send_without_enc('icursor', idx)
  end

  def post
    tk_send_without_enc('post')
    self
  end

  def unpost
    tk_send_without_enc('unpost')
    self
  end
end
