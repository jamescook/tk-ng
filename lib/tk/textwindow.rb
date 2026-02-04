# frozen_string_literal: false
#
# tk/textwindow.rb - treat Tk text window object
#
require 'tk/text'
require_relative 'callback'
require_relative 'core/callable'

# A widget embedded within a Text widget.
#
# Embedded windows appear inline with text, allowing buttons, entries,
# or any widget to be placed within flowing text content. They occupy
# a single character position and move with surrounding text.
#
# @example Inserting a button
#   text = TkText.new(root)
#   text.insert(:end, "Click here: ")
#   btn = TkButton.new(text, text: "OK") { puts "Clicked!" }
#   TkTextWindow.new(text, :end, window: btn)
#   text.insert(:end, " to continue.")
#
# @example Lazy creation with :create option
#   # Widget is only created when needed (useful for peer widgets)
#   TkTextWindow.new(text, "1.0",
#     create: proc { TkButton.new(text, text: "Generated") }
#   )
#
# @example With alignment
#   TkTextWindow.new(text, :end,
#     window: my_entry,
#     align: :center,  # top, center, bottom, baseline
#     stretch: true,   # Expand vertically if line is taller
#     padx: 5
#   )
#
# ## Options
#
# - `:window` - The widget to embed
# - `:create` - Proc to create widget lazily (alternative to :window)
# - `:align` - Vertical alignment: :top, :center, :bottom, :baseline
# - `:stretch` - Expand vertically if smaller than line height
# - `:padx`, `:pady` - Padding around the widget
#
# @note Deleting the text range containing the window destroys the widget.
#
# @note Windows cannot be shared between peer text widgets. Use the
#   `:create` option so each peer creates its own widget instance.
#
# @see TkTextImage For embedding images instead of widgets
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/text.htm Tcl/Tk text manual
class TkTextWindow
  include TkUtil
  include Tk::Core::Callable
  include TkCallback
  include Tk::Text::IndexModMethods

  def initialize(parent, index, keys = {})
    @t = parent
    if index == 'end' || index == :end
      @path = TkTextMark.new(@t, tk_call(@t.path, 'index', 'end - 1 chars'))
    elsif index.kind_of?(TkTextMark)
      if tk_call(@t.path, 'index', index.path) == tk_call(@t.path, 'index', 'end')
        @path = TkTextMark.new(@t, tk_call(@t.path, 'index', 'end - 1 chars'))
      else
        @path = TkTextMark.new(@t, tk_call(@t.path, 'index', index.path))
      end
    else
      @path = TkTextMark.new(@t, tk_call(@t.path, 'index', index.to_s))
    end
    @path.gravity = 'left'
    @index = @path.path
    keys = _symbolkey2str(keys)
    @id = keys['window']
    keys['window'] = eval_path(@id) if @id
    if keys['create']
      @p_create = keys['create']
      if TkCallback._callback_entry?(@p_create)
        keys['create'] = install_cmd(proc{@id = @p_create.call; eval_path(@id)})
      end
    end
    tk_call(@t.path, 'window', 'create', @index, *hash_kv(keys, true))
    @path.gravity = 'right'
  end

  def id
    Tk::Text::IndexString.new(eval_path(@id))
  end
  def mark
    @path
  end

  def [](slot)
    cget(slot)
  end
  def []=(slot, value)
    configure(slot, value)
    value
  end

  def cget(slot)
    @t.window_cget(@index, slot)
  end
  def cget_strict(slot)
    @t.window_cget_strict(@index, slot)
  end

  def configure(slot, value=None)
    if slot.kind_of?(Hash)
      slot = _symbolkey2str(slot)
      if slot['window']
        @id = slot['window']
        slot['window'] = eval_path(@id) if @id
      end
      if slot['create']
        self.create=slot.delete('create')
      end
      if slot.size > 0
        tk_call(@t.path, 'window', 'configure', @index, *hash_kv(slot, true))
      end
    else
      if slot == 'window' || slot == :window
        @id = value
        value = eval_path(@id) if @id
      end
      if slot == 'create' || slot == :create
        self.create=value
      else
        tk_call(@t.path, 'window', 'configure', @index,
                "-#{slot}", eval_val(value))
      end
    end
    self
  end

  def configinfo(slot = nil)
    @t.window_configinfo(@index, slot)
  end

  def current_configinfo(slot = nil)
    @t.current_window_configinfo(@index, slot)
  end

  def window
    @id
  end

  def window=(value)
    @id = value
    val = eval_path(@id) if @id
    tk_call(@t.path, 'window', 'configure', @index, '-window', val)
    value
  end

  def create
    @p_create
  end

  def create=(value)
    @p_create = value
    if TkCallback._callback_entry?(@p_create)
      value = install_cmd(proc{
                            @id = @p_create.call
                            eval_path(@id)
                          })
    end
    tk_call(@t.path, 'window', 'configure', @index, '-create', eval_val(value))
    value
  end

  private

  # Get the Tk path string for a widget or object.
  def eval_path(win)
    if win.respond_to?(:epath)
      win.epath
    elsif win.respond_to?(:path)
      win.path
    else
      win.to_s
    end
  end

  # Get an eval-safe string for a value.
  def eval_val(val)
    if val.respond_to?(:path) then val.path
    elsif val.respond_to?(:to_eval) then val.to_eval
    else val.to_s
    end
  end
end

TktWindow = TkTextWindow
