# frozen_string_literal: true

# Test for Tk.raise_window and Tk.lower_window (z-order control)

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestWindowStacking < Minitest::Test
  include TkTestHelper

  def test_raise_and_lower_window
    assert_tk_app("Tk.raise_window and Tk.lower_window", method(:stacking_app))
  end

  def stacking_app
    require 'tk'

    errors = []

    # Create two toplevel windows
    win1 = TkToplevel.new(root, title: "Window 1")
    win2 = TkToplevel.new(root, title: "Window 2")

    # Need to update to ensure windows are mapped
    Tk.update

    # Get stack order via wm stackorder (returns list lowest-to-highest)
    def stack_order
      Tk.ip_invoke('wm', 'stackorder', '.').split
    end

    # win2 was created last, should be on top initially
    order = stack_order
    win1_path = win1.path
    win2_path = win2.path

    # Lower win2 below win1
    Tk.lower_window(win2, win1)
    Tk.update

    order = stack_order
    idx1 = order.index(win1_path)
    idx2 = order.index(win2_path)
    errors << "lower_window failed: win2 should be below win1" if idx2 && idx1 && idx2 > idx1

    # Raise win2 above win1
    Tk.raise_window(win2, win1)
    Tk.update

    order = stack_order
    idx1 = order.index(win1_path)
    idx2 = order.index(win2_path)
    errors << "raise_window failed: win2 should be above win1" if idx2 && idx1 && idx2 < idx1

    # Raise win1 to top (no second arg)
    Tk.raise_window(win1)
    Tk.update

    order = stack_order
    errors << "raise_window(win1) failed: win1 should be at top" if order.last != win1_path

    # Lower win1 to bottom (no second arg)
    Tk.lower_window(win1)
    Tk.update

    order = stack_order
    # win1 should be lower than win2 now
    idx1 = order.index(win1_path)
    idx2 = order.index(win2_path)
    errors << "lower_window(win1) failed: win1 should be below win2" if idx1 && idx2 && idx1 > idx2

    raise "Stacking test failures:\n  " + errors.join("\n  ") unless errors.empty?
  end
end
