# frozen_string_literal: false
require 'tk/scrollable'
require 'tk/option_dsl'
require 'tk/item_option_dsl'
require_relative 'core/callable'
require_relative 'core/configurable'
require_relative 'core/widget'
require_relative 'callback'

# A scrollable list of selectable text items.
#
# == Selection Modes
# - `:single` / `:browse` - one item at a time (browse allows drag)
# - `:multiple` - toggle individual items
# - `:extended` - multiple with shift/ctrl and drag support
#
# @example Basic listbox
#   listbox = Tk::Listbox.new(height: 10, selectmode: :browse)
#   listbox.insert('end', 'Apple', 'Banana', 'Cherry')
#   listbox.pack
#
# @example Get selection
#   listbox.bind('<<ListboxSelect>>') do
#     indices = listbox.curselection  # array of selected indices
#     values = indices.map { |i| listbox.get(i) }
#     puts "Selected: #{values}"
#   end
#
# @example With scrollbar
#   frame = Tk::Frame.new.pack(fill: :both, expand: true)
#   listbox = Tk::Listbox.new(frame).pack(side: :left, fill: :both, expand: true)
#   scrollbar = Tk::Scrollbar.new(frame).pack(side: :right, fill: :y)
#   listbox.yscrollbar(scrollbar)
#
# @note `<<ListboxSelect>>` fires only for mouse/keyboard selection,
#   not programmatic `selection set` calls.
#
# @see https://www.tcl-lang.org/man/tcl/TkCmd/listbox.html Tcl/Tk listbox manual
#
class Tk::Listbox
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  extend Tk::ItemOptionDSL
  include Tk::Scrollable
  include Tk::Generated::Listbox
  # @generated:options:start
  # Available options (auto-generated from Tk introspection):
  #
  #   :activestyle
  #   :background
  #   :borderwidth
  #   :cursor
  #   :disabledforeground
  #   :exportselection
  #   :font
  #   :foreground
  #   :height
  #   :highlightbackground
  #   :highlightcolor
  #   :highlightthickness
  #   :justify
  #   :listvariable (tkvariable)
  #   :relief
  #   :selectbackground
  #   :selectborderwidth
  #   :selectforeground
  #   :selectmode
  #   :setgrid
  #   :state
  #   :takefocus
  #   :width
  #   :xscrollcommand
  #   :yscrollcommand
  # @generated:options:end



  TkCommandNames = ['listbox'.freeze].freeze
  WidgetClassName = 'Listbox'.freeze

  # Item options (for listbox items)
  item_option :background,        type: :string
  item_option :foreground,        type: :string
  item_option :selectbackground,  type: :string
  item_option :selectforeground,  type: :string

  def tagid(id)
    #id.to_s
    _get_eval_string(id)
  end

  # -- Methods from TkTextWin (shared with Text) --

  def bbox(index)
    list(tk_send_without_enc('bbox', index))
  end

  def delete(first, last=None)
    tk_send_without_enc('delete', first, last)
    self
  end

  def insert(index, *args)
    tk_send('insert', index, *args)
    self
  end

  def scan_mark(x, y)
    tk_send_without_enc('scan', 'mark', x, y)
    self
  end

  def scan_dragto(x, y)
    tk_send_without_enc('scan', 'dragto', x, y)
    self
  end

  def see(index)
    tk_send_without_enc('see', index)
    self
  end

  # -- Listbox-specific methods --

  def activate(y)
    tk_send_without_enc('activate', y)
    self
  end
  def curselection
    list(tk_send_without_enc('curselection'))
  end
  def get(first, last=nil)
    if last
      tk_split_simplelist(tk_send_without_enc('get', first, last), false, true)
    else
      tk_send_without_enc('get', first)
    end
  end
  def nearest(y)
    tk_send_without_enc('nearest', y).to_i
  end
  def size
    tk_send_without_enc('size').to_i
  end
  def selection_anchor(index)
    tk_send_without_enc('selection', 'anchor', index)
    self
  end
  def selection_clear(first, last=None)
    tk_send_without_enc('selection', 'clear', first, last)
    self
  end
  def selection_includes(index)
    bool(tk_send_without_enc('selection', 'includes', index))
  end
  def selection_set(first, last=None)
    tk_send_without_enc('selection', 'set', first, last)
    self
  end

  def index(idx)
    tk_send_without_enc('index', idx).to_i
  end

  def value
    get('0', 'end')
  end

  def value=(vals)
    unless vals.kind_of?(Array)
      fail ArgumentError, 'an Array is expected'
    end
    tk_send_without_enc('delete', '0', 'end')
    tk_send_without_enc('insert', '0',
                        *(vals.collect{|v| _get_eval_enc_str(v)}))
    vals
  end

  def clear
    tk_send_without_enc('delete', '0', 'end')
    self
  end
  alias erase clear
end

#TkListbox = Tk::Listbox unless Object.const_defined? :TkListbox
#Tk.__set_toplevel_aliases__(:Tk, Tk::Listbox, :TkListbox)
Tk.__set_loaded_toplevel_aliases__('tk/listbox.rb', :Tk, Tk::Listbox,
                                   :TkListbox)
