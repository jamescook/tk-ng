# frozen_string_literal: false
#
#  tkextlib/bwidget/dragsite.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
    # Drag source registration for BWidget drag-and-drop.
    #
    # DragSite enables widgets to initiate drag operations.
    # Use with DropSite for complete drag-and-drop functionality.
    #
    # @example Register a drag source
    #   require 'tkextlib/bwidget'
    #   Tk::BWidget::DragSite.register(label,
    #     dragevent: 1,
    #     draginitcmd: proc { |path, x, y, top|
    #       # Return: type, data, operations
    #       ['TEXT', label.text, 'copy']
    #     })
    #
    # @see Tk::BWidget::DropSite For drop targets
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/DragSite.html
    module DragSite
    end
  end
end

module Tk::BWidget::DragSite
  include Tk
  extend Tk

  def self.include(klass, type, event)
    tk_call('DragSite::include', klass, type, event)
  end

  def self.register(path, keys={})
    tk_call('DragSite::register', path, *hash_kv(keys))
  end

  def self.set_drag(path, subpath, initcmd, endcmd, force=None)
    tk_call('DragSite::setdrag', path, subpath, initcmd, endcmd, force)
  end
end
