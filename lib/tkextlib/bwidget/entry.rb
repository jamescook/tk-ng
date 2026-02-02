# frozen_string_literal: false
#
#  tkextlib/bwidget/entry.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tk/entry'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
    # Enhanced entry widget with dynamic help and drag-and-drop.
    #
    # Extends the standard Tk entry with:
    # - Dynamic help (tooltip) support via `:helptext`
    # - Drag-and-drop capabilities
    # - State-dependent visual styling
    # - Command execution on Return key
    #
    # @example Entry with help text
    #   require 'tkextlib/bwidget'
    #   entry = Tk::BWidget::Entry.new(root,
    #     helptext: 'Enter your username')
    #   entry.pack
    #
    # @example Non-editable display field
    #   entry = Tk::BWidget::Entry.new(root,
    #     editable: false,
    #     textvariable: status_var)
    #
    # @example With command on Return
    #   entry = Tk::BWidget::Entry.new(root,
    #     command: proc { submit_form })
    #
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/Entry.html
    class Entry < Tk::Entry
    end
  end
end

class Tk::BWidget::Entry
  extend Tk::OptionDSL
  include Scrollable

  TkCommandNames = ['Entry'.freeze].freeze
  WidgetClassName = 'Entry'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  # BWidget Entry options
  option :helptext, type: :string
  option :helpvar, type: :tkvariable
  option :insertbackground, type: :string
  option :editable, type: :boolean
  option :dragenabled, type: :boolean
  option :dropenabled, type: :boolean

  def invoke
    tk_send_without_enc('invoke')
    self
  end
end
