# frozen_string_literal: true

# Tests for accessor-style option access (widget.text, widget.text=)
# These exercise the method_missing -> cget/configure path in TkObject.
#
# This ensures the accessor pattern works before/after any refactoring
# to generate explicit accessor methods.

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestOptionAccessors < Minitest::Test
  include TkTestHelper

  def test_button_accessors
    assert_tk_app("Button accessor-style options", method(:button_accessors_app))
  end

  def button_accessors_app
    require 'tk'
    require 'tk/button'

    errors = []

    btn = TkButton.new(root, text: "Hello")

    # Getter via accessor
    errors << "getter failed: expected 'Hello', got #{btn.text.inspect}" unless btn.text == "Hello"

    # Setter via accessor
    btn.text = "World"
    errors << "setter failed: expected 'World', got #{btn.text.inspect}" unless btn.text == "World"

    # Integer option
    btn.width = 20
    errors << "width setter failed: got #{btn.width.inspect}" unless btn.width == 20

    # Alias: bg -> background
    btn.bg = "red"
    errors << "alias bg failed: got #{btn.background.inspect}" unless btn.background == "red"
    errors << "bg getter failed: got #{btn.bg.inspect}" unless btn.bg == "red"

    # Alias: fg -> foreground
    btn.fg = "blue"
    errors << "alias fg failed: got #{btn.foreground.inspect}" unless btn.foreground == "blue"

    # State option
    btn.state = "disabled"
    errors << "state failed: got #{btn.state.inspect}" unless btn.state == "disabled"

    raise errors.join("\n") unless errors.empty?
  end

  def test_label_accessors
    assert_tk_app("Label accessor-style options", method(:label_accessors_app))
  end

  def label_accessors_app
    require 'tk'
    require 'tk/label'

    errors = []

    lbl = TkLabel.new(root, text: "Test Label")

    # Basic getter/setter
    errors << "initial text wrong" unless lbl.text == "Test Label"

    lbl.text = "Updated"
    errors << "text setter failed" unless lbl.text == "Updated"

    # Anchor
    lbl.anchor = "nw"
    errors << "anchor failed: got #{lbl.anchor.inspect}" unless lbl.anchor == "nw"

    # Relief
    lbl.relief = "raised"
    errors << "relief failed: got #{lbl.relief.inspect}" unless lbl.relief == "raised"

    # Justify
    lbl.justify = "center"
    errors << "justify failed: got #{lbl.justify.inspect}" unless lbl.justify == "center"

    # Padding via alias
    lbl.padx = 10
    errors << "padx failed" unless lbl.padx.to_i == 10

    raise errors.join("\n") unless errors.empty?
  end

  def test_entry_accessors
    assert_tk_app("Entry accessor-style options", method(:entry_accessors_app))
  end

  def entry_accessors_app
    require 'tk'
    require 'tk/entry'

    errors = []

    entry = TkEntry.new(root, width: 30)

    # Width
    errors << "initial width wrong: got #{entry.width.inspect}" unless entry.width == 30

    entry.width = 50
    errors << "width setter failed: got #{entry.width.inspect}" unless entry.width == 50

    # Show (password masking)
    entry.show = "*"
    errors << "show failed: got #{entry.show.inspect}" unless entry.show == "*"

    # State
    entry.state = "readonly"
    errors << "state failed: got #{entry.state.inspect}" unless entry.state == "readonly"

    # Background via alias
    entry.bg = "yellow"
    errors << "bg alias failed" unless entry.background == "yellow"

    raise errors.join("\n") unless errors.empty?
  end

  def test_chained_setter_returns_value
    assert_tk_app("Setter returns assigned value", method(:chained_setter_app))
  end

  def chained_setter_app
    require 'tk'
    require 'tk/button'

    errors = []

    btn = TkButton.new(root)

    # Setter should return the value (for chaining like a = b = c)
    result = (btn.text = "Chained")
    errors << "setter should return value, got #{result.inspect}" unless result == "Chained"

    raise errors.join("\n") unless errors.empty?
  end

  def test_method_call_setter_style
    assert_tk_app("Method call setter style", method(:method_call_setter_app))
  end

  def method_call_setter_app
    require 'tk'
    require 'tk/button'

    errors = []

    btn = TkButton.new(root)

    # widget.text("value") style - sets and returns self for chaining
    result = btn.text("Hello")
    errors << "method call setter should return self" unless result == btn
    errors << "method call setter failed: got #{btn.text.inspect}" unless btn.text == "Hello"

    # Chaining: btn.text("A").width(10).state("disabled")
    btn.text("Chained").width(20)
    errors << "chaining failed for text" unless btn.text == "Chained"
    errors << "chaining failed for width" unless btn.width == 20

    raise errors.join("\n") unless errors.empty?
  end

  # Test method_missing fallback for options that can't have Ruby accessors
  # (reserved names like 'class', 'type', 'format')
  def test_method_missing_fallback_for_reserved_options
    assert_tk_app("method_missing fallback for reserved options", method(:method_missing_fallback_app))
  end

  def method_missing_fallback_app
    require 'tk'
    require 'tk/frame'

    errors = []

    # Frame has a 'class' option - can't define a Ruby method for it
    # (conflicts with Object#class). Must use cget/configure or [].
    # Note: class is read-only after creation, so set it in constructor.
    frame = TkFrame.new(root, class: "MyCustomClass")

    # Use cget directly (the safe way for reserved option names)
    result = frame.cget(:class)
    errors << "class option via cget failed: got #{result.inspect}" unless result == "MyCustomClass"

    # The [] syntax also works
    errors << "class via [] failed" unless frame[:class] == "MyCustomClass"

    raise errors.join("\n") unless errors.empty?
  end
end
