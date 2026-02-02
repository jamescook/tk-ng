# frozen_string_literal: true

require 'erb'
require_relative 'version_options'

module Tk
  # Generates minitest files from option declarations.
  # Used by `rake tk:generate_option_tests`.
  #
  # @api private
  class OptionTestGenerator
    # Option types that need special test handling (not simple round-trip)
    CALLBACK_TYPES = %i[callback].freeze
    VARIABLE_TYPES = %i[tkvariable].freeze

    # Option names that conflict with Ruby methods
    SKIP_OPTIONS = %w[class].freeze

    # Override require path for widgets not in standard tk/<widget>.rb location
    REQUIRE_OVERRIDES = {
      'menubutton' => 'tk/menu',
    }.freeze

    # Widget-specific skips for options where the widget defines methods
    # that intentionally have different semantics than the option accessor.
    # This is a legacy design decision maintained for compatibility.
    #
    # To access the actual Tk option when a widget overrides the accessor:
    #   widget.cget(:option_name)           # get the Tk option value
    #   widget.configure('option_name', v)  # set the Tk option value
    #
    # Key: lowercase widget name, Value: array of option names to skip
    WIDGET_SKIPS = {
      # Entry's cursor/cursor= handle text insertion cursor position, not mouse cursor
      # Entry's validate() runs validation command, not gets validate mode
      'entry' => %w[cursor validate],
      # Menu includes Wm, so title() is WM title, not the -title option
      # Menu's tearoffcommand() sets callback and returns self, not a getter
      'menu' => %w[tearoffcommand title],
      # Spinbox is entry-like: same cursor/validate method semantics as Entry
      'spinbox' => %w[cursor validate],
    }.freeze

    # Widget-specific options that can only be set at creation time (Tk limitation).
    # These get read-only tests (verify getter works, skip setter test).
    # Key: lowercase widget name, Value: array of option names
    WIDGET_READONLY = {
      'frame' => %w[colormap container visual],
      'labelframe' => %w[colormap container visual],
      'toplevel' => %w[colormap container screen use visual],
    }.freeze

    def initialize(tcl_version:)
      @tcl_version = tcl_version
    end

    # Parse a generated widget file and extract option info
    # Returns array of { name:, type:, aliases: }
    def parse_generated_file(filepath)
      content = File.read(filepath)
      options = []

      content.scan(/option\s+:(\w+)(?:,\s*type:\s*:(\w+))?(?:,\s*alias:\s*:(\w+))?/) do |name, type, single_alias|
        options << {
          name: name,
          type: (type || 'string').to_sym,
          aliases: single_alias ? [single_alias] : []
        }
      end

      # Also catch aliases: [...] syntax
      content.scan(/option\s+:(\w+)(?:,\s*type:\s*:(\w+))?(?:,\s*aliases:\s*\[([^\]]+)\])/) do |name, type, aliases_str|
        aliases = aliases_str.scan(/:(\w+)/).flatten
        existing = options.find { |o| o[:name] == name }
        if existing
          existing[:aliases] = aliases
        else
          options << { name: name, type: (type || 'string').to_sym, aliases: aliases }
        end
      end

      options.uniq { |o| o[:name] }
    end

    # Generate test file content for a widget
    def generate_test_file(widget_name, options)
      widget_cmd = widget_name.downcase
      widget_skips = WIDGET_SKIPS[widget_cmd] || []
      all_skips = SKIP_OPTIONS + widget_skips
      readonly_opts = WIDGET_READONLY[widget_cmd] || []

      # Filter unconditional skips only - version checks happen at runtime
      testable_options = options.reject do |opt|
        all_skips.include?(opt[:name])
      end

      require_path = REQUIRE_OVERRIDES[widget_name.downcase] || "tk/#{widget_name.downcase}"

      ERB.new(TEST_TEMPLATE, trim_mode: '-').result_with_hash(
        widget_name: widget_name,
        widget_class: "Tk#{widget_name}",
        require_path: require_path,
        options: testable_options,
        callback_types: CALLBACK_TYPES,
        variable_types: VARIABLE_TYPES,
        skip_options: all_skips,
        readonly_options: readonly_opts
      )
    end

    TEST_TEMPLATE = <<~'ERB'
      # frozen_string_literal: true

      # Auto-generated option accessor tests for <%= widget_class %>
      # DO NOT EDIT - regenerate with: rake tk:generate_option_tests
      #
      # Tests that accessor methods (widget.option, widget.option=) properly
      # delegate to cget/configure by round-tripping values through both APIs.
      #
      # Skipped option names: <%= skip_options.join(', ') %>

      require_relative '../test_helper'
      require_relative '../tk_test_helper'

      class TestGenerated<%= widget_name %>Options < Minitest::Test
        include TkTestHelper

        def test_<%= widget_name.downcase %>_accessors
          assert_tk_app("<%= widget_name %> accessor tests", method(:<%= widget_name.downcase %>_accessors_app))
        end

        def <%= widget_name.downcase %>_accessors_app
          require 'tk'
          require 'tk/option_test_support'
          require '<%= require_path %>'

          errors = []
          w = <%= widget_class %>.new(root)

      <%- options.each do |opt| -%>
          # :<%= opt[:name] %> (<%= opt[:type] %>)
          if Tk::OptionTestSupport.option_testable?('<%= widget_name.downcase %>', '<%= opt[:name] %>')
          begin
      <%- if readonly_options.include?(opt[:name]) -%>
            # Read-only after creation: verify getter works
            w.<%= opt[:name] %>  # should not raise
      <%- elsif callback_types.include?(opt[:type]) -%>
            # Callback: set a proc, verify getter works
            test_proc = proc { }
            w.<%= opt[:name] %> = test_proc
            w.<%= opt[:name] %>  # should not raise
      <%- elsif variable_types.include?(opt[:type]) -%>
            # TkVariable: set a variable, verify getter works
            test_var = TkVariable.new
            w.<%= opt[:name] %> = test_var
            w.<%= opt[:name] %>  # should not raise
      <%- else -%>
            # Round-trip: get via cget, set via accessor, get via accessor
            original = w.cget(:<%= opt[:name] %>)
            w.<%= opt[:name] %> = original
            result = w.<%= opt[:name] %>
            unless result == original
              errors << ":<%= opt[:name] %> accessor mismatch: cget=#{original.inspect}, accessor=#{result.inspect}"
            end
      <%- end -%>
          rescue NoMethodError => e
            errors << ":<%= opt[:name] %> accessor missing: #{e.message}"
          rescue => e
            errors << ":<%= opt[:name] %> accessor raised: #{e.class}: #{e.message}"
          end
          end

      <%- end -%>
          w.destroy
          raise errors.join("\n") unless errors.empty?
        end
      end
    ERB
  end
end
