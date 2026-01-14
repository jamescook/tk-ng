# frozen_string_literal: true

# Test for Tk::BWidget::Dialog widget options.

require_relative '../../../../test/test_helper'
require_relative '../../../../test/tk_test_helper'

class TestBWidgetDialog < Minitest::Test
  include TkTestHelper

  def test_dialog_comprehensive
    assert_tk_app("BWidget Dialog test", method(:dialog_app))
  end

  def dialog_app
    require 'tk'
    require 'tkextlib/bwidget'

    errors = []

    # --- Create dialog (not shown) ---
    dlg = Tk::BWidget::Dialog.new(root, title: "Test Dialog")

    errors << "title failed" unless dlg.cget(:title) == "Test Dialog"

    # --- Configure options ---
    dlg.configure(modal: "none")
    errors << "modal failed" unless dlg.cget(:modal) == "none"

    # --- Add button ---
    dlg.add(text: "OK")

    # --- Get frame for content ---
    frame = dlg.get_frame
    errors << "get_frame failed" if frame.nil?

    # --- Add content ---
    TkLabel.new(frame, text: "Dialog content").pack

    # --- withdraw (don't show during test) ---
    dlg.withdraw

    raise "BWidget Dialog test failures:\n  " + errors.join("\n  ") unless errors.empty?
  end
end
