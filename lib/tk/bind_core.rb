# frozen_string_literal: true
#
# tk/bind_core.rb - Mixin for event binding on Tk objects
#
require_relative 'callback'

# Mixin providing event binding methods.
#
# TkBindCore is included by TkWindow (so all widgets have it) and
# extended by the Tk module for class-level bindings.
#
# ## Basic Binding
#
#     widget.bind('<Button-1>') { puts "Clicked!" }
#     widget.bind('<Return>') { |event| submit(event) }
#
# ## Event Sequences
#
# Common patterns:
# - `<Button-1>`, `<Button-2>`, `<Button-3>` - Mouse buttons
# - `<Double-Button-1>` - Double-click
# - `<KeyPress-Return>`, `<Key-a>` - Key presses
# - `<Control-c>`, `<Shift-Tab>` - With modifiers
# - `<Motion>` - Mouse movement
# - `<Enter>`, `<Leave>` - Mouse enters/leaves widget
# - `<FocusIn>`, `<FocusOut>` - Keyboard focus
# - `<<Paste>>` - Virtual events
#
# ## Callback Arguments
#
# Callbacks can receive an Event object or specific fields:
#
#     # Event object (no args specified)
#     widget.bind('<Motion>') { |e| puts "#{e.x}, #{e.y}" }
#
#     # Specific fields only
#     widget.bind('<Motion>', :x, :y) { |x, y| puts "#{x}, #{y}" }
#
# ## Binding Precedence
#
# Multiple bindings can match the same event. Execution order:
# 1. Widget-specific binding
# 2. Class binding (e.g., all TkButton widgets)
# 3. Toplevel binding
# 4. "all" binding
#
# Use {#bind_append} to add to existing bindings instead of replacing.
#
# @see TkEvent::Event Event object fields
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/bind.htm Tcl/Tk bind manual
module TkBindCore
  # Bind an event to this widget.
  #
  # @param context [String] Event sequence (e.g., '<Button-1>', '<Return>')
  # @param args [Array<Symbol>] Optional event fields to pass to callback
  # @yield [event_or_fields] Called when event occurs
  # @yieldparam event_or_fields [TkEvent::Event, Object] Event object or
  #   individual field values if args specified
  # @return [self]
  #
  # @example Simple click handler
  #   button.bind('<Button-1>') { do_something }
  #
  # @example With event object
  #   canvas.bind('<Motion>') { |e| draw_at(e.x, e.y) }
  #
  # @example With specific fields
  #   canvas.bind('<Button-1>', :x, :y) { |x, y| click_at(x, y) }
  def bind(context, *args, &block)
    if TkCallback._callback_entry?(args[0]) || !block
      cmd = args.shift
    else
      cmd = block
    end
    Tk.bind(self, context, cmd, *args)
  end

  # Append a binding without replacing existing ones.
  #
  # Unlike {#bind}, this adds to the existing binding script rather
  # than replacing it. Both the old and new callbacks will execute.
  #
  # @param context [String] Event sequence
  # @param args [Array<Symbol>] Optional event fields
  # @yield Called when event occurs (after existing bindings)
  # @return [self]
  #
  # @example Adding behavior to existing binding
  #   # First binding
  #   button.bind('<Enter>') { button.configure(bg: 'yellow') }
  #   # Second binding (both will run)
  #   button.bind_append('<Enter>') { puts "Hovering!" }
  def bind_append(context, *args, &block)
    if TkCallback._callback_entry?(args[0]) || !block
      cmd = args.shift
    else
      cmd = block
    end
    Tk.bind_append(self, context, cmd, *args)
  end

  # Remove a binding for an event.
  #
  # @param context [String] Event sequence to unbind
  # @return [self]
  #
  # @example
  #   button.bind_remove('<Button-1>')
  def bind_remove(context)
    Tk.bind_remove(self, context)
  end

  # Get information about current bindings.
  #
  # @param context [String, nil] Event sequence, or nil for all
  # @return [Array<String>, String] List of bound sequences, or
  #   the script for a specific sequence
  #
  # @example List all bindings
  #   button.bindinfo  # => ["<Button-1>", "<Enter>", ...]
  #
  # @example Get specific binding
  #   button.bindinfo('<Button-1>')  # => script string
  def bindinfo(context = nil)
    Tk.bindinfo(self, context)
  end
end
