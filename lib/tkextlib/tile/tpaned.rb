# frozen_string_literal: false
#
#  tpaned widget
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
# See: https://www.tcl-lang.org/man/tcl/TkCmd/ttk_panedwindow.html
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
    class TPaned
    end
    PanedWindow = Panedwindow = Paned = TPaned
  end
end

class Tk::Tile::TPaned
  include TkUtil
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include Tk::Tile::TileWidget
  include Tk::Generated::TtkPanedwindow

  if Tk::Tile::USE_TTK_NAMESPACE
    if Tk::Tile::TILE_SPEC_VERSION_ID < 8
      TkCommandNames = ['::ttk::paned'.freeze].freeze
    else
      TkCommandNames = ['::ttk::panedwindow'.freeze].freeze
    end
  else
    TkCommandNames = ['::tpaned'.freeze].freeze
  end
  WidgetClassName = 'TPaned'.freeze
  Tk::Core::Widget.registry[WidgetClassName] ||= self

  def self.style(*args)
    [self::WidgetClassName, *(args.map!(&:to_s))].join('.')
  end

  private

  def _epath(win)
    if win.respond_to?(:epath)
      win.epath
    elsif win.respond_to?(:path)
      win.path
    else
      win
    end
  end

  public

  def add(*args)
    keys = args.pop
    fail ArgumentError, "no window in arguments" unless keys

    if keys && keys.kind_of?(Hash)
      fail ArgumentError, "no window in arguments" if args == []
      opts = hash_kv(keys)
    else
      args.push(keys) if keys
      opts = []
    end

    args.each{|win|
      tk_send('add', _epath(win), *opts)
    }
    self
  end

  def forget(pane)
    pane = _epath(pane)
    tk_send('forget', pane)
    self
  end

  def insert(pos, win, keys)
    win = _epath(win)
    tk_send('insert', pos, win, *hash_kv(keys))
    self
  end

  def panecget_tkstring(pane, slot)
    pane = _epath(pane)
    tk_send('pane', pane, "-#{slot}")
  end
  alias pane_cget_tkstring panecget_tkstring

  def panecget_strict(pane, slot)
    pane = _epath(pane)
    value_from_tcl(tk_send('pane', pane, "-#{slot}"))
  end
  alias pane_cget_strict panecget_strict

  def panecget(pane, slot)
    panecget_strict(pane, slot)
  end
  alias pane_cget panecget

  def paneconfigure(pane, key, value=nil)
    pane = _epath(pane)
    if key.kind_of? Hash
      params = []
      key.each{|k, v|
        params.push("-#{k}")
        params.push(_epath(v))
      }
      tk_send('pane', pane, *params)
    else
      value = _epath(value)
      tk_send('pane', pane, "-#{key}", value)
    end
    self
  end
  alias pane_config paneconfigure
  alias pane_configure paneconfigure

  def paneconfiginfo(win, key=nil)
    win = _epath(win)
    if key
      conf = TclTkLib._split_tklist(tk_send('pane', win, "-#{key}"))
      conf[0] = conf[0][1..-1]
      if conf[0] == 'hide'
        conf[3] = bool(conf[3]) unless conf[3].empty?
        conf[4] = bool(conf[4]) unless conf[4].empty?
      end
      conf
    else
      TclTkLib._split_tklist(tk_send('pane', win)).collect{|conflist|
        conf = TclTkLib._split_tklist(conflist)
        conf[0] = conf[0][1..-1]
        if conf[3]
          if conf[0] == 'hide'
            conf[3] = bool(conf[3]) unless conf[3].empty?
          else
            conf[3] = value_from_tcl(conf[3])
          end
        end
        if conf[4]
          if conf[0] == 'hide'
            conf[4] = bool(conf[4]) unless conf[4].empty?
          else
            conf[4] = value_from_tcl(conf[4])
          end
        end
        conf[1] = conf[1][1..-1] if conf.size == 2 # alias info
        conf
      }
    end
  end
  alias pane_configinfo paneconfiginfo

  def current_paneconfiginfo(win, key=nil)
    if key
      conf = paneconfiginfo(win, key)
      {conf[0] => conf[4]}
    else
      ret = {}
      paneconfiginfo(win).each{|conf|
        ret[conf[0]] = conf[4] if conf.size > 2
      }
      ret
    end
  end
  alias current_pane_configinfo current_paneconfiginfo

  def panes
    TclTkLib._split_tklist(tk_send('panes')).map{|w|
      TkCore::INTERP.tk_windows[w] || w
    }
  end

  def identify(x, y)
    num_or_nil(tk_send('identify', x, y))
  end

  def sashpos(idx, newpos=NONE)
    num_or_str(tk_send('sashpos', idx, newpos))
  end
end

#Tk.__set_toplevel_aliases__(:Ttk, Tk::Tile::Panedwindow,
#                            :TkPanedwindow, :TkPanedWindow)
Tk.__set_loaded_toplevel_aliases__('tkextlib/tile/tpaned.rb',
                                   :Ttk, Tk::Tile::Panedwindow,
                                   :TkPanedwindow, :TkPanedWindow)
