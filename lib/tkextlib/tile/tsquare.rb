# frozen_string_literal: false
#
#  tsquare widget
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'
require 'tkextlib/tile.rb'
require_relative '../../tk/core/callable'
require_relative '../../tk/core/configurable'
require_relative '../../tk/core/widget'
require_relative '../../tk/callback'

class Tk::Tile::TSquare
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include Tk::Tile::TileWidget

  if Tk::Tile::USE_TTK_NAMESPACE
    TkCommandNames = ['::ttk::square'.freeze].freeze
  else
    TkCommandNames = ['::tsquare'.freeze].freeze
  end
  WidgetClassName = 'TSquare'.freeze

  def self.style(*args)
    [self::WidgetClassName, *(args.map!(&:to_s))].join('.')
  end
end

module Tk
  module Tile
    Square = TSquare
  end
end
