# frozen_string_literal: true

# Test for Tk.place, Tk.place_forget, Tk.unplace

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestPlace < Minitest::Test
  include TkTestHelper

  def test_place_methods
    assert_tk_app("Tk.place methods", method(:place_app))
  end

  def place_app
    require 'tk'

    errors = []

    # Create widgets
    lbl = TkLabel.new(root, text: "Test")
    btn = TkButton.new(root, text: "Button")

    # Tk.place - absolute positioning
    Tk.place(lbl, x: 10, y: 10)
    Tk.place(btn, x: 10, y: 50)

    # Verify they're placed
    errors << "label not placed" unless lbl.winfo_manager == "place"
    errors << "button not placed" unless btn.winfo_manager == "place"

    # Tk.place_forget - remove from place
    Tk.place_forget(lbl)
    errors << "label should be unplaced" unless lbl.winfo_manager == ""

    # Tk.unplace - alias for place_forget
    Tk.unplace(btn)
    errors << "button should be unplaced" unless btn.winfo_manager == ""

    raise "Place test failures:\n  " + errors.join("\n  ") unless errors.empty?
  end
end
