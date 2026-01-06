# frozen_string_literal: true

# Test for TkNamespace and TkNamespace::Ensemble.
# Runs in a single subprocess to minimize overhead.

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestNamespace < Minitest::Test
  include TkTestHelper

  def test_namespace_ensemble
    assert_tk_app("Namespace Ensemble test", method(:namespace_app))
  end

  def namespace_app
    require 'tk'
    require 'tk/namespace'

    root = TkRoot.new { withdraw }
    errors = []

    # --- Create ensemble ---
    ensemble = TkNamespace::Ensemble.new

    errors << "ensemble should have path" unless ensemble.path

    # --- Test prefixes option (DSL-declared boolean) ---
    ensemble.configure(prefixes: true)
    errors << "prefixes true failed" unless ensemble.cget(:prefixes)
    errors << "prefixes true not boolean" unless ensemble.cget(:prefixes).is_a?(TrueClass)

    ensemble.configure(prefixes: false)
    errors << "prefixes false failed" if ensemble.cget(:prefixes)
    errors << "prefixes false not boolean" unless ensemble.cget(:prefixes).is_a?(FalseClass)

    # --- Test subcommands option (DSL-declared list) ---
    ensemble.configure(subcommands: ["cmd1", "cmd2"])
    subcmds = ensemble.cget(:subcommands)
    errors << "subcommands should be array" unless subcmds.is_a?(Array)

    # --- Ensemble.exist? ---
    errors << "exist? should return true" unless TkNamespace::Ensemble.exist?(ensemble.path)

    # Check errors before tk_end
    unless errors.empty?
      root.destroy
      raise "Namespace test failures:\n  " + errors.join("\n  ")
    end

    tk_end(root)
  end
end
