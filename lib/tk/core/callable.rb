# frozen_string_literal: true

module Tk
  module Core
    # Clean tk_call interface for widgets.
    #
    # Instance methods only. No include+extend pattern.
    module Callable
      NONE = TkUtil::None

      # Call a Tcl command with this widget's path as first arg
      def tk_send(cmd, *args)
        TkCore::INTERP._invoke(path, cmd, *tcl_args(args))
      end

      # Call arbitrary Tcl command (not widget-specific)
      def tk_call(*args)
        TkCore::INTERP._invoke(*tcl_args(args))
      end

      private

      # Convert args to Tcl strings, filtering out None sentinels.
      def tcl_args(args)
        args.each_with_object([]) do |a, out|
          next if a.equal?(NONE)
          if a.respond_to?(:to_eval)
            out << a.to_eval
          elsif a.respond_to?(:path)
            out << a.path
          else
            out << a.to_s
          end
        end
      end

      # Convert a single Ruby value to a Tcl string.
      #
      # Handles widgets (path), booleans, procs (via install_cmd),
      # symbols, arrays, hashes, and falls back to to_s.
      #
      # @param v [Object] Ruby value
      # @return [String] Tcl representation
      def value_to_tcl(v)
        case v
        when String then v
        when true then '1'
        when false then '0'
        when Integer, Float then v.to_s
        when Symbol then v.to_s
        when Proc
          respond_to?(:install_cmd) ? install_cmd(v) : v.to_s
        when Array
          # Flat array of simple values → separate Tcl list elements
          # Complex array (contains Hash/Symbol) → nested Tcl list
          parts = []
          v.each do |el|
            if el.is_a?(Hash)
              el.each { |hk, hv| parts << "-#{hk}"; parts << value_to_tcl(hv) }
            else
              parts << value_to_tcl(el)
            end
          end
          TclTkLib._merge_tklist(*parts)
        when Hash
          parts = []
          v.each { |hk, hv| parts << "-#{hk}"; parts << value_to_tcl(hv) }
          TclTkLib._merge_tklist(*parts)
        else
          return v.path if v.respond_to?(:path)
          return v.to_eval if v.respond_to?(:to_eval)
          v.to_s
        end
      end

      # Convert a Hash of options to a flat array of Tcl -key value args.
      #
      # @param hash [Hash] {key: value, ...}
      # @param flat_arrays [Boolean] If true, Array values are flattened
      #   as separate args (e.g. to: [0,0,16,16] → -to 0 0 16 16).
      #   If false, Array values become a single Tcl list string.
      # @return [Array<String>] ['-key', 'val', '-key2', 'val2', ...]
      def hash_to_args(hash, flat_arrays: false)
        result = []
        hash.each do |k, v|
          next if v.equal?(NONE)
          result << "-#{k}"
          if flat_arrays && v.is_a?(Array) && v.all? { |el| el.is_a?(Integer) || el.is_a?(String) || el.is_a?(Float) }
            v.each { |el| result << el.to_s }
          else
            result << value_to_tcl(v)
          end
        end
        result
      end

      # Convert a Tcl string to an appropriate Ruby value.
      #
      # @param val [String] Tcl string
      # @return [Object] Integer, true/false, or String
      def value_from_tcl(val)
        return val unless val.is_a?(String)
        case val
        when '1', 'true', 'yes' then true
        when '0', 'false', 'no' then false
        when /\A-?\d+\z/ then val.to_i
        when /\A-?\d+\.\d+\z/ then val.to_f
        else val
        end
      end

      # @deprecated Legacy encoding variants - just use tk_send/tk_call
      def tk_send_without_enc(cmd, *args) = tk_send(cmd, *args)
      def tk_send_with_enc(cmd, *args) = tk_send(cmd, *args)
      def tk_call_without_enc(*args) = tk_call(*args)
      def tk_call_with_enc(*args) = tk_call(*args)
    end
  end
end
