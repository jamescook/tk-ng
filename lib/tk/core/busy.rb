# frozen_string_literal: true

module Tk
  module Core
    # Clean busy methods for widgets.
    # Wraps 'tk busy' Tcl commands. No old-world dependencies.
    module Busy
      def busy(keys = {})
        args = ['tk', 'busy', 'hold', @path]
        keys.each { |k, v| args << "-#{k}" << v.to_s }
        tk_call(*args)
        self
      end
      alias busy_hold busy

      def busy_forget
        tk_call('tk', 'busy', 'forget', @path)
        self
      end

      def busy_status
        tk_call('tk', 'busy', 'status', @path) == '1'
      end

      def busy_current?
        !tk_call('tk', 'busy', 'current', @path).empty?
      end

      def busy_configure(option, value = nil)
        if option.is_a?(Hash)
          args = ['tk', 'busy', 'configure', @path]
          option.each { |k, v| args << "-#{k}" << v.to_s }
          tk_call(*args)
        else
          tk_call('tk', 'busy', 'configure', @path, "-#{option}", value.to_s)
        end
        self
      end

      def busy_cget(option)
        tk_call('tk', 'busy', 'cget', @path, "-#{option}")
      end
    end
  end
end
