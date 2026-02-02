# frozen_string_literal: true

# Auto-generated option accessor tests for TkSpinbox
# DO NOT EDIT - regenerate with: rake tk:generate_option_tests
#
# Tests that accessor methods (widget.option, widget.option=) properly
# delegate to cget/configure by round-tripping values through both APIs.
#
# Skipped option names: class, cursor, validate

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestGeneratedSpinboxOptions < Minitest::Test
  include TkTestHelper

  def test_spinbox_accessors
    assert_tk_app("Spinbox accessor tests", method(:spinbox_accessors_app))
  end

  def spinbox_accessors_app
    require 'tk'
    require 'tk/option_test_support'
    require 'tk/spinbox'

    errors = []
    w = TkSpinbox.new(root)

    # :activebackground (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'activebackground')
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
    if Tk::OptionTestSupport.option_testable?('spinbox', 'background')
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

    # :borderwidth (integer)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'borderwidth')
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

    # :buttonbackground (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'buttonbackground')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:buttonbackground)
      w.buttonbackground = original
      result = w.buttonbackground
      unless result == original
        errors << ":buttonbackground accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":buttonbackground accessor missing: #{e.message}"
    rescue => e
      errors << ":buttonbackground accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :buttoncursor (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'buttoncursor')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:buttoncursor)
      w.buttoncursor = original
      result = w.buttoncursor
      unless result == original
        errors << ":buttoncursor accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":buttoncursor accessor missing: #{e.message}"
    rescue => e
      errors << ":buttoncursor accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :buttondownrelief (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'buttondownrelief')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:buttondownrelief)
      w.buttondownrelief = original
      result = w.buttondownrelief
      unless result == original
        errors << ":buttondownrelief accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":buttondownrelief accessor missing: #{e.message}"
    rescue => e
      errors << ":buttondownrelief accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :buttonuprelief (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'buttonuprelief')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:buttonuprelief)
      w.buttonuprelief = original
      result = w.buttonuprelief
      unless result == original
        errors << ":buttonuprelief accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":buttonuprelief accessor missing: #{e.message}"
    rescue => e
      errors << ":buttonuprelief accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :command (callback)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'command')
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

    # :disabledbackground (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'disabledbackground')
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
    end

    # :disabledforeground (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'disabledforeground')
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

    # :exportselection (boolean)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'exportselection')
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
    end

    # :font (font)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'font')
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
    if Tk::OptionTestSupport.option_testable?('spinbox', 'foreground')
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

    # :format (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'format')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:format)
      w.format = original
      result = w.format
      unless result == original
        errors << ":format accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":format accessor missing: #{e.message}"
    rescue => e
      errors << ":format accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :from (float)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'from')
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
    if Tk::OptionTestSupport.option_testable?('spinbox', 'highlightbackground')
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
    if Tk::OptionTestSupport.option_testable?('spinbox', 'highlightcolor')
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
    if Tk::OptionTestSupport.option_testable?('spinbox', 'highlightthickness')
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

    # :increment (float)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'increment')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:increment)
      w.increment = original
      result = w.increment
      unless result == original
        errors << ":increment accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":increment accessor missing: #{e.message}"
    rescue => e
      errors << ":increment accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :insertbackground (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'insertbackground')
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
    end

    # :insertborderwidth (integer)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'insertborderwidth')
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
    end

    # :insertofftime (integer)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'insertofftime')
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
    end

    # :insertontime (integer)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'insertontime')
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
    end

    # :insertwidth (integer)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'insertwidth')
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
    end

    # :invalidcommand (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'invalidcommand')
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
    end

    # :justify (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'justify')
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

    # :placeholder (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'placeholder')
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
    end

    # :placeholderforeground (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'placeholderforeground')
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
    end

    # :readonlybackground (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'readonlybackground')
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
    end

    # :relief (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'relief')
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
    if Tk::OptionTestSupport.option_testable?('spinbox', 'repeatdelay')
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
    if Tk::OptionTestSupport.option_testable?('spinbox', 'repeatinterval')
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

    # :selectbackground (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'selectbackground')
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
    end

    # :selectborderwidth (integer)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'selectborderwidth')
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
    end

    # :selectforeground (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'selectforeground')
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
    end

    # :state (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'state')
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
    if Tk::OptionTestSupport.option_testable?('spinbox', 'takefocus')
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

    # :textvariable (tkvariable)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'textvariable')
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

    # :to (float)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'to')
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

    # :validatecommand (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'validatecommand')
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
    end

    # :values (list)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'values')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:values)
      w.values = original
      result = w.values
      unless result == original
        errors << ":values accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":values accessor missing: #{e.message}"
    rescue => e
      errors << ":values accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :width (integer)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'width')
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

    # :wrap (string)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'wrap')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:wrap)
      w.wrap = original
      result = w.wrap
      unless result == original
        errors << ":wrap accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":wrap accessor missing: #{e.message}"
    rescue => e
      errors << ":wrap accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :xscrollcommand (callback)
    if Tk::OptionTestSupport.option_testable?('spinbox', 'xscrollcommand')
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
    end

    w.destroy
    raise errors.join("\n") unless errors.empty?
  end
end
