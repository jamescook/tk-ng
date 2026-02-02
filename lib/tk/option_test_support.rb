# frozen_string_literal: true

require_relative 'version_options'

module Tk
  # Runtime support for generated option tests.
  # Provides version-aware test filtering.
  # @api private
  module OptionTestSupport
    # Version-specific skips for options that exist but have broken round-trip
    # behavior in certain Tcl versions (e.g., cget returns invalid value).
    # Key: tcl version, Value: hash of widget => [options]
    VERSION_SKIPS = {
      '8.6' => {
        # Canvas offset: cget returns "0" which isn't valid for setting
        # (expects "x,y", "#x,y", n, ne, e, se, s, sw, w, nw, or center)
        'canvas' => %w[offset],
      },
    }.freeze

    # Runtime check: is this option testable on the current Tcl version?
    # Checks both VersionOptions (option exists) and VERSION_SKIPS (broken round-trip).
    # @param widget_cmd [String] lowercase widget name (e.g., 'canvas')
    # @param option_name [String] option name (e.g., 'offset')
    # @return [Boolean]
    def self.option_testable?(widget_cmd, option_name)
      tcl_version = defined?(Tk::TK_VERSION) ? Tk::TK_VERSION : '9.0'

      # Check if option exists in this Tcl version
      return false unless VersionOptions.available?(widget_cmd, option_name, tcl_version)

      # Check if option has broken round-trip in this version
      version_widgets = VERSION_SKIPS[tcl_version]
      if version_widgets
        widget_opts = version_widgets[widget_cmd]
        return false if widget_opts&.include?(option_name)
      end

      true
    end
  end
end
