# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestMsgCatalog < Minitest::Test
  include TkTestHelper

  def test_msgcat_basics
    assert_tk_app("TkMsgCatalog basics", method(:msgcat_app))
  end

  def msgcat_app
    require 'tk'
    require 'tk/msgcat'

    errors = []

    # Verify class methods exist
    errors << "translate should be defined" unless TkMsgCatalog.respond_to?(:translate)
    errors << "mc should be defined" unless TkMsgCatalog.respond_to?(:mc)
    errors << "[] should be defined" unless TkMsgCatalog.respond_to?(:[])
    errors << "locale should be defined" unless TkMsgCatalog.respond_to?(:locale)
    errors << "locale= should be defined" unless TkMsgCatalog.respond_to?(:locale=)
    errors << "preferences should be defined" unless TkMsgCatalog.respond_to?(:preferences)
    errors << "set_translation should be defined" unless TkMsgCatalog.respond_to?(:set_translation)
    errors << "set_translation_list should be defined" unless TkMsgCatalog.respond_to?(:set_translation_list)

    # Get current locale
    loc = TkMsgCatalog.locale
    errors << "locale should return a string" unless loc.is_a?(String)

    # Preferences should return an array
    prefs = TkMsgCatalog.preferences
    errors << "preferences should return an array" unless prefs.is_a?(Array)

    # Set and retrieve a translation
    TkMsgCatalog.set_translation('en', 'hello_test', 'Hello Test')
    saved_locale = TkMsgCatalog.locale
    TkMsgCatalog.locale = 'en'
    result = TkMsgCatalog['hello_test']
    errors << "translate failed: got '#{result}'" unless result == 'Hello Test'

    # Set translation list
    TkMsgCatalog.set_translation_list('en', [
      ['goodbye_test', 'Goodbye Test'],
      ['yes_test', 'Yes Test']
    ])
    errors << "translate list failed" unless TkMsgCatalog['goodbye_test'] == 'Goodbye Test'
    errors << "translate list failed (2)" unless TkMsgCatalog['yes_test'] == 'Yes Test'

    # Restore locale
    TkMsgCatalog.locale = saved_locale

    errors.empty? ? "OK" : errors.join("; ")
  end
end
