# frozen_string_literal: false
#
#  tkextlib/bwidget/entry.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk' unless defined?(Tk)
require 'tk/entry'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
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
  option :insertbackground, type: :string
  option :editable, type: :boolean
  option :dragenabled, type: :boolean
  option :dropenabled, type: :boolean

  def __strval_optkeys
    super() << 'helptext' << 'insertbackground'
  end
  private :__strval_optkeys

  def __boolval_optkeys
    super() << 'dragenabled' << 'dropenabled' << 'editable'
  end
  private :__boolval_optkeys

  def __tkvariable_optkeys
    super() << 'helpvar'
  end
  private :__tkvariable_optkeys

  def invoke
    tk_send_without_enc('invoke')
    self
  end
end
