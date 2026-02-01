# frozen_string_literal: false
require 'tk/label'

# A widget for displaying multi-line text with automatic line wrapping.
#
# Unlike {Tk::Label}, Message automatically wraps text based on the
# `:aspect` ratio or `:width`. Useful for longer messages and dialogs.
#
# @example Basic message
#   Tk::Message.new(
#     text: "This is a longer message that will be automatically " \
#           "wrapped to fit the aspect ratio.",
#     aspect: 200  # wider than tall
#   ).pack
#
# @example Fixed width
#   Tk::Message.new(
#     text: "Message with fixed width",
#     width: 200,
#     justify: :center
#   ).pack
#
# @note The `:aspect` option is `100 * width / height`. Default 150 (roughly
#   square). Use 200+ for wider, 100 or less for taller.
#
# @note Tabs don't work well with centered or right-justified text.
#
# @see Tk::Label for single-line or fixed-layout text
# @see https://www.tcl-lang.org/man/tcl/TkCmd/message.html Tcl/Tk message manual
#
class Tk::Message<Tk::Label
  include Tk::Generated::Message
  # @generated:options:start
  # Available options (auto-generated from Tk introspection):
  #
  #   :anchor
  #   :aspect
  #   :background
  #   :borderwidth
  #   :cursor
  #   :font
  #   :foreground
  #   :highlightbackground
  #   :highlightcolor
  #   :highlightthickness
  #   :justify
  #   :padx
  #   :pady
  #   :relief
  #   :takefocus
  #   :text
  #   :textvariable (tkvariable)
  #   :width
  # @generated:options:end


  TkCommandNames = ['message'.freeze].freeze
  WidgetClassName = 'Message'.freeze
  WidgetClassNames[WidgetClassName] ||= self

  #def create_self(keys)
  #  if keys and keys != None
  #    tk_call_without_enc('message', @path, *hash_kv(keys, true))
  #  else
  #    tk_call_without_enc('message', @path)
  #  end
  #end
  private :create_self
end

#TkMessage = Tk::Message unless Object.const_defined? :TkMessage
#Tk.__set_toplevel_aliases__(:Tk, Tk::Message, :TkMessage)
Tk.__set_loaded_toplevel_aliases__('tk/message.rb', :Tk, Tk::Message,
                                   :TkMessage)
