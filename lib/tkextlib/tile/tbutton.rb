# frozen_string_literal: false
#
#  tbutton widget
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
# See: https://www.tcl-lang.org/man/tcl/TkCmd/ttk_button.html
#
require 'tk'
require 'tkextlib/tile.rb'
require_relative '../../tk/core/callable'
require_relative '../../tk/core/configurable'
require_relative '../../tk/core/widget'
require_relative '../../tk/callback'

class Tk::Tile::TButton
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include Tk::Tile::TileWidget
  include Tk::Generated::TtkButton

  if Tk::Tile::USE_TTK_NAMESPACE
    TkCommandNames = ['::ttk::button'.freeze].freeze
  else
    TkCommandNames = ['::tbutton'.freeze].freeze
  end
  WidgetClassName = 'TButton'.freeze

  def self.style(*args)
    [self::WidgetClassName, *(args.map!(&:to_s))].join('.')
  end

  def invoke
    tk_send('invoke')
  end

  def flash
    tk_send('flash')
    self
  end
end

module Tk
  module Tile
    Button = TButton
  end
end

#Tk.__set_toplevel_aliases__(:Ttk, Tk::Tile::Button, :TkButton)
Tk.__set_loaded_toplevel_aliases__('tkextlib/tile/tbutton.rb',
                                   :Ttk, Tk::Tile::Button, :TkButton)
