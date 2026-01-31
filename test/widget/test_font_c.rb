# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestFontC < Minitest::Test
  include TkTestHelper

  def test_text_width_basic
    assert_tk_app("TclTkIp#text_width basic", method(:text_width_basic_app))
  end

  def text_width_basic_app
    require 'tk'

    interp = Tk::INTERP

    # Measure some text with default font
    width = interp.text_width("TkDefaultFont", "Hello World")
    raise "Expected positive width, got #{width}" unless width > 0

    # Longer text should be wider
    width1 = interp.text_width("TkDefaultFont", "A")
    width2 = interp.text_width("TkDefaultFont", "AAAA")
    raise "Expected 4x A (#{width2}) to be wider than 1x A (#{width1})" unless width2 > width1

    # Empty string should have zero width
    width_empty = interp.text_width("TkDefaultFont", "")
    raise "Expected zero width for empty string, got #{width_empty}" unless width_empty == 0
  end

  def test_text_width_fonts
    assert_tk_app("TclTkIp#text_width with different fonts", method(:text_width_fonts_app))
  end

  def text_width_fonts_app
    require 'tk'

    interp = Tk::INTERP
    text = "Test String"

    # Various font specifications should work
    fonts = [
      "TkDefaultFont",
      "TkFixedFont",
      "Helvetica 12",
      "{Courier} 10"
    ]

    fonts.each do |font|
      width = interp.text_width(font, text)
      raise "Font '#{font}' returned non-positive width: #{width}" unless width > 0
    end
  end

  def test_font_metrics_basic
    assert_tk_app("TclTkIp#font_metrics basic", method(:font_metrics_basic_app))
  end

  def font_metrics_basic_app
    require 'tk'

    interp = Tk::INTERP

    metrics = interp.font_metrics("TkDefaultFont")
    raise "Expected hash result" unless metrics.is_a?(Hash)

    [:ascent, :descent, :linespace].each do |key|
      raise "Missing key: #{key}" unless metrics.key?(key)
      raise "#{key} should be positive" unless metrics[key] > 0
    end

    # Linespace should equal ascent + descent
    expected_linespace = metrics[:ascent] + metrics[:descent]
    raise "linespace (#{metrics[:linespace]}) != ascent+descent (#{expected_linespace})" unless metrics[:linespace] == expected_linespace
  end

  def test_font_metrics_different_sizes
    assert_tk_app("TclTkIp#font_metrics with different sizes", method(:font_metrics_sizes_app))
  end

  def font_metrics_sizes_app
    require 'tk'

    interp = Tk::INTERP

    # Larger fonts should have larger metrics
    small = interp.font_metrics("Helvetica 8")
    large = interp.font_metrics("Helvetica 24")

    raise "Large font ascent should be > small font ascent" unless large[:ascent] > small[:ascent]
    raise "Large font linespace should be > small font linespace" unless large[:linespace] > small[:linespace]
  end

  def test_measure_chars_basic
    assert_tk_app("TclTkIp#measure_chars basic", method(:measure_chars_basic_app))
  end

  def measure_chars_basic_app
    require 'tk'

    interp = Tk::INTERP
    text = "Hello World Test"

    # Measure full text with unlimited width
    result = interp.measure_chars("TkDefaultFont", text, -1)
    raise "Expected hash result" unless result.is_a?(Hash)
    raise "Missing :bytes key" unless result.key?(:bytes)
    raise "Missing :width key" unless result.key?(:width)

    # With unlimited width, should fit all bytes
    raise "Expected all bytes to fit" unless result[:bytes] == text.bytesize
    raise "Expected positive width" unless result[:width] > 0

    # Measure with limited width - should fit fewer characters
    full_width = result[:width]
    half_width = full_width / 2

    limited = interp.measure_chars("TkDefaultFont", text, half_width)
    raise "Expected fewer bytes with limited width" unless limited[:bytes] < text.bytesize
    raise "Expected width <= max_pixels" unless limited[:width] <= half_width
  end

  def test_measure_chars_options
    assert_tk_app("TclTkIp#measure_chars options", method(:measure_chars_options_app))
  end

  def measure_chars_options_app
    require 'tk'

    interp = Tk::INTERP
    text = "Hello World"

    # Test at_least_one option - even with 0 pixels, should return at least 1 char
    result = interp.measure_chars("TkDefaultFont", text, 1, at_least_one: true)
    raise "Expected at least 1 byte with at_least_one: true" unless result[:bytes] >= 1
  end
end
