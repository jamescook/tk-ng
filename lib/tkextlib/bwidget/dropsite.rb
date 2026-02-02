# frozen_string_literal: false
#
#  tkextlib/bwidget/dropsite.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'
require 'tkextlib/bwidget.rb'

module Tk
  module BWidget
    # Drop target registration for BWidget drag-and-drop.
    #
    # DropSite enables widgets to receive dropped data.
    # Use with DragSite for complete drag-and-drop functionality.
    #
    # @example Register a drop target
    #   require 'tkextlib/bwidget'
    #   Tk::BWidget::DropSite.register(label,
    #     droptypes: ['TEXT'],
    #     dropcmd: proc { |path, data, op, type, x, y|
    #       puts "Dropped: #{data}"
    #     })
    #
    # @see Tk::BWidget::DragSite For drag sources
    # @see https://core.tcl-lang.org/bwidget/doc/trunk/BWman/DropSite.html
    module DropSite
    end
  end
end

module Tk::BWidget::DropSite
  include Tk
  extend Tk

  def self.include(klass, type)
    tk_call('DropSite::include', klass, type)
  end

  def self.register(path, keys={})
    tk_call('DropSite::register', path, *hash_kv(keys))
  end

  def self.set_cursor(cursor)
    tk_call('DropSite::setcursor', cursor)
  end

  def self.set_drop(path, subpath, dropover, drop, force=None)
    tk_call('DropSite::setdrop', path, subpath, dropover, drop, force)
  end

  def self.set_operation(op)
    tk_call('DropSite::setoperation', op)
  end
end
