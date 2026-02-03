# frozen_string_literal: false
#
#  tseparator widget
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
# See: https://www.tcl-lang.org/man/tcl/TkCmd/ttk_separator.html
#
require 'tk'
require 'tkextlib/tile.rb'
require_relative '../../tk/core/callable'
require_relative '../../tk/core/configurable'
require_relative '../../tk/core/widget'
require_relative '../../tk/callback'

class Tk::Tile::TSeparator
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include Tk::Tile::TileWidget
  include Tk::Generated::TtkSeparator

  if Tk::Tile::USE_TTK_NAMESPACE
    TkCommandNames = ['::ttk::separator'.freeze].freeze
  else
    TkCommandNames = ['::tseparator'.freeze].freeze
  end
  WidgetClassName = 'TSeparator'.freeze

  def self.style(*args)
    [self::WidgetClassName, *(args.map!(&:to_s))].join('.')
  end
end

module Tk
  module Tile
    Separator = TSeparator
  end
end

#Tk.__set_toplevel_aliases__(:Ttk, Tk::Tile::Separator, :TkSeparator)
Tk.__set_loaded_toplevel_aliases__('tkextlib/tile/tseparator.rb',
                                   :Ttk, Tk::Tile::Separator, :TkSeparator)
