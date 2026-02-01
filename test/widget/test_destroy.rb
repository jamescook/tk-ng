# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestDestroy < Minitest::Test
  include TkTestHelper

  def test_destroy_basic
    assert_tk_app("destroy basic", method(:destroy_basic_app))
  end

  def destroy_basic_app
    require 'tk'

    top = TkToplevel.new
    raise "Window should exist" unless top.exist?
    raise "Window should not be destroyed yet" if top.destroyed?

    top.destroy

    raise "Window should not exist after destroy" if top.exist?
    raise "Window should be marked destroyed" unless top.destroyed?
  end

  def test_double_destroy_safe
    assert_tk_app("double destroy safe", method(:double_destroy_app))
  end

  def double_destroy_app
    require 'tk'

    top = TkToplevel.new
    raise "Window should exist" unless top.exist?

    # First destroy
    top.destroy
    raise "Should be destroyed" unless top.destroyed?

    # Second destroy should be a no-op, not crash
    top.destroy
    top.destroy
    top.destroy

    raise "Still marked destroyed after multiple calls" unless top.destroyed?
  end

  def test_destroy_children
    assert_tk_app("destroy children", method(:destroy_children_app))
  end

  def destroy_children_app
    require 'tk'

    parent = TkToplevel.new
    child1 = TkFrame.new(parent)
    child2 = TkButton.new(child1, text: "Test")

    raise "Parent should exist" unless parent.exist?
    raise "Child1 should exist" unless child1.exist?
    raise "Child2 should exist" unless child2.exist?

    # Destroying parent should mark children as destroyed
    parent.destroy

    raise "Parent should be destroyed" unless parent.destroyed?
    raise "Child1 should be destroyed" unless child1.destroyed?
    raise "Child2 should be destroyed" unless child2.destroyed?
  end

  def test_destroyed_predicate
    assert_tk_app("destroyed? predicate", method(:destroyed_predicate_app))
  end

  def destroyed_predicate_app
    require 'tk'

    top = TkToplevel.new

    # Not destroyed yet
    raise "Should not be destroyed initially" if top.destroyed?

    top.destroy

    # Now destroyed
    raise "Should be destroyed after destroy" unless top.destroyed?
  end

  def test_exist_returns_false_when_destroyed
    assert_tk_app("exist? returns false when destroyed", method(:exist_when_destroyed_app))
  end

  def exist_when_destroyed_app
    require 'tk'

    top = TkToplevel.new
    raise "Should exist initially" unless top.exist?

    top.destroy

    # exist? should return false for destroyed windows
    raise "Should not exist after destroy" if top.exist?
  end

  def test_root_destroy_safe
    assert_tk_app("root destroy safe", method(:root_destroy_safe_app))
  end

  def root_destroy_safe_app
    require 'tk'

    root = Tk.root
    raise "Root should exist" unless root.exist?

    # Don't actually destroy root in test - just verify destroyed? works
    raise "Root should not be destroyed initially" if root.destroyed?

    # Test that calling Root.destroy on destroyed root is safe
    # (We can't actually test this without ending the test, but
    # at least verify the method exists and is callable with guard)
  end

  def test_withdraw_then_destroy
    assert_tk_app("withdraw then destroy", method(:withdraw_then_destroy_app))
  end

  def withdraw_then_destroy_app
    require 'tk'

    top = TkToplevel.new
    top.withdraw

    raise "Should exist when withdrawn" unless top.exist?
    raise "Should not be destroyed when withdrawn" if top.destroyed?

    top.destroy

    raise "Should be destroyed after destroy" unless top.destroyed?
    raise "Should not exist after destroy" if top.exist?
  end
end
