# frozen_string_literal: true

# Tests for TkTextWindow - widgets embedded in Text widgets
#
# See: https://www.tcl-lang.org/man/tcl8.6/TkCmd/text.htm

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestTextWindow < Minitest::Test
  include TkTestHelper

  def test_create_text_window
    assert_tk_app("TkTextWindow create", method(:create_app))
  end

  def create_app
    require 'tk'
    require 'tk/textwindow'

    errors = []

    text = TkText.new(root)
    text.pack

    btn = TkButton.new(text, text: "OK")
    tw = TkTextWindow.new(text, "1.0", window: btn)

    errors << "should have id" if tw.id.nil?
    errors << "should have mark" if tw.mark.nil?
    errors << "window should be the button" unless tw.window == btn

    raise errors.join("\n") unless errors.empty?
  end

  def test_create_at_end
    assert_tk_app("TkTextWindow at end", method(:end_app))
  end

  def end_app
    require 'tk'
    require 'tk/textwindow'

    errors = []

    text = TkText.new(root)
    text.pack
    text.insert(:end, "Click: ")

    btn = TkButton.new(text, text: "Here")
    tw = TkTextWindow.new(text, :end, window: btn)
    errors << "should create at end" if tw.id.nil?

    raise errors.join("\n") unless errors.empty?
  end

  def test_cget_and_configure
    assert_tk_app("TkTextWindow cget/configure", method(:config_app))
  end

  def config_app
    require 'tk'
    require 'tk/textwindow'

    errors = []

    text = TkText.new(root)
    text.pack

    btn = TkButton.new(text, text: "Test")
    tw = TkTextWindow.new(text, "1.0", window: btn, padx: 5)

    # cget
    padx = tw.cget(:padx)
    errors << "padx should be 5, got '#{padx}'" unless padx.to_i == 5

    # configure returns self
    result = tw.configure(:pady, 3)
    errors << "configure should return self" unless result == tw

    # [] and []=
    tw[:padx] = 10
    errors << "[] should return 10" unless tw[:padx].to_i == 10

    raise errors.join("\n") unless errors.empty?
  end

  def test_window_accessor
    assert_tk_app("TkTextWindow window get/set", method(:window_accessor_app))
  end

  def window_accessor_app
    require 'tk'
    require 'tk/textwindow'

    errors = []

    text = TkText.new(root)
    text.pack

    btn1 = TkButton.new(text, text: "First")
    btn2 = TkButton.new(text, text: "Second")

    tw = TkTextWindow.new(text, "1.0", window: btn1)
    errors << "window should be btn1" unless tw.window == btn1

    tw.window = btn2
    errors << "window should now be btn2" unless tw.window == btn2

    raise errors.join("\n") unless errors.empty?
  end

  def test_configinfo
    assert_tk_app("TkTextWindow configinfo", method(:configinfo_app))
  end

  def configinfo_app
    require 'tk'
    require 'tk/textwindow'

    errors = []

    text = TkText.new(root)
    text.pack

    btn = TkButton.new(text, text: "Info")
    tw = TkTextWindow.new(text, "1.0", window: btn)

    info = tw.configinfo
    errors << "configinfo should return array" unless info.is_a?(Array)

    raise errors.join("\n") unless errors.empty?
  end

  def test_create_with_proc
    assert_tk_app("TkTextWindow with create proc", method(:create_proc_app))
  end

  def create_proc_app
    require 'tk'
    require 'tk/textwindow'

    errors = []

    text = TkText.new(root)
    text.pack

    tw = TkTextWindow.new(text, "1.0",
      create: proc { TkButton.new(text, text: "Lazy") }
    )

    errors << "should have create proc" if tw.create.nil?

    raise errors.join("\n") unless errors.empty?
  end
end
