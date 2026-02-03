# frozen_string_literal: false
require_relative 'core/callable'
require_relative 'core/configurable'
require_relative 'callback'
require_relative 'core/widget'

# A container with resizable panes separated by draggable sashes.
#
# Panes can be arranged horizontally or vertically. Users can drag
# the sash between panes to resize them.
#
# @example Horizontal split
#   paned = Tk::PanedWindow.new(orient: :horizontal)
#   left = Tk::Frame.new(paned, width: 200, height: 300)
#   right = Tk::Frame.new(paned, width: 400, height: 300)
#   paned.add(left, right)
#   paned.pack(fill: :both, expand: true)
#
# @example Vertical split with weights
#   paned = Tk::PanedWindow.new(orient: :vertical)
#   top = Tk::Text.new(paned)
#   bottom = Tk::Text.new(paned)
#   paned.add(top, minsize: 100)
#   paned.add(bottom, minsize: 50)
#   paned.pack(fill: :both, expand: true)
#
# @see https://www.tcl-lang.org/man/tcl/TkCmd/panedwindow.html Tcl/Tk panedwindow manual
#
class Tk::PanedWindow
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include Tk::Generated::Panedwindow

  TkCommandNames = ['panedwindow'.freeze].freeze
  WidgetClassName = 'Panedwindow'.freeze
  Tk::Core::Widget.registry[WidgetClassName] ||= self

  def add(*args)
    keys = args.pop
    fail ArgumentError, "no window in arguments" unless keys
    if keys.kind_of?(Hash)
      fail ArgumentError, "no window in arguments" if args.empty?
      cmd_args = args.map { |w| _pw_path(w) }
      keys.each do |k, v|
        cmd_args << "-#{k}"
        cmd_args << _pw_path(v)
      end
    else
      args.push(keys)
      cmd_args = args.map { |w| _pw_path(w) }
    end
    tk_send('add', *cmd_args)
    self
  end

  def forget(win, *wins)
    wins.unshift(win)
    tk_send('forget', *(wins.map { |w| _pw_path(w) }))
    self
  end
  alias del forget
  alias delete forget
  alias remove forget

  def identify(x, y)
    result = tk_send('identify', x, y)
    TclTkLib._split_tklist(result).map { |v| v =~ /\A-?\d+\z/ ? v.to_i : v }
  end

  def proxy_coord
    result = tk_send('proxy', 'coord')
    TclTkLib._split_tklist(result).map(&:to_i)
  end

  def proxy_forget
    tk_send('proxy', 'forget')
    self
  end

  def proxy_place(x, y)
    tk_send('proxy', 'place', x, y)
    self
  end

  def sash_coord(index)
    result = tk_send('sash', 'coord', index)
    result.split.map(&:to_i)
  end

  def sash_dragto(index, x, y)
    tk_send('sash', 'dragto', index, x, y)
    self
  end

  def sash_mark(index, x, y)
    tk_send('sash', 'mark', index, x, y)
    self
  end

  def sash_place(index, x, y)
    tk_send('sash', 'place', index, x, y)
    self
  end

  def panecget_strict(win, key)
    val = tk_send('panecget', _pw_path(win), "-#{key}")
    value_from_tcl(val)
  end

  def panecget(win, key)
    panecget_strict(win, key)
  end

  def paneconfigure(win, key, value=nil)
    w = _pw_path(win)
    if key.kind_of?(Hash)
      params = []
      key.each do |k, v|
        params << "-#{k}"
        params << _pw_path(v)
      end
      tk_send('paneconfigure', w, *params)
    else
      tk_send('paneconfigure', w, "-#{key}", _pw_path(value))
    end
    self
  end
  alias pane_config paneconfigure

  def paneconfiginfo(win, key=nil)
    w = _pw_path(win)
    if key
      conf = TclTkLib._split_tklist(tk_send('paneconfigure', w, "-#{key}"))
      conf[0] = conf[0][1..-1]
      conf[3] = value_from_tcl(conf[3]) if conf[3]
      conf[4] = value_from_tcl(conf[4]) if conf[4]
      conf
    else
      TclTkLib._split_tklist(tk_send('paneconfigure', w)).map do |conflist|
        conf = TclTkLib._split_tklist(conflist)
        conf[0] = conf[0][1..-1]
        conf[1] = conf[1][1..-1] if conf.size == 2 # alias info
        conf[3] = value_from_tcl(conf[3]) if conf[3]
        conf[4] = value_from_tcl(conf[4]) if conf[4]
        conf
      end
    end
  end
  alias pane_configinfo paneconfiginfo

  def current_paneconfiginfo(win, key=nil)
    if key
      conf = paneconfiginfo(win, key)
      {conf[0] => conf[4]}
    else
      ret = {}
      paneconfiginfo(win).each do |conf|
        ret[conf[0]] = conf[4] if conf.size > 2
      end
      ret
    end
  end
  alias current_pane_configinfo current_paneconfiginfo

  def panes
    result = tk_send('panes')
    TclTkLib._split_tklist(result)
  end

  private

  # Convert widget or value to path string for pane commands
  def _pw_path(v)
    if v.respond_to?(:epath)
      v.epath
    elsif v.respond_to?(:path)
      v.path
    else
      v.to_s
    end
  end

end

Tk::Panedwindow = Tk::PanedWindow
Tk.__set_loaded_toplevel_aliases__('tk/panedwindow.rb', :Tk, Tk::PanedWindow,
                                   :TkPanedWindow, :TkPanedwindow)
