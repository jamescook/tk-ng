# frozen_string_literal: true

# Tests for Tk.errorInfo and Tk.errorCode

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestErrorInfo < Minitest::Test
  include TkTestHelper

  def test_error_info_after_tcl_error
    assert_tk_app("Tk.errorInfo", method(:error_info_app))
  end

  def error_info_app
    require 'tk'

    errors = []

    # Trigger a Tcl error to populate errorInfo
    begin
      Tk.ip_eval('error "test error message"')
    rescue RuntimeError
      # Expected
    end

    # errorInfo should contain the error message and stack trace
    info = Tk.errorInfo
    errors << "errorInfo should be a string" unless info.is_a?(String)
    errors << "errorInfo should contain the error message" unless info.include?("test error message")

    raise "errorInfo failures:\n  " + errors.join("\n  ") unless errors.empty?
  end

  def test_error_code_basic
    assert_tk_app("Tk.errorCode", method(:error_code_app))
  end

  def error_code_app
    require 'tk'

    errors = []

    # errorCode should return an array
    code = Tk.errorCode
    errors << "errorCode should be an array, got #{code.class}" unless code.is_a?(Array)

    # Trigger a specific error with errorcode
    begin
      Tk.ip_eval('error "test" {} {POSIX ENOENT "no such file"}')
    rescue RuntimeError
      # Expected
    end

    code = Tk.errorCode
    errors << "errorCode should be POSIX, got #{code.inspect}" unless code[0] == "POSIX"

    raise "errorCode failures:\n  " + errors.join("\n  ") unless errors.empty?
  end
end
