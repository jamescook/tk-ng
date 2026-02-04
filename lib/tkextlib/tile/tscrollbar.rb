# frozen_string_literal: false
#
#  tscrollbar widget
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
# See: https://www.tcl-lang.org/man/tcl/TkCmd/ttk_scrollbar.html
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
    class TScrollbar
    end
    Scrollbar = TScrollbar
  end
end

class Tk::Tile::TScrollbar
  include TkUtil
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
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

  def initialize(parent = nil, keys = {}, &block)
    @assigned = []
    @scroll_proc = proc { |*args|
      if orient == 'horizontal'
        @assigned.each { |w| w.xview(*args) }
      else
        @assigned.each { |w| w.yview(*args) }
      end
    }
    super
  end

  def propagate_set(src_win, first, last)
    set(first, last)
    if orient == 'horizontal'
      @assigned.each { |w| w.xview('moveto', first) if w != src_win }
    else
      @assigned.each { |w| w.yview('moveto', first) if w != src_win }
    end
  end

  def assign(*wins)
    begin
      self.command(@scroll_proc) if cget('command').cmd != @scroll_proc
    rescue StandardError
      self.command(@scroll_proc)
    end
    o = orient
    wins.each do |w|
      @assigned << w unless @assigned.index(w)
      if o == 'horizontal'
        w.xscrollcommand proc { |first, last| propagate_set(w, first, last) }
      else
        w.yscrollcommand proc { |first, last| propagate_set(w, first, last) }
      end
    end
    Tk.update
    self
  end

  def assigned_list
    begin
      return @assigned.dup if cget('command').cmd == @scroll_proc
    rescue StandardError
    end
    fail RuntimeError, "not depend on the assigned_list"
  end

  def delta(deltax, deltay)
    tk_send('delta', deltax, deltay).to_f
  end

  def fraction(x, y)
    tk_send('fraction', x, y).to_f
  end

  def get
    TclTkLib._split_tklist(tk_send('get')).map(&:to_f)
  end

  def set(first, last)
    tk_send('set', first, last)
    self
  end

  def activate(element = nil)
    if element
      tk_send('activate', element)
    else
      tk_send('activate')
    end
  end

  def moveto(fraction)
    tk_send('moveto', fraction)
    self
  end

  def scroll(*args)
    tk_send('scroll', *args)
    self
  end

  def scroll_units(num)
    scroll(num, 'units')
  end

  def scroll_pages(num)
    scroll(num, 'pages')
  end
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
