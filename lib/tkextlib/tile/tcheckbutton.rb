# frozen_string_literal: false
#
#  tcheckbutton widget
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
# See: https://www.tcl-lang.org/man/tcl/TkCmd/ttk_checkbutton.html
#
require 'tk'
require 'tkextlib/tile.rb'
require_relative '../../tk/core/callable'
require_relative '../../tk/core/configurable'
require_relative '../../tk/core/widget'
require_relative '../../tk/callback'

class Tk::Tile::TCheckButton
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include Tk::Tile::TileWidget
  include Tk::Generated::TtkCheckbutton

  if Tk::Tile::USE_TTK_NAMESPACE
    TkCommandNames = ['::ttk::checkbutton'.freeze].freeze
  else
    TkCommandNames = ['::tcheckbutton'.freeze].freeze
  end
  WidgetClassName = 'TCheckbutton'.freeze

  def self.style(*args)
    [self::WidgetClassName, *(args.map!{|a| _get_eval_string(a)})].join('.')
  end

  def deselect
    tk_send('deselect')
    self
  end

  def select
    tk_send('select')
    self
  end

  def toggle
    tk_send('toggle')
    self
  end

  def invoke
    tk_send('invoke')
  end
end

module Tk
  module Tile
    TCheckbutton = TCheckButton
    CheckButton  = TCheckButton
    Checkbutton  = TCheckButton
  end
end

#Tk.__set_toplevel_aliases__(:Ttk, Tk::Tile::Checkbutton,
#                            :TkCheckbutton, :TkCheckButton)
Tk.__set_loaded_toplevel_aliases__('tkextlib/tile/tcheckbutton.rb',
                                   :Ttk, Tk::Tile::Checkbutton,
                                   :TkCheckbutton, :TkCheckButton)
