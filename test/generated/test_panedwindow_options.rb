# frozen_string_literal: true

# Auto-generated option accessor tests for TkPanedwindow
# DO NOT EDIT - regenerate with: rake tk:generate_option_tests
#
# Tests that accessor methods (widget.option, widget.option=) properly
# delegate to cget/configure by round-tripping values through both APIs.
#
# Skipped option names: class

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestGeneratedPanedwindowOptions < Minitest::Test
  include TkTestHelper

  def test_panedwindow_accessors
    assert_tk_app("Panedwindow accessor tests", method(:panedwindow_accessors_app))
  end

  def panedwindow_accessors_app
    require 'tk'
    require 'tk/panedwindow'

    errors = []
    w = TkPanedwindow.new(root)

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

    # :handlepad (integer)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:handlepad)
      w.handlepad = original
      result = w.handlepad
      unless result == original
        errors << ":handlepad accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":handlepad accessor missing: #{e.message}"
    rescue => e
      errors << ":handlepad accessor raised: #{e.class}: #{e.message}"
    end

    # :handlesize (integer)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:handlesize)
      w.handlesize = original
      result = w.handlesize
      unless result == original
        errors << ":handlesize accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":handlesize accessor missing: #{e.message}"
    rescue => e
      errors << ":handlesize accessor raised: #{e.class}: #{e.message}"
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

    # :opaqueresize (boolean)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:opaqueresize)
      w.opaqueresize = original
      result = w.opaqueresize
      unless result == original
        errors << ":opaqueresize accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":opaqueresize accessor missing: #{e.message}"
    rescue => e
      errors << ":opaqueresize accessor raised: #{e.class}: #{e.message}"
    end

    # :orient (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:orient)
      w.orient = original
      result = w.orient
      unless result == original
        errors << ":orient accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":orient accessor missing: #{e.message}"
    rescue => e
      errors << ":orient accessor raised: #{e.class}: #{e.message}"
    end

    # :proxybackground (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:proxybackground)
      w.proxybackground = original
      result = w.proxybackground
      unless result == original
        errors << ":proxybackground accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":proxybackground accessor missing: #{e.message}"
    rescue => e
      errors << ":proxybackground accessor raised: #{e.class}: #{e.message}"
    end

    # :proxyborderwidth (integer)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:proxyborderwidth)
      w.proxyborderwidth = original
      result = w.proxyborderwidth
      unless result == original
        errors << ":proxyborderwidth accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":proxyborderwidth accessor missing: #{e.message}"
    rescue => e
      errors << ":proxyborderwidth accessor raised: #{e.class}: #{e.message}"
    end

    # :proxyrelief (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:proxyrelief)
      w.proxyrelief = original
      result = w.proxyrelief
      unless result == original
        errors << ":proxyrelief accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":proxyrelief accessor missing: #{e.message}"
    rescue => e
      errors << ":proxyrelief accessor raised: #{e.class}: #{e.message}"
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

    # :sashcursor (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:sashcursor)
      w.sashcursor = original
      result = w.sashcursor
      unless result == original
        errors << ":sashcursor accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":sashcursor accessor missing: #{e.message}"
    rescue => e
      errors << ":sashcursor accessor raised: #{e.class}: #{e.message}"
    end

    # :sashpad (integer)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:sashpad)
      w.sashpad = original
      result = w.sashpad
      unless result == original
        errors << ":sashpad accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":sashpad accessor missing: #{e.message}"
    rescue => e
      errors << ":sashpad accessor raised: #{e.class}: #{e.message}"
    end

    # :sashrelief (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:sashrelief)
      w.sashrelief = original
      result = w.sashrelief
      unless result == original
        errors << ":sashrelief accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":sashrelief accessor missing: #{e.message}"
    rescue => e
      errors << ":sashrelief accessor raised: #{e.class}: #{e.message}"
    end

    # :sashwidth (integer)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:sashwidth)
      w.sashwidth = original
      result = w.sashwidth
      unless result == original
        errors << ":sashwidth accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":sashwidth accessor missing: #{e.message}"
    rescue => e
      errors << ":sashwidth accessor raised: #{e.class}: #{e.message}"
    end

    # :showhandle (boolean)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:showhandle)
      w.showhandle = original
      result = w.showhandle
      unless result == original
        errors << ":showhandle accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":showhandle accessor missing: #{e.message}"
    rescue => e
      errors << ":showhandle accessor raised: #{e.class}: #{e.message}"
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
