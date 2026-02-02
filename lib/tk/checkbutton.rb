# frozen_string_literal: false
require 'tk/radiobutton'

# A checkbox widget that toggles between on/off states.
#
# The state is stored in a TkVariable. Use `:onvalue` and `:offvalue`
# to customize what values represent checked/unchecked (default "1"/"0").
#
# @example Basic checkbox
#   agree = TkVariable.new(0)
#   Tk::CheckButton.new(
#     text: "I agree to the terms",
#     variable: agree,
#     command: -> { puts "Agreed: #{agree.value}" }
#   ).pack
#
# @example Custom on/off values
#   enabled = TkVariable.new("no")
#   Tk::CheckButton.new(
#     text: "Enable feature",
#     variable: enabled,
#     onvalue: "yes",
#     offvalue: "no"
#   ).pack
#
# @example Toolbar-style (no indicator box)
#   Tk::CheckButton.new(text: "Bold", indicatoron: false).pack
#
# @note The checkbox automatically updates when its variable changes,
#   even if changed elsewhere in code.
#
# @see Tk::RadioButton for one-of-many selection
# @see https://www.tcl-lang.org/man/tcl/TkCmd/checkbutton.html Tcl/Tk checkbutton manual
#
class Tk::CheckButton<Tk::RadioButton
  include Tk::Generated::Checkbutton
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
  #   :offvalue
  #   :onvalue
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
  #   :variable (tkvariable)
  #   :width
  #   :wraplength
  # @generated:options:end

  TkCommandNames = ['checkbutton'.freeze].freeze
  WidgetClassName = 'Checkbutton'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  def toggle
    tk_send_without_enc('toggle')
    self
  end
end

Tk::Checkbutton = Tk::CheckButton
#TkCheckButton = Tk::CheckButton unless Object.const_defined? :TkCheckButton
#TkCheckbutton = Tk::Checkbutton unless Object.const_defined? :TkCheckbutton
#Tk.__set_toplevel_aliases__(:Tk, Tk::CheckButton,
#                            :TkCheckButton, :TkCheckbutton)
Tk.__set_loaded_toplevel_aliases__('tk/checkbutton.rb', :Tk, Tk::CheckButton,
                                   :TkCheckButton, :TkCheckbutton)
