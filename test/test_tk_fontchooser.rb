# frozen_string_literal: true

# Tests for TkFont::Chooser (tk fontchooser wrapper)

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestTkFontchooser < Minitest::Test
  include TkTestHelper

  def test_fontchooser_configure_title
    assert_tk_app("TkFont::Chooser configure title", method(:app_configure_title))
  end

  def app_configure_title
    require 'tk'
    require 'tk/fontchooser'

    TkFont::Chooser.configure(title: 'Pick a Font')
    title = TkFont::Chooser.cget(:title)
    raise "title should be set, got #{title.inspect}" unless title == 'Pick a Font'
  end

  def test_fontchooser_configure_parent
    assert_tk_app("TkFont::Chooser configure parent", method(:app_configure_parent))
  end

  def app_configure_parent
    require 'tk'
    require 'tk/fontchooser'

    TkFont::Chooser.configure(parent: root)
    parent = TkFont::Chooser.cget(:parent)
    raise "parent should be set, got #{parent.inspect}" unless parent
  end

  def test_fontchooser_visible_initially_false
    assert_tk_app("TkFont::Chooser visible is false initially", method(:app_visible_false))
  end

  def app_visible_false
    require 'tk'
    require 'tk/fontchooser'

    visible = TkFont::Chooser.cget(:visible)
    raise "should not be visible initially, got #{visible.inspect}" if visible
  end

  def test_fontchooser_bracket_accessors
    assert_tk_app("TkFont::Chooser [] and []= accessors", method(:app_bracket_accessors))
  end

  def app_bracket_accessors
    require 'tk'
    require 'tk/fontchooser'

    TkFont::Chooser[:title] = 'Test Title'
    title = TkFont::Chooser[:title]
    raise "[]= and [] should work, got #{title.inspect}" unless title == 'Test Title'
  end

  def test_fontchooser_method_missing_accessors
    assert_tk_app("TkFont::Chooser method_missing accessors", method(:app_method_missing))
  end

  def app_method_missing
    require 'tk'
    require 'tk/fontchooser'

    TkFont::Chooser.title = 'Method Missing Title'
    title = TkFont::Chooser.title
    raise "method_missing accessors should work, got #{title.inspect}" unless title == 'Method Missing Title'
  end

  def test_fontchooser_show_hide
    assert_tk_app("TkFont::Chooser show and hide", method(:app_show_hide))
  end

  def app_show_hide
    require 'tk'
    require 'tk/fontchooser'

    # Configure parent first (required on some platforms)
    TkFont::Chooser.configure(parent: root)

    # Show then immediately hide
    TkFont::Chooser.show
    Tk.update

    # Should be visible now (or may not be on headless)
    # Just verify hide doesn't error
    TkFont::Chooser.hide
    Tk.update

    # Should not be visible after hide
    visible = TkFont::Chooser.cget(:visible)
    raise "should not be visible after hide, got #{visible.inspect}" if visible
  end

  def test_fontchooser_tk_alias
    assert_tk_app("Tk::Fontchooser alias exists", method(:app_tk_alias))
  end

  def app_tk_alias
    require 'tk'
    require 'tk/fontchooser'

    # Tk::Fontchooser should be an alias for TkFont::Chooser
    raise "Tk::Fontchooser should exist" unless defined?(Tk::Fontchooser)
    raise "Tk::Fontchooser should equal TkFont::Chooser" unless Tk::Fontchooser == TkFont::Chooser
  end
end
