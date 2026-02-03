# frozen_string_literal: false
#
#  ttk::sizegrip widget
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
# See: https://www.tcl-lang.org/man/tcl/TkCmd/ttk_sizegrip.html
#
require 'tk'
require 'tkextlib/tile.rb'
require_relative '../../tk/core/callable'
require_relative '../../tk/core/configurable'
require_relative '../../tk/core/widget'
require_relative '../../tk/callback'

class Tk::Tile::SizeGrip
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include Tk::Tile::TileWidget
  include Tk::Generated::TtkSizegrip

  TkCommandNames = ['::ttk::sizegrip'.freeze].freeze
  WidgetClassName = 'TSizegrip'.freeze

  def self.style(*args)
    [self::WidgetClassName, *(args.map!(&:to_s))].join('.')
  end
end

module Tk
  module Tile
    Sizegrip = SizeGrip
  end
end

#Tk.__set_toplevel_aliases__(:Ttk, Tk::Tile::Sizegrip,
#                            :TkSizegrip, :TkSizeGrip)
Tk.__set_loaded_toplevel_aliases__('tkextlib/tile/sizegrip.rb',
                                   :Ttk, Tk::Tile::Sizegrip,
                                   :TkSizegrip, :TkSizeGrip)
