# frozen_string_literal: false
#
#  tkextlib/bwidget/progressdlg.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tk/variable'
require 'tkextlib/bwidget.rb'
require 'tkextlib/bwidget/progressbar'
require 'tkextlib/bwidget/messagedlg'

module Tk
  module BWidget
    # Modal dialog with progress bar for lengthy operations.
    #
    # ProgressDlg displays a progress indicator with optional cancel
    # button. The dialog blocks interaction until dismissed.
    #
    # @example Progress dialog
    #   require 'tkextlib/bwidget'
    #   dlg = Tk::BWidget::ProgressDlg.new(root,
    #     title: 'Processing',
    #     maximum: 100)
    #   dlg.create
    #
    #   100.times do |i|
    #     dlg.value = i
    #     dlg.text = "Processing item #{i}..."
    #     # do work
    #   end
    #   dlg.destroy
    #
    # @see Tk::BWidget::ProgressBar For embedded progress bars
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/ProgressDlg.html
    class ProgressDlg < Tk::BWidget::MessageDlg
    end
  end
end

class Tk::BWidget::ProgressDlg
  TkCommandNames = ['ProgressDlg'.freeze].freeze
  WidgetClassName = 'ProgressDlg'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  def create_self(keys)
    # NOT create widget for reusing the object
    super(keys)
    @keys['textvariable'] = TkVariable.new unless @keys.key?('textvariable')
    @keys['variable']     = TkVariable.new unless @keys.key?('variable')
  end

  def textvariable
    @keys['textvariable']
  end

  def text
    @keys['textvariable'].value
  end

  def text=(txt)
    @keys['textvariable'].value = txt
  end

  def variable
    @keys['variable']
  end

  def value
    @keys['variable'].value
  end

  def value=(val)
    @keys['variable'].value = val
  end

  def create
    window(tk_call(self.class::TkCommandNames[0], @path, *hash_kv(@keys)))
  end
end
