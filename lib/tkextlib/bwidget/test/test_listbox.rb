# frozen_string_literal: true

# Test for Tk::BWidget::ListBox widget options.

require_relative '../../../../test/test_helper'
require_relative '../../../../test/tk_test_helper'

class TestBWidgetListBox < Minitest::Test
  include TkTestHelper

  def test_listbox_comprehensive
    assert_tk_app("BWidget ListBox test", method(:listbox_app))
  end

  def listbox_app
    require 'tk'
    require 'tkextlib/bwidget'

    errors = []

    # --- Basic listbox ---
    lb = Tk::BWidget::ListBox.new(root)
    lb.pack(fill: "both", expand: true, padx: 10, pady: 10)

    # --- Insert items ---
    lb.insert("end", "item1", text: "Item 1")
    lb.insert("end", "item2", text: "Item 2")
    lb.insert("end", "item3", text: "Item 3")

    # --- selectmode ---
    lb.configure(selectmode: "single")
    errors << "selectmode single failed" unless lb.cget(:selectmode) == "single"

    lb.configure(selectmode: "multiple")
    errors << "selectmode multiple failed" unless lb.cget(:selectmode) == "multiple"

    # --- background ---
    lb.configure(background: "white")
    errors << "background failed" if lb.cget(:background).to_s.empty?

    # --- height ---
    lb.configure(height: 10)
    errors << "height failed" unless lb.cget(:height).to_i == 10

    # --- Delete items ---
    lb.delete("item2")

    raise "BWidget ListBox test failures:\n  " + errors.join("\n  ") unless errors.empty?
  end
end
