# frozen_string_literal: true

# Auto-generated option accessor tests for TkScale
# DO NOT EDIT - regenerate with: rake tk:generate_option_tests
#
# Tests that accessor methods (widget.option, widget.option=) properly
# delegate to cget/configure by round-tripping values through both APIs.
#
# Skipped option names: class

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestGeneratedScaleOptions < Minitest::Test
  include TkTestHelper

  def test_scale_accessors
    assert_tk_app("Scale accessor tests", method(:scale_accessors_app))
  end

  def scale_accessors_app
    require 'tk'
    require 'tk/option_test_support'
    require 'tk/scale'

    errors = []
    w = TkScale.new(root)

    # :activebackground (string)
    if Tk::OptionTestSupport.option_testable?('scale', 'activebackground')
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

    # :background (string)
    if Tk::OptionTestSupport.option_testable?('scale', 'background')
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

    # :bigincrement (float)
    if Tk::OptionTestSupport.option_testable?('scale', 'bigincrement')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:bigincrement)
      w.bigincrement = original
      result = w.bigincrement
      unless result == original
        errors << ":bigincrement accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":bigincrement accessor missing: #{e.message}"
    rescue => e
      errors << ":bigincrement accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :borderwidth (integer)
    if Tk::OptionTestSupport.option_testable?('scale', 'borderwidth')
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
    if Tk::OptionTestSupport.option_testable?('scale', 'command')
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

    # :cursor (string)
    if Tk::OptionTestSupport.option_testable?('scale', 'cursor')
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

    # :digits (integer)
    if Tk::OptionTestSupport.option_testable?('scale', 'digits')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:digits)
      w.digits = original
      result = w.digits
      unless result == original
        errors << ":digits accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":digits accessor missing: #{e.message}"
    rescue => e
      errors << ":digits accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :font (font)
    if Tk::OptionTestSupport.option_testable?('scale', 'font')
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
    if Tk::OptionTestSupport.option_testable?('scale', 'foreground')
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

    # :from (float)
    if Tk::OptionTestSupport.option_testable?('scale', 'from')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:from)
      w.from = original
      result = w.from
      unless result == original
        errors << ":from accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":from accessor missing: #{e.message}"
    rescue => e
      errors << ":from accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :highlightbackground (string)
    if Tk::OptionTestSupport.option_testable?('scale', 'highlightbackground')
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
    if Tk::OptionTestSupport.option_testable?('scale', 'highlightcolor')
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
    if Tk::OptionTestSupport.option_testable?('scale', 'highlightthickness')
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

    # :label (string)
    if Tk::OptionTestSupport.option_testable?('scale', 'label')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:label)
      w.label = original
      result = w.label
      unless result == original
        errors << ":label accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":label accessor missing: #{e.message}"
    rescue => e
      errors << ":label accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :length (integer)
    if Tk::OptionTestSupport.option_testable?('scale', 'length')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:length)
      w.length = original
      result = w.length
      unless result == original
        errors << ":length accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":length accessor missing: #{e.message}"
    rescue => e
      errors << ":length accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :orient (string)
    if Tk::OptionTestSupport.option_testable?('scale', 'orient')
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
    end

    # :relief (string)
    if Tk::OptionTestSupport.option_testable?('scale', 'relief')
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
    if Tk::OptionTestSupport.option_testable?('scale', 'repeatdelay')
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
    if Tk::OptionTestSupport.option_testable?('scale', 'repeatinterval')
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

    # :resolution (float)
    if Tk::OptionTestSupport.option_testable?('scale', 'resolution')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:resolution)
      w.resolution = original
      result = w.resolution
      unless result == original
        errors << ":resolution accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":resolution accessor missing: #{e.message}"
    rescue => e
      errors << ":resolution accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :showvalue (boolean)
    if Tk::OptionTestSupport.option_testable?('scale', 'showvalue')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:showvalue)
      w.showvalue = original
      result = w.showvalue
      unless result == original
        errors << ":showvalue accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":showvalue accessor missing: #{e.message}"
    rescue => e
      errors << ":showvalue accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :sliderlength (integer)
    if Tk::OptionTestSupport.option_testable?('scale', 'sliderlength')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:sliderlength)
      w.sliderlength = original
      result = w.sliderlength
      unless result == original
        errors << ":sliderlength accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":sliderlength accessor missing: #{e.message}"
    rescue => e
      errors << ":sliderlength accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :sliderrelief (string)
    if Tk::OptionTestSupport.option_testable?('scale', 'sliderrelief')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:sliderrelief)
      w.sliderrelief = original
      result = w.sliderrelief
      unless result == original
        errors << ":sliderrelief accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":sliderrelief accessor missing: #{e.message}"
    rescue => e
      errors << ":sliderrelief accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :state (string)
    if Tk::OptionTestSupport.option_testable?('scale', 'state')
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
    if Tk::OptionTestSupport.option_testable?('scale', 'takefocus')
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

    # :tickinterval (float)
    if Tk::OptionTestSupport.option_testable?('scale', 'tickinterval')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:tickinterval)
      w.tickinterval = original
      result = w.tickinterval
      unless result == original
        errors << ":tickinterval accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":tickinterval accessor missing: #{e.message}"
    rescue => e
      errors << ":tickinterval accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :to (float)
    if Tk::OptionTestSupport.option_testable?('scale', 'to')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:to)
      w.to = original
      result = w.to
      unless result == original
        errors << ":to accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":to accessor missing: #{e.message}"
    rescue => e
      errors << ":to accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :troughcolor (string)
    if Tk::OptionTestSupport.option_testable?('scale', 'troughcolor')
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
    end

    # :variable (tkvariable)
    if Tk::OptionTestSupport.option_testable?('scale', 'variable')
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
    if Tk::OptionTestSupport.option_testable?('scale', 'width')
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

    w.destroy
    raise errors.join("\n") unless errors.empty?
  end
end
