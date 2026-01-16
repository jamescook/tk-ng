# frozen_string_literal: true

# Test for Tk::Tile::TLabel (ttk::label) widget
# This tests tkextlib coverage

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestTileLabelWidget < Minitest::Test
  include TkTestHelper

  def test_tile_label_basic
    assert_tk_app("Tile Label basic test", method(:tile_label_app))
  end

  def tile_label_app
    require 'tk'
    require 'tkextlib/tile/tlabel'

    errors = []

    # Basic creation
    lbl = Tk::Tile::TLabel.new(root, text: "Tile Label")
    errors << "text not set" unless lbl.cget(:text) == "Tile Label"

    # Style option (tile-specific)
    lbl_styled = Tk::Tile::TLabel.new(root, text: "Styled")
    # Just verify it doesn't error - style may be empty string by default
    lbl_styled.cget(:style)

    # Dynamic configure
    lbl.configure(text: "Updated")
    errors << "configure failed" unless lbl.cget(:text) == "Updated"

    unless errors.empty?
      raise "Tile Label test failures:\n  " + errors.join("\n  ")
    end
  end
end
