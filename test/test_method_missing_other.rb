# frozen_string_literal: true

# Test method_missing works for text tags and menu items
# These have NO item_option declarations - 100% method_missing

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestMethodMissingOther < Minitest::Test
  include TkTestHelper

  def test_text_tag_method_missing
    assert_tk_app("text tag config via method_missing", method(:app_text_tag))
  end

  def app_text_tag
    require 'tk'
    require 'tk/text'

    text = TkText.new(root)
    tag = TkTextTag.new(text)  # ID is auto-generated

    # Configure via method_missing
    tag.foreground = 'red'
    tag.background = 'yellow'

    # Get via method_missing
    fg = tag.foreground
    bg = tag.background

    raise "foreground failed: expected 'red', got #{fg.inspect}" unless fg == 'red'
    raise "background failed: expected 'yellow', got #{bg.inspect}" unless bg == 'yellow'
  end

  def test_menu_item_method_missing
    assert_tk_app("menu entryconfigure via method_missing", method(:app_menu_item))
  end

  def app_menu_item
    require 'tk'
    require 'tk/menu'

    menu = TkMenu.new(root)
    menu.add('command', label: 'Test')

    # Configure menu entry
    menu.entryconfigure(0, label: 'Changed')
    result = menu.entrycget(0, :label)

    raise "menu label failed: expected 'Changed', got #{result.inspect}" unless result == 'Changed'
  end

  def test_regular_widget_method_missing
    assert_tk_app("widget config via method_missing", method(:app_widget))
  end

  def app_widget
    require 'tk'
    require 'tk/button'

    btn = TkButton.new(root)

    # Use an option that's NOT declared with the option DSL
    # 'cursor' is typically not declared explicitly
    btn.cursor = 'hand2'
    result = btn.cursor

    raise "cursor failed: expected 'hand2', got #{result.inspect}" unless result == 'hand2'
  end
end
