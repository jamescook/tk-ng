# frozen_string_literal: false
require_relative 'core/callable'
require_relative 'core/configurable'
require_relative 'core/widget'
require_relative 'callback'
require 'tk/scrollable'
require 'tk/validation'
require 'tk/option_dsl'

# A single-line text input field.
#
# Entry widgets allow users to type text. Use {Tk::Text} for multi-line input.
#
# @example Basic entry with variable binding
#   name = TkVariable.new
#   entry = Tk::Entry.new(textvariable: name, width: 30)
#   entry.pack
#   # Later: name.value contains what user typed
#
# @example Password entry (masked input)
#   password = TkVariable.new
#   Tk::Entry.new(textvariable: password, show: "*").pack
#
# @example Entry with validation
#   entry = Tk::Entry.new(
#     validate: :key,
#     validatecommand: [->(new_val) { new_val.match?(/^\d*$/) }, '%P']
#   )  # Only allows digits
#
# @example Get/set text directly
#   entry.insert('end', "default text")
#   text = entry.get
#   entry.delete(0, 'end')  # clear
#
# @note **Validation + textvariable warning**: Mixing textvariable with
#   validatecommand is risky. Setting the variable to an invalid value
#   silently disables validation. Use one or the other, not both.
#
# @note **Valid indices**: `0` (first char), `end`, `insert` (cursor),
#   `anchor`, `sel.first`, `sel.last`, or `@x` (x-coordinate).
#
# @see Tk::Text for multi-line text editing
# @see https://www.tcl-lang.org/man/tcl/TkCmd/entry.html Tcl/Tk entry manual
#
class Tk::Entry
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include TkUtil  # for bool, number, _get_eval_enc_str
  include Tk::XScrollable
  include TkValidation
  include Tk::Generated::Entry
  # @generated:options:start
  # Available options (auto-generated from Tk introspection):
  #
  #   :background
  #   :borderwidth
  #   :cursor
  #   :disabledbackground
  #   :disabledforeground
  #   :exportselection
  #   :font
  #   :foreground
  #   :highlightbackground
  #   :highlightcolor
  #   :highlightthickness
  #   :insertbackground
  #   :insertborderwidth
  #   :insertofftime
  #   :insertontime
  #   :insertwidth
  #   :invalidcommand
  #   :justify
  #   :placeholder
  #   :placeholderforeground
  #   :readonlybackground
  #   :relief
  #   :selectbackground
  #   :selectborderwidth
  #   :selectforeground
  #   :show
  #   :state
  #   :takefocus
  #   :textvariable (tkvariable)
  #   :validate
  #   :validatecommand
  #   :width
  #   :xscrollcommand
  # @generated:options:end



  TkCommandNames = ['entry'.freeze].freeze
  WidgetClassName = 'Entry'.freeze

  def bbox(index)
    list(tk_send_without_enc('bbox', index))
  end
  def cursor
    number(tk_send_without_enc('index', 'insert'))
  end
  alias icursor cursor
  def cursor=(index)
    tk_send_without_enc('icursor', index)
    #self
    index
  end
  alias icursor= cursor=
  def index(idx)
    number(tk_send_without_enc('index', idx))
  end
  def insert(pos,text)
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
  alias set value=

  def [](*args)
    self.value[*args]
  end
  def []=(*args)
    val = args.pop
    str = self.value
    str[*args] = val
    self.value = str
    val
  end
end

#TkEntry = Tk::Entry unless Object.const_defined? :TkEntry
#Tk.__set_toplevel_aliases__(:Tk, Tk::Entry, :TkEntry)
Tk.__set_loaded_toplevel_aliases__('tk/entry.rb', :Tk, Tk::Entry, :TkEntry)
