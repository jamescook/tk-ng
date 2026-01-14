# frozen_string_literal: true

# Test for Tcl variable accessors and library loading

require_relative 'test_helper'
require 'tk'

class TestTclVars < Minitest::Test
  # --- Tcl library loading ---

  def test_load_tcllibrary_with_invalid_file
    # Test that load_tcllibrary properly delegates to Tcl's load command
    # by verifying it raises an error for a non-existent file
    assert_raises(TclTkLib::TclError) do
      Tk.load_tcllibrary('/nonexistent/file.so')
    end
  end

  def test_unload_tcllibrary_with_invalid_args
    # Test that unload_tcllibrary properly delegates to Tcl's unload command
    assert_raises(TclTkLib::TclError) do
      Tk.unload_tcllibrary('/nonexistent/file.so')
    end
  end

  # --- New method-based API ---

  def test_tcl_library_method
    result = Tk.tcl_library
    assert_kind_of String, result
    refute_empty result
    assert result.frozen?
  end

  def test_tk_library_method
    result = Tk.tk_library
    assert_kind_of String, result
    refute_empty result
    assert result.frozen?
  end

  def test_library_method
    result = Tk.library
    assert_kind_of String, result
    refute_empty result
    assert result.frozen?
  end

  def test_platform_method
    result = Tk.platform
    assert_kind_of Hash, result
    assert_includes %w[unix windows macintosh], result['platform']
  end

  def test_tcl_env_method
    result = Tk.tcl_env
    assert_kind_of Hash, result
    refute_empty result
  end

  def test_auto_index_method
    result = Tk.auto_index
    assert_kind_of Hash, result
  end

  def test_priv_method
    result = Tk.priv
    assert_kind_of Hash, result
  end

  # --- Deprecated const_missing API (should still work) ---

  def test_unknown_constant_raises_name_error
    assert_raises(NameError) { Tk::NONEXISTENT_CONSTANT_12345 }
  end
end
