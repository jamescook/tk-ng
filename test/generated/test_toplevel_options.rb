# frozen_string_literal: true

# Auto-generated option accessor tests for TkToplevel
# DO NOT EDIT - regenerate with: rake tk:generate_option_tests
#
# Tests that accessor methods (widget.option, widget.option=) properly
# delegate to cget/configure by round-tripping values through both APIs.
#
# Skipped option names: class

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestGeneratedToplevelOptions < Minitest::Test
  include TkTestHelper

  def test_toplevel_accessors
    assert_tk_app("Toplevel accessor tests", method(:toplevel_accessors_app))
  end

  def toplevel_accessors_app
    require 'tk'
    require 'tk/toplevel'

    errors = []
    w = TkToplevel.new(root)

    # :background (string)
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

    # :backgroundimage (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:backgroundimage)
      w.backgroundimage = original
      result = w.backgroundimage
      unless result == original
        errors << ":backgroundimage accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":backgroundimage accessor missing: #{e.message}"
    rescue => e
      errors << ":backgroundimage accessor raised: #{e.class}: #{e.message}"
    end

    # :borderwidth (integer)
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

    # :colormap (string)
    begin
      # Read-only after creation: verify getter works
      w.colormap  # should not raise
    rescue NoMethodError => e
      errors << ":colormap accessor missing: #{e.message}"
    rescue => e
      errors << ":colormap accessor raised: #{e.class}: #{e.message}"
    end

    # :container (boolean)
    begin
      # Read-only after creation: verify getter works
      w.container  # should not raise
    rescue NoMethodError => e
      errors << ":container accessor missing: #{e.message}"
    rescue => e
      errors << ":container accessor raised: #{e.class}: #{e.message}"
    end

    # :cursor (string)
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

    # :height (integer)
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

    # :highlightbackground (string)
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

    # :highlightcolor (string)
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

    # :highlightthickness (integer)
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

    # :menu (widget)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:menu)
      w.menu = original
      result = w.menu
      unless result == original
        errors << ":menu accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":menu accessor missing: #{e.message}"
    rescue => e
      errors << ":menu accessor raised: #{e.class}: #{e.message}"
    end

    # :padx (integer)
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

    # :pady (integer)
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

    # :relief (string)
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

    # :screen (string)
    begin
      # Read-only after creation: verify getter works
      w.screen  # should not raise
    rescue NoMethodError => e
      errors << ":screen accessor missing: #{e.message}"
    rescue => e
      errors << ":screen accessor raised: #{e.class}: #{e.message}"
    end

    # :takefocus (string)
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

    # :tile (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:tile)
      w.tile = original
      result = w.tile
      unless result == original
        errors << ":tile accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":tile accessor missing: #{e.message}"
    rescue => e
      errors << ":tile accessor raised: #{e.class}: #{e.message}"
    end

    # :use (string)
    begin
      # Read-only after creation: verify getter works
      w.use  # should not raise
    rescue NoMethodError => e
      errors << ":use accessor missing: #{e.message}"
    rescue => e
      errors << ":use accessor raised: #{e.class}: #{e.message}"
    end

    # :visual (string)
    begin
      # Read-only after creation: verify getter works
      w.visual  # should not raise
    rescue NoMethodError => e
      errors << ":visual accessor missing: #{e.message}"
    rescue => e
      errors << ":visual accessor raised: #{e.class}: #{e.message}"
    end

    # :width (integer)
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

    w.destroy
    raise errors.join("\n") unless errors.empty?
  end
end
