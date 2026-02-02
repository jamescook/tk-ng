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
      @entry.get
    else
      self.value = val
    end
  end

  # Setter for value - allows box.value = "text" syntax
  def value=(val)
    @entry.delete(0, :end)
    @entry.insert(0, val.to_s)
    fire_callback
    val
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
  Tk.root.geometry('500x400')  # Sized to hold up to 4 SearchBoxes

  # Title
  TkLabel.new(Tk.root,
    text: "TkComposite SearchBox Demo",
    font: 'Helvetica 14 bold'
  ).pack(pady: 10)

  # Description
  TkLabel.new(Tk.root,
    text: "Click 'Clone' to create new SearchBox widgets.\n" \
          "Each is a complete composite widget created with one line of code.",
    wraplength: 450,
    justify: :center
  ).pack(pady: [0, 10])

  # Status display
  status_var = TkVariable.new("Type in any search box...")

  # Container for SearchBoxes
  search_container = TkFrame.new(Tk.root)
  search_container.pack(fill: :both, expand: true, padx: 20, pady: 10)

  # Track created boxes
  boxes = []
  clone_count = 0
  max_clones = 3

  # Style variations for cloned boxes
  styles = [
    { label: 'Search 1:' },
    { label: 'Search 2:', relief: :groove, borderwidth: 2 },
    { label: 'Search 3:', relief: :ridge, borderwidth: 2 },
    { label: 'Search 4:', relief: :sunken, borderwidth: 1 },
  ]

  # Create a new SearchBox - demonstrates the power of composite widgets
  create_box = proc do |index|
    style = styles[index] || styles.last
    box_num = index + 1

    opts = {
      label: style[:label],
      width: 30,
      command: proc { |v| status_var.value = "Box #{box_num}: #{v}" }
    }
    opts[:relief] = style[:relief] if style[:relief]
    opts[:borderwidth] = style[:borderwidth] if style[:borderwidth]

    Tk::RbWidget::SearchBox.new(search_container, opts).pack(fill: :x, pady: 5)
  end

  # Create first box
  boxes << create_box.call(0)

  # Separator
  TkFrame.new(Tk.root, height: 2, relief: :sunken, borderwidth: 1
  ).pack(fill: :x, pady: 10, padx: 20)

  # Status bar
  TkLabel.new(Tk.root,
    textvariable: status_var,
    anchor: :w
  ).pack(fill: :x, padx: 20)

  # Button frame
  button_frame = TkFrame.new(Tk.root)
  button_frame.pack(pady: 15)

  # Clone button
  clone_btn = TkButton.new(button_frame,
    text: "Clone (#{max_clones} remaining)",
    width: 18
  )
  clone_btn.pack(side: :left, padx: 5)

  clone_btn.command = proc {
    if clone_count < max_clones
      clone_count += 1
      boxes << create_box.call(boxes.size)
      remaining = max_clones - clone_count

      if remaining > 0
        clone_btn.text = "Clone (#{remaining} remaining)"
      else
        clone_btn.text = "Clone (max reached)"
        clone_btn.state = :disabled
      end

      status_var.value = "Created SearchBox #{boxes.size} - composite widgets are easy!"
    end
  }

  # Clear all button
  TkButton.new(button_frame,
    text: 'Clear All',
    width: 10,
    command: proc {
      boxes.each(&:clear_entry)
      status_var.value = "All boxes cleared"
    }
  ).pack(side: :left, padx: 5)

  # Automated demo support (testing and recording)
  require 'tk/demo_support'

  if TkDemo.active?
    TkDemo.after_idle {
      puts "UI loaded"

      Tk.after(TkDemo.delay(test: 100, record: 500)) {
        boxes[0].value = "hello"
      }

      Tk.after(TkDemo.delay(test: 200, record: 1000)) {
        clone_btn.invoke
      }

      Tk.after(TkDemo.delay(test: 300, record: 1500)) {
        boxes[1].value = "world"
      }

      Tk.after(TkDemo.delay(test: 400, record: 2000)) {
        clone_btn.invoke
      }

      Tk.after(TkDemo.delay(test: 500, record: 2500)) {
        clone_btn.invoke
      }

      Tk.after(TkDemo.delay(test: 600, record: 3000)) {
        TkDemo.finish
      }
    }
  end

  Tk.mainloop
end
