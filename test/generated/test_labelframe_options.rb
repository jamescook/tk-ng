# frozen_string_literal: true

# Auto-generated option accessor tests for TkLabelframe
# DO NOT EDIT - regenerate with: rake tk:generate_option_tests
#
# Tests that accessor methods (widget.option, widget.option=) properly
# delegate to cget/configure by round-tripping values through both APIs.
#
# Skipped option names: class

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestGeneratedLabelframeOptions < Minitest::Test
  include TkTestHelper

  def test_labelframe_accessors
    assert_tk_app("Labelframe accessor tests", method(:labelframe_accessors_app))
  end

  def labelframe_accessors_app
    require 'tk'
    require 'tk/option_test_support'
    require 'tk/labelframe'

    errors = []
    w = TkLabelframe.new(root)

    # :background (string)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'background')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:background)
      w.background = original
      result = w.background
      unless result == original
        errors << ":background accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":background accessor missing: #{e.message}"
    rescue => e
      errors << ":background accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :borderwidth (integer)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'borderwidth')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:borderwidth)
      w.borderwidth = original
      result = w.borderwidth
      unless result == original
        errors << ":borderwidth accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":borderwidth accessor missing: #{e.message}"
    rescue => e
      errors << ":borderwidth accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :colormap (string)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'colormap')
    begin
      # Read-only after creation: verify getter works
      w.colormap  # should not raise
    rescue NoMethodError => e
      errors << ":colormap accessor missing: #{e.message}"
    rescue => e
      errors << ":colormap accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :container (boolean)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'container')
    begin
      # Read-only after creation: verify getter works
      w.container  # should not raise
    rescue NoMethodError => e
      errors << ":container accessor missing: #{e.message}"
    rescue => e
      errors << ":container accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :cursor (string)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'cursor')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:cursor)
      w.cursor = original
      result = w.cursor
      unless result == original
        errors << ":cursor accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":cursor accessor missing: #{e.message}"
    rescue => e
      errors << ":cursor accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :font (font)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'font')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:font)
      w.font = original
      result = w.font
      unless result == original
        errors << ":font accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":font accessor missing: #{e.message}"
    rescue => e
      errors << ":font accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :foreground (string)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'foreground')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:foreground)
      w.foreground = original
      result = w.foreground
      unless result == original
        errors << ":foreground accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":foreground accessor missing: #{e.message}"
    rescue => e
      errors << ":foreground accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :height (integer)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'height')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:height)
      w.height = original
      result = w.height
      unless result == original
        errors << ":height accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":height accessor missing: #{e.message}"
    rescue => e
      errors << ":height accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :highlightbackground (string)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'highlightbackground')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:highlightbackground)
      w.highlightbackground = original
      result = w.highlightbackground
      unless result == original
        errors << ":highlightbackground accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":highlightbackground accessor missing: #{e.message}"
    rescue => e
      errors << ":highlightbackground accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :highlightcolor (string)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'highlightcolor')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:highlightcolor)
      w.highlightcolor = original
      result = w.highlightcolor
      unless result == original
        errors << ":highlightcolor accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":highlightcolor accessor missing: #{e.message}"
    rescue => e
      errors << ":highlightcolor accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :highlightthickness (integer)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'highlightthickness')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:highlightthickness)
      w.highlightthickness = original
      result = w.highlightthickness
      unless result == original
        errors << ":highlightthickness accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":highlightthickness accessor missing: #{e.message}"
    rescue => e
      errors << ":highlightthickness accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :labelanchor (string)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'labelanchor')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:labelanchor)
      w.labelanchor = original
      result = w.labelanchor
      unless result == original
        errors << ":labelanchor accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":labelanchor accessor missing: #{e.message}"
    rescue => e
      errors << ":labelanchor accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :labelwidget (widget)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'labelwidget')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:labelwidget)
      w.labelwidget = original
      result = w.labelwidget
      unless result == original
        errors << ":labelwidget accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":labelwidget accessor missing: #{e.message}"
    rescue => e
      errors << ":labelwidget accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :padx (integer)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'padx')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:padx)
      w.padx = original
      result = w.padx
      unless result == original
        errors << ":padx accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":padx accessor missing: #{e.message}"
    rescue => e
      errors << ":padx accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :pady (integer)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'pady')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:pady)
      w.pady = original
      result = w.pady
      unless result == original
        errors << ":pady accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":pady accessor missing: #{e.message}"
    rescue => e
      errors << ":pady accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :relief (string)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'relief')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:relief)
      w.relief = original
      result = w.relief
      unless result == original
        errors << ":relief accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":relief accessor missing: #{e.message}"
    rescue => e
      errors << ":relief accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :takefocus (string)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'takefocus')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:takefocus)
      w.takefocus = original
      result = w.takefocus
      unless result == original
        errors << ":takefocus accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":takefocus accessor missing: #{e.message}"
    rescue => e
      errors << ":takefocus accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :text (string)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'text')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:text)
      w.text = original
      result = w.text
      unless result == original
        errors << ":text accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":text accessor missing: #{e.message}"
    rescue => e
      errors << ":text accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :visual (string)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'visual')
    begin
      # Read-only after creation: verify getter works
      w.visual  # should not raise
    rescue NoMethodError => e
      errors << ":visual accessor missing: #{e.message}"
    rescue => e
      errors << ":visual accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :width (integer)
    if Tk::OptionTestSupport.option_testable?('labelframe', 'width')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:width)
      w.width = original
      result = w.width
      unless result == original
        errors << ":width accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":width accessor missing: #{e.message}"
    rescue => e
      errors << ":width accessor raised: #{e.class}: #{e.message}"
    end
    end

    w.destroy
    raise errors.join("\n") unless errors.empty?
  end
end
