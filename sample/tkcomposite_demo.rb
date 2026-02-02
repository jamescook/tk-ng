# frozen_string_literal: false
# tk-record: title=TkComposite Demo
#
# tkcomposite_demo.rb - Demonstrates TkComposite for building compound widgets
#
# This sample shows how to use TkComposite to create reusable widgets
# from multiple Tk primitives. The SearchBox widget combines a label,
# entry field, and clear button into a single configurable component.
#
# Key TkComposite features demonstrated:
#   - delegate('option', @widget)       Forward options to child widgets
#   - delegate('DEFAULT', @widget)      Forward unknown options to main widget
#   - delegate_alias('alias', 'opt')    Expose option under different name
#   - option_methods(:method)           Custom getter/setter for options
#
require 'tk'

module Tk
  module RbWidget
    class SearchBox < TkFrame
    end
  end
end

# A search box widget combining label, entry, and clear button.
#
# Options:
#   :label     - Text shown before the entry (default: "Search:")
#   :value     - Current entry value (get/set via custom method)
#   :command   - Callback when value changes (receives new value)
#   :cleartext - Text for clear button (default: "×")
#   Plus all TkEntry options via DEFAULT delegation
#
# Example:
#   box = Tk::RbWidget::SearchBox.new(root, label: 'Find:', width: 30)
#   box.command { |val| puts "Searching: #{val}" }
#   box.value = "initial text"
#
class Tk::RbWidget::SearchBox < TkFrame
  include TkComposite

  def initialize_composite(keys = {})
    keys = _symbolkey2str(keys)

    # Extract our custom options before passing to children
    @callback = keys.delete('command')
    cleartext = keys.delete('cleartext') || "\u00D7"  # × symbol

    # Create child widgets inside @frame (provided by TkComposite)
    @label = TkLabel.new(@frame)
    @entry = TkEntry.new(@frame)
    @clear_btn = TkButton.new(@frame,
      text: cleartext,
      width: 2,
      command: proc { clear_entry }
    )

    # Layout
    @label.pack(side: :left, padx: [0, 5])
    @entry.pack(side: :left, fill: :x, expand: true)
    @clear_btn.pack(side: :left, padx: [5, 0])

    # Bind entry changes to callback
    @entry.bind('KeyRelease') { fire_callback }

    # ============================================================
    # DELEGATION SETUP - The heart of TkComposite
    # ============================================================

    # delegate('DEFAULT', widget) - Forward all unrecognized options
    # to the entry widget. This makes the SearchBox configurable
    # like a regular entry (width, font, state, etc.)
    delegate('DEFAULT', @entry)

    # delegate('option', widget) - Forward specific options
    # Background color applies to all visible parts
    delegate('background', @frame, @label, @entry)
    delegate('foreground', @label, @entry)

    # Forward frame-specific options explicitly
    delegate('borderwidth', @frame)
    delegate('relief', @frame)

    # delegate_alias('alias', 'option', widget) - Expose an option
    # under a different name. Here 'label' sets the TkLabel's 'text'.
    delegate_alias('label', 'text', @label)

    # Forward clear button options with custom names
    delegate_alias('cleartext', 'text', @clear_btn)
    delegate_alias('clearwidth', 'width', @clear_btn)

    # ============================================================
    # OPTION METHODS - Custom getter/setter logic
    # ============================================================

    # option_methods registers methods to handle options that need
    # custom logic beyond simple forwarding.
    #
    # Single method style: method handles both get (no arg) and set (with arg)
    option_methods(:value)
    option_methods(:command)

    # Apply remaining configuration options
    # (This processes both delegated and option_method options)
    configure(keys) unless keys.empty?

    # Set default label if not specified
    @label.text = 'Search:' if @label.text.to_s.empty?
  end

  # Custom option method for 'value' - handles entry content
  # Called by configure(:value, x) and cget(:value)
  def value(val = nil)
    if val.nil?
      # getter
      @entry.get
    else
      # setter
      @entry.delete(0, :end)
      @entry.insert(0, val.to_s)
      fire_callback
      val
    end
  end

  # Custom option method for 'command' - handles callback
  def command(cmd = nil, &block)
    if cmd.nil? && !block
      # getter
      @callback
    else
      # setter
      @callback = cmd || block
      self
    end
  end

  # Clear the entry and fire callback
  def clear_entry
    @entry.delete(0, :end)
    fire_callback
    @entry.focus
  end

  # Focus the entry field
  def focus
    @entry.focus
  end

  private

  def fire_callback
    @callback&.call(@entry.get)
  end
end

# ============================================================
# DEMO / TEST
# ============================================================
if __FILE__ == $0
  Tk.root.title('TkComposite Demo')
  Tk.root.geometry('480x320')

  # Title
  TkLabel.new(Tk.root,
    text: "TkComposite SearchBox Demo",
    font: 'Helvetica 14 bold'
  ).pack(pady: 10)

  # Description
  TkLabel.new(Tk.root,
    text: "SearchBox combines Label + Entry + Button using TkComposite",
    wraplength: 400,
    justify: :center
  ).pack(pady: [0, 15])

  # Status display
  status_var = TkVariable.new("Type something...")

  # ---- First SearchBox: Basic usage ----
  TkLabel.new(Tk.root,
    text: "Basic SearchBox (default label):",
    anchor: :w
  ).pack(fill: :x, padx: 20)

  box1 = Tk::RbWidget::SearchBox.new(Tk.root,
    width: 25,
    command: proc { |v| status_var.value = "Search 1: #{v}" }
  ).pack(padx: 20, pady: 5, fill: :x)

  # ---- Second SearchBox: Customized ----
  TkLabel.new(Tk.root,
    text: "Customized SearchBox:",
    anchor: :w
  ).pack(fill: :x, padx: 20, pady: [15, 0])

  box2 = Tk::RbWidget::SearchBox.new(Tk.root,
    label: 'Find:',              # Custom label via delegate_alias
    width: 25,
    value: 'preset value',       # Initial value via option_methods
    background: '#f0f8ff',       # Applies to frame, label, entry
    foreground: '#333',
    relief: :groove,
    borderwidth: 2,
    command: proc { |v| status_var.value = "Search 2: #{v}" }
  ).pack(padx: 20, pady: 5, fill: :x)

  # ---- Third SearchBox: Disabled state ----
  TkLabel.new(Tk.root,
    text: "Disabled SearchBox (via DEFAULT delegation to entry):",
    anchor: :w
  ).pack(fill: :x, padx: 20, pady: [15, 0])

  Tk::RbWidget::SearchBox.new(Tk.root,
    label: 'Disabled:',
    value: 'cannot edit',
    state: :disabled,            # Forwarded to entry via DEFAULT
    width: 25
  ).pack(padx: 20, pady: 5, fill: :x)

  # Status bar
  TkFrame.new(Tk.root, height: 2, relief: :sunken, borderwidth: 1
  ).pack(fill: :x, pady: 15, padx: 20)

  TkLabel.new(Tk.root,
    textvariable: status_var,
    anchor: :w
  ).pack(fill: :x, padx: 20)

  # Buttons
  TkFrame.new(Tk.root) do |f|
    TkButton.new(f,
      text: 'Get box1 value',
      command: proc { status_var.value = "box1.cget(:value) = #{box1.cget(:value).inspect}" }
    ).pack(side: :left, padx: 5)

    TkButton.new(f,
      text: 'Set box1 value',
      command: proc {
        box1.configure(:value, "set at #{Time.now.strftime('%H:%M:%S')}")
      }
    ).pack(side: :left, padx: 5)

    TkButton.new(f,
      text: 'Focus box1',
      command: proc { box1.focus }
    ).pack(side: :left, padx: 5)
  end.pack(pady: 10)

  # Automated demo support (testing and recording)
  require 'tk/demo_support'

  if TkDemo.active?
    TkDemo.after_idle {
      puts "UI loaded"

      # Demo sequence: interact with the widgets
      Tk.after(TkDemo.delay(test: 100, record: 500)) {
        # Type in first box
        box1.value = "hello"
      }

      Tk.after(TkDemo.delay(test: 200, record: 1200)) {
        # Type in second box
        box2.value = "world"
      }

      Tk.after(TkDemo.delay(test: 300, record: 2000)) {
        # Clear first box
        box1.clear_entry
      }

      Tk.after(TkDemo.delay(test: 400, record: 2800)) {
        TkDemo.finish
      }
    }
  end

  Tk.mainloop
end
