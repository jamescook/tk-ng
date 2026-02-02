# frozen_string_literal: true

# Auto-generated option accessor tests for TkMenubutton
# DO NOT EDIT - regenerate with: rake tk:generate_option_tests
#
# Tests that accessor methods (widget.option, widget.option=) properly
# delegate to cget/configure by round-tripping values through both APIs.
#
# Skipped option names: class

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestGeneratedMenubuttonOptions < Minitest::Test
  include TkTestHelper

  def test_menubutton_accessors
    assert_tk_app("Menubutton accessor tests", method(:menubutton_accessors_app))
  end

  def menubutton_accessors_app
    require 'tk'
    require 'tk/menu'

    errors = []
    w = TkMenubutton.new(root)

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

    # :anchor (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:anchor)
      w.anchor = original
      result = w.anchor
      unless result == original
        errors << ":anchor accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":anchor accessor missing: #{e.message}"
    rescue => e
      errors << ":anchor accessor raised: #{e.class}: #{e.message}"
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

    # :bitmap (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:bitmap)
      w.bitmap = original
      result = w.bitmap
      unless result == original
        errors << ":bitmap accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":bitmap accessor missing: #{e.message}"
    rescue => e
      errors << ":bitmap accessor raised: #{e.class}: #{e.message}"
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

    # :compound (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:compound)
      w.compound = original
      result = w.compound
      unless result == original
        errors << ":compound accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":compound accessor missing: #{e.message}"
    rescue => e
      errors << ":compound accessor raised: #{e.class}: #{e.message}"
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

    # :direction (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:direction)
      w.direction = original
      result = w.direction
      unless result == original
        errors << ":direction accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":direction accessor missing: #{e.message}"
    rescue => e
      errors << ":direction accessor raised: #{e.class}: #{e.message}"
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

    # :image (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:image)
      w.image = original
      result = w.image
      unless result == original
        errors << ":image accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":image accessor missing: #{e.message}"
    rescue => e
      errors << ":image accessor raised: #{e.class}: #{e.message}"
    end

    # :indicatoron (boolean)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:indicatoron)
      w.indicatoron = original
      result = w.indicatoron
      unless result == original
        errors << ":indicatoron accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":indicatoron accessor missing: #{e.message}"
    rescue => e
      errors << ":indicatoron accessor raised: #{e.class}: #{e.message}"
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

    # :text (string)
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

    # :underline (integer)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:underline)
      w.underline = original
      result = w.underline
      unless result == original
        errors << ":underline accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":underline accessor missing: #{e.message}"
    rescue => e
      errors << ":underline accessor raised: #{e.class}: #{e.message}"
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

    # :wraplength (integer)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:wraplength)
      w.wraplength = original
      result = w.wraplength
      unless result == original
        errors << ":wraplength accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":wraplength accessor missing: #{e.message}"
    rescue => e
      errors << ":wraplength accessor raised: #{e.class}: #{e.message}"
    end

    w.destroy
    raise errors.join("\n") unless errors.empty?
  end
end
