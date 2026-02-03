# frozen_string_literal: false
#
#  tcombobox widget
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
# See: https://www.tcl-lang.org/man/tcl/TkCmd/ttk_combobox.html
#
require 'tk'
require 'tkextlib/tile.rb'
require_relative '../../tk/core/callable'
require_relative '../../tk/core/configurable'
require_relative '../../tk/core/widget'
require_relative '../../tk/callback'
require 'tk/scrollable'
require 'tk/validation'

class Tk::Tile::TCombobox
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include TkUtil
  include Tk::XScrollable
  include TkValidation
  include Tk::Tile::TileWidget
  include Tk::Generated::TtkCombobox

  if Tk::Tile::USE_TTK_NAMESPACE
    TkCommandNames = ['::ttk::combobox'.freeze].freeze
  else
    TkCommandNames = ['::tcombobox'.freeze].freeze
  end
  WidgetClassName = 'TCombobox'.freeze

  def self.style(*args)
    [self::WidgetClassName, *(args.map!(&:to_s))].join('.')
  end

  # TODO: Entry-like methods below are duplicated from Tk::Entry.
  # Extract into Tk::Core::EntryMethods module to share.
  def bbox(index)
    list(tk_send_without_enc('bbox', index))
  end
  def cursor
    number(tk_send_without_enc('index', 'insert'))
  end
  alias icursor cursor
  def cursor=(index)
    tk_send_without_enc('icursor', index)
    index
  end
  alias icursor= cursor=
  def index(idx)
    number(tk_send_without_enc('index', idx))
  end
  def insert(pos, text)
    tk_send_without_enc('insert', pos, _get_eval_enc_str(text))
    self
  end
  def delete(first, last=None)
    tk_send_without_enc('delete', first, last)
    self
  end
  def mark(pos)
    tk_send_without_enc('scan', 'mark', pos)
    self
  end
  def dragto(pos)
    tk_send_without_enc('scan', 'dragto', pos)
    self
  end
  def selection_adjust(index)
    tk_send_without_enc('selection', 'adjust', index)
    self
  end
  def selection_clear
    tk_send_without_enc('selection', 'clear')
    self
  end
  def selection_from(index)
    tk_send_without_enc('selection', 'from', index)
    self
  end
  def selection_present()
    bool(tk_send_without_enc('selection', 'present'))
  end
  def selection_range(s, e)
    tk_send_without_enc('selection', 'range', s, e)
    self
  end
  def selection_to(index)
    tk_send_without_enc('selection', 'to', index)
    self
  end

  def invoke_validate
    bool(tk_send_without_enc('validate'))
  end
  def validate(mode = nil)
    if mode
      configure 'validate', mode
    else
      invoke_validate
    end
  end

  def value
    tk_send_without_enc('get')
  end
  def value=(val)
    tk_send_without_enc('delete', 0, 'end')
    tk_send_without_enc('insert', 0, _get_eval_enc_str(val))
    val
  end
  alias get value

  # Combobox-specific methods
  def current
    number(tk_send_without_enc('current'))
  end
  def current=(idx)
    tk_send_without_enc('current', idx)
  end

  def set(val)
    tk_send('set', val)
  end
end

module Tk
  module Tile
    Combobox = TCombobox
  end
end

#Tk.__set_toplevel_aliases__(:Ttk, Tk::Tile::Combobox, :TkCombobox)
Tk.__set_loaded_toplevel_aliases__('tkextlib/tile/tcombobox.rb',
                                   :Ttk, Tk::Tile::Combobox, :TkCombobox)
