# frozen_string_literal: false
require_relative 'core/callable'
require_relative 'core/configurable'
require_relative 'core/widget'
require_relative 'callback'

# A scrollbar for scrolling other widgets.
#
# Scrollbars are typically paired with Text, Listbox, or Canvas widgets.
# The scrollbar and widget communicate bidirectionally:
# - Scrollbar tells widget to scroll (via widget's xview/yview)
# - Widget tells scrollbar its visible range (via scrollbar's set)
#
# @example Scrollbar with Text widget (manual wiring)
#   frame = Tk::Frame.new.pack(fill: :both, expand: true)
#   text = Tk::Text.new(frame).pack(side: :left, fill: :both, expand: true)
#   scrollbar = Tk::Scrollbar.new(frame, orient: :vertical)
#   scrollbar.pack(side: :right, fill: :y)
#
#   # Wire them together
#   text.yscrollcommand = proc { |*args| scrollbar.set(*args) }
#   scrollbar.command = proc { |*args| text.yview(*args) }
#
# @example Using helper method (if widget supports it)
#   text = Tk::Text.new
#   scrollbar = Tk::Scrollbar.new
#   text.yscrollbar(scrollbar)  # automatic wiring
#
# @note The `:jump` option controls drag behavior. When true, the view
#   updates only on mouse release (smoother for large documents).
#
# @see https://www.tcl-lang.org/man/tcl/TkCmd/scrollbar.html Tcl/Tk scrollbar manual
#
class Tk::Scrollbar
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include Tk::Generated::Scrollbar
  # @generated:options:start
  # Available options (auto-generated from Tk introspection):
  #
  #   :activebackground
  #   :activerelief
  #   :background
  #   :bd
  #   :bg
  #   :borderwidth
  #   :command (callback)
  #   :cursor
  #   :elementborderwidth
  #   :highlightbackground
  #   :highlightcolor
  #   :highlightthickness
  #   :jump
  #   :orient
  #   :relief
  #   :repeatdelay
  #   :repeatinterval
  #   :takefocus
  #   :troughcolor
  #   :width
  # @generated:options:end

  TkCommandNames = ['scrollbar'.freeze].freeze
  WidgetClassName = 'Scrollbar'.freeze

  def initialize(parent = nil, keys = {}, &block)
    @assigned = []
    @scroll_proc = proc { |*args|
      if orient == 'horizontal'
        @assigned.each { |w| w.xview(*args) }
      else
        @assigned.each { |w| w.yview(*args) }
      end
    }
    super
  end

  def propagate_set(src_win, first, last)
    set(first, last)
    if orient == 'horizontal'
      @assigned.each { |w| w.xview('moveto', first) if w != src_win }
    else
      @assigned.each { |w| w.yview('moveto', first) if w != src_win }
    end
  end

  def assign(*wins)
    begin
      self.command(@scroll_proc) if cget('command').cmd != @scroll_proc
    rescue StandardError
      self.command(@scroll_proc)
    end
    o = orient
    wins.each do |w|
      @assigned << w unless @assigned.index(w)
      if o == 'horizontal'
        w.xscrollcommand proc { |first, last| propagate_set(w, first, last) }
      else
        w.yscrollcommand proc { |first, last| propagate_set(w, first, last) }
      end
    end
    Tk.update
    self
  end

  def assigned_list
    begin
      return @assigned.dup if cget('command').cmd == @scroll_proc
    rescue StandardError
    end
    fail RuntimeError, "not depend on the assigned_list"
  end

  def delta(deltax, deltay)
    tk_send('delta', deltax, deltay).to_f
  end

  def fraction(x, y)
    tk_send('fraction', x, y).to_f
  end

  def identify(x, y)
    tk_send('identify', x, y)
  end

  def get
    TclTkLib._split_tklist(tk_send('get')).map(&:to_f)
  end

  def set(first, last)
    tk_send('set', first, last)
    self
  end

  def activate(element = nil)
    if element
      tk_send('activate', element)
    else
      tk_send('activate')
    end
  end

  def moveto(fraction)
    tk_send('moveto', fraction)
    self
  end

  def scroll(*args)
    tk_send('scroll', *args)
    self
  end

  def scroll_units(num)
    scroll(num, 'units')
  end

  def scroll_pages(num)
    scroll(num, 'pages')
  end
end

#TkScrollbar = Tk::Scrollbar unless Object.const_defined? :TkScrollbar
#Tk.__set_toplevel_aliases__(:Tk, Tk::Scrollbar, :TkScrollbar)
Tk.__set_loaded_toplevel_aliases__('tk/scrollbar.rb', :Tk, Tk::Scrollbar,
                                   :TkScrollbar)


class Tk::XScrollbar < Tk::Scrollbar
  def initialize(parent = nil, keys = {}, &block)
    keys = parent.is_a?(Hash) ? parent.merge(orient: 'horizontal') : keys.merge(orient: 'horizontal')
    super(parent.is_a?(Hash) ? keys : parent, parent.is_a?(Hash) ? {} : keys, &block)
  end
end

#TkXScrollbar = Tk::XScrollbar unless Object.const_defined? :TkXScrollbar
#Tk.__set_toplevel_aliases__(:Tk, Tk::XScrollbar, :TkXScrollbar)
Tk.__set_loaded_toplevel_aliases__('tk/scrollbar.rb', :Tk, Tk::XScrollbar,
                                   :TkXScrollbar)


class Tk::YScrollbar < Tk::Scrollbar
  def initialize(parent = nil, keys = {}, &block)
    keys = parent.is_a?(Hash) ? parent.merge(orient: 'vertical') : keys.merge(orient: 'vertical')
    super(parent.is_a?(Hash) ? keys : parent, parent.is_a?(Hash) ? {} : keys, &block)
  end
end

#TkYScrollbar = Tk::YScrollbar unless Object.const_defined? :TkYScrollbar
#Tk.__set_toplevel_aliases__(:Tk, Tk::YScrollbar, :TkYScrollbar)
Tk.__set_loaded_toplevel_aliases__('tk/scrollbar.rb', :Tk, Tk::YScrollbar,
                                   :TkYScrollbar)
