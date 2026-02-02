# frozen_string_literal: false
#
#  tkextlib/bwidget/button.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tk/button'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
    # Enhanced button widget with dynamic help and repeat capabilities.
    #
    # Extends the standard Tk button with additional features:
    # - Dynamic help (tooltip) support via `:helptext`
    # - Arm/disarm callbacks with repeat functionality
    # - Additional relief style `:link` (flat until hovered)
    #
    # @example Basic button with help text
    #   require 'tkextlib/bwidget'
    #   btn = Tk::BWidget::Button.new(root,
    #     text: 'Save',
    #     helptext: 'Save the current document',
    #     command: proc { save_document })
    #   btn.pack
    #
    # @example Button with repeat (for increment/decrement)
    #   btn = Tk::BWidget::Button.new(root,
    #     text: '+',
    #     armcommand: proc { increment },
    #     repeatdelay: 300,
    #     repeatinterval: 100)
    #
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/Button.html
    class Button < Tk::Button
    end
  end
end

class Tk::BWidget::Button
  extend Tk::OptionDSL

  TkCommandNames = ['Button'.freeze].freeze
  WidgetClassName = 'BWidget::Button'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  # BWidget Button options
  option :helptext, type: :string
  option :helpvar, type: :tkvariable
end
