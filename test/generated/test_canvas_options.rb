# frozen_string_literal: true

# Auto-generated option accessor tests for TkCanvas
# DO NOT EDIT - regenerate with: rake tk:generate_option_tests
#
# Tests that accessor methods (widget.option, widget.option=) properly
# delegate to cget/configure by round-tripping values through both APIs.
#
# Skipped option names: class

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestGeneratedCanvasOptions < Minitest::Test
  include TkTestHelper

  def test_canvas_accessors
    assert_tk_app("Canvas accessor tests", method(:canvas_accessors_app))
  end

  def canvas_accessors_app
    require 'tk'
    require 'tk/canvas'

    errors = []
    w = TkCanvas.new(root)

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

    # :closeenough (float)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:closeenough)
      w.closeenough = original
      result = w.closeenough
      unless result == original
        errors << ":closeenough accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":closeenough accessor missing: #{e.message}"
    rescue => e
      errors << ":closeenough accessor raised: #{e.class}: #{e.message}"
    end

    # :confine (boolean)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:confine)
      w.confine = original
      result = w.confine
      unless result == original
        errors << ":confine accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":confine accessor missing: #{e.message}"
    rescue => e
      errors << ":confine accessor raised: #{e.class}: #{e.message}"
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

    # :insertbackground (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:insertbackground)
      w.insertbackground = original
      result = w.insertbackground
      unless result == original
        errors << ":insertbackground accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":insertbackground accessor missing: #{e.message}"
    rescue => e
      errors << ":insertbackground accessor raised: #{e.class}: #{e.message}"
    end

    # :insertborderwidth (integer)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:insertborderwidth)
      w.insertborderwidth = original
      result = w.insertborderwidth
      unless result == original
        errors << ":insertborderwidth accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":insertborderwidth accessor missing: #{e.message}"
    rescue => e
      errors << ":insertborderwidth accessor raised: #{e.class}: #{e.message}"
    end

    # :insertofftime (integer)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:insertofftime)
      w.insertofftime = original
      result = w.insertofftime
      unless result == original
        errors << ":insertofftime accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":insertofftime accessor missing: #{e.message}"
    rescue => e
      errors << ":insertofftime accessor raised: #{e.class}: #{e.message}"
    end

    # :insertontime (integer)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:insertontime)
      w.insertontime = original
      result = w.insertontime
      unless result == original
        errors << ":insertontime accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":insertontime accessor missing: #{e.message}"
    rescue => e
      errors << ":insertontime accessor raised: #{e.class}: #{e.message}"
    end

    # :insertwidth (integer)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:insertwidth)
      w.insertwidth = original
      result = w.insertwidth
      unless result == original
        errors << ":insertwidth accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":insertwidth accessor missing: #{e.message}"
    rescue => e
      errors << ":insertwidth accessor raised: #{e.class}: #{e.message}"
    end

    # :offset (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:offset)
      w.offset = original
      result = w.offset
      unless result == original
        errors << ":offset accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":offset accessor missing: #{e.message}"
    rescue => e
      errors << ":offset accessor raised: #{e.class}: #{e.message}"
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

    # :scrollregion (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:scrollregion)
      w.scrollregion = original
      result = w.scrollregion
      unless result == original
        errors << ":scrollregion accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":scrollregion accessor missing: #{e.message}"
    rescue => e
      errors << ":scrollregion accessor raised: #{e.class}: #{e.message}"
    end

    # :selectbackground (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:selectbackground)
      w.selectbackground = original
      result = w.selectbackground
      unless result == original
        errors << ":selectbackground accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":selectbackground accessor missing: #{e.message}"
    rescue => e
      errors << ":selectbackground accessor raised: #{e.class}: #{e.message}"
    end

    # :selectborderwidth (integer)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:selectborderwidth)
      w.selectborderwidth = original
      result = w.selectborderwidth
      unless result == original
        errors << ":selectborderwidth accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":selectborderwidth accessor missing: #{e.message}"
    rescue => e
      errors << ":selectborderwidth accessor raised: #{e.class}: #{e.message}"
    end

    # :selectforeground (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:selectforeground)
      w.selectforeground = original
      result = w.selectforeground
      unless result == original
        errors << ":selectforeground accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":selectforeground accessor missing: #{e.message}"
    rescue => e
      errors << ":selectforeground accessor raised: #{e.class}: #{e.message}"
    end

    # :state (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:state)
      w.state = original
      result = w.state
      unless result == original
        errors << ":state accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":state accessor missing: #{e.message}"
    rescue => e
      errors << ":state accessor raised: #{e.class}: #{e.message}"
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

    # :xscrollcommand (callback)
    begin
      # Callback: set a proc, verify getter works
      test_proc = proc { }
      w.xscrollcommand = test_proc
      w.xscrollcommand  # should not raise
    rescue NoMethodError => e
      errors << ":xscrollcommand accessor missing: #{e.message}"
    rescue => e
      errors << ":xscrollcommand accessor raised: #{e.class}: #{e.message}"
    end

    # :xscrollincrement (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:xscrollincrement)
      w.xscrollincrement = original
      result = w.xscrollincrement
      unless result == original
        errors << ":xscrollincrement accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":xscrollincrement accessor missing: #{e.message}"
    rescue => e
      errors << ":xscrollincrement accessor raised: #{e.class}: #{e.message}"
    end

    # :yscrollcommand (callback)
    begin
      # Callback: set a proc, verify getter works
      test_proc = proc { }
      w.yscrollcommand = test_proc
      w.yscrollcommand  # should not raise
    rescue NoMethodError => e
      errors << ":yscrollcommand accessor missing: #{e.message}"
    rescue => e
      errors << ":yscrollcommand accessor raised: #{e.class}: #{e.message}"
    end

    # :yscrollincrement (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:yscrollincrement)
      w.yscrollincrement = original
      result = w.yscrollincrement
      unless result == original
        errors << ":yscrollincrement accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":yscrollincrement accessor missing: #{e.message}"
    rescue => e
      errors << ":yscrollincrement accessor raised: #{e.class}: #{e.message}"
    end

    w.destroy
    raise errors.join("\n") unless errors.empty?
  end
end
