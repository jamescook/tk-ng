# frozen_string_literal: false
require 'tk/button'

# A radio button for one-of-many selection.
#
# Multiple radiobuttons sharing the same variable form a group.
# Selecting one deselects the others automatically.
#
# @example Radio button group
#   choice = TkVariable.new("medium")
#
#   Tk::RadioButton.new(text: "Small",  variable: choice, value: "small").pack
#   Tk::RadioButton.new(text: "Medium", variable: choice, value: "medium").pack
#   Tk::RadioButton.new(text: "Large",  variable: choice, value: "large").pack
#
#   # choice.value returns whichever is selected ("small", "medium", or "large")
#
# @example With command callback
#   Tk::RadioButton.new(
#     text: "Option A",
#     variable: selection,
#     value: "a",
#     command: -> { puts "Selected: #{selection.value}" }
#   ).pack
#
# @note All radiobuttons in a group must share the same TkVariable.
#   Each button needs a unique `:value` to distinguish it.
#
# @see Tk::CheckButton for independent on/off toggles
# @see https://www.tcl-lang.org/man/tcl/TkCmd/radiobutton.html Tcl/Tk radiobutton manual
#
class Tk::RadioButton<Tk::Button
  include Tk::Generated::Radiobutton
  # @generated:options:start
  # Available options (auto-generated from Tk introspection):
  #
  #   :activebackground
  #   :activeforeground
  #   :anchor
  #   :background
  #   :bitmap
  #   :borderwidth
  #   :command (callback)
  #   :compound
  #   :cursor
  #   :disabledforeground
  #   :font
  #   :foreground
  #   :height
  #   :highlightbackground
  #   :highlightcolor
  #   :highlightthickness
  #   :image
  #   :indicatoron
  #   :justify
  #   :offrelief
  #   :overrelief
  #   :padx
  #   :pady
  #   :relief
  #   :selectcolor
  #   :selectimage
  #   :state
  #   :takefocus
  #   :text
  #   :textvariable (tkvariable)
  #   :tristateimage
  #   :tristatevalue
  #   :underline
  #   :value
  #   :variable (tkvariable)
  #   :width
  #   :wraplength
  # @generated:options:end

  TkCommandNames = ['radiobutton'.freeze].freeze
  WidgetClassName = 'Radiobutton'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  def deselect
    tk_send_without_enc('deselect')
    self
  end
  def select
    tk_send_without_enc('select')
    self
  end

  def get_value
    var = tk_send_without_enc('cget', '-variable')
    if TkVariable::USE_TCLs_SET_VARIABLE_FUNCTIONS
      INTERP._get_global_var(var)
    else
      INTERP._eval(Kernel.format('global %s; set %s', var, var))
    end
  end

  def set_value(val)
    var = tk_send_without_enc('cget', '-variable')
    if TkVariable::USE_TCLs_SET_VARIABLE_FUNCTIONS
      INTERP._set_global_var(var, _get_eval_string(val, true))
    else
      s = '"' + _get_eval_string(val).gsub(/[\[\]$"\\]/, '\\\\\&') + '"'
      INTERP._eval(Kernel.format('global %s; set %s %s', var, var, s))
    end
  end
end

Tk::Radiobutton = Tk::RadioButton
#TkRadioButton = Tk::RadioButton unless Object.const_defined? :TkRadioButton
#TkRadiobutton = Tk::Radiobutton unless Object.const_defined? :TkRadiobutton
#Tk.__set_toplevel_aliases__(:Tk, Tk::RadioButton,
#                            :TkRadioButton, :TkRadiobutton)
Tk.__set_loaded_toplevel_aliases__('tk/radiobutton.rb', :Tk, Tk::RadioButton,
                                   :TkRadioButton, :TkRadiobutton)
