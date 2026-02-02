# frozen_string_literal: true

# Auto-generated option accessor tests for TkText
# DO NOT EDIT - regenerate with: rake tk:generate_option_tests
#
# Tests that accessor methods (widget.option, widget.option=) properly
# delegate to cget/configure by round-tripping values through both APIs.
#
# Skipped option names: class

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestGeneratedTextOptions < Minitest::Test
  include TkTestHelper

  def test_text_accessors
    assert_tk_app("Text accessor tests", method(:text_accessors_app))
  end

  def text_accessors_app
    require 'tk'
    require 'tk/option_test_support'
    require 'tk/text'

    errors = []
    w = TkText.new(root)

    # :autoseparators (boolean)
    if Tk::OptionTestSupport.option_testable?('text', 'autoseparators')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:autoseparators)
      w.autoseparators = original
      result = w.autoseparators
      unless result == original
        errors << ":autoseparators accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":autoseparators accessor missing: #{e.message}"
    rescue => e
      errors << ":autoseparators accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :background (string)
    if Tk::OptionTestSupport.option_testable?('text', 'background')
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

    # :blockcursor (boolean)
    if Tk::OptionTestSupport.option_testable?('text', 'blockcursor')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:blockcursor)
      w.blockcursor = original
      result = w.blockcursor
      unless result == original
        errors << ":blockcursor accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":blockcursor accessor missing: #{e.message}"
    rescue => e
      errors << ":blockcursor accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :borderwidth (integer)
    if Tk::OptionTestSupport.option_testable?('text', 'borderwidth')
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

    # :cursor (string)
    if Tk::OptionTestSupport.option_testable?('text', 'cursor')
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

    # :endline (string)
    if Tk::OptionTestSupport.option_testable?('text', 'endline')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:endline)
      w.endline = original
      result = w.endline
      unless result == original
        errors << ":endline accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":endline accessor missing: #{e.message}"
    rescue => e
      errors << ":endline accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :exportselection (boolean)
    if Tk::OptionTestSupport.option_testable?('text', 'exportselection')
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
    if Tk::OptionTestSupport.option_testable?('text', 'font')
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
    if Tk::OptionTestSupport.option_testable?('text', 'foreground')
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
    if Tk::OptionTestSupport.option_testable?('text', 'height')
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
    if Tk::OptionTestSupport.option_testable?('text', 'highlightbackground')
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
    if Tk::OptionTestSupport.option_testable?('text', 'highlightcolor')
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
    if Tk::OptionTestSupport.option_testable?('text', 'highlightthickness')
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

    # :inactiveselectbackground (string)
    if Tk::OptionTestSupport.option_testable?('text', 'inactiveselectbackground')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:inactiveselectbackground)
      w.inactiveselectbackground = original
      result = w.inactiveselectbackground
      unless result == original
        errors << ":inactiveselectbackground accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":inactiveselectbackground accessor missing: #{e.message}"
    rescue => e
      errors << ":inactiveselectbackground accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :insertbackground (string)
    if Tk::OptionTestSupport.option_testable?('text', 'insertbackground')
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
    if Tk::OptionTestSupport.option_testable?('text', 'insertborderwidth')
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
    if Tk::OptionTestSupport.option_testable?('text', 'insertofftime')
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
    if Tk::OptionTestSupport.option_testable?('text', 'insertontime')
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

    # :insertunfocussed (string)
    if Tk::OptionTestSupport.option_testable?('text', 'insertunfocussed')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:insertunfocussed)
      w.insertunfocussed = original
      result = w.insertunfocussed
      unless result == original
        errors << ":insertunfocussed accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":insertunfocussed accessor missing: #{e.message}"
    rescue => e
      errors << ":insertunfocussed accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :insertwidth (integer)
    if Tk::OptionTestSupport.option_testable?('text', 'insertwidth')
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

    # :maxundo (integer)
    if Tk::OptionTestSupport.option_testable?('text', 'maxundo')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:maxundo)
      w.maxundo = original
      result = w.maxundo
      unless result == original
        errors << ":maxundo accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":maxundo accessor missing: #{e.message}"
    rescue => e
      errors << ":maxundo accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :padx (integer)
    if Tk::OptionTestSupport.option_testable?('text', 'padx')
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
    if Tk::OptionTestSupport.option_testable?('text', 'pady')
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
    if Tk::OptionTestSupport.option_testable?('text', 'relief')
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

    # :selectbackground (string)
    if Tk::OptionTestSupport.option_testable?('text', 'selectbackground')
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
    if Tk::OptionTestSupport.option_testable?('text', 'selectborderwidth')
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
    if Tk::OptionTestSupport.option_testable?('text', 'selectforeground')
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

    # :setgrid (boolean)
    if Tk::OptionTestSupport.option_testable?('text', 'setgrid')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:setgrid)
      w.setgrid = original
      result = w.setgrid
      unless result == original
        errors << ":setgrid accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":setgrid accessor missing: #{e.message}"
    rescue => e
      errors << ":setgrid accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :spacing1 (integer)
    if Tk::OptionTestSupport.option_testable?('text', 'spacing1')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:spacing1)
      w.spacing1 = original
      result = w.spacing1
      unless result == original
        errors << ":spacing1 accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":spacing1 accessor missing: #{e.message}"
    rescue => e
      errors << ":spacing1 accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :spacing2 (integer)
    if Tk::OptionTestSupport.option_testable?('text', 'spacing2')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:spacing2)
      w.spacing2 = original
      result = w.spacing2
      unless result == original
        errors << ":spacing2 accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":spacing2 accessor missing: #{e.message}"
    rescue => e
      errors << ":spacing2 accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :spacing3 (integer)
    if Tk::OptionTestSupport.option_testable?('text', 'spacing3')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:spacing3)
      w.spacing3 = original
      result = w.spacing3
      unless result == original
        errors << ":spacing3 accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":spacing3 accessor missing: #{e.message}"
    rescue => e
      errors << ":spacing3 accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :startline (string)
    if Tk::OptionTestSupport.option_testable?('text', 'startline')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:startline)
      w.startline = original
      result = w.startline
      unless result == original
        errors << ":startline accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":startline accessor missing: #{e.message}"
    rescue => e
      errors << ":startline accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :state (string)
    if Tk::OptionTestSupport.option_testable?('text', 'state')
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

    # :tabs (string)
    if Tk::OptionTestSupport.option_testable?('text', 'tabs')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:tabs)
      w.tabs = original
      result = w.tabs
      unless result == original
        errors << ":tabs accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":tabs accessor missing: #{e.message}"
    rescue => e
      errors << ":tabs accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :tabstyle (string)
    if Tk::OptionTestSupport.option_testable?('text', 'tabstyle')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:tabstyle)
      w.tabstyle = original
      result = w.tabstyle
      unless result == original
        errors << ":tabstyle accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":tabstyle accessor missing: #{e.message}"
    rescue => e
      errors << ":tabstyle accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :takefocus (string)
    if Tk::OptionTestSupport.option_testable?('text', 'takefocus')
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

    # :undo (boolean)
    if Tk::OptionTestSupport.option_testable?('text', 'undo')
    begin
      # Round-trip: get via cget, set via accessor, get via accessor
      original = w.cget(:undo)
      w.undo = original
      result = w.undo
      unless result == original
        errors << ":undo accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
      end
    rescue NoMethodError => e
      errors << ":undo accessor missing: #{e.message}"
    rescue => e
      errors << ":undo accessor raised: #{e.class}: #{e.message}"
    end
    end

    # :width (integer)
    if Tk::OptionTestSupport.option_testable?('text', 'width')
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
    if Tk::OptionTestSupport.option_testable?('text', 'wrap')
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
    if Tk::OptionTestSupport.option_testable?('text', 'xscrollcommand')
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

    # :yscrollcommand (callback)
    if Tk::OptionTestSupport.option_testable?('text', 'yscrollcommand')
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
    end

    w.destroy
    raise errors.join("\n") unless errors.empty?
  end
end
