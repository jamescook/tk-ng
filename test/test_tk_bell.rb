# frozen_string_literal: true

# Test for Tk.bell and Tk.bell_on_display

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestTkBell < Minitest::Test
  include TkTestHelper

  def test_bell
    assert_tk_app("Tk.bell test", method(:bell_app))
  end

  def bell_app
    require 'tk'

    errors = []

    # Basic bell (can't verify audio, just verify no error and returns nil)
    result = Tk.bell
    errors << "Tk.bell should return nil" unless result.nil?

    # Nice mode
    result = Tk.bell(true)
    errors << "Tk.bell(true) should return nil" unless result.nil?

    # bell_on_display with root window
    result = Tk.bell_on_display(root)
    errors << "Tk.bell_on_display should return nil" unless result.nil?

    # bell_on_display with nice mode
    result = Tk.bell_on_display(root, true)
    errors << "Tk.bell_on_display(root, true) should return nil" unless result.nil?

    raise "Bell test failures:\n  " + errors.join("\n  ") unless errors.empty?
  end
end
