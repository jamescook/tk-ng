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

      # @deprecated Legacy encoding variants - just use tk_send/tk_call
      def tk_send_without_enc(cmd, *args) = tk_send(cmd, *args)
      def tk_send_with_enc(cmd, *args) = tk_send(cmd, *args)
      def tk_call_without_enc(*args) = tk_call(*args)
      def tk_call_with_enc(*args) = tk_call(*args)
    end
  end
end
