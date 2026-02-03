# frozen_string_literal: true
require 'set'

module Tk
  module Core
    # Simple event object for bind callbacks
    class BindEvent
      attr_reader :x, :y, :rootx, :rooty, :width, :height,
                  :keycode, :keysym, :char, :state, :time,
                  :widget, :type, :serial, :wheel_delta,
                  :borderwidth, :send_event, :mode, :override,
                  :place, :value_mask

      alias delta wheel_delta

      def initialize(attrs = {})
        attrs.each { |k, v| instance_variable_set("@#{k}", v) }
      end
    end

    # Clean event binding for widgets.
    # Provides both instance-level and class-level binding.
    #
    # Instance: widget.bind('Button-1') { ... }
    # Class: Tk::Button.bind('Button-1') { ... }  # binds to ALL buttons
    #
    module Bindable
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Class methods for class-level binding (binds to all instances)
      module ClassMethods
        def bind(event, cmd = nil, args = nil, &block)
          cmd ||= block
          return self unless cmd

          do_class_bind(event, cmd, args: args, append: false)
          self
        end

        def bind_append(event, cmd = nil, args = nil, &block)
          cmd ||= block
          return self unless cmd

          do_class_bind(event, cmd, args: args, append: true)
          self
        end

        def bind_remove(event)
          event = normalize_event(event)
          TkCore::INTERP._invoke('bind', self::WidgetClassName, event, '')
          self
        end

        def bindinfo(event = nil)
          if event
            event = normalize_event(event)
            TkCore::INTERP._invoke('bind', self::WidgetClassName, event)
          else
            result = TkCore::INTERP._invoke('bind', self::WidgetClassName)
            TclTkLib._split_tklist(result)
          end
        end

        private

        def normalize_event(event)
          if event.start_with?('<<')
            event
          elsif event.start_with?('<')
            # Virtual events: <Name> with no modifier → <<Name>>
            # Physical events contain dashes or known prefixes
            inner = event[1..-2]
            if inner && !inner.match?(/[-\s]/) && inner.match?(/\A[A-Z]/) && !PHYSICAL_EVENTS.include?(inner)
              "<#{event}>"
            else
              event
            end
          else
            "<#{event}>"
          end
        end

        # Known Tcl physical event types (not virtual events)
        PHYSICAL_EVENTS = %w[
          Activate ButtonPress ButtonRelease Button Circulate Colormap Configure
          Deactivate Destroy Enter Expose FocusIn FocusOut Gravity
          KeyPress KeyRelease Key Leave Map Motion MouseWheel
          Property Reparent Unmap Visibility
        ].to_set.freeze

        def do_class_bind(event, cmd, args: nil, append: false)
          event = normalize_event(event)

          if args
            callback_id = TkCallback.install_cmd(cmd)
            script = "#{callback_id} #{args}"
          elsif cmd.arity != 0
            wrapper = proc do |*cb_args|
              evt = Bindable.parse_event_args(cb_args)
              cmd.call(evt)
            end
            callback_id = TkCallback.install_cmd(wrapper)
            subst_args = Bindable::EVENT_SUBST.values.join(' ')
            script = "#{callback_id} #{subst_args}"
          else
            callback_id = TkCallback.install_cmd(cmd)
            script = callback_id
          end

          script = '+' + script if append
          TkCore::INTERP._invoke('bind', self::WidgetClassName, event, script)
        end
      end
      # Common event substitution fields
      # Maps Ruby attr name to Tcl substitution code
      EVENT_SUBST = {
        x: '%x',
        y: '%y',
        rootx: '%X',
        rooty: '%Y',
        width: '%w',
        height: '%h',
        keycode: '%k',
        keysym: '%K',
        char: '%A',
        state: '%s',
        time: '%t',
        widget: '%W',
        type: '%T',
        serial: '%#',
        wheel_delta: '%D',
        borderwidth: '%B',
        send_event: '%E',
        mode: '%m',
        override: '%o',
        place: '%p',
        value_mask: '%v'
      }.freeze

      # Substitution keys that should be converted to integers
      INT_SUBST_KEYS = Set[:x, :y, :rootx, :rooty, :width, :height,
                           :keycode, :state, :time, :serial, :type,
                           :wheel_delta, :borderwidth, :value_mask].freeze

      # Bind an event to this widget.
      #
      # @param event [String] Event sequence like 'Button-1', '<Enter>', 'KeyPress-a'
      # @param cmd [Proc] Optional callback (alternative to block)
      # @yield [event] Block receives BindEvent object with event details
      # @return [self]
      #
      # @example
      #   button.bind('Button-1') { |e| puts "clicked at #{e.x}, #{e.y}" }
      #   button.bind('<Enter>') { puts "mouse entered" }
      #
      def bind(event, cmd = nil, *args, &block)
        cmd ||= block
        return self unless cmd

        do_bind(event, cmd, raw_args: args.empty? ? nil : args, append: false)
        self
      end

      # Append a binding without replacing existing ones.
      #
      # @param event [String] Event sequence
      # @param args [String, nil] Tcl substitution string (e.g. "%W %x")
      # @yield [event] Block receives BindEvent object
      # @return [self]
      #
      def bind_append(event, cmd = nil, *args, &block)
        cmd ||= block
        return self unless cmd

        do_bind(event, cmd, raw_args: args.empty? ? nil : args, append: true)
        self
      end

      # Remove a binding for an event.
      #
      # @param event [String] Event sequence
      # @return [self]
      #
      def bind_remove(event)
        event = normalize_event(event)
        tk_call('bind', @path, event, '')
        self
      end

      # Get current binding(s) for this widget.
      #
      # @param event [String, nil] Event sequence, or nil for all bound events
      # @return [String, Array<String>] Binding script or list of bound events
      #
      def bindinfo(event = nil)
        if event
          event = normalize_event(event)
          tk_call('bind', @path, event)
        else
          result = tk_call('bind', @path)
          TclTkLib._split_tklist(result)
        end
      end

      # Parse event substitution args into BindEvent (shared by instance and class methods)
      def self.parse_event_args(args)
        attrs = {}
        EVENT_SUBST.keys.each_with_index do |key, i|
          val = args[i]
          if INT_SUBST_KEYS.include?(key)
            attrs[key] = val.to_i rescue val
          elsif key == :widget
            attrs[key] = TkCore::INTERP.tk_windows[val] || val
          else
            attrs[key] = val
          end
        end
        BindEvent.new(attrs)
      end

      private

      def normalize_event(event)
        if event.respond_to?(:path)
          # TkVirtualEvent#path is "<VirtEventNNN>" — Tcl bind needs "<<VirtEventNNN>>"
          path = event.path
          return "<#{path}>"
        end

        if event.start_with?('<<')
          event
        elsif event.start_with?('<')
          inner = event[1..-2]
          if inner && !inner.match?(/[-\s]/) && inner.match?(/\A[A-Z]/) && !ClassMethods::PHYSICAL_EVENTS.include?(inner)
            "<#{event}>"
          else
            event
          end
        else
          "<#{event}>"
        end
      end

      # Convert symbol args (e.g. :x, :y) to Tcl % substitutions (%x, %y).
      # Strings are passed through as-is (already Tcl format).
      def _subst_args(args)
        args.map { |a|
          a.is_a?(Symbol) ? (EVENT_SUBST[a] || "%#{a}") : a.to_s
        }.join(' ')
      end

      def do_bind(event, cmd, raw_args: nil, append: false)
        event = normalize_event(event)

        if raw_args
          # Caller provided explicit args (e.g. :x, :y or "%x %y").
          # Convert symbols to % substitutions and wrap with type conversion.
          sym_keys = raw_args.select { |a| a.is_a?(Symbol) }
          subst_str = _subst_args(raw_args)

          if sym_keys.any?
            # Wrap callback to convert Tcl strings to Ruby types
            int_keys = INT_SUBST_KEYS & sym_keys
            wrapper = proc do |*cb_args|
              converted = cb_args.each_with_index.map do |val, i|
                int_keys.include?(sym_keys[i]) ? (val.to_i rescue val) : val
              end
              cmd.call(*converted)
            end
            callback_id = install_cmd(wrapper)
          else
            callback_id = install_cmd(cmd)
          end
          script = "#{callback_id} #{subst_str}"
        elsif cmd.arity != 0
          # Auto-wrap with standard event substitutions → BindEvent object
          wrapper = proc do |*cb_args|
            evt = Bindable.parse_event_args(cb_args)
            cmd.call(evt)
          end
          callback_id = install_cmd(wrapper)
          subst_args = EVENT_SUBST.values.join(' ')
          script = "#{callback_id} #{subst_args}"
        else
          callback_id = install_cmd(cmd)
          script = callback_id
        end

        script = '+' + script if append
        tk_call('bind', @path, event, script)
      end
    end
  end
end
