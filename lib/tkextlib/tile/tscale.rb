# frozen_string_literal: false
#
#  tscale & tprogress widget
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
# See: https://www.tcl-lang.org/man/tcl/TkCmd/ttk_scale.html
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
    class TScale
    end
    Scale = TScale

    class TProgress < TScale
    end
    Progress = TProgress
  end
end

class Tk::Tile::TScale
  include TkUtil
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include Tk::Tile::TileWidget
  include Tk::Generated::TtkScale

  if Tk::Tile::USE_TTK_NAMESPACE
    TkCommandNames = ['::ttk::scale'.freeze].freeze
  else
    TkCommandNames = ['::tscale'.freeze].freeze
  end
  WidgetClassName = 'TScale'.freeze
  Tk::Core::Widget.registry[WidgetClassName] ||= self

  def self.style(*args)
    [self::WidgetClassName, *(args.map!(&:to_s))].join('.')
  end

  alias identify ttk_identify

  def get(x = nil, y = nil)
    if x && y
      tk_send('get', x, y).to_f
    else
      tk_send('get').to_f
    end
  end

  def set(val)
    tk_send('set', val)
  end

  def coords(val = nil)
    if val
      TclTkLib._split_tklist(tk_send('coords', val))
    else
      TclTkLib._split_tklist(tk_send('coords'))
    end
  end

  def value
    get
  end

  def value=(val)
    set(val)
    val
  end
end

class Tk::Tile::TProgress

  if Tk::Tile::USE_TTK_NAMESPACE
    TkCommandNames = ['::ttk::progress'.freeze].freeze
  else
    TkCommandNames = ['::tprogress'.freeze].freeze
  end
  WidgetClassName = 'TProgress'.freeze
  Tk::Core::Widget.registry[WidgetClassName] ||= self

  def self.style(*args)
    [self::WidgetClassName, *(args.map!(&:to_s))].join('.')
  end
end

#Tk.__set_toplevel_aliases__(:Ttk, Tk::Tile::Scale, :TkScale)
Tk.__set_loaded_toplevel_aliases__('tkextlib/tile/tscale.rb',
                                   :Ttk, Tk::Tile::Scale, :TkScale)
