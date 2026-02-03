# frozen_string_literal: true

module Tk
  # Type converters for widget options.
  #
  # OptionType handles bidirectional conversion between Ruby values and
  # Tcl strings. Each type defines two converters:
  # - `to_tcl`: Ruby value -> Tcl string (for configure)
  # - `from_tcl`: Tcl string -> Ruby value (for cget)
  #
  # ## Built-in Types
  #
  # | Type        | Ruby                | Tcl         | Notes                              |
  # |-------------|---------------------|-------------|------------------------------------|
  # | :string     | String              | String      | Pass-through                       |
  # | :integer    | Integer             | "123"       | Handles dimension strings like "10c" |
  # | :float      | Float               | "1.5"       | Handles dimension strings like "1.5i" |
  # | :boolean    | true/false          | "1"/"0"     | Accepts "yes/no", "on/off"         |
  # | :list       | Array               | "a b c"     | Space-separated                    |
  # | :pixels     | Integer or String   | "10" or "2c"| Preserves unit suffixes            |
  # | :color      | String              | "red"       | Color names or #RRGGBB             |
  # | :anchor     | Symbol/String       | "nw"        | n, ne, e, se, s, sw, w, nw, center |
  # | :relief     | Symbol/String       | "raised"    | flat, raised, sunken, groove, ridge|
  # | :widget     | TkWindow            | ".path"     | Converts path to widget object     |
  # | :tkvariable | TkVariable          | "varname"   | Converts to TkVarAccess            |
  # | :font       | TkFont              | "fontspec"  | Creates TkFont wrapper             |
  # | :callback   | Proc                | "cb_id"     | Registers callback, returns ID     |
  # | :canvas_tags| Array of TkcTag     | "tag1 tag2" | Converts to TkcTag objects         |
  #
  # @example Using built-in types
  #   OptionType[:boolean].to_tcl(true)     # => "1"
  #   OptionType[:boolean].from_tcl("yes")  # => true
  #
  #   OptionType[:integer].from_tcl("10c")  # => 10 (ignores unit suffix)
  #   OptionType[:list].to_tcl([:a, :b])    # => "a b"
  #
  # @example Registering a custom type
  #   MyType = OptionType.new(:mytype,
  #     to_tcl: ->(v) { v.upcase },
  #     from_tcl: ->(v) { v.downcase.to_sym }
  #   )
  #   OptionType.register(:mytype, MyType)
  #
  # @see Option Uses OptionType for value conversion
  # @see OptionDSL Declares options with type: parameter
  class OptionType
    # @return [Symbol] Type name (e.g., :string, :boolean, :widget)
    attr_reader :name

    # Tcl 9.0 uses empty string for "unset" numeric options (e.g. -underline)
    # where Tcl 8.6 used -1. Cached on first call (Tk::TK_VERSION is set at
    # interpreter startup, which always happens before any cget/configure).
    def self.tcl9?
      @tcl9 = (Tk::TK_VERSION.to_f >= 9.0) unless defined?(@tcl9)
      @tcl9
    end

    # Create a new type converter.
    #
    # @param name [Symbol] Type name for registry lookup
    # @param to_tcl [Symbol, Proc] Converter for Ruby -> Tcl.
    #   If Symbol, calls that method on the value.
    #   If Proc, calls with (value) or (value, widget:).
    # @param from_tcl [Symbol, Proc] Converter for Tcl -> Ruby.
    #   Same calling convention as to_tcl.
    #
    # @example Simple type using method names
    #   OptionType.new(:upcase, to_tcl: :upcase, from_tcl: :downcase)
    #
    # @example Type with procs
    #   OptionType.new(:reversed,
    #     to_tcl: ->(v) { v.reverse },
    #     from_tcl: ->(v) { v.reverse }
    #   )
    #
    # @example Type needing widget context
    #   OptionType.new(:widget,
    #     to_tcl: ->(v, widget:) { v.path },
    #     from_tcl: ->(v, widget:) { widget.window(v) }
    #   )
    def initialize(name, to_tcl:, from_tcl:)
      @name = name
      @to_tcl = to_tcl
      @from_tcl = from_tcl
    end

    # Convert a Ruby value to Tcl string representation.
    #
    # @param value [Object] Ruby value to convert
    # @param widget [TkWindow, nil] Widget context for types that need it
    # @return [String] Tcl string representation
    def to_tcl(value, widget: nil)
      case @to_tcl
      when Symbol then value.send(@to_tcl)
      when Proc
        @to_tcl.arity == 1 ? @to_tcl.call(value) : @to_tcl.call(value, widget: widget)
      else
        value.to_s
      end
    end

    # Convert a Tcl string to Ruby value.
    #
    # @param value [String] Tcl string to convert
    # @param widget [TkWindow, nil] Widget context for types that need it
    # @return [Object] Ruby value
    def from_tcl(value, widget: nil)
      case @from_tcl
      when Symbol then value.send(@from_tcl)
      when Proc
        @from_tcl.arity == 1 ? @from_tcl.call(value) : @from_tcl.call(value, widget: widget)
      else
        value
      end
    end

    def inspect
      "#<Tk::OptionType:#{@name}>"
    end

    # Built-in type converters.
    #
    # Access via `OptionType::Types::Boolean` or `OptionType[:boolean]`.
    module Types
      String = OptionType.new(:string,
        to_tcl: ->(v) {
          if v.respond_to?(:path)
            v.path
          elsif v.respond_to?(:to_eval)
            v.to_eval
          else
            v.to_s
          end
        },
        from_tcl: :itself
      )

      Integer = OptionType.new(:integer,
        to_tcl: ->(v) {
          if v.nil?
            # Tcl 9.0 defaults some integer options to "" (empty = unset);
            # Tcl 8.6 used -1 for the same purpose. Preserve the appropriate sentinel.
            OptionType.tcl9? ? '' : '-1'
          else
            v.to_i.to_s
          end
        },
        # Tcl 9.0 returns "" for unset integer options; map to nil.
        # Use to_i to handle Tcl dimension strings like "10c" (centimeters).
        from_tcl: ->(v) { v.to_s.empty? ? nil : v.to_s.to_i }
      )

      Float = OptionType.new(:float,
        to_tcl: ->(v) {
          if v.nil?
            OptionType.tcl9? ? '' : v.to_f.to_s
          else
            v.to_f.to_s
          end
        },
        from_tcl: ->(v) { v.to_s.empty? ? nil : v.to_s.to_f }
      )

      Boolean = OptionType.new(:boolean,
        to_tcl: ->(v) {
          case v
          when ::String
            v.match?(/^(0|false|no|off)$/i) ? "0" : "1"
          else
            v ? "1" : "0"
          end
        },
        from_tcl: ->(v) { !v.to_s.match?(/^(0|false|no|off|)$/i) }
      )

      # List of strings
      List = OptionType.new(:list,
        to_tcl: ->(v) { Array(v).join(" ") },
        from_tcl: ->(v) { v.to_s.split }
      )

      # Pixels - can be integer or string with units (e.g., "10p", "2c")
      Pixels = OptionType.new(:pixels,
        to_tcl: :to_s,
        from_tcl: ->(v) { v =~ /^\d+$/ ? Integer(v) : v }
      )

      # Color - just a string but semantically distinct
      Color = OptionType.new(:color,
        to_tcl: :to_s,
        from_tcl: :itself
      )

      # Anchor position (n, ne, e, se, s, sw, w, nw, center)
      # to_tcl: accepts symbol or string (e.g., :nw or "nw")
      # from_tcl: returns string for backwards compatibility
      Anchor = OptionType.new(:anchor,
        to_tcl: :to_s,
        from_tcl: :to_s
      )

      # Relief style (flat, raised, sunken, groove, ridge, solid)
      # to_tcl: accepts symbol or string (e.g., :raised or "raised")
      # from_tcl: returns string for backwards compatibility
      Relief = OptionType.new(:relief,
        to_tcl: :to_s,
        from_tcl: :to_s
      )

      # Widget reference - converts Tcl path to Ruby widget object
      Widget = OptionType.new(:widget,
        to_tcl: ->(v, widget:) { v.respond_to?(:path) ? v.path : v.to_s },
        from_tcl: ->(v, widget:) {
          path = v.to_s
          return nil unless path =~ /^\./
          TkCore::INTERP.tk_windows[path] || path
        }
      )

      # TkVariable reference - converts Tcl variable name to TkVarAccess
      # Used for textvariable, variable, listvariable options
      TkVariable = OptionType.new(:tkvariable,
        to_tcl: ->(v) { v.respond_to?(:id) ? v.id : v.to_s },
        from_tcl: ->(v) { v.to_s.empty? ? nil : TkVarAccess.new(v) }
      )

      # Font - wraps font string in TkFont for backwards compatibility
      # Allows font.weight('bold') style method chaining
      # Uses TkFont.id2obj to return the same TkFont object if already registered
      # Passes widget reference so font setters can reconfigure the widget
      Font = OptionType.new(:font,
        to_tcl: ->(v) { v.to_s },
        from_tcl: ->(v, widget:) {
          return nil if v.to_s.empty?
          existing = TkFont.id2obj(v)
          return existing if existing
          # Create new TkFont with widget reference for auto-reconfigure
          TkFont.new(v, nil, widget: widget)
        }
      )

      # Callback - Tcl command string, typically registered via install_cmd
      # to_tcl: proc/lambda gets registered and returns callback ID
      # from_tcl: returns the raw Tcl command string (can't recover proc)
      Callback = OptionType.new(:callback,
        to_tcl: ->(v, widget:) {
          if v.respond_to?(:call)
            # Register the proc and return callback ID
            widget.install_cmd(v) if widget
          else
            v.to_s
          end
        },
        from_tcl: ->(v) { v.to_s }
      )

      # Validation callback - wraps procs in ValidateCmd for proper Tcl
      # substitution args (%P, %d, etc.) and boolean return value conversion.
      # Handles: plain procs, [proc, :value, :action] arrays, ValidateCmd objects, strings.
      ValidateCallback = OptionType.new(:validate_callback,
        to_tcl: ->(v, widget:) {
          require 'tk/validation'
          if v.is_a?(Array)
            # [proc, :value, :action] form
            cmd, *args = v
            TkValidation::ValidateCmd.new(cmd, *args).to_eval
          elsif v.respond_to?(:call)
            # Plain proc/lambda - wrap in ValidateCmd for ret_val and substitution
            TkValidation::ValidateCmd.new(v).to_eval
          elsif v.respond_to?(:to_eval)
            # Already a ValidateCmd or similar
            v.to_eval
          else
            v.to_s
          end
        },
        from_tcl: ->(v) { v.to_s }
      )

      # Canvas tags - converts space-separated tag names to TkcTag objects
      # Looks up registered tags via the canvas widget's canvastagid2obj method
      CanvasTags = OptionType.new(:canvas_tags,
        to_tcl: ->(v, widget:) {
          Array(v).map { |t| t.respond_to?(:id) ? t.id : t.to_s }.join(' ')
        },
        from_tcl: ->(v, widget:) {
          return [] if v.to_s.empty?
          tag_names = v.to_s.split
          tag_names.map { |tag_name| widget.canvastagid2obj(tag_name) }
        }
      )
    end

    # @!visibility private
    # Registry for looking up types by name
    @registry = {}

    class << self
      # Register a type converter by name.
      #
      # @param name [Symbol, String] Type name for lookup
      # @param type [OptionType] Type converter instance
      # @return [OptionType] The registered type
      def register(name, type)
        @registry[name.to_sym] = type
      end

      # Look up a type converter by name.
      #
      # @param name [Symbol, String] Type name
      # @return [OptionType] The type, or Types::String if not found
      #
      # @example
      #   OptionType[:boolean]  # => OptionType::Types::Boolean
      #   OptionType[:unknown]  # => OptionType::Types::String (fallback)
      def [](name)
        @registry[name.to_sym] || Types::String
      end

      # Check if a type is registered.
      #
      # @param name [Symbol, String] Type name
      # @return [Boolean]
      def registered?(name)
        @registry.key?(name.to_sym)
      end
    end

    # Register built-in types
    Types.constants.each do |const|
      type = Types.const_get(const)
      register(type.name, type) if type.is_a?(OptionType)
    end
  end
end
