# frozen_string_literal: false
require 'tk/entry'

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
class Tk::Spinbox<Tk::Entry
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
  WidgetClassNames[WidgetClassName] ||= self

  class SpinCommand < TkValidateCommand
    class ValidateArgs < TkUtil::CallbackSubst
      KEY_TBL = [
        [ ?d, ?s, :direction ],
        [ ?s, ?e, :current ],
        [ ?W, ?w, :widget ],
        nil
      ]

      PROC_TBL = [
        [ ?s, TkComm.method(:string) ],
        [ ?w, TkComm.method(:window) ],

        [ ?e, proc{|val| TkComm::string(val) } ],

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

  #def create_self(keys)
  #  tk_call_without_enc('spinbox', @path)
  #  if keys and keys != None
  #    configure(keys)
  #  end
  #end
  #private :create_self

  # NOTE: __boolval_optkeys override for 'wrap' removed - now declared via OptionDSL
  # NOTE: __strval_optkeys override for 'buttonbackground', 'format' removed - now declared via OptionDSL
  # NOTE: __listval_optkeys override for 'values' removed - now declared via OptionDSL

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
end

#TkSpinbox = Tk::Spinbox unless Object.const_defined? :TkSpinbox
#Tk.__set_toplevel_aliases__(:Tk, Tk::Spinbox, :TkSpinbox)
Tk.__set_loaded_toplevel_aliases__('tk/spinbox.rb', :Tk, Tk::Spinbox,
                                   :TkSpinbox)
