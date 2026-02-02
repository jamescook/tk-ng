# frozen_string_literal: true

# Auto-generated option accessor tests for TkMenu
# DO NOT EDIT - regenerate with: rake tk:generate_option_tests
#
# Tests that accessor methods (widget.option, widget.option=) properly
# delegate to cget/configure by round-tripping values through both APIs.
#
# Skipped option names: class, tearoffcommand, title

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestGeneratedMenuOptions < Minitest::Test
  include TkTestHelper

  def test_menu_accessors
    assert_tk_app("Menu accessor tests", method(:menu_accessors_app))
  end

  def menu_accessors_app
    require 'tk'
    require 'tk/menu'

    errors = []
    w = TkMenu.new(root)

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

    # :activeborderwidth (integer)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:activeborderwidth)
      w.activeborderwidth = original
      result = w.activeborderwidth
      unless result == original
        errors << ":activeborderwidth accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":activeborderwidth accessor missing: #{e.message}"
    rescue => e
      errors << ":activeborderwidth accessor raised: #{e.class}: #{e.message}"
    end

    # :activeforeground (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:activeforeground)
      w.activeforeground = original
      result = w.activeforeground
      unless result == original
        errors << ":activeforeground accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":activeforeground accessor missing: #{e.message}"
    rescue => e
      errors << ":activeforeground accessor raised: #{e.class}: #{e.message}"
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

    # :disabledforeground (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:disabledforeground)
      w.disabledforeground = original
      result = w.disabledforeground
      unless result == original
        errors << ":disabledforeground accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":disabledforeground accessor missing: #{e.message}"
    rescue => e
      errors << ":disabledforeground accessor raised: #{e.class}: #{e.message}"
    end

    # :font (font)
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

    # :foreground (string)
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

    # :postcommand (callback)
    begin
      # Callback: set a proc, verify getter works
      test_proc = proc { }
      w.postcommand = test_proc
      w.postcommand  # should not raise
    rescue NoMethodError => e
      errors << ":postcommand accessor missing: #{e.message}"
    rescue => e
      errors << ":postcommand accessor raised: #{e.class}: #{e.message}"
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

    # :selectcolor (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:selectcolor)
      w.selectcolor = original
      result = w.selectcolor
      unless result == original
        errors << ":selectcolor accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":selectcolor accessor missing: #{e.message}"
    rescue => e
      errors << ":selectcolor accessor raised: #{e.class}: #{e.message}"
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

    # :tearoff (boolean)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:tearoff)
      w.tearoff = original
      result = w.tearoff
      unless result == original
        errors << ":tearoff accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":tearoff accessor missing: #{e.message}"
    rescue => e
      errors << ":tearoff accessor raised: #{e.class}: #{e.message}"
    end

    # :type (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:type)
      w.type = original
      result = w.type
      unless result == original
        errors << ":type accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":type accessor missing: #{e.message}"
    rescue => e
      errors << ":type accessor raised: #{e.class}: #{e.message}"
    end

    w.destroy
    raise errors.join("\n") unless errors.empty?
  end
end
