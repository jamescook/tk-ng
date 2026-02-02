# frozen_string_literal: true

# Auto-generated option accessor tests for TkEntry
# DO NOT EDIT - regenerate with: rake tk:generate_option_tests
#
# Tests that accessor methods (widget.option, widget.option=) properly
# delegate to cget/configure by round-tripping values through both APIs.
#
# Skipped option names: class, cursor, validate

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestGeneratedEntryOptions < Minitest::Test
  include TkTestHelper

  def test_entry_accessors
    assert_tk_app("Entry accessor tests", method(:entry_accessors_app))
  end

  def entry_accessors_app
    require 'tk'
    require 'tk/entry'

    errors = []
    w = TkEntry.new(root)

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

    # :disabledbackground (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:disabledbackground)
      w.disabledbackground = original
      result = w.disabledbackground
      unless result == original
        errors << ":disabledbackground accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":disabledbackground accessor missing: #{e.message}"
    rescue => e
      errors << ":disabledbackground accessor raised: #{e.class}: #{e.message}"
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

    # :exportselection (boolean)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:exportselection)
      w.exportselection = original
      result = w.exportselection
      unless result == original
        errors << ":exportselection accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":exportselection accessor missing: #{e.message}"
    rescue => e
      errors << ":exportselection accessor raised: #{e.class}: #{e.message}"
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

    # :invalidcommand (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:invalidcommand)
      w.invalidcommand = original
      result = w.invalidcommand
      unless result == original
        errors << ":invalidcommand accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":invalidcommand accessor missing: #{e.message}"
    rescue => e
      errors << ":invalidcommand accessor raised: #{e.class}: #{e.message}"
    end

    # :justify (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:justify)
      w.justify = original
      result = w.justify
      unless result == original
        errors << ":justify accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":justify accessor missing: #{e.message}"
    rescue => e
      errors << ":justify accessor raised: #{e.class}: #{e.message}"
    end

    # :placeholder (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:placeholder)
      w.placeholder = original
      result = w.placeholder
      unless result == original
        errors << ":placeholder accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":placeholder accessor missing: #{e.message}"
    rescue => e
      errors << ":placeholder accessor raised: #{e.class}: #{e.message}"
    end

    # :placeholderforeground (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:placeholderforeground)
      w.placeholderforeground = original
      result = w.placeholderforeground
      unless result == original
        errors << ":placeholderforeground accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":placeholderforeground accessor missing: #{e.message}"
    rescue => e
      errors << ":placeholderforeground accessor raised: #{e.class}: #{e.message}"
    end

    # :readonlybackground (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:readonlybackground)
      w.readonlybackground = original
      result = w.readonlybackground
      unless result == original
        errors << ":readonlybackground accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":readonlybackground accessor missing: #{e.message}"
    rescue => e
      errors << ":readonlybackground accessor raised: #{e.class}: #{e.message}"
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

    # :show (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:show)
      w.show = original
      result = w.show
      unless result == original
        errors << ":show accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":show accessor missing: #{e.message}"
    rescue => e
      errors << ":show accessor raised: #{e.class}: #{e.message}"
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

    # :textvariable (tkvariable)
    begin
      # TkVariable: set a variable, verify getter works
      test_var = TkVariable.new
      w.textvariable = test_var
      w.textvariable  # should not raise
    rescue NoMethodError => e
      errors << ":textvariable accessor missing: #{e.message}"
    rescue => e
      errors << ":textvariable accessor raised: #{e.class}: #{e.message}"
    end

    # :validatecommand (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:validatecommand)
      w.validatecommand = original
      result = w.validatecommand
      unless result == original
        errors << ":validatecommand accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":validatecommand accessor missing: #{e.message}"
    rescue => e
      errors << ":validatecommand accessor raised: #{e.class}: #{e.message}"
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

    w.destroy
    raise errors.join("\n") unless errors.empty?
  end
end
