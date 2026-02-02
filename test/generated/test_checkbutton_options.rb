# frozen_string_literal: true

# Auto-generated option accessor tests for TkCheckbutton
# DO NOT EDIT - regenerate with: rake tk:generate_option_tests
#
# Tests that accessor methods (widget.option, widget.option=) properly
# delegate to cget/configure by round-tripping values through both APIs.
#
# Skipped option names: class

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestGeneratedCheckbuttonOptions < Minitest::Test
  include TkTestHelper

  def test_checkbutton_accessors
    assert_tk_app("Checkbutton accessor tests", method(:checkbutton_accessors_app))
  end

  def checkbutton_accessors_app
    require 'tk'
    require 'tk/checkbutton'

    errors = []
    w = TkCheckbutton.new(root)

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

    # :offrelief (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:offrelief)
      w.offrelief = original
      result = w.offrelief
      unless result == original
        errors << ":offrelief accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":offrelief accessor missing: #{e.message}"
    rescue => e
      errors << ":offrelief accessor raised: #{e.class}: #{e.message}"
    end

    # :offvalue (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:offvalue)
      w.offvalue = original
      result = w.offvalue
      unless result == original
        errors << ":offvalue accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":offvalue accessor missing: #{e.message}"
    rescue => e
      errors << ":offvalue accessor raised: #{e.class}: #{e.message}"
    end

    # :onvalue (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:onvalue)
      w.onvalue = original
      result = w.onvalue
      unless result == original
        errors << ":onvalue accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":onvalue accessor missing: #{e.message}"
    rescue => e
      errors << ":onvalue accessor raised: #{e.class}: #{e.message}"
    end

    # :overrelief (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:overrelief)
      w.overrelief = original
      result = w.overrelief
      unless result == original
        errors << ":overrelief accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":overrelief accessor missing: #{e.message}"
    rescue => e
      errors << ":overrelief accessor raised: #{e.class}: #{e.message}"
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

    # :selectimage (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:selectimage)
      w.selectimage = original
      result = w.selectimage
      unless result == original
        errors << ":selectimage accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":selectimage accessor missing: #{e.message}"
    rescue => e
      errors << ":selectimage accessor raised: #{e.class}: #{e.message}"
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

    # :tristateimage (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:tristateimage)
      w.tristateimage = original
      result = w.tristateimage
      unless result == original
        errors << ":tristateimage accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":tristateimage accessor missing: #{e.message}"
    rescue => e
      errors << ":tristateimage accessor raised: #{e.class}: #{e.message}"
    end

    # :tristatevalue (string)
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:tristatevalue)
      w.tristatevalue = original
      result = w.tristatevalue
      unless result == original
        errors << ":tristatevalue accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":tristatevalue accessor missing: #{e.message}"
    rescue => e
      errors << ":tristatevalue accessor raised: #{e.class}: #{e.message}"
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

    # :variable (tkvariable)
    begin
      # TkVariable: set a variable, verify getter works
      test_var = TkVariable.new
      w.variable = test_var
      w.variable  # should not raise
    rescue NoMethodError => e
      errors << ":variable accessor missing: #{e.message}"
    rescue => e
      errors << ":variable accessor raised: #{e.class}: #{e.message}"
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
