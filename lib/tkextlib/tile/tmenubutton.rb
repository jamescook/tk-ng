# frozen_string_literal: false
#
#  tmenubutton widget
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
# See: https://www.tcl-lang.org/man/tcl/TkCmd/ttk_menubutton.html
#
require 'tk'
require 'tkextlib/tile.rb'
require_relative '../../tk/core/callable'
require_relative '../../tk/core/configurable'
require_relative '../../tk/core/widget'
require_relative '../../tk/callback'

class Tk::Tile::TMenubutton
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include Tk::Tile::TileWidget
  include Tk::Generated::TtkMenubutton

  if Tk::Tile::USE_TTK_NAMESPACE
    TkCommandNames = ['::ttk::menubutton'.freeze].freeze
  else
    TkCommandNames = ['::tmenubutton'.freeze].freeze
  end
  WidgetClassName = 'TMenubutton'.freeze

  def self.style(*args)
    [self::WidgetClassName, *(args.map!(&:to_s))].join('.')
  end
end

module Tk
  module Tile
    TMenuButton = TMenubutton
    Menubutton  = TMenubutton
    MenuButton  = TMenubutton
  end
end

#Tk.__set_toplevel_aliases__(:Ttk, Tk::Tile::Menubutton,
#                            :TkMenubutton, :TkMenuButton)
Tk.__set_loaded_toplevel_aliases__('tkextlib/tile/tmenubutton.rb',
                                   :Ttk, Tk::Tile::Menubutton,
                                   :TkMenubutton, :TkMenuButton)
