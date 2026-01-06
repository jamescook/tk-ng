# frozen_string_literal: true

require_relative 'option_type'

module Tk
  # Metadata for a widget configuration option.
  #
  # Holds the option name, Tcl name, type converter, any aliases, and version requirements.
  #
  # Example:
  #   opt = Tk::Option.new(name: :bg, tcl_name: 'background', type: :color, aliases: [:background])
  #   opt.to_tcl("red")   # => "red"
  #   opt.from_tcl("red") # => "red"
  #
  #   # Version-restricted option (Tcl/Tk 9.0+)
  #   opt = Tk::Option.new(name: :activerelief, type: :relief, min_version: 9)
  #   opt.available?      # => false on Tk 8.6, true on Tk 9.0+
  #
  class Option
    attr_reader :name, :tcl_name, :type, :aliases, :min_version

    def initialize(name:, tcl_name: nil, type: :string, aliases: [], min_version: nil)
      @name = name.to_sym
      @tcl_name = (tcl_name || name).to_s
      @type = resolve_type(type)
      @aliases = Array(aliases).map(&:to_sym)
      @min_version = min_version
    end

    # Convert Ruby value to Tcl string
    def to_tcl(value, widget: nil)
      @type.to_tcl(value, widget: widget)
    end

    # Convert Tcl string to Ruby value
    def from_tcl(value, widget: nil)
      @type.from_tcl(value, widget: widget)
    end

    # Check if this option is available in the current Tcl/Tk version.
    # Returns true if no min_version is set, or if current version >= min_version.
    def available?
      return true unless @min_version
      # Tk::TK_MAJOR_VERSION is set when Tk is loaded
      defined?(Tk::TK_MAJOR_VERSION) && Tk::TK_MAJOR_VERSION >= @min_version
    end

    # Check if this option requires a newer Tcl/Tk version than currently running.
    # Returns the required version if unavailable, nil if available.
    def version_required
      return nil if available?
      @min_version
    end

    def inspect
      alias_str = @aliases.empty? ? "" : " aliases=#{@aliases}"
      version_str = @min_version ? " min_version=#{@min_version}" : ""
      "#<Tk::Option #{@name} tcl=#{@tcl_name} type=#{@type.name}#{alias_str}#{version_str}>"
    end

    private

    def resolve_type(type)
      case type
      when OptionType then type
      when Symbol, String then OptionType[type]
      else OptionType[:string]
      end
    end
  end
end
