# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestManageFocus < Minitest::Test
  include TkTestHelper

  def test_focus_traversal
    assert_tk_app("TkManageFocus traversal", method(:mngfocus_app))
  end

  def mngfocus_app
    require 'tk'
    require 'tk/mngfocus'

    errors = []

    # Verify module methods exist
    errors << "followsMouse should be defined" unless TkManageFocus.respond_to?(:followsMouse)
    errors << "next should be defined" unless TkManageFocus.respond_to?(:next)
    errors << "prev should be defined" unless TkManageFocus.respond_to?(:prev)

    # Create widgets to traverse between
    f = TkFrame.new(root)
    f.pack
    b1 = TkButton.new(f, text: "One")
    b2 = TkButton.new(f, text: "Two")
    b3 = TkButton.new(f, text: "Three")
    b1.pack; b2.pack; b3.pack
    Tk.update

    # tk_focusNext should return a widget object
    nxt = TkManageFocus.next(b1)
    errors << "next(b1) should return a widget, got #{nxt.class}" unless nxt.respond_to?(:path)

    # tk_focusPrev should return a widget object
    prv = TkManageFocus.prev(b3)
    errors << "prev(b3) should return a widget, got #{prv.class}" unless prv.respond_to?(:path)

    # followsMouse should not raise
    TkManageFocus.followsMouse

    errors.empty? ? "OK" : errors.join("; ")
  end
end
