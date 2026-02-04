# frozen_string_literal: true

# Tests for TkTextMark - position markers in Text widgets
#
# See: https://www.tcl-lang.org/man/tcl8.6/TkCmd/text.htm

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestTextMark < Minitest::Test
  include TkTestHelper

  def test_create_mark
    assert_tk_app("TkTextMark create", method(:create_app))
  end

  def create_app
    require 'tk'
    require 'tk/textmark'

    errors = []

    text = TkText.new(root)
    text.insert(:end, "Hello World")

    mark = TkTextMark.new(text, "1.5")
    errors << "should have id" if mark.id.nil?
    errors << "should have path" if mark.path.nil?

    raise errors.join("\n") unless errors.empty?
  end

  def test_mark_pos
    assert_tk_app("TkTextMark pos", method(:pos_app))
  end

  def pos_app
    require 'tk'
    require 'tk/textmark'

    errors = []

    text = TkText.new(root)
    text.insert(:end, "Hello World")

    mark = TkTextMark.new(text, "1.5")
    pos = mark.pos
    errors << "pos should be 1.5, got '#{pos}'" unless pos.to_s == "1.5"

    raise errors.join("\n") unless errors.empty?
  end

  def test_mark_set
    assert_tk_app("TkTextMark set", method(:set_app))
  end

  def set_app
    require 'tk'
    require 'tk/textmark'

    errors = []

    text = TkText.new(root)
    text.insert(:end, "Hello World")

    mark = TkTextMark.new(text, "1.0")
    result = mark.set("1.5")
    errors << "set should return self" unless result == mark

    pos = mark.pos
    errors << "pos should be 1.5 after set, got '#{pos}'" unless pos.to_s == "1.5"

    # pos= alias
    mark.pos = "1.3"
    errors << "pos should be 1.3 after pos=, got '#{mark.pos}'" unless mark.pos.to_s == "1.3"

    raise errors.join("\n") unless errors.empty?
  end

  def test_mark_gravity
    assert_tk_app("TkTextMark gravity", method(:gravity_app))
  end

  def gravity_app
    require 'tk'
    require 'tk/textmark'

    errors = []

    text = TkText.new(root)
    text.insert(:end, "Hello World")

    mark = TkTextMark.new(text, "1.5")

    # Default gravity is right
    g = mark.gravity
    errors << "default gravity should be 'right', got '#{g}'" unless g == "right"

    # Set to left
    mark.gravity = :left
    errors << "gravity should be 'left', got '#{mark.gravity}'" unless mark.gravity == "left"

    # Set back to right
    mark.gravity = "right"
    errors << "gravity should be 'right', got '#{mark.gravity}'" unless mark.gravity == "right"

    raise errors.join("\n") unless errors.empty?
  end

  def test_mark_exist
    assert_tk_app("TkTextMark exist?", method(:exist_app))
  end

  def exist_app
    require 'tk'
    require 'tk/textmark'

    errors = []

    text = TkText.new(root)
    text.insert(:end, "Hello World")

    mark = TkTextMark.new(text, "1.5")
    errors << "mark should exist" unless mark.exist?

    mark.unset
    errors << "mark should not exist after unset" if mark.exist?

    raise errors.join("\n") unless errors.empty?
  end

  def test_mark_next_previous
    assert_tk_app("TkTextMark next/previous", method(:next_prev_app))
  end

  def next_prev_app
    require 'tk'
    require 'tk/textmark'

    errors = []

    text = TkText.new(root)
    text.insert(:end, "Hello World Test")

    mark1 = TkTextMark.new(text, "1.0")
    mark2 = TkTextMark.new(text, "1.5")
    mark3 = TkTextMark.new(text, "1.11")

    # next from mark1 should find mark2 or insert (built-in marks exist too)
    next_mark = mark1.next
    errors << "next should return something" if next_mark.nil?

    # previous from mark3
    prev_mark = mark3.previous
    errors << "previous should return something" if prev_mark.nil?

    raise errors.join("\n") unless errors.empty?
  end

  def test_named_mark
    assert_tk_app("TkTextNamedMark", method(:named_mark_app))
  end

  def named_mark_app
    require 'tk'
    require 'tk/textmark'

    errors = []

    text = TkText.new(root)
    text.insert(:end, "Hello World")

    mark1 = TkTextNamedMark.new(text, "mybookmark", "1.5")
    errors << "named mark should have path 'mybookmark'" unless mark1.path == "mybookmark"

    # Creating same name again returns cached instance
    mark2 = TkTextNamedMark.new(text, "mybookmark")
    errors << "should return same object" unless mark2.equal?(mark1)

    raise errors.join("\n") unless errors.empty?
  end

  def test_insert_mark
    assert_tk_app("TkTextMarkInsert", method(:insert_mark_app))
  end

  def insert_mark_app
    require 'tk'
    require 'tk/textmark'

    errors = []

    text = TkText.new(root)
    text.insert(:end, "Hello World")

    ins = TkTextMarkInsert.new(text)
    errors << "insert mark path should be 'insert'" unless ins.path == "insert"

    # Move cursor
    ins.set("1.3")
    errors << "insert pos should be 1.3" unless ins.pos.to_s == "1.3"

    raise errors.join("\n") unless errors.empty?
  end
end
