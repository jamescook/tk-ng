# frozen_string_literal: true

# Tests for TkFont compatibility shim

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestTkFont < Minitest::Test
  include TkTestHelper

  def test_font_new_with_string
    assert_tk_app("TkFont.new with string", method(:app_font_new_string))
  end

  def app_font_new_string
    require 'tk'

    font = TkFont.new('Helvetica 12 bold')

    raise "to_s failed" unless font.to_s == 'Helvetica 12 bold'
    raise "to_str failed" unless font.to_str == 'Helvetica 12 bold'
  end

  def test_font_new_with_hash
    assert_tk_app("TkFont.new with hash options", method(:app_font_new_hash))
  end

  def app_font_new_hash
    require 'tk'

    font = TkFont.new(family: 'Helvetica', size: 14, weight: 'bold')

    raise "font string incorrect: #{font.to_s}" unless font.to_s == 'Helvetica 14 bold'
  end

  def test_font_families
    assert_tk_app("TkFont.families", method(:app_font_families))
  end

  def app_font_families
    require 'tk'

    families = TkFont.families

    raise "families should return array" unless families.is_a?(Array)
    raise "families should not be empty" if families.empty?
  end

  def test_font_measure
    assert_tk_app("TkFont.measure", method(:app_font_measure))
  end

  def app_font_measure
    require 'tk'

    width = TkFont.measure('Helvetica 12', 'Hello World')

    raise "measure should return integer" unless width.is_a?(Integer)
    raise "measure should be positive" unless width > 0
  end

  def test_font_used_in_widget
    assert_tk_app("TkFont used in widget configure", method(:app_font_in_widget))
  end

  def app_font_in_widget
    require 'tk'

    font = TkFont.new('Courier 10')
    label = TkLabel.new(root, text: 'Test', font: font)

    # Should work - TkFont has to_str so it converts to string
    configured_font = label.cget(:font)
    raise "font not configured" if configured_font.nil? || configured_font.to_s.empty?
  end
end
