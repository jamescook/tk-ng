# frozen_string_literal: false
#
#  tframe widget
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
# See: https://www.tcl-lang.org/man/tcl/TkCmd/ttk_frame.html
#
require 'tk'
require 'tk/option_dsl'
require 'tkextlib/tile.rb'
require_relative '../../tk/core/callable'
require_relative '../../tk/core/configurable'
require_relative '../../tk/core/widget'
require_relative '../../tk/callback'

module Tk
  module Tile
    class TFrame
    end
    Frame = TFrame
  end
end

class Tk::Tile::TFrame
  include TkUtil
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include Tk::Tile::TileWidget
  include Tk::Generated::TtkFrame

  if Tk::Tile::USE_TTK_NAMESPACE
    TkCommandNames = ['::ttk::frame'.freeze].freeze
  else
    TkCommandNames = ['::tframe'.freeze].freeze
  end
  WidgetClassName = 'TFrame'.freeze
  Tk::Core::Widget.registry[WidgetClassName] ||= self

  def self.style(*args)
    [self::WidgetClassName, *(args.map!(&:to_s))].join('.')
  end
end

#Tk.__set_toplevel_aliases__(:Ttk, Tk::Tile::Frame, :TkFrame)
Tk.__set_loaded_toplevel_aliases__('tkextlib/tile/tframe.rb',
                                   :Ttk, Tk::Tile::Frame, :TkFrame)
