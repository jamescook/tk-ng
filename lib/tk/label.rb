# frozen_string_literal: false
require 'tk/option_dsl'

# A widget that displays text or an image.
#
# Labels are non-interactive by default - use {Tk::Button} for clickable text.
#
# @example Simple text label
#   label = Tk::Label.new(text: "Hello, World!")
#   label.pack
#
# @example Label with variable binding (updates automatically)
#   status = TkVariable.new("Ready")
#   label = Tk::Label.new(textvariable: status)
#   label.pack
#   status.value = "Processing..."  # label updates automatically
#
# @note **textvariable update timing**: Changes fire immediately via Tcl's
#   trace mechanism. The visual update occurs on the next event loop iteration,
#   which is essentially instant during {Tk.mainloop}. If you're in a tight
#   loop, call `Tk.update` or `Tk.update_idletasks` to force a redraw.
#
# @example Styled label
#   Tk::Label.new(
#     text: "Important!",
#     fg: "red",
#     font: "Helvetica 14 bold"
#   ).pack
#
# @see https://www.tcl.tk/man/tcl/TkCmd/label.html Tcl/Tk label manual
#
class Tk::Label<TkWindow
  include Tk::Generated::Label
  # @generated:options:start
  # Available options (auto-generated from Tk introspection):
  #
  #   :activebackground
  #   :activeforeground
  #   :anchor
  #   :background
  #   :bitmap
  #   :borderwidth
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
  #   :justify
  #   :padx
  #   :pady
  #   :relief
  #   :state
  #   :takefocus
  #   :text
  #   :textvariable (tkvariable)
  #   :underline
  #   :width
  #   :wraplength
  # @generated:options:end

  TkCommandNames = ['label'.freeze].freeze
  WidgetClassName = 'Label'.freeze
  WidgetClassNames[WidgetClassName] ||= self
  #def create_self(keys)
  #  if keys and keys != None
  #    tk_call_without_enc('label', @path, *hash_kv(keys, true))
  #  else
  #    tk_call_without_enc('label', @path)
  #  end
  #end
  #private :create_self
end

#TkLabel = Tk::Label unless Object.const_defined? :TkLabel
#Tk.__set_toplevel_aliases__(:Tk, Tk::Label, :TkLabel)
Tk.__set_loaded_toplevel_aliases__('tk/label.rb', :Tk, Tk::Label, :TkLabel)
