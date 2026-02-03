# frozen_string_literal: false
#
#  tscrollbar widget
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
# See: https://www.tcl-lang.org/man/tcl/TkCmd/ttk_scrollbar.html
#
require 'tk'
require 'tkextlib/tile.rb'

module Tk
  module Tile
    class TScrollbar < Tk::Scrollbar
    end
    Scrollbar = TScrollbar
  end
end

class Tk::Tile::TScrollbar < Tk::Scrollbar
  include Tk::Tile::TileWidget
  include Tk::Generated::TtkScrollbar

  if Tk::Tile::USE_TTK_NAMESPACE
    TkCommandNames = ['::ttk::scrollbar'.freeze].freeze
  else
    TkCommandNames = ['::tscrollbar'.freeze].freeze
  end
  WidgetClassName = 'TScrollbar'.freeze
  Tk::Core::Widget.registry[WidgetClassName] ||= self

  def self.style(*args)
    [self::WidgetClassName, *(args.map!(&:to_s))].join('.')
  end

  alias identify ttk_identify
end

#Tk.__set_toplevel_aliases__(:Ttk, Tk::Tile::Scrollbar, :TkScrollbar)
Tk.__set_loaded_toplevel_aliases__('tkextlib/tile/tscrollbar.rb',
                                   :Ttk, Tk::Tile::Scrollbar, :TkScrollbar)

#######################################################################

class Tk::Tile::XScrollbar < Tk::Tile::TScrollbar
  def initialize(parent = nil, keys = {}, &block)
    keys = parent.is_a?(Hash) ? parent.dup : keys.dup
    parent = keys.delete(:parent) if parent.is_a?(Hash)
    keys[:orient] = 'horizontal'
    super(parent, keys, &block)
  end
end

class Tk::Tile::YScrollbar < Tk::Tile::TScrollbar
  def initialize(parent = nil, keys = {}, &block)
    keys = parent.is_a?(Hash) ? parent.dup : keys.dup
    parent = keys.delete(:parent) if parent.is_a?(Hash)
    keys[:orient] = 'vertical'
    super(parent, keys, &block)
  end
end

#Tk.__set_toplevel_aliases__(:Ttk, Tk::Tile::XScrollbar, :TkXScrollbar)
#Tk.__set_toplevel_aliases__(:Ttk, Tk::Tile::YScrollbar, :TkYScrollbar)
Tk.__set_loaded_toplevel_aliases__('tkextlib/tile/tscrollbar.rb',
                                   :Ttk, Tk::Tile::XScrollbar, :TkXScrollbar)
Tk.__set_loaded_toplevel_aliases__('tkextlib/tile/tscrollbar.rb',
                                   :Ttk, Tk::Tile::YScrollbar, :TkYScrollbar)
