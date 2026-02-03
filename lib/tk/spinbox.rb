# frozen_string_literal: false
require_relative 'core/callable'
require_relative 'core/configurable'
require_relative 'core/widget'
require_relative 'callback'
require 'tk/scrollable'
require 'tk/validation'

# An entry widget with increment/decrement spin buttons.
#
# Spinboxes allow both direct text entry and cycling through values
# using up/down buttons. Values can be a numeric range or a list.
#
# @example Numeric range
#   Tk::Spinbox.new(
#     from: 1,
#     to: 100,
#     increment: 5
#   ).pack
#
# @example Fixed list of values
#   Tk::Spinbox.new(
#     values: %w[Small Medium Large X-Large]
#   ).pack
#
# @example With variable binding
#   quantity = TkVariable.new(1)
#   Tk::Spinbox.new(
#     from: 1,
#     to: 99,
#     textvariable: quantity
#   ).pack
#
# @note If both `:values` and `:from/:to` are specified, `:values` takes precedence.
#
# @note Same validation quirk as Entry: mixing textvariable with
#   validatecommand can silently disable validation.
#
# @see Tk::Entry for the base text entry functionality
# @see https://www.tcl-lang.org/man/tcl/TkCmd/spinbox.html Tcl/Tk spinbox manual
#
class Tk::Spinbox
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include TkUtil
  include Tk::XScrollable
  include TkValidation
  include Tk::Generated::Spinbox
  # @generated:options:start
  # Available options (auto-generated from Tk introspection):
  #
  #   :activebackground
  #   :background
  #   :borderwidth
  #   :buttonbackground
  #   :buttoncursor
  #   :buttondownrelief
  #   :buttonuprelief
  #   :command (callback)
  #   :cursor
  #   :disabledbackground
  #   :disabledforeground
  #   :exportselection
  #   :font
  #   :foreground
  #   :format
  #   :from
  #   :highlightbackground
  #   :highlightcolor
  #   :highlightthickness
  #   :increment
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
  #   :repeatdelay
  #   :repeatinterval
  #   :selectbackground
  #   :selectborderwidth
  #   :selectforeground
  #   :state
  #   :takefocus
  #   :textvariable (tkvariable)
  #   :to
  #   :validate
  #   :validatecommand
  #   :values
  #   :width
  #   :wrap
  #   :xscrollcommand
  # @generated:options:end


  TkCommandNames = ['spinbox'.freeze].freeze
  WidgetClassName = 'Spinbox'.freeze

  class SpinCommand < TkValidateCommand
    class ValidateArgs < TkUtil::CallbackSubst
      KEY_TBL = [
        [ ?d, ?s, :direction ],
        [ ?s, ?e, :current ],
        [ ?W, ?w, :widget ],
        nil
      ]

      PROC_TBL = [
        [ ?s, TkUtil.method(:string) ],
        [ ?w, proc{|val| val =~ /^\./ ? (TkCore::INTERP.tk_windows[val] || val) : nil } ],

        [ ?e, proc{|val| TkUtil.string(val) } ],

        nil
      ]

=begin
      # for Ruby m17n :: ?x --> String --> char-code ( getbyte(0) )
      KEY_TBL.map!{|inf|
        if inf.kind_of?(Array)
          inf[0] = inf[0].getbyte(0) if inf[0].kind_of?(String)
          inf[1] = inf[1].getbyte(0) if inf[1].kind_of?(String)
        end
        inf
      }

      PROC_TBL.map!{|inf|
        if inf.kind_of?(Array)
          inf[0] = inf[0].getbyte(0) if inf[0].kind_of?(String)
        end
        inf
      }
=end

      _setup_subst_table(KEY_TBL, PROC_TBL);

      def self.ret_val(val)
        (val)? '1': '0'
      end
    end

    def self._config_keys
      ['command']
    end
  end

  def __validation_class_list
    super() << SpinCommand
  end

  Tk::ValidateConfigure.__def_validcmd(binding, SpinCommand)

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

  def identify(x, y)
    tk_send_without_enc('identify', x, y)
  end

  def invoke(elem)
    tk_send_without_enc('invoke', elem)
    self
  end

  def spinup
    begin
      tk_send_without_enc('invoke', 'buttonup')
    rescue RuntimeError => e
      # old version of element?
      begin
        tk_send_without_enc('invoke', 'spinup')
      rescue
        fail e
      end
    end
    self
  end

  def spindown
    begin
      tk_send_without_enc('invoke', 'buttondown')
    rescue RuntimeError => e
      # old version of element?
      begin
        tk_send_without_enc('invoke', 'spinup')
      rescue
        fail e
      end
    end
    self
  end

  def set(str)
    tk_send_without_enc('set', _get_eval_enc_str(str))
  end

  # Kernel#format (sprintf) shadows the Tk -format option.
  # Use set_format/get_format/format= for the Tk option.
  def format(*args)
    Tk::Warnings.warn_once(:spinbox_format,
      "Spinbox#format calls Kernel#format (sprintf), not the Tk -format option. " \
      "Use get_format/set_format/format= for the Tk option.")
    super
  end

  def get_format
    cget(:format)
  end

  def set_format(val)
    configure(:format, val)
  end

  def format=(val)
    configure(:format, val)
    val
  end
end

#TkSpinbox = Tk::Spinbox unless Object.const_defined? :TkSpinbox
#Tk.__set_toplevel_aliases__(:Tk, Tk::Spinbox, :TkSpinbox)
Tk.__set_loaded_toplevel_aliases__('tk/spinbox.rb', :Tk, Tk::Spinbox,
                                   :TkSpinbox)
