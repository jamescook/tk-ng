# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestUtilC < Minitest::Test
  include TkTestHelper

  def test_user_inactive_time_basic
    assert_tk_app("TclTkIp#user_inactive_time basic", method(:user_inactive_time_app))
  end

  def user_inactive_time_app
    require 'tk'

    interp = Tk::INTERP

    # Get inactive time
    time1 = interp.user_inactive_time

    # Should return an integer
    raise "Expected Integer, got #{time1.class}" unless time1.is_a?(Integer)

    # Should be >= -1 (-1 means unsupported)
    raise "Expected >= -1, got #{time1}" unless time1 >= -1

    # On most systems, should be a valid positive value
    # Only fail if consistently getting -1 and we expected support
    if time1 == -1
      # Display may not support inactive time queries - that's OK
      return
    end

    # Small delay and check again - time should have increased
    sleep 0.1
    time2 = interp.user_inactive_time

    # Time should have advanced (with some tolerance for system jitter)
    raise "Expected time to advance: #{time1} -> #{time2}" unless time2 >= time1
  end

  def test_get_root_coords_basic
    assert_tk_app("TclTkIp#get_root_coords basic", method(:get_root_coords_app))
  end

  def get_root_coords_app
    require 'tk'

    interp = Tk::INTERP

    # Query root window coordinates
    coords = interp.get_root_coords(".")
    raise "Expected array, got #{coords.class}" unless coords.is_a?(Array)
    raise "Expected 2 elements, got #{coords.size}" unless coords.size == 2

    x, y = coords
    raise "Expected integer x, got #{x.class}" unless x.is_a?(Integer)
    raise "Expected integer y, got #{y.class}" unless y.is_a?(Integer)

    # Coordinates should be reasonable (on screen)
    # Could be 0,0 or could be window manager positioned
    raise "x coordinate out of range: #{x}" unless x >= -10000 && x <= 10000
    raise "y coordinate out of range: #{y}" unless y >= -10000 && y <= 10000
  end

  def test_coords_to_window_basic
    assert_tk_app("TclTkIp#coords_to_window basic", method(:coords_to_window_app))
  end

  def coords_to_window_app
    require 'tk'

    interp = Tk::INTERP

    # Get root window coordinates
    coords = interp.get_root_coords(".")
    x, y = coords

    # Query what window is at those coordinates + small offset into the window
    # Adding offset to avoid window border/decorations
    result = interp.coords_to_window(x + 10, y + 10)

    # Result should be a string (window path) or nil
    raise "Expected String or nil, got #{result.class}" unless result.nil? || result.is_a?(String)

    # If we found a window, it should start with "."
    if result
      raise "Expected window path starting with '.', got #{result}" unless result.start_with?(".")
    end

    # Query coordinates way off screen - should return nil
    offscreen = interp.coords_to_window(-99999, -99999)
    raise "Expected nil for off-screen coords, got #{offscreen.inspect}" unless offscreen.nil?
  end
end
