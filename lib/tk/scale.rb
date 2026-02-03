# frozen_string_literal: false
require_relative 'core/callable'
require_relative 'core/configurable'
require_relative 'core/widget'
require_relative 'callback'

# A slider widget for selecting a numeric value from a range.
#
# @example Basic scale
#   volume = TkVariable.new(50)
#   Tk::Scale.new(
#     from: 0,
#     to: 100,
#     variable: volume,
#     orient: :horizontal,
#     label: "Volume"
#   ).pack
#
# @example Scale with callback
#   Tk::Scale.new(
#     from: 0.0,
#     to: 1.0,
#     resolution: 0.1,
#     command: ->(val) { puts "Value: #{val}" }
#   ).pack
#
# @note The `:resolution` option controls value rounding. Default is 1
#   (integers only). Set to 0.1 for one decimal place, or a negative
#   value to disable rounding entirely.
#
# @see https://www.tcl-lang.org/man/tcl/TkCmd/scale.html Tcl/Tk scale manual
#
class Tk::Scale
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include Tk::Generated::Scale
  # @generated:options:start
  # Available options (auto-generated from Tk introspection):
  #
  #   :activebackground
  #   :background
  #   :bigincrement
  #   :borderwidth
  #   :command (callback)
  #   :cursor
  #   :digits
  #   :font
  #   :foreground
  #   :from
  #   :highlightbackground
  #   :highlightcolor
  #   :highlightthickness
  #   :label
  #   :length
  #   :orient
  #   :relief
  #   :repeatdelay
  #   :repeatinterval
  #   :resolution
  #   :showvalue
  #   :sliderlength
  #   :sliderrelief
  #   :state
  #   :takefocus
  #   :tickinterval
  #   :to
  #   :troughcolor
  #   :variable (tkvariable)
  #   :width
  # @generated:options:end

  TkCommandNames = ['scale'.freeze].freeze
  WidgetClassName = 'Scale'.freeze

  def get(x = nil, y = nil)
    if x && y
      tk_send('get', x, y).to_f
    else
      tk_send('get').to_f
    end
  end

  def coords(val = nil)
    if val
      TclTkLib._split_tklist(tk_send('coords', val))
    else
      TclTkLib._split_tklist(tk_send('coords'))
    end
  end

  def identify(x, y)
    tk_send('identify', x, y)
  end

  def set(val)
    tk_send('set', val)
  end

  def value
    get
  end

  def value=(val)
    set(val)
    val
  end
end

#TkScale = Tk::Scale unless Object.const_defined? :TkScale
#Tk.__set_toplevel_aliases__(:Tk, Tk::Scale, :TkScale)
Tk.__set_loaded_toplevel_aliases__('tk/scale.rb', :Tk, Tk::Scale, :TkScale)
