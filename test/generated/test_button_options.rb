# frozen_string_literal: true

# Auto-generated option accessor tests for TkButton
# DO NOT EDIT - regenerate with: rake tk:generate_option_tests
#
# Tests that accessor methods (widget.option, widget.option=) properly
# delegate to cget/configure by round-tripping values through both APIs.
#
# Skipped option names: class

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestGeneratedButtonOptions < Minitest::Test
  include TkTestHelper

  def test_button_accessors
    assert_tk_app("Button accessor tests", method(:button_accessors_app))
  end

  def button_accessors_app
    require 'tk'
    require 'tk/option_test_support'
    require 'tk/button'

    errors = []
    w = TkButton.new(root)

    # :activebackground (string)
    if Tk::OptionTestSupport.option_testable?('button', 'activebackground')
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
    if Tk::OptionTestSupport.option_testable?('button', 'activeforeground')
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
    if Tk::OptionTestSupport.option_testable?('button', 'anchor')
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
    if Tk::OptionTestSupport.option_testable?('button', 'background')
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
    if Tk::OptionTestSupport.option_testable?('button', 'bitmap')
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
    if Tk::OptionTestSupport.option_testable?('button', 'borderwidth')
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
    if Tk::OptionTestSupport.option_testable?('button', 'command')
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
    if Tk::OptionTestSupport.option_testable?('button', 'compound')
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
    if Tk::OptionTestSupport.option_testable?('button', 'cursor')
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

    # :default (string)
    if Tk::OptionTestSupport.option_testable?('button', 'default')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:default)
      w.default = original
      result = w.default
      unless result == original
        errors << ":default accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":default accessor missing: #{e.message}"
    rescue => e
      errors << ":default accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :disabledforeground (string)
    if Tk::OptionTestSupport.option_testable?('button', 'disabledforeground')
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
    if Tk::OptionTestSupport.option_testable?('button', 'font')
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
    if Tk::OptionTestSupport.option_testable?('button', 'foreground')
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
    if Tk::OptionTestSupport.option_testable?('button', 'height')
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
    if Tk::OptionTestSupport.option_testable?('button', 'highlightbackground')
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
    if Tk::OptionTestSupport.option_testable?('button', 'highlightcolor')
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
    if Tk::OptionTestSupport.option_testable?('button', 'highlightthickness')
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
    if Tk::OptionTestSupport.option_testable?('button', 'image')
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

    # :justify (string)
    if Tk::OptionTestSupport.option_testable?('button', 'justify')
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

    # :overrelief (string)
    if Tk::OptionTestSupport.option_testable?('button', 'overrelief')
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
    if Tk::OptionTestSupport.option_testable?('button', 'padx')
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
    if Tk::OptionTestSupport.option_testable?('button', 'pady')
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
    if Tk::OptionTestSupport.option_testable?('button', 'relief')
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

    # :repeatdelay (integer)
    if Tk::OptionTestSupport.option_testable?('button', 'repeatdelay')
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
    end

    # :repeatinterval (integer)
    if Tk::OptionTestSupport.option_testable?('button', 'repeatinterval')
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
    end

    # :state (string)
    if Tk::OptionTestSupport.option_testable?('button', 'state')
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
    if Tk::OptionTestSupport.option_testable?('button', 'takefocus')
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
    if Tk::OptionTestSupport.option_testable?('button', 'text')
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
    if Tk::OptionTestSupport.option_testable?('button', 'textvariable')
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

    # :underline (integer)
    if Tk::OptionTestSupport.option_testable?('button', 'underline')
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

    # :width (integer)
    if Tk::OptionTestSupport.option_testable?('button', 'width')
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
    if Tk::OptionTestSupport.option_testable?('button', 'wraplength')
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
