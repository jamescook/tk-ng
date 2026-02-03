# frozen_string_literal: true

require_relative 'option'

module Tk
  # DSL for declaring widget options at the class level.
  #
  # OptionDSL lets widget classes declare their configuration options
  # with type information, aliases, and version requirements. This
  # metadata is used by cget/configure to convert values and resolve
  # option names.
  #
  # ## Basic Usage
  #
  #     class MyWidget < TkWindow
  #       extend Tk::OptionDSL
  #
  #       option :text                           # String (default)
  #       option :width, type: :integer          # With type
  #       option :background, alias: :bg         # With alias
  #       option :font, type: :font              # Returns TkFont object
  #     end
  #
  # ## Option Types
  #
  # The `type:` parameter specifies how values are converted:
  #
  # - `:string` (default) - Pass-through
  # - `:integer` - Converts to/from Integer
  # - `:boolean` - Converts to/from true/false
  # - `:font` - Returns TkFont objects
  # - `:widget` - Returns widget objects from paths
  # - `:tkvariable` - Returns TkVarAccess objects
  # - `:callback` - Registers procs, returns callback IDs
  #
  # See {OptionType} for the full list.
  #
  # ## Aliases
  #
  # Short names for convenience:
  #
  #     option :background, alias: :bg
  #     option :foreground, aliases: [:fg, :fgcolor]
  #
  # Both cget(:bg) and cget(:background) will work.
  #
  # ## Version Requirements
  #
  # Mark options that need newer Tk versions:
  #
  #     option :placeholder, type: :string, min_version: 9
  #
  # Calling this on Tk 8.6 will raise an appropriate error.
  #
  # ## Inheritance
  #
  # Subclasses inherit parent options and can override them:
  #
  #     class ParentWidget
  #       extend Tk::OptionDSL
  #       option :text
  #     end
  #
  #     class ChildWidget < ParentWidget
  #       option :text, type: :string  # Inherits, can override
  #       option :value                # Add new option
  #     end
  #
  # ## Integration with TkObject
  #
  # TkObject's cget/configure/configinfo methods automatically use
  # the options declared via this DSL for:
  # - Type conversion (to_tcl/from_tcl)
  # - Alias resolution
  # - Version checking
  #
  # @example Complete widget with options
  #   class TkEntry
  #     extend Tk::OptionDSL
  #
  #     option :textvariable, type: :tkvariable
  #     option :width, type: :integer
  #     option :show               # Password masking character
  #     option :state              # normal, disabled, readonly
  #     option :validate           # none, focus, focusin, focusout, key, all
  #     option :validatecommand, type: :callback, alias: :vcmd
  #   end
  #
  # @see Option Metadata for individual options
  # @see OptionType Type converters
  # @see ItemOptionDSL For item options (canvas items, menu entries)
  module OptionDSL
    # Method names that conflict with Ruby builtins - can't generate accessors.
    # These options must use cget/configure or [] syntax instead.
    RESERVED_METHODS = %i[class method send id].to_set.freeze

    # Called when module is extended into a class
    # Merge with existing options (from parent) instead of resetting
    def self.extended(base)
      existing = base.instance_variable_get(:@options) || {}
      base.instance_variable_set(:@options, existing.dup)
    end

    # Inherit options from parent class
    def inherited(subclass)
      super
      subclass.instance_variable_set(:@options, (@options || {}).dup)
    end

    # Declare an option for this widget class.
    #
    # @param name [Symbol] Ruby-facing option name
    # @param type [Symbol] Type converter (:string, :integer, :boolean, etc.)
    # @param tcl_name [String, nil] Tcl option name if different from Ruby name
    # @param aliases [Array<Symbol>] Alternative names for this option
    # @param min_version [Integer, nil] Minimum Tcl/Tk major version required (e.g., 9 for Tk 9.0+)
    # @param from_tcl [Proc, nil] Custom converter for Tcl->Ruby (receives value, widget: keyword)
    # @param to_tcl [Proc, nil] Custom converter for Ruby->Tcl (receives value, widget: keyword)
    #
    def option(name, type: :string, tcl_name: nil, alias: nil, aliases: [], min_version: nil,
               from_tcl: nil, to_tcl: nil)
      @options ||= {}

      # Support both alias: :foo (single) and aliases: [:foo, :bar] (multiple)
      all_aliases = Array(binding.local_variable_get(:alias)) + Array(aliases)
      all_aliases.compact!

      # Check for conflicts with existing option (e.g., from parent class)
      existing = @options[name.to_sym]
      if existing
        if existing.type.name == type && existing.aliases.sort == all_aliases.sort
          return # Same config, already inherited - skip silently
        else
          # Different config - warn but allow override (may be intentional)
          class_name = self.name || self.inspect
          warn "[ruby-tk] Option :#{name} redefined with different config in #{class_name}. " \
            "Was: type=#{existing.type.name}, aliases=#{existing.aliases}. " \
            "Now: type=#{type}, aliases=#{all_aliases}"
        end
      end

      opt = Option.new(name: name, tcl_name: tcl_name, type: type, aliases: all_aliases,
                       min_version: min_version, from_tcl: from_tcl, to_tcl: to_tcl)
      @options[opt.name] = opt
      all_aliases.each { |a| @options[a.to_sym] = opt }

      # Generate accessor methods for this option and its aliases
      [name, *all_aliases].each do |method_name|
        next if RESERVED_METHODS.include?(method_name.to_sym)

        # Skip if method already defined (e.g., custom implementation)
        next if method_defined?(method_name) || private_method_defined?(method_name)

        # Getter that also works as setter: widget.text or widget.text("value")
        # Also handles blocks for callback options: widget.command { ... }
        define_method(method_name) do |*args, &block|
          if args.empty? && block.nil?
            cget(method_name)
          else
            # Prefer positional arg over block (args[0] could be false/nil)
            configure(method_name, args.empty? ? block : args[0])
            self
          end
        end
        define_method(:"#{method_name}=") { |v| configure(method_name, v); v }
      end
    end

    # Add an alias for an existing option without redefining it.
    # Use when the generator doesn't detect an alias (e.g., vcmd → validatecommand
    # on TTK widgets).
    #
    # @param alias_name [Symbol] The alias to register
    # @param target [Symbol] The existing option name
    #
    def option_alias(alias_name, target)
      @options ||= {}
      opt = @options[target.to_sym]
      raise ArgumentError, "No option :#{target} declared to alias" unless opt

      @options[alias_name.to_sym] = opt

      method_name = alias_name
      unless RESERVED_METHODS.include?(method_name.to_sym) ||
             method_defined?(method_name) || private_method_defined?(method_name)
        define_method(method_name) do |*args, &block|
          if args.empty? && block.nil?
            cget(method_name)
          else
            configure(method_name, args.empty? ? block : args[0])
            self
          end
        end
        define_method(:"#{method_name}=") { |v| configure(method_name, v); v }
      end
    end

    # All declared options (including aliases pointing to same Option)
    def options
      @options ||= {}
      @options.dup
    end

    # Declare a future option - one that exists in newer Tk versions but not current.
    # Used to provide helpful warnings when code tries to use unsupported options.
    #
    # @param name [Symbol] Option name
    # @param min_version [String] Minimum Tk version required (e.g., '9.0')
    #
    def future_option(name, min_version:)
      @future_options ||= {}
      @future_options[name.to_sym] = { min_version: min_version }
    end

    # List of future option names
    def future_option_names
      @future_options ||= {}
      @future_options.keys
    end

    # Get info about a future option
    def future_option_info(name)
      @future_options ||= {}
      @future_options[name.to_sym]
    end

    # Look up an option by name or alias
    #
    # @param name [Symbol, String] Option name or alias
    # @return [Tk::Option, nil]
    #
    def resolve_option(name)
      @options ||= {}
      @options[name.to_sym]
    end

    # List of canonical option names (excludes aliases)
    def option_names
      @options ||= {}
      @options.values.uniq.map(&:name)
    end

    # Check if an option requires a newer Tcl/Tk version than currently running.
    # Returns the required version number if unavailable, nil if available or unknown.
    #
    # @param name [Symbol, String] Option name to check
    # @return [Integer, nil] Required version if unavailable, nil if available
    #
    def option_version_required(name)
      opt = resolve_option(name)
      return nil unless opt
      opt.version_required
    end

    def declared_optkey_aliases
      @options ||= {}
      @options.values.uniq.each_with_object({}) do |opt, hash|
        opt.aliases.each { |a| hash[a] = opt.name }
      end
    end

    # Resolve aliases in a hash of options. Modifies hash in place.
    # Call as: self.class.resolve_option_aliases(options_hash)
    def resolve_option_aliases(hash)
      declared_optkey_aliases.each do |alias_name, real_name|
        alias_name = alias_name.to_s
        if hash.key?(alias_name)
          hash[real_name.to_s] = hash.delete(alias_name)
        end
      end
      hash
    end

    # Resolve a single option name, returning canonical name if alias.
    # Call as: self.class.resolve_option_alias(name)
    def resolve_option_alias(name)
      name = name.to_s
      _, real_name = declared_optkey_aliases.find { |k, _| k.to_s == name }
      real_name ? real_name.to_s : name
    end
  end
end
