# frozen_string_literal: true

module Tk
  module Core
    # Option configuration (cget/configure) for widgets.
    #
    # Instance methods only. No include+extend pattern.
    #
    # TODO: Consider including this from Tk::Generated::* modules automatically.
    # Widgets should use typed accessors (e.g., `text`, `width`) not raw cget.
    # cget/configure are implementation details that Generated modules depend on.
    module Configurable
      # Get an option value.
      def cget(slot)
        slot = slot.to_s
        raise ArgumentError, "Invalid option `#{slot.inspect}'" if slot.empty?

        # Resolve via OptionDSL registry if available
        opt = self.class.respond_to?(:resolve_option) && self.class.resolve_option(slot)
        slot = opt.tcl_name if opt

        raw_value = tk_call(path, 'cget', "-#{slot}")

        # Type conversion via Option registry
        if opt
          opt.from_tcl(raw_value, widget: self)
        else
          raw_value
        end
      end

      # Set one or more options.
      def configure(slot, value = nil)
        if slot.is_a?(Hash)
          slot.each { |k, v| configure(k, v) }
        else
          slot = slot.to_s
          raise ArgumentError, "Invalid option `#{slot.inspect}'" if slot.empty?

          # Resolve via OptionDSL registry if available
          opt = self.class.respond_to?(:resolve_option) && self.class.resolve_option(slot)
          slot = opt.tcl_name if opt

          # Convert value to Tcl string via Option type system or fallback
          tcl_value = if value.is_a?(Array)
            TclTkLib._merge_tklist(*value.map(&:to_s))
          elsif opt
            opt.to_tcl(value, widget: self)
          elsif value.respond_to?(:path)
            value.path
          elsif value.respond_to?(:to_eval)
            value.to_eval
          else
            value.to_s
          end

          tk_call(path, 'configure', "-#{slot}", tcl_value)
        end
        self
      end

      # Configure an option with a command (proc/lambda) value.
      # Registers the command as a Tcl callback and sets the option to the callback ID.
      def configure_cmd(slot, value)
        configure(slot, install_cmd(value))
      end

      # Query configuration info for one or all options.
      # Returns [name, dbname, dbclass, default, current] arrays.
      def configinfo(slot = nil)
        if slot
          slot = slot.to_s
          info = TclTkLib._split_tklist(tk_call(path, 'configure', "-#{slot}"))
          info[0] = info[0].sub(/\A-/, '') if info[0]
          info
        else
          TclTkLib._split_tklist(tk_call(path, 'configure')).map { |item|
            info = TclTkLib._split_tklist(item)
            info[0] = info[0].sub(/\A-/, '') if info[0]
            info
          }
        end
      end

      # Returns a hash of {option_name => current_value}.
      # TODO: tk-2hb - unify with configinfo into a single Hash-returning method
      def current_configinfo(slot = nil)
        if slot
          {slot.to_s => cget(slot)}
        else
          result = {}
          configinfo.each do |conf|
            result[conf[0]] = conf[-1] if conf.size > 2
          end
          result
        end
      end

      alias cget_strict cget

      # Hash-style access
      def [](key)
        cget(key)
      end

      def []=(key, value)
        configure(key, value)
      end
    end
  end
end
