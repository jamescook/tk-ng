# frozen_string_literal: true

require_relative 'option'

module Tk
  # DSL for declaring item options on container widgets.
  #
  # ItemOptionDSL is for widgets that contain configurable items:
  # - Canvas items (rectangles, lines, text, etc.)
  # - Menu entries
  # - Text widget tags, marks, images, windows
  # - Listbox entries (conceptually)
  #
  # This module provides:
  # 1. Class-level DSL for declaring item options
  # 2. Instance methods for itemcget/itemconfigure
  # 3. Flexible command building for different widget patterns
  #
  # ## Basic Usage
  #
  #     class TkCanvas
  #       extend Tk::ItemOptionDSL
  #
  #       # Specify Tcl subcommands
  #       item_commands cget: 'itemcget', configure: 'itemconfigure'
  #
  #       # Declare item options with types
  #       item_option :fill, type: :color
  #       item_option :outline, type: :color
  #       item_option :width, type: :integer
  #       item_option :smooth, type: :boolean
  #     end
  #
  #     # Instance methods are automatically available:
  #     canvas.itemcget(item_id, :fill)
  #     canvas.itemconfigure(item_id, fill: 'red', width: 2)
  #
  # ## Command Patterns
  #
  # Different widgets use different Tcl command patterns:
  #
  #     # Canvas: .canvas itemcget $id -option
  #     item_commands cget: 'itemcget', configure: 'itemconfigure'
  #
  #     # Menu: .menu entrycget $index -option
  #     item_commands cget: 'entrycget', configure: 'entryconfigure'
  #
  # For complex patterns, use procs:
  #
  #     # Text widget: .text $type cget $id -option
  #     item_cget_cmd { |(type, id)| [path, type, 'cget', id] }
  #     item_configure_cmd { |(type, id)| [path, type, 'configure', id] }
  #
  # ## Inheritance
  #
  # Item options and command configuration are inherited by subclasses,
  # allowing specialized widgets to extend the base set.
  #
  # @example Canvas with item options
  #   canvas.itemconfigure(rect, fill: 'blue', outline: 'black')
  #   color = canvas.itemcget(rect, :fill)  # => "blue"
  #
  # @example Menu with entry options
  #   menu.entryconfigure(0, label: 'New', command: proc { new_file })
  #   label = menu.entrycget(0, :label)  # => "New"
  #
  # @see OptionDSL For widget-level options
  # @see Option Metadata for individual options
  module ItemOptionDSL
    # Called when module is extended into a class/module - adds instance methods
    def self.extended(base)
      base.instance_variable_set(:@_item_options, {})
      if base.is_a?(Class)
        # Class: include so instances get the methods
        base.include(InstanceMethods)
      else
        # Module singleton (like Tk::Busy): extend so module itself gets the methods
        base.extend(InstanceMethods)
      end
    end

    # Inherit item options and command config from parent class
    def inherited(subclass)
      super
      if instance_variable_defined?(:@_item_options)
        subclass.instance_variable_set(:@_item_options, _item_options.dup)
      end
      # Inherit item command configuration
      %i[@_item_command_cget @_item_command_configure
         @_item_cget_proc @_item_configure_proc].each do |ivar|
        if instance_variable_defined?(ivar)
          subclass.instance_variable_set(ivar, instance_variable_get(ivar))
        end
      end
    end

    # Declare an item option for this widget class.
    #
    # @param name [Symbol] Ruby-facing option name
    # @param type [Symbol] Type converter (:string, :integer, :boolean, etc.)
    # @param tcl_name [String, nil] Tcl option name if different from Ruby name
    # @param alias [Symbol, nil] Single alias for this option
    # @param aliases [Array<Symbol>] Alternative names for this option
    #
    def item_option(name, type: :string, tcl_name: nil, alias: nil, aliases: [])
      # Support both alias: :foo (single) and aliases: [:foo, :bar] (multiple)
      all_aliases = Array(binding.local_variable_get(:alias)) + Array(aliases)
      all_aliases.compact!

      opt = Option.new(name: name, tcl_name: tcl_name, type: type, aliases: all_aliases)
      _item_options[opt.name] = opt
      all_aliases.each { |a| _item_options[a.to_sym] = opt }
    end

    # All declared item options (including aliases pointing to same Option)
    def item_options
      _item_options.dup
    end

    # Look up an item option by name or alias
    #
    # @param name [Symbol, String] Option name or alias
    # @return [Tk::Option, nil]
    #
    def resolve_item_option(name)
      _item_options[name.to_sym]
    end

    # List of canonical item option names (excludes aliases)
    def item_option_names
      _item_options.values.uniq.map(&:name)
    end

    def declared_item_optkey_aliases
      _item_options.values.uniq.each_with_object({}) do |opt, hash|
        opt.aliases.each { |a| hash[a] = opt.name }
      end
    end

    # ========================================================================
    # Item Command DSL
    # ========================================================================
    #
    # Declarative way to specify how item cget/configure commands are built.
    #
    # Simple usage (most widgets):
    #   item_commands cget: 'entrycget', configure: 'entryconfigure'
    #
    # Full control via procs:
    #   item_cget_cmd { |(type, tag_or_id)| [path, type, 'cget', tag_or_id] }
    #   item_configure_cmd { |(type, tag_or_id)| [path, type, 'configure', tag_or_id] }
    #
    # ========================================================================

    # Shorthand for widgets that just need different command words.
    # Builds: [path, cget_cmd, id] and [path, configure_cmd, id]
    #
    # @param cget [String] The cget subcommand (e.g., 'itemcget', 'entrycget')
    # @param configure [String] The configure subcommand (e.g., 'itemconfigure', 'entryconfigure')
    #
    def item_commands(cget:, configure:)
      @_item_command_cget = cget
      @_item_command_configure = configure
    end

    # Full control over cget command building via a block.
    # Block receives (id) and should return command array.
    # Block is instance_exec'd on the widget, so `path` etc. are available.
    #
    # @example Text widget with structured id
    #   item_cget_cmd { |(type, tag_or_id)| [path, type, 'cget', tag_or_id] }
    #
    # @example Treeview where id is splatted
    #   item_cget_cmd { |id| [path, *id] }
    #
    # @example Busy with window path extraction
    #   item_cget_cmd { |win| ['tk', 'busy', 'cget', win.path] }
    #
    def item_cget_cmd(&block)
      @_item_cget_proc = block
    end

    # Full control over configure command building via a block.
    #
    def item_configure_cmd(&block)
      @_item_configure_proc = block
    end

    # Returns the item command configuration, or nil if not configured.
    #
    # @return [Hash, nil] Configuration hash with :cget, :configure, :cget_proc, :configure_proc
    #
    def item_command_config
      cget_cmd = instance_variable_get(:@_item_command_cget)
      cget_proc = instance_variable_get(:@_item_cget_proc)

      return nil unless cget_cmd || cget_proc

      {
        cget: cget_cmd,
        configure: instance_variable_get(:@_item_command_configure),
        cget_proc: cget_proc,
        configure_proc: instance_variable_get(:@_item_configure_proc),
      }
    end

    private

    def _item_options
      @_item_options ||= {}
    end

    # Instance methods for item configuration.
    #
    # Automatically included when extending ItemOptionDSL.
    # Provides itemcget, itemconfigure, itemconfiginfo methods.
    #
    # @note These methods use the DSL configuration to build Tcl commands
    #   and convert values using declared item options.
    module InstanceMethods
      include TkUtil

      # Get raw Tcl string value for an item option (no type conversion).
      #
      # @param tagOrId [Object] Item identifier
      # @param option [Symbol, String] Option name
      # @return [String] Raw Tcl value
      def itemcget_tkstring(tagOrId, option)
        opt = option.to_s
        raise ArgumentError, "Invalid option `#{option.inspect}'" if opt.empty?
        tk_call_without_enc(*(_item_cget_cmd(tagid(tagOrId)) << "-#{opt}"))
      end

      # Get an item option value with type conversion.
      #
      # @param tagOrId [Object] Item identifier (e.g., canvas item ID, menu index)
      # @param option [Symbol, String] Option name (aliases are resolved)
      # @return [Object] Ruby value (converted from Tcl)
      #
      # @example
      #   canvas.itemcget(rect, :fill)     # => "blue"
      #   canvas.itemcget(rect, :width)    # => 2 (Integer, not "2")
      #   canvas.itemcget(rect, :smooth)   # => true (Boolean)
      def itemcget(tagOrId, option)
        option = option.to_s
        raise ArgumentError, "Invalid option `#{option.inspect}'" if option.empty?

        # Resolve alias if declared
        if self.class.respond_to?(:resolve_item_option)
          opt = self.class.resolve_item_option(option)
          option = opt.tcl_name if opt
        end

        raw = tk_call_without_enc(*(_item_cget_cmd(tagid(tagOrId)) << "-#{option}"))
        _convert_item_value(option, raw)
      end
      alias itemcget_strict itemcget

      # Configure one or more item options.
      #
      # @overload itemconfigure(tagOrId, options_hash)
      #   @param tagOrId [Object] Item identifier
      #   @param options_hash [Hash] Option names to values
      #   @return [self]
      #
      # @overload itemconfigure(tagOrId, option, value)
      #   @param tagOrId [Object] Item identifier
      #   @param option [Symbol, String] Single option name
      #   @param value [Object] Value to set
      #   @return [self]
      #
      # @example Hash form (multiple options)
      #   canvas.itemconfigure(rect, fill: 'blue', outline: 'black', width: 2)
      #
      # @example Single option form
      #   canvas.itemconfigure(rect, :fill, 'red')
      def itemconfigure(tagOrId, slot, value = None)
        if slot.kind_of?(Hash)
          slot = _symbolkey2str(slot)

          # Resolve aliases
          if self.class.respond_to?(:declared_item_optkey_aliases)
            self.class.declared_item_optkey_aliases.each do |alias_name, real_name|
              if slot.key?(alias_name.to_s)
                slot[real_name.to_s] = slot.delete(alias_name.to_s)
              end
            end
          end

          tk_call(*(_item_config_cmd(tagid(tagOrId)).concat(hash_kv(slot)))) unless slot.empty?
        else
          slot = slot.to_s
          raise ArgumentError, "Invalid option `#{slot.inspect}'" if slot.empty?

          # Resolve alias if declared
          if self.class.respond_to?(:resolve_item_option)
            opt = self.class.resolve_item_option(slot)
            slot = opt.tcl_name if opt
          end

          tk_call(*(_item_config_cmd(tagid(tagOrId)) << "-#{slot}" << value))
        end
        self
      end

      # Get configuration info for an item option.
      #
      # Returns the full Tcl configuration tuple:
      # `[option_name, db_name, db_class, default, current]`
      #
      # For alias options, returns: `[alias_name, target_name]`
      #
      # @param tagOrId [Object] Item identifier
      # @param slot [Symbol, String, nil] Specific option, or nil for all
      # @return [Array, Array<Array>] Config tuple(s)
      #
      # @example Single option
      #   canvas.itemconfiginfo(rect, :fill)
      #   # => ["fill", "fill", "Fill", "", "blue"]
      #
      # @example All options
      #   canvas.itemconfiginfo(rect)
      #   # => [["fill", ...], ["outline", ...], ...]
      def itemconfiginfo(tagOrId, slot = nil)
        if slot
          slot = slot.to_s

          # Resolve alias if declared
          if self.class.respond_to?(:resolve_item_option)
            opt = self.class.resolve_item_option(slot)
            slot = opt.tcl_name if opt
          end

          _process_item_conf(tk_split_simplelist(tk_call_without_enc(*(_item_confinfo_cmd(tagid(tagOrId)) << "-#{slot}")), false, true))
        else
          tk_split_simplelist(tk_call_without_enc(*(_item_confinfo_cmd(tagid(tagOrId)))), false, false).map do |conflist|
            _process_item_conf(tk_split_simplelist(conflist, false, true))
          end
        end
      end

      # Get current values of item options as a hash.
      #
      # @param tagOrId [Object] Item identifier
      # @param slot [Symbol, String, nil] Specific option, or nil for all
      # @return [Hash] Option name => current value
      #
      # @example
      #   canvas.current_itemconfiginfo(rect)
      #   # => {"fill" => "blue", "outline" => "black", "width" => 2, ...}
      #
      #   canvas.current_itemconfiginfo(rect, :fill)
      #   # => {"fill" => "blue"}
      def current_itemconfiginfo(tagOrId, slot = nil)
        if slot
          conf = itemconfiginfo(tagOrId, slot)
          # Follow alias chain
          while conf.size == 2
            conf = itemconfiginfo(tagOrId, conf[1])
          end
          { conf[0] => conf[-1] }
        else
          ret = {}
          itemconfiginfo(tagOrId).each do |conf|
            ret[conf[0]] = conf[-1] if conf.size > 2  # skip aliases
          end
          ret
        end
      end

      # Override in subclass if needed
      def tagid(tagOrId)
        tagOrId
      end

      private

      # Build the cget command array using DSL configuration
      def _item_cget_cmd(id)
        _build_item_cmd(:cget, id) || [self.path, 'itemcget', id]
      end

      # Build the configure command array using DSL configuration
      def _item_config_cmd(id)
        _build_item_cmd(:configure, id) || [self.path, 'itemconfigure', id]
      end

      # Build the confinfo command array (usually same as configure)
      def _item_confinfo_cmd(id)
        _item_config_cmd(id)
      end

      # Build item command from DSL configuration.
      def _build_item_cmd(cmd_type, id)
        # For class instances, check self.class; for module singletons (like Tk::Busy), check self
        config_source = self.is_a?(Module) ? self : self.class
        config = config_source.respond_to?(:item_command_config) ? config_source.item_command_config : nil
        return nil unless config

        # Check for proc-based configuration (full control)
        proc_key = :"#{cmd_type}_proc"
        if config[proc_key]
          return instance_exec(id, &config[proc_key])
        end

        # Check for simple command-word configuration
        cmd_word = config[cmd_type]
        return nil unless cmd_word

        [self.path, cmd_word, id]
      end

      # Convert a raw Tcl value to Ruby using the ItemOption registry
      def _convert_item_value(option_name, raw_value)
        return raw_value unless self.class.respond_to?(:resolve_item_option)
        opt = self.class.resolve_item_option(option_name)
        opt ? opt.from_tcl(raw_value, widget: self) : raw_value
      end

      # Process a raw Tcl configure array: strip dashes, convert current value
      def _process_item_conf(conf)
        conf[TkComm::CONF_KEY] = conf[TkComm::CONF_KEY][1..-1]  # strip leading dash
        if conf.size == 2
          # Alias entry: strip dash from target
          conf[TkComm::CONF_DBNAME] = conf[TkComm::CONF_DBNAME][1..-1] if conf[TkComm::CONF_DBNAME]&.start_with?('-')
        else
          conf[TkComm::CONF_CURRENT] = _convert_item_value(conf[TkComm::CONF_KEY], conf[TkComm::CONF_CURRENT])
        end
        conf
      end
    end
  end
end
