# frozen_string_literal: false
require 'tk/label'
require 'tk/option_dsl'

# A clickable button widget.
#
# Buttons display text or an image and execute a command when clicked.
#
# @example Simple button with command
#   button = Tk::Button.new(text: "Click me") do
#     puts "Button clicked!"
#   end
#   button.pack
#
# @example Button with explicit command option
#   Tk::Button.new(
#     text: "Save",
#     command: -> { save_file }
#   ).pack
#
# @example Disabled button
#   button = Tk::Button.new(text: "Submit", state: :disabled)
#   # Later enable it:
#   button.state = :normal
#
# @see Tk::Label for display-only text
# @see https://www.tcl.tk/man/tcl/TkCmd/button.html Tcl/Tk button manual
#
class Tk::Button<Tk::Label
  include Tk::Generated::Button
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
  #   :default
  #   :disabledforeground
  #   :font
  #   :foreground
  #   :height
  #   :highlightbackground
  #   :highlightcolor
  #   :highlightthickness
  #   :image
  #   :justify
  #   :overrelief
  #   :padx
  #   :pady
  #   :relief
  #   :repeatdelay
  #   :repeatinterval
  #   :state
  #   :takefocus
  #   :text
  #   :textvariable (tkvariable)
  #   :underline
  #   :width
  #   :wraplength
  # @generated:options:end



  TkCommandNames = ['button'.freeze].freeze
  WidgetClassName = 'Button'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  # Programmatically trigger the button's command callback.
  #
  # Acts as if the user clicked the button. The button flashes briefly
  # and the command executes.
  #
  # @return [String] the return value of the command, or empty string
  #
  # @example Trigger button from code
  #   submit_button.invoke
  #
  def invoke
    tk_send_without_enc('invoke')
  end

  # Flash the button to draw attention.
  #
  # Alternates between active and normal colors several times.
  # Does not invoke the command.
  #
  # @return [self]
  #
  def flash
    tk_send_without_enc('flash')
    self
  end
end

#TkButton = Tk::Button unless Object.const_defined? :TkButton
#Tk.__set_toplevel_aliases__(:Tk, Tk::Button, :TkButton)
Tk.__set_loaded_toplevel_aliases__('tk/button.rb', :Tk, Tk::Button, :TkButton)
