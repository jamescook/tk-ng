# frozen_string_literal: true

# Tests for TkVariable - Tcl variable wrapper
#
# TkVariable wraps Tcl variables for use in Ruby. It supports both scalar
# variables and associative arrays (hashes).
#
# These tests exercise the USE_TCLs_SET_VARIABLE_FUNCTIONS=true code path
# which uses direct Tcl C API calls (tcl_get_var, tcl_set_var, etc.)
# rather than eval-based variable access.

require_relative 'test_helper'
require 'tk'

class TestTkVariable < Minitest::Test
  def setup
    @created_vars = []
  end

  def teardown
    # Clean up any variables created during the test
    @created_vars.each { |var| var.unset }
  end

  # Helper to create and track a TkVariable for cleanup
  def make_var(*args)
    var = TkVariable.new(*args)
    @created_vars << var
    var
  end

  # --- Scalar Variables ---

  def test_new_with_string
    var = make_var("hello")
    assert_equal "hello", var.value
  end

  def test_new_with_empty_string
    var = make_var
    assert_equal "", var.value
  end

  def test_new_with_integer
    var = make_var(42)
    assert_equal "42", var.value
  end

  def test_value_assignment
    var = make_var("initial")
    var.value = "changed"
    assert_equal "changed", var.value
  end

  def test_is_scalar
    var = make_var("hello")
    assert var.is_scalar?
    refute var.is_hash?
  end

  def test_to_s
    var = make_var("hello")
    assert_equal "hello", var.to_s
  end

  def test_to_i
    var = make_var("42")
    assert_equal 42, var.to_i
  end

  def test_to_f
    var = make_var("3.14")
    assert_in_delta 3.14, var.to_f, 0.001
  end

  def test_numeric
    var = make_var("42")
    assert_equal 42, var.numeric
  end

  def test_exist_scalar
    var = make_var("hello")
    assert var.exist?
  end

  def test_unset_scalar
    var = make_var("hello")
    var.unset
    refute var.exist?
  end

  # --- Hash/Array Variables ---

  def test_new_with_hash
    var = make_var({})
    assert var.is_hash?
    refute var.is_scalar?
  end

  def test_hash_set_and_get
    var = make_var({})
    var["key1"] = "value1"
    var["key2"] = "value2"
    assert_equal "value1", var["key1"]
    assert_equal "value2", var["key2"]
  end

  def test_hash_keys
    var = make_var({})
    var["a"] = "1"
    var["b"] = "2"
    assert_equal ["a", "b"], var.keys.sort
  end

  def test_hash_size
    var = make_var({})
    var["a"] = "1"
    var["b"] = "2"
    var["c"] = "3"
    assert_equal 3, var.size
  end

  def test_hash_clear
    var = make_var({})
    var["a"] = "1"
    var["b"] = "2"
    var.clear
    assert_equal 0, var.size
  end

  def test_hash_unset_element
    var = make_var({})
    var["a"] = "1"
    var["b"] = "2"
    var.unset("a")
    assert_equal 1, var.size
    assert var.exist?("b")
    refute var.exist?("a")
  end

  def test_hash_with_initial_values
    var = make_var({"x" => "10", "y" => "20"})
    assert_equal 2, var.size
    assert_equal "10", var["x"]
    assert_equal "20", var["y"]
  end

  def test_hash_update
    var = make_var({})
    var["a"] = "1"
    var.update({"b" => "2", "c" => "3"})
    assert_equal 3, var.size
  end

  def test_to_hash
    var = make_var({"a" => "1", "b" => "2"})
    h = var.to_hash
    assert_kind_of Hash, h
    assert_equal 2, h.size
  end

  # --- Multi-index element access ---

  def test_multi_index_set_and_get
    var = make_var({})
    var["x", "y"] = "coord"
    assert_equal "coord", var["x", "y"]
  end

  # --- Variable ID and reference ---

  def test_id
    var = make_var("test")
    assert var.id.start_with?("v")
  end

  def test_inspect
    var = make_var("test")
    assert_includes var.inspect, "TkVariable"
  end

  # --- TkVarAccess ---

  def test_tkvaraccess_new
    var = make_var("hello")
    access = TkVarAccess.new(var.id)
    @created_vars << access  # track for cleanup
    assert_equal var.value, access.value
  end

  def test_tkvaraccess_set_value
    var = make_var("initial")
    access = TkVarAccess.new(var.id)
    @created_vars << access  # track for cleanup
    access.value = "changed"
    assert_equal "changed", var.value
  end

  # --- Bool type ---

  def test_bool_true_values
    var = make_var("1")
    assert_equal true, var.bool

    var.value = "true"
    assert_equal true, var.bool

    var.value = "yes"
    assert_equal true, var.bool

    var.value = "on"
    assert_equal true, var.bool
  end

  def test_bool_false_values
    var = make_var("0")
    assert_equal false, var.bool

    var.value = "false"
    assert_equal false, var.bool

    var.value = "no"
    assert_equal false, var.bool

    var.value = "off"
    assert_equal false, var.bool
  end

  def test_set_bool
    var = make_var("")
    var.bool = true
    assert_equal "1", var.value

    var.bool = false
    assert_equal "0", var.value
  end

  # --- List operations ---

  def test_list
    var = make_var("a b c")
    assert_equal ["a", "b", "c"], var.list
  end

  def test_lappend
    var = make_var("a b")
    var.lappend("c", "d")
    assert_equal ["a", "b", "c", "d"], var.list
  end

  # --- Comparison and equality ---

  def test_equality_with_string
    var = make_var("hello")
    assert_equal "hello", var
    refute_equal "world", var
  end

  def test_equality_with_integer
    var = make_var("42")
    assert_equal 42, var
  end

  def test_spaceship_operator
    var = make_var("5")
    assert_operator var, :<, 10
    assert_operator var, :>, 3
    assert_equal 0, var <=> 5
  end
end
