# frozen_string_literal: false
#
#  tkextlib/bwidget/label.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tk/label'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
    # Enhanced label widget with dynamic help and drag-and-drop.
    #
    # Extends the standard Tk label with:
    # - Dynamic help (tooltip) support via `:helptext`
    # - Drag-and-drop capabilities
    # - State-dependent visual styling
    # - Keyboard shortcut via `:underline`
    #
    # @example Label with tooltip
    #   require 'tkextlib/bwidget'
    #   label = Tk::BWidget::Label.new(root,
    #     text: 'Username:',
    #     helptext: 'Enter your login name')
    #   label.pack
    #
    # @example Label with keyboard shortcut
    #   label = Tk::BWidget::Label.new(root,
    #     text: 'Password:',
    #     underline: 0)  # Alt+P focuses associated widget
    #
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/Label.html
    class Label < Tk::Label
    end
  end
end

class Tk::BWidget::Label
  extend Tk::OptionDSL

  TkCommandNames = ['Label'.freeze].freeze
  WidgetClassName = 'Label'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  # BWidget Label options
  option :helptext, type: :string
  option :helpvar, type: :tkvariable
  option :dragenabled, type: :boolean
  option :dropenabled, type: :boolean

  def set_focus
    tk_send_without_enc('setfocus')
    self
  end
end
