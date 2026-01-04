# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'tk_test_helper'
require 'tk/bridge'

class TestBridge < Minitest::Test
  include TkTestHelper

  def teardown
    Tk::Bridge.reset_default!
  end

  def test_basic_creation
    bridge = Tk::Bridge.new
    assert_instance_of Tk::Bridge, bridge
    assert_instance_of TclTkIp, bridge.interp
  end

  def test_default_singleton
    bridge1 = Tk::Bridge.default
    bridge2 = Tk::Bridge.default
    assert_same bridge1, bridge2, "default should return same instance"
  end

  def test_reset_default
    bridge1 = Tk::Bridge.default
    Tk::Bridge.reset_default!
    bridge2 = Tk::Bridge.default
    refute_same bridge1, bridge2, "reset should create new instance"
  end

  def test_eval_tcl
    bridge = Tk::Bridge.new
    result = bridge.eval("expr {1 + 2}")
    assert_equal "3", result
  end

  def test_invoke_tcl
    bridge = Tk::Bridge.new
    result = bridge.invoke("expr", "1 + 2")
    assert_equal "3", result
  end

  def test_version_info
    bridge = Tk::Bridge.new
    assert_match(/\d+\.\d+/, bridge.tcl_version)
    assert_match(/\d+\.\d+/, bridge.tk_version)
  end

  def test_window_exists
    bridge = Tk::Bridge.new
    assert bridge.window_exists?("."), "Root window should exist"
    refute bridge.window_exists?(".nonexistent"), "Nonexistent window should not exist"
  end

  def test_register_callback
    bridge = Tk::Bridge.new
    called = false
    id = bridge.register_callback { called = true }

    assert_match(/^cb_\d+$/, id)
  end

  def test_tcl_callback_command
    bridge = Tk::Bridge.new
    id = bridge.register_callback { }

    cmd = bridge.tcl_callback_command(id)
    assert_includes cmd, id
    assert_includes cmd, "lappend"

    cmd_with_subs = bridge.tcl_callback_command(id, "%W", "%x")
    assert_includes cmd_with_subs, "%W"
    assert_includes cmd_with_subs, "%x"
  end

  def test_callback_dispatch
    bridge = Tk::Bridge.new
    results = []

    id = bridge.register_callback { |*args| results << args }

    # Simulate what Tcl does: append to the queue variable
    bridge.eval("lappend #{Tk::Bridge::CALLBACK_QUEUE_VAR} [list #{id} arg1 arg2]")

    # Dispatch should process the queue
    bridge.dispatch_pending_callbacks

    assert_equal [["arg1", "arg2"]], results
  end

  def test_multiple_bridges_isolated
    bridge1 = Tk::Bridge.new
    bridge2 = Tk::Bridge.new

    # Each bridge has its own interpreter
    refute_same bridge1.interp, bridge2.interp

    # Set variable in one, shouldn't affect other
    bridge1.eval("set myvar 1")
    bridge2.eval("set myvar 2")

    assert_equal "1", bridge1.eval("set myvar")
    assert_equal "2", bridge2.eval("set myvar")
  end

  def test_unregister_callback
    bridge = Tk::Bridge.new
    called = false
    id = bridge.register_callback { called = true }

    bridge.unregister_callback(id)

    # Queue a call to the unregistered callback
    bridge.eval("lappend #{Tk::Bridge::CALLBACK_QUEUE_VAR} [list #{id}]")
    bridge.dispatch_pending_callbacks

    refute called, "Unregistered callback should not be called"
  end
end
