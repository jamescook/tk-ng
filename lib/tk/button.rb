# frozen_string_literal: false
require_relative 'core/callable'
require_relative 'core/configurable'
require_relative 'core/widget'
require_relative 'callback'  # TkCallback (Tk::Core::Callback shim)

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
class Tk::Button
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback  # for install_cmd used by Widget
  include Tk::Core::Widget
  include Tk::Generated::Button

  TkCommandNames = ['button'.freeze].freeze
  WidgetClassName = 'Button'.freeze

  # Programmatically trigger the button's command callback.
  def invoke
    tk_send('invoke')
  end

  # Flash the button to draw attention.
  def flash
    tk_send('flash')
    self
  end
end

Tk.__set_loaded_toplevel_aliases__('tk/button.rb', :Tk, Tk::Button, :TkButton)
