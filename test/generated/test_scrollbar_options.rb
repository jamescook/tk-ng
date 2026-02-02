# frozen_string_literal: true

# Auto-generated option accessor tests for TkScrollbar
# DO NOT EDIT - regenerate with: rake tk:generate_option_tests
#
# Tests that accessor methods (widget.option, widget.option=) properly
# delegate to cget/configure by round-tripping values through both APIs.
#
# Skipped option names: class

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestGeneratedScrollbarOptions < Minitest::Test
  include TkTestHelper

  def test_scrollbar_accessors
    assert_tk_app("Scrollbar accessor tests", method(:scrollbar_accessors_app))
  end

  def scrollbar_accessors_app
    require 'tk'
    require 'tk/scrollbar'

    errors = []
    w = TkScrollbar.new(root)

    # :activebackground (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:activebackground)
      w.activebackground = original
      result = w.activebackground
      unless result == original
        errors << ":activebackground accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":activebackground accessor missing: #{e.message}"
    rescue => e
      errors << ":activebackground accessor raised: #{e.class}: #{e.message}"
    end

    # :activerelief (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:activerelief)
      w.activerelief = original
      result = w.activerelief
      unless result == original
        errors << ":activerelief accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":activerelief accessor missing: #{e.message}"
    rescue => e
      errors << ":activerelief accessor raised: #{e.class}: #{e.message}"
    end

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

    # :bd (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:bd)
      w.bd = original
      result = w.bd
      unless result == original
        errors << ":bd accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":bd accessor missing: #{e.message}"
    rescue => e
      errors << ":bd accessor raised: #{e.class}: #{e.message}"
    end

    # :bg (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:bg)
      w.bg = original
      result = w.bg
      unless result == original
        errors << ":bg accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":bg accessor missing: #{e.message}"
    rescue => e
      errors << ":bg accessor raised: #{e.class}: #{e.message}"
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

    # :command (callback)
    begin
      # Callback: set a proc, verify getter works
      test_proc = proc { }
      w.command = test_proc
      w.command  # should not raise
    rescue NoMethodError => e
      errors << ":command accessor missing: #{e.message}"
    rescue => e
      errors << ":command accessor raised: #{e.class}: #{e.message}"
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

    # :elementborderwidth (integer)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:elementborderwidth)
      w.elementborderwidth = original
      result = w.elementborderwidth
      unless result == original
        errors << ":elementborderwidth accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":elementborderwidth accessor missing: #{e.message}"
    rescue => e
      errors << ":elementborderwidth accessor raised: #{e.class}: #{e.message}"
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

    # :jump (boolean)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:jump)
      w.jump = original
      result = w.jump
      unless result == original
        errors << ":jump accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":jump accessor missing: #{e.message}"
    rescue => e
      errors << ":jump accessor raised: #{e.class}: #{e.message}"
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

    # :repeatdelay (integer)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:repeatdelay)
      w.repeatdelay = original
      result = w.repeatdelay
      unless result == original
        errors << ":repeatdelay accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":repeatdelay accessor missing: #{e.message}"
    rescue => e
      errors << ":repeatdelay accessor raised: #{e.class}: #{e.message}"
    end

    # :repeatinterval (integer)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:repeatinterval)
      w.repeatinterval = original
      result = w.repeatinterval
      unless result == original
        errors << ":repeatinterval accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":repeatinterval accessor missing: #{e.message}"
    rescue => e
      errors << ":repeatinterval accessor raised: #{e.class}: #{e.message}"
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

    # :troughcolor (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:troughcolor)
      w.troughcolor = original
      result = w.troughcolor
      unless result == original
        errors << ":troughcolor accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":troughcolor accessor missing: #{e.message}"
    rescue => e
      errors << ":troughcolor accessor raised: #{e.class}: #{e.message}"
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
