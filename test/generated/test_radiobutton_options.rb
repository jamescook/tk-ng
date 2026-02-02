# frozen_string_literal: true

# Auto-generated option accessor tests for TkRadiobutton
# DO NOT EDIT - regenerate with: rake tk:generate_option_tests
#
# Tests that accessor methods (widget.option, widget.option=) properly
# delegate to cget/configure by round-tripping values through both APIs.
#
# Skipped option names: class

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestGeneratedRadiobuttonOptions < Minitest::Test
  include TkTestHelper

  def test_radiobutton_accessors
    assert_tk_app("Radiobutton accessor tests", method(:radiobutton_accessors_app))
  end

  def radiobutton_accessors_app
    require 'tk'
    require 'tk/option_test_support'
    require 'tk/radiobutton'

    errors = []
    w = TkRadiobutton.new(root)

    # :activebackground (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'activebackground')
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
    end

    # :activeforeground (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'activeforeground')
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
    end

    # :anchor (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'anchor')
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
    end

    # :background (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'background')
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

    # :bitmap (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'bitmap')
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
    end

    # :borderwidth (integer)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'borderwidth')
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

    # :command (callback)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'command')
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
    end

    # :compound (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'compound')
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
    end

    # :cursor (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'cursor')
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

    # :disabledforeground (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'disabledforeground')
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
    end

    # :font (font)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'font')
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
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'foreground')
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
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'height')
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
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'highlightbackground')
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
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'highlightcolor')
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
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'highlightthickness')
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

    # :image (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'image')
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
    end

    # :indicatoron (boolean)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'indicatoron')
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
    end

    # :justify (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'justify')
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
    end

    # :offrelief (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'offrelief')
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
    end

    # :overrelief (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'overrelief')
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
    end

    # :padx (integer)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'padx')
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
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'pady')
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
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'relief')
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

    # :selectcolor (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'selectcolor')
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
    end

    # :selectimage (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'selectimage')
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
    end

    # :state (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'state')
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
    end

    # :takefocus (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'takefocus')
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
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'text')
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

    # :textvariable (tkvariable)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'textvariable')
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
    end

    # :tristateimage (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'tristateimage')
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
    end

    # :tristatevalue (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'tristatevalue')
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
    end

    # :underline (integer)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'underline')
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
    end

    # :value (string)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'value')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:value)
      w.value = original
      result = w.value
      unless result == original
        errors << ":value accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":value accessor missing: #{e.message}"
    rescue => e
      errors << ":value accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :variable (tkvariable)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'variable')
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
    end

    # :width (integer)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'width')
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

    # :wraplength (integer)
    if Tk::OptionTestSupport.option_testable?('radiobutton', 'wraplength')
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
    end

    w.destroy
    raise errors.join("\n") unless errors.empty?
  end
end
