# frozen_string_literal: true

# Test for Tk.grid, Tk.grid_forget, Tk.ungrid

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestGrid < Minitest::Test
  include TkTestHelper

  def test_grid_methods
    assert_tk_app("Tk.grid methods", method(:grid_app))
  end

  def grid_app
    require 'tk'

    errors = []

    # Create widgets
    lbl = TkLabel.new(root, text: "Test")
    btn = TkButton.new(root, text: "Button")

    # Tk.grid - arrange in grid
    Tk.grid(lbl, row: 0, column: 0)
    Tk.grid(btn, row: 1, column: 0)

    # Verify they're gridded
    errors << "label not gridded" unless lbl.winfo_manager == "grid"
    errors << "button not gridded" unless btn.winfo_manager == "grid"

    # Tk.grid_forget - remove from grid
    Tk.grid_forget(lbl)
    errors << "label should be ungridded" unless lbl.winfo_manager == ""

    # Tk.ungrid - alias for grid_forget
    Tk.ungrid(btn)
    errors << "button should be ungridded" unless btn.winfo_manager == ""

    raise "Grid test failures:\n  " + errors.join("\n  ") unless errors.empty?
  end
end
