# frozen_string_literal: false
#
#  tkextlib/bwidget/progressbar.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
    # Progress indicator widget for lengthy operations.
    #
    # ProgressBar displays operation progress. Supports normal mode
    # (0 to max), incremental mode, and infinite/indeterminate mode.
    #
    # @example Basic progress bar
    #   require 'tkextlib/bwidget'
    #   progress_var = TkVariable.new(0)
    #   pb = Tk::BWidget::ProgressBar.new(root,
    #     variable: progress_var,
    #     maximum: 100)
    #   pb.pack(fill: :x)
    #
    #   # Update progress
    #   progress_var.value = 50  # 50%
    #
    # @example Indeterminate progress
    #   pb = Tk::BWidget::ProgressBar.new(root,
    #     type: :infinite,
    #     maximum: 20)
    #
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/ProgressBar.html
    class ProgressBar < TkWindow
    end
  end
end

class Tk::BWidget::ProgressBar
  TkCommandNames = ['ProgressBar'.freeze].freeze
  WidgetClassName = 'ProgressBar'.freeze
  WidgetClassNames[WidgetClassName] ||= self
end
