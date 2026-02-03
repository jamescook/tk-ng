# frozen_string_literal: true

require_relative 'winfo'
require_relative 'bindable'
require_relative 'busy'

module Tk
  module Core
    # Base widget creation and path management.
    #
    # Handles: path generation, Tcl widget creation, widget registry.
    # Instance methods only. No include+extend pattern.
    module Widget
      include Tk::Core::Winfo
      include Tk::Core::Bindable
      include Tk::Core::Busy

      # When Widget is included in a class, extend with class methods
      def self.included(base)
        base.extend(Tk::Core::Bindable::ClassMethods)
      end

      # Tcl WidgetClassName → Ruby class registry for clean widgets.
      # Used by old-world code (_genobj_for_tkwidget) to find Ruby classes
      # for widget paths created by new-world code.
      @registry = {}

      def self.registry
        @registry
      end

      # Counter for generating unique widget names
      @counter = 0
      @mutex = Mutex.new

      def self.next_id
        @mutex.synchronize { @counter += 1 }
      end

      attr_reader :path

      # Standard widget initialization.
      #
      # @param parent [nil, TkWindow] Parent widget (nil = root window)
      # @param keys [Hash] Widget options
      # @yield Optional block evaluated in widget context (for DSL-style config)
      #
      # Subclasses must define `tk_command` returning the Tcl command (e.g., 'button')
      def initialize(parent = nil, keys = {}, &block)
        # Handle (keys) signature - parent as hash key
        if parent.is_a?(Hash)
          keys = parent
          parent = keys.delete(:parent)
        end

        # Generate unique path
        @path = generate_path(parent, keys.delete(:widgetname))

        # Register in window table
        TkCore::INTERP.tk_windows[@path] = self

        # Create the Tcl widget
        create_widget(keys)

        # Evaluate block in widget context if given (for DSL-style: command proc{})
        instance_eval(&block) if block
      end

      private

      def generate_path(parent, custom_name = nil)
        if custom_name
          name = custom_name
        else
          id = Tk::Core::Widget.next_id
          name = "w#{id}"
        end

        parent_path = parent.respond_to?(:path) ? parent.path : '.'
        parent_path == '.' ? ".#{name}" : "#{parent_path}.#{name}"
      end

      def create_widget(keys)
        cmd = self.class::TkCommandNames[0]
        raise "#{self.class} must define TkCommandNames" unless cmd

        args = [cmd, @path]

        keys.each do |k, v|
          args << "-#{k}"
          # Handle special value types
          case v
          when Proc
            # Register callback
            args << install_cmd(v)
          when TrueClass
            args << '1'
          when FalseClass
            args << '0'
          when Array
            # Convert Ruby array to Tcl list (e.g. values: ["a", "b"])
            args << TclTkLib._merge_tklist(*v.map(&:to_s))
          else
            # Convert Tk objects to their Tcl names:
            # - TkImage/widgets have :path (Tcl widget/image path)
            # - TkVariable/TkBindTag have :to_eval
            if v.respond_to?(:path)
              args << v.path
            elsif v.respond_to?(:to_eval)
              args << v.to_eval
            else
              args << v.to_s
            end
          end
        end

        tk_call(*args)

        # Auto-register in widget registry on first instantiation
        Tk::Core::Widget.registry[self.class::WidgetClassName] ||= self.class
      end

      # @deprecated Override initialize instead.
      #
      # Old-world TkWindow used create_self as the widget creation hook:
      # TkWindow#initialize called create_self(keys), and subclasses
      # overrode it to customize widget creation or run post-creation
      # setup (e.g., compound widgets creating child widgets).
      #
      # Widgets built with Tk::Core::Widget use create_widget for Tcl
      # widget creation and standard Ruby initialize for setup. This
      # method exists so that legacy code calling super in a create_self
      # override gets a clear error instead of a silent NoMethodError.
      #
      # To migrate: move your create_self body into initialize and call
      # super to create the widget.
      def create_self(keys = nil)
        Tk::Warnings.warn_once(:"create_self_deprecated_#{self.class}",
          "#{self.class}#create_self is deprecated. Override initialize instead.")
        raise NoMethodError,
          "#{self.class}#create_self is no longer called. " \
          "Move your create_self code into initialize (call super to create the widget)."
      end

      public

      # Returns true for all Tk widgets.
      # Use this instead of kind_of?(TkWindow) for widget type checks.
      def tk_widget?
        true
      end

      # Destroy this widget and remove from Tk.
      def destroy
        tk_call('destroy', @path)
        TkCore::INTERP.tk_windows.delete(@path)
      end

      # Generate a synthetic event on this widget.
      #
      # @param event [String] Event sequence like 'ButtonPress-1'
      # @param keys [Hash] Optional event fields (x:, y:, etc.)
      #
      def event_generate(event, keys = nil)
        event = "<#{event}>" unless event.start_with?('<')
        if keys
          args = ['event', 'generate', @path, event]
          keys.each { |k, v| args << "-#{k}" << v.to_s }
          tk_call(*args)
        else
          tk_call('event', 'generate', @path, event)
        end
      end

      # Geometry management - pack
      def pack(keys = {})
        args = ['pack', @path]
        keys.each do |k, v|
          args << "-#{k}"
          args << geo_value(v)
        end
        tk_call(*args)
        self
      end

      # Remove from pack geometry management
      def unpack
        tk_call('pack', 'forget', @path)
        self
      end
      alias pack_forget unpack

      # Query or set pack geometry propagation
      def pack_propagate(mode = nil)
        if mode.nil?
          tk_call('pack', 'propagate', @path) == '1'
        else
          tk_call('pack', 'propagate', @path, mode ? '1' : '0')
          self
        end
      end

      # Query or set grid geometry propagation
      def grid_propagate(mode = nil)
        if mode.nil?
          tk_call('grid', 'propagate', @path) == '1'
        else
          tk_call('grid', 'propagate', @path, mode ? '1' : '0')
          self
        end
      end

      # Remove from grid geometry management
      def grid_forget
        tk_call('grid', 'forget', @path)
        self
      end

      # Remove from place geometry management
      def place_forget
        tk_call('place', 'forget', @path)
        self
      end

      # Geometry management - grid
      def grid(keys = {})
        args = ['grid', @path]
        keys.each do |k, v|
          args << "-#{k}"
          args << geo_value(v)
        end
        tk_call(*args)
        self
      end

      # Geometry management - place
      def place(keys = {})
        args = ['place', @path]
        keys.each do |k, v|
          args << "-#{k}"
          args << geo_value(v)
        end
        tk_call(*args)
        self
      end

      private

      # Convert a geometry manager option value to a Tcl string.
      # Prefers epath (composite outer frame) over path (inner widget).
      def geo_value(v)
        if v.is_a?(Array)
          TclTkLib._merge_tklist(*v.map(&:to_s))
        elsif v.respond_to?(:epath)
          v.epath
        elsif v.respond_to?(:path)
          v.path
        else
          v.to_s
        end
      end

      public

      # Place widget inside a target container
      def place_in(target, keys = {})
        keys = keys.dup
        keys[:in] = target
        place(keys)
      end

      # Get or set bind tags for this widget
      def bindtags(taglist = nil)
        if taglist
          fail ArgumentError, "taglist must be Array" unless taglist.kind_of?(Array)
          # Convert each tag to Tcl format
          tcl_tags = taglist.map do |tag|
            case tag
            when String
              tag
            when Class
              # Ruby widget class -> Tcl class name
              tag.const_defined?(:WidgetClassName) ? tag::WidgetClassName : tag.name
            else
              # Widget instance -> path
              # TkBindTag -> to_eval returns Tcl tag id
              # Other objects -> to_s
              if tag.respond_to?(:path)
                tag.path
              elsif tag.respond_to?(:to_eval)
                tag.to_eval
              else
                tag.to_s
              end
            end
          end
          tcl_list = TclTkLib._merge_tklist(*tcl_tags)
          tk_call('bindtags', @path, tcl_list)
          taglist
        else
          result = tk_call('bindtags', @path)
          tags = TclTkLib._split_tklist(result)
          # Replace own path with self so tags.index(self) works
          tags.map { |t| t == @path ? self : t }
        end
      end

      def bindtags=(taglist)
        bindtags(taglist)
      end
    end
  end
end
