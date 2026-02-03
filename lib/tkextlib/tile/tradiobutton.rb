# frozen_string_literal: false
#
#  tradiobutton widget
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
# See: https://www.tcl-lang.org/man/tcl/TkCmd/ttk_radiobutton.html
#
require 'tk'
require 'tkextlib/tile.rb'
require_relative '../../tk/core/callable'
require_relative '../../tk/core/configurable'
require_relative '../../tk/core/widget'
require_relative '../../tk/callback'

class Tk::Tile::TRadioButton
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include Tk::Tile::TileWidget
  include Tk::Generated::TtkRadiobutton

  if Tk::Tile::USE_TTK_NAMESPACE
    TkCommandNames = ['::ttk::radiobutton'.freeze].freeze
  else
    TkCommandNames = ['::tradiobutton'.freeze].freeze
  end
  WidgetClassName = 'TRadiobutton'.freeze

  def self.style(*args)
    [self::WidgetClassName, *(args.map!(&:to_s))].join('.')
  end

  def deselect
    tk_send('deselect')
    self
  end

  def select
    tk_send('select')
    self
  end

  def invoke
    tk_send('invoke')
  end
end

module Tk
  module Tile
    TRadiobutton = TRadioButton
    RadioButton  = TRadioButton
    Radiobutton  = TRadioButton
  end
end

#Tk.__set_toplevel_aliases__(:Ttk, Tk::Tile::Radiobutton,
#                            :TkRadiobutton, :TkRadioButton)
Tk.__set_loaded_toplevel_aliases__('tkextlib/tile/tradiobutton.rb',
                                   :Ttk, Tk::Tile::Radiobutton,
                                   :TkRadiobutton, :TkRadioButton)
