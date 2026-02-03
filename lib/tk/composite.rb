# frozen_string_literal: false
#
# tk/composite.rb :
#
require_relative 'core/widget'

# Mixin for building compound widgets from multiple Tk widgets.
#
# TkComposite lets you create complex widgets by combining simpler ones.
# The compound widget appears as a single widget to users, but internally
# consists of a frame containing child widgets. Options can be delegated
# to child widgets so configuring the compound widget affects its parts.
#
# ## How It Works
#
# 1. Include TkComposite in a class that inherits from TkFrame
# 2. Override `initialize_composite` to create child widgets
# 3. Use `delegate` to forward options to child widgets
# 4. Use `option_methods` for custom option handling
#
# ## Example: Labeled Entry
#
#     class LabeledEntry < TkFrame
#       include TkComposite
#
#       def initialize_composite(keys={})
#         @label = TkLabel.new(@frame)
#         @entry = TkEntry.new(@frame)
#         @label.pack(side: :left)
#         @entry.pack(side: :left, fill: :x, expand: true)
#
#         # Forward 'text' to label, entry options to entry
#         delegate('text', @label)
#         delegate('DEFAULT', @entry)
#
#         # Apply any options passed to constructor
#         configure(keys) unless keys.empty?
#       end
#
#       def value
#         @entry.get
#       end
#
#       def value=(v)
#         @entry.delete(0, :end)
#         @entry.insert(0, v)
#       end
#     end
#
#     # Usage
#     le = LabeledEntry.new(root, text: 'Name:', width: 30)
#     le.pack
#
# ## The DEFAULT Delegate
#
# Use `delegate('DEFAULT', widget)` to forward all unrecognized options
# to a specific child widget. This is useful when one child widget is
# the "main" widget and should receive most configuration options.
#
# ## Option Priority
#
# When `cget` or `configure` is called, options are resolved in this order:
# 1. Options registered via `option_methods`
# 2. Explicitly delegated options
# 3. DEFAULT delegate (if set)
# 4. The frame itself (via super)
#
# @see TkFrame Base class typically used with TkComposite
# @see https://wiki.tcl-lang.org/page/megawidget Tcl megawidget pattern
module TkComposite
  include TkUtil

  # Create a new composite widget.
  #
  # Creates a TkFrame as the container, then calls {#initialize_composite}
  # for subclass setup. The frame becomes the widget's path.
  #
  # @param parent [TkWindow, nil] Parent widget
  # @param args [Array] Additional arguments passed to {#initialize_composite}
  # @option args [String] :class Tk class name for the base frame
  # @option args [String] :classname Alias for :class
  # @option args [TkWindow] :parent Alternative way to specify parent
  #
  # @example
  #   widget = MyComposite.new(root, text: 'Hello', width: 100)
  def initialize(*args, &block)
    @delegates = {}
    @option_methods = {}
    @option_setting = {}

    if args[-1].kind_of?(Hash)
      keys = _symbolkey2str(args.pop)
    else
      keys = {}
    end
    parent = args.shift
    parent = keys.delete('parent') if keys.has_key?('parent')

    @classname = keys.delete('class') || keys.delete('classname') || self.class.name || 'Composite'
    @frame = TkFrame.new(parent, :class => @classname)
    @path = @epath = @frame.path

    args.push(keys) unless keys.empty?
    initialize_composite(*args)

    instance_eval(&block) if block
  end

  # Tk database class name for the base frame.
  # @return [String]
  def database_classname
    @classname
  end

  def database_class
    @classname
  end

  # The widget's evaluation path (same as widget path for composites).
  # @return [String]
  def epath
    @epath
  end

  # Geometry management operates on the outer frame (@epath), not
  # the inner component (@path). Without this, packing a composite
  # widget tries to pack the inner component that's already managed
  # inside the frame.
  def pack(keys = {})
    @frame.pack(keys)
    self
  end

  def grid(keys = {})
    @frame.grid(keys)
    self
  end

  def place(keys = {})
    @frame.place(keys)
    self
  end

  def pack_forget
    @frame.pack_forget
    self
  end

  def grid_forget
    @frame.grid_forget
    self
  end

  def place_forget
    @frame.place_forget
    self
  end

  # Hook for subclasses to set up child widgets.
  #
  # Override this method to create child widgets inside `@frame`,
  # set up delegations, and configure the composite widget.
  # Called automatically by {#initialize} after the frame is created.
  #
  # @param args [Array] Arguments passed from {#initialize}
  #   (typically a Hash of options after processing)
  # @return [void]
  #
  # @example
  #   def initialize_composite(keys={})
  #     @button = TkButton.new(@frame, text: 'Click')
  #     @button.pack
  #     delegate('command', @button)
  #     configure(keys) unless keys.empty?
  #   end
  def initialize_composite(*args) end
  private :initialize_composite

  # String representation including the evaluation path.
  # @return [String]
  def inspect
    str = super
    str.chop << ' @epath=' << @epath.inspect << '>'
  end

  # Register custom methods to handle configuration options.
  #
  # Use this when you need custom logic for getting/setting an option,
  # rather than simply forwarding to a child widget.
  #
  # @param opts [Array<Symbol, Array>] Option method specifications.
  #   Each can be:
  #   - A Symbol: method name used for both set and get (must accept optional arg)
  #   - An Array: `[setter]`, `[setter, getter]`, or `[setter, getter, info]`
  # @return [void]
  #
  # @example Single method for get/set
  #   # Method must handle both: foo() for get, foo(val) for set
  #   def foo(val=nil)
  #     val ? @foo = val : @foo
  #   end
  #   option_methods(:foo)
  #
  # @example Separate getter and setter
  #   def set_value(v); @entry.insert(0, v); end
  #   def get_value; @entry.get; end
  #   option_methods([:set_value, :get_value])
  #
  # @example With configinfo method
  #   option_methods([:set_foo, :get_foo, :foo_info])
  def option_methods(*opts)
    if opts.size == 1 && opts[0].kind_of?(Hash)
      # {name => [m_set, m_cget, m_info], name => method} style
      # Deprecated: prefer array style for consistency with configure
      Tk::Warnings.warn_once(:composite_option_methods_hash,
        "TkComposite#option_methods hash style is deprecated and untested. " \
        "Prefer array style: option_methods(:setter) or option_methods([:setter, :getter])")
      opts[0].each{|name, arg|
        m_set, m_cget, m_info = get_opt_method_list(arg)
        @option_methods[name.to_s] = {
          :set => m_set, :cget => m_cget, :info => m_info
        }
      }
    else
      # [m_set, m_cget, m_info] or method style (preferred)
      opts.each{|arg|
        m_set, m_cget, m_info = get_opt_method_list(arg)
        @option_methods[m_set] = {
          :set => m_set, :cget => m_cget, :info => m_info
        }
      }
    end
  end

  # Forward an option to child widgets under a different name.
  #
  # Like {#delegate}, but the option exposed by the composite widget
  # can have a different name than the option on the child widget.
  #
  # @param alias_opt [String, Symbol] Option name exposed by composite
  # @param option [String, Symbol] Actual option name on child widgets
  # @param wins [Array<TkWindow>] Child widgets to forward to
  # @return [void]
  # @raise [ArgumentError] If no widgets given or aliasing 'DEFAULT'
  #
  # @example Expose 'label' option that maps to 'text' on a TkLabel
  #   delegate_alias('label', 'text', @label_widget)
  #   # Now: widget.configure(label: 'Hello') sets @label_widget's text
  def delegate_alias(alias_opt, option, *wins)
    if wins.length == 0
      fail ArgumentError, "target widgets are not given"
    end
    if alias_opt != option && (alias_opt == 'DEFAULT' || option == 'DEFAULT')
      fail ArgumentError, "cannot alias 'DEFAULT' option"
    end
    alias_opt = alias_opt.to_s
    option = option.to_s
    if @delegates[alias_opt].kind_of?(Array)
      if (elem = @delegates[alias_opt].assoc(option))
        wins.each{|w| elem[1].push(w)}
      else
        @delegates[alias_opt] << [option, wins]
      end
    else
      @delegates[alias_opt] = [ [option, wins] ]
    end
  end

  # Forward an option to child widgets.
  #
  # When the composite widget's option is configured or queried,
  # the operation is forwarded to the specified child widgets.
  #
  # Use `'DEFAULT'` as the option name to forward all unrecognized
  # options to the specified widgets.
  #
  # @param option [String, Symbol] Option name to delegate
  # @param wins [Array<TkWindow>] Child widgets to forward to
  # @return [void]
  #
  # @example Forward specific options
  #   delegate('text', @label)
  #   delegate('command', @button)
  #
  # @example Forward all unknown options to main widget
  #   delegate('DEFAULT', @entry)
  #
  # @example Forward to multiple widgets (e.g., sync colors)
  #   delegate('background', @label, @entry, @button)
  def delegate(option, *wins)
    delegate_alias(option, option, *wins)
  end

  # Get option value as a Tk string.
  #
  # Checks option_methods and delegates before falling back to frame.
  # (see TkConfigMethod#cget_tkstring)
  def cget_tkstring(slot)
    if (ret = cget_delegates(slot)) == None
      @frame.cget_tkstring(slot)
    else
      _get_eval_string(ret)
    end
  end

  # Get an option value.
  #
  # Checks option_methods and delegates before falling back to frame.
  #
  # @param slot [String, Symbol] Option name
  # @return [Object] The option value
  #
  # @example
  #   widget.cget(:text)   # => "Hello"
  #   widget.cget(:width)  # => 100
  def cget(slot)
    if (ret = cget_delegates(slot)) == None
      @frame.cget(slot)
    else
      ret
    end
  end

  # (see #cget)
  def cget_strict(slot)
    if (ret = cget_delegates(slot)) == None
      @frame.cget_strict(slot)
    else
      ret
    end
  end

  # Set one or more options.
  #
  # Checks option_methods and delegates before falling back to frame.
  #
  # @param slot [String, Symbol, Hash] Option name, or Hash of options
  # @param value [Object] Value to set (ignored if slot is Hash)
  # @return [self, Object] self for chaining, or result of delegated configure
  #
  # @example Set single option
  #   widget.configure(:text, 'Hello')
  #
  # @example Set multiple options
  #   widget.configure(text: 'Hello', width: 100)
  def configure(slot, value=None)
    if slot.kind_of? Hash
      slot.each{|slot,value| configure slot, value}
      return self
    end

    slot = slot.to_s

    if @option_methods.include?(slot)
      unless @option_methods[slot][:cget]
        if value.kind_of?(Symbol)
          @option_setting[slot] = value.to_s
        else
          @option_setting[slot] = value
        end
      end
      return self.__send__(@option_methods[slot][:set], value)
    end

    tbl = @delegates[slot]
    tbl = @delegates['DEFAULT'] unless tbl

    begin
      if tbl
        last = nil
        tbl.each{|opt, wins|
          opt = slot if opt == 'DEFAULT'
          wins.each{|w| last = w.configure(opt, value)}
        }
        return last
      end
    rescue => e
      Tk::Warnings.warn_once(:"composite_configure_#{slot}",
        "TkComposite#configure failed for '#{slot}' on delegate: #{e.message}")
    end

    # Component fallback: @path may point to an inner widget (e.g. text)
    # that supports options the frame doesn't. Try it first.
    if defined?(@component) && @component
      return @component.configure(slot, value)
    end
    @frame.configure(slot, value)
  end

  # Get configuration information.
  #
  # Returns detailed info about options including database name,
  # class, default value, and current value.
  #
  # @param slot [String, Symbol, nil] Option name, or nil for all options
  # @return [Array] For single option: [name, dbname, dbclass, default, value]
  # @return [Array<Array>] For all options: array of option info arrays
  #
  # @example Get info for one option
  #   widget.configinfo(:text)
  #   # => ['text', 'text', 'Text', '', 'Hello']
  #
  # @example Get all options
  #   widget.configinfo.each { |info| puts info.inspect }
  def configinfo(slot = nil)
    if slot
      slot = slot.to_s
      if @option_methods.include?(slot)
        if @option_methods[slot][:info]
          return self.__send__(@option_methods[slot][:info])
        else
          return [slot, '', '', '', self.cget(slot)]
        end
      end

      tbl = @delegates[slot]
      tbl = @delegates['DEFAULT'] unless tbl

      begin
        if tbl
          if tbl.length == 1
            opt, wins = tbl[0]
            if slot == opt || opt == 'DEFAULT'
              return wins[-1].configinfo(slot)
            else
              info = wins[-1].configinfo(opt)
              info[0] = slot
              return info
            end
          else
            opt, wins = tbl[-1]
            return [slot, '', '', '', wins[-1].cget(opt)]
          end
        end
      rescue => e
        Tk::Warnings.warn_once(:"composite_configinfo_#{slot}",
          "TkComposite#configinfo failed for '#{slot}' on delegate: #{e.message}")
      end

      @frame.configinfo(slot)

    else # slot == nil
      info_list = @frame.configinfo

      tbl = @delegates['DEFAULT']
      if tbl
        wins = tbl[0][1]
        if wins && wins[-1]
          wins[-1].configinfo.each{|info|
            slot = info[0]
            info_list.delete_if{|i| i[0] == slot} << info
          }
        end
      end

      @delegates.each{|slot, tbl|
        next if slot == 'DEFAULT'
        if tbl.length == 1
          opt, wins = tbl[0]
          next unless wins && wins[-1]
          if slot == opt
            info_list.delete_if{|i| i[0] == slot} << wins[-1].configinfo(slot)
          else
            info = wins[-1].configinfo(opt)
            info[0] = slot
            info_list.delete_if{|i| i[0] == slot} << info
          end
        else
          opt, wins = tbl[-1]
          info_list.delete_if{|i| i[0] == slot} << [slot, '', '', '', wins[-1].cget(opt)]
        end
      }

      @option_methods.each{|slot, m|
        if m[:info]
          info = self.__send__(m[:info])
        else
          info = [slot, '', '', '', self.cget(slot)]
        end
        info_list.delete_if{|i| i[0] == slot} << info
      }

      info_list
    end
  end

  private

  # Parse option method specification into [setter, getter, info] tuple.
  def get_opt_method_list(arg)
    m_set, m_cget, m_info = arg
    m_set  = m_set.to_s
    m_cget = m_set if !m_cget && self.method(m_set).arity == -1
    m_cget = m_cget.to_s if m_cget
    m_info = m_info.to_s if m_info
    [m_set, m_cget, m_info]
  end

  # Query delegates for an option value.
  # Returns None if option not found in delegates.
  def cget_delegates(slot)
    slot = slot.to_s

    if @option_methods.include?(slot)
      if @option_methods[slot][:cget]
        return self.__send__(@option_methods[slot][:cget])
      else
        if @option_setting[slot]
          return @option_setting[slot]
        else
          return ''
        end
      end
    end

    explicit = @delegates.key?(slot)
    tbl = @delegates[slot] || @delegates['DEFAULT']

    begin
      if tbl
        opt, wins = tbl[-1]
        opt = slot if opt == 'DEFAULT'
        if wins && wins[-1]
          return wins[-1].cget_strict(opt)
        end
      end
    rescue => e
      # Only warn for explicit delegations. DEFAULT is a catch-all that's
      # expected to fail for non-Tk options (e.g. Ruby's to_ary coercion
      # hitting method_missing -> cget)
      if explicit
        Tk::Warnings.warn_once(:"composite_cget_#{slot}",
          "TkComposite#cget failed for '#{slot}' on delegate: #{e.message}")
      end
    end

    return None
  end
end
