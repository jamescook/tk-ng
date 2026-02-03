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
    if id.respond_to?(:path)
      id.path
    elsif id.respond_to?(:to_eval)
      id.to_eval
    else
      id.to_s
    end
  end

  # -- Methods from TkTextWin (shared with Text) --

  def bbox(index)
    result = tk_send('bbox', index)
    return [] if result.empty?
    result.split.map(&:to_i)
  end

  def delete(first, last=NONE)
    tk_send('delete', first, last)
    self
  end

  def insert(index, *args)
    tk_send('insert', index, *args)
    self
  end

  def scan_mark(x, y)
    tk_send('scan', 'mark', x, y)
    self
  end

  def scan_dragto(x, y)
    tk_send('scan', 'dragto', x, y)
    self
  end

  def see(index)
    tk_send('see', index)
    self
  end

  # -- Listbox-specific methods --

  def activate(y)
    tk_send('activate', y)
    self
  end

  def curselection
    result = tk_send('curselection')
    return [] if result.empty?
    result.split.map(&:to_i)
  end

  def get(first, last=nil)
    if last
      TclTkLib._split_tklist(tk_send('get', first, last))
    else
      tk_send('get', first)
    end
  end

  def nearest(y)
    tk_send('nearest', y).to_i
  end

  def size
    tk_send('size').to_i
  end

  def selection_anchor(index)
    tk_send('selection', 'anchor', index)
    self
  end

  def selection_clear(first, last=NONE)
    tk_send('selection', 'clear', first, last)
    self
  end

  def selection_includes(index)
    tk_send('selection', 'includes', index) == '1'
  end

  def selection_set(first, last=NONE)
    tk_send('selection', 'set', first, last)
    self
  end

  def index(idx)
    tk_send('index', idx).to_i
  end

  def value
    get('0', 'end')
  end

  def value=(vals)
    unless vals.kind_of?(Array)
      fail ArgumentError, 'an Array is expected'
    end
    tk_send('delete', '0', 'end')
    tk_send('insert', '0', *vals.map { |v| value_to_tcl(v) })
    vals
  end

  def clear
    tk_send('delete', '0', 'end')
    self
  end
  alias erase clear
end

#TkListbox = Tk::Listbox unless Object.const_defined? :TkListbox
#Tk.__set_toplevel_aliases__(:Tk, Tk::Listbox, :TkListbox)
Tk.__set_loaded_toplevel_aliases__('tk/listbox.rb', :Tk, Tk::Listbox,
                                   :TkListbox)
