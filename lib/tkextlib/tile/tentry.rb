# frozen_string_literal: false
#
#  tentry widget
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk' unless defined?(Tk)
require 'tkextlib/tile.rb'

module Tk
  module Tile
    class TEntry < Tk::Entry
    end
    Entry = TEntry
  end
end

class Tk::Tile::TEntry < Tk::Entry
  include Tk::Tile::TileWidget

  if Tk::Tile::USE_TTK_NAMESPACE
    TkCommandNames = ['::ttk::entry'.freeze].freeze
  else
    TkCommandNames = ['::tentry'.freeze].freeze
  end
  WidgetClassName = 'TEntry'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  # Options added in Tcl/Tk 9.0
  TCL9_OPTIONS = ['placeholder', 'placeholderforeground'].freeze

  def __optkey_aliases
    {:vcmd=>:validatecommand, :invcmd=>:invalidcommand}
  end
  private :__optkey_aliases

  def __boolval_optkeys
    super() << 'exportselection'
  end
  private :__boolval_optkeys

  def __strval_optkeys
    keys = super() << 'show'
    # Add placeholder options for Tcl/Tk 9.0+
    if Tk::TCL_MAJOR_VERSION >= 9
      keys.concat(TCL9_OPTIONS)
    end
    keys
  end
  private :__strval_optkeys

  # Filter out Tcl 9 options on Tcl 8.x
  def self.filter_tcl9_options(keys)
    return keys unless keys.is_a?(Hash) && Tk::TCL_MAJOR_VERSION < 9
    TCL9_OPTIONS.each do |opt|
      if keys.key?(opt) || keys.key?(opt.to_sym)
        warn "Warning: '#{opt}' option requires Tcl/Tk 9.0+ (you have #{Tk::TCL_VERSION})"
        keys.delete(opt)
        keys.delete(opt.to_sym)
      end
    end
    keys
  end

  def initialize(parent=nil, keys=nil)
    if parent.is_a?(Hash)
      self.class.filter_tcl9_options(parent)
    elsif keys.is_a?(Hash)
      self.class.filter_tcl9_options(keys)
    end
    super
  end

  def configure(slot, value=TkComm::None)
    if slot.is_a?(Hash)
      self.class.filter_tcl9_options(slot)
    elsif Tk::TCL_MAJOR_VERSION < 9 && TCL9_OPTIONS.include?(slot.to_s)
      warn "Warning: '#{slot}' option requires Tcl/Tk 9.0+ (you have #{Tk::TCL_VERSION})"
      return self
    end
    super
  end

  def self.style(*args)
    [self::WidgetClassName, *(args.map!{|a| _get_eval_string(a)})].join('.')
  end
end

#Tk.__set_toplevel_aliases__(:Ttk, Tk::Tile::Entry, :TkEntry)
Tk.__set_loaded_toplevel_aliases__('tkextlib/tile/tentry.rb',
                                   :Ttk, Tk::Tile::Entry, :TkEntry)
