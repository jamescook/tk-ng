# frozen_string_literal: true

# Test for Tk focus and grab methods

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestFocusGrab < Minitest::Test
  include TkTestHelper

  def test_focus_methods
    assert_tk_app("Tk.focus methods", method(:focus_app))
  end

  def focus_app
    require 'tk'

    errors = []

    # Need visible window for focus to work
    root.deiconify
    Tk.update

    # Create widgets that can receive focus
    entry1 = TkEntry.new(root)
    entry1.pack
    entry2 = TkEntry.new(root)
    entry2.pack

    Tk.update

    # Tk.focus_to - set focus to a widget (use force for headless environments)
    Tk.focus_to(entry1, true)
    Tk.update

    # Tk.focus - get current focus
    focused = Tk.focus
    errors << "focus_to failed: expected entry1" unless focused && focused.path == entry1.path

    # Tk.focus_to another widget
    Tk.focus_to(entry2, true)
    Tk.update

    focused = Tk.focus
    errors << "focus_to failed: expected entry2" unless focused && focused.path == entry2.path

    # Tk.focus_lastfor - get last focused widget in window
    last = Tk.focus_lastfor(root)
    errors << "focus_lastfor should return a window" unless last

    # Tk.focus_next / focus_prev - traverse focus order
    Tk.focus_to(entry1, true)
    Tk.update

    next_widget = Tk.focus_next(entry1)
    errors << "focus_next should return a widget" unless next_widget

    prev_widget = Tk.focus_prev(entry2)
    errors << "focus_prev should return a widget" unless prev_widget

    raise "Focus test failures:\n  " + errors.join("\n  ") unless errors.empty?
  end

  def test_grab_methods
    assert_tk_app("Tk.current_grabs methods", method(:grab_app))
  end

  def grab_app
    require 'tk'

    errors = []

    # Initially no grabs
    grabs = Tk.current_grabs
    errors << "initial grabs should be empty array" unless grabs.is_a?(Array)

    # Create a toplevel to grab
    win = TkToplevel.new(root)
    Tk.update

    # Set a grab on the window
    win.grab_set

    # Check current_grabs with window arg
    grabbed = Tk.current_grabs(win)
    errors << "current_grabs(win) should return the grabbed window" unless grabbed

    # Check current_grabs without arg (returns list)
    grabs = Tk.current_grabs
    errors << "current_grabs should include grabbed window" unless grabs.any? { |w| w.path == win.path }

    # Release grab
    win.grab_release
    Tk.update

    grabs = Tk.current_grabs
    has_win = grabs.any? { |w| w.path == win.path rescue false }
    errors << "grab_release failed: window should not be in grabs" if has_win

    raise "Grab test failures:\n  " + errors.join("\n  ") unless errors.empty?
  end
end
