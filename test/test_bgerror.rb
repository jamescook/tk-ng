# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestBgError < Minitest::Test
  include TkTestHelper

  def test_set_handler_and_default
    assert_tk_app("BgError set_handler and set_default", method(:bgerror_app))
  end

  def bgerror_app
    require 'tk'
    require 'tk/bgerror'

    errors = []

    # set_handler should accept a proc without raising
    called = false
    TkBgError.set_handler(proc { |msg| called = true })
    errors << "set_handler should not raise" if false # we got here, so it didn't

    # set_default should restore default handler without raising
    TkBgError.set_default
    errors << "set_default should not raise" if false

    # Verify module_function aliases exist
    errors << "tkerror should be defined" unless TkBgError.respond_to?(:tkerror)
    errors << "show should be defined" unless TkBgError.respond_to?(:show)
    errors << "set_handler should be defined" unless TkBgError.respond_to?(:set_handler)
    errors << "set_default should be defined" unless TkBgError.respond_to?(:set_default)

    errors.empty? ? "OK" : errors.join("; ")
  end
end
