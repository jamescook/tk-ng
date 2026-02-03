# frozen_string_literal: false

module Tk
  # @!visibility private
  # Mixin for widgets supporting validation commands.
  module ValidateConfigure
    def self.__def_validcmd(scope, klass, keys=nil)
      keys = klass._config_keys unless keys
      keys.each{|key|
        eval("def #{key}(*args, &b)
                 __validcmd_call(#{klass.name}, '#{key}', *args, &b)
              end", scope)
      }
    end

    def __validcmd_call(klass, key, *args, &b)
      return cget(key) if args.empty? && !b

      cmd = (b)? proc(&b) : args.shift

      if cmd.kind_of?(klass)
        configure(key, cmd)
      elsif !args.empty?
        configure(key, [cmd, args])
      else
        configure(key, cmd)
      end
    end

    def __validation_class_list
      # maybe need to override
      []
    end

    def __get_validate_key2class
      k2c = {}
      __validation_class_list.each{|klass|
        klass._config_keys.each{|key|
          k2c[key.to_s] = klass
        }
      }
      k2c
    end

    def __conv_vcmd_on_hash_kv(keys)
      key2class = __get_validate_key2class

      keys = _symbolkey2str(keys)
      key2class.each{|key, klass|
        if keys[key].kind_of?(Array)
          cmd, *args = keys[key]
          #keys[key] = klass.new(cmd, args.join(' '))
          keys[key] = klass.new(cmd, *args)
        # elsif keys[key].kind_of?(Proc) ||  keys[key].kind_of?(Method)
        elsif TkComm._callback_entry?(keys[key])
          keys[key] = klass.new(keys[key])
        end
      }
      keys
    end

    def create_self(keys)
      super(__conv_vcmd_on_hash_kv(keys))
    end
    private :create_self

    def configure(slot, value=TkComm::None)
      if slot.kind_of?(Hash)
        __conv_vcmd_on_hash_kv(slot).each { |k, v| super(k, v) }
      else
        __conv_vcmd_on_hash_kv(slot=>value).each { |k, v| super(k, v) }
      end
      self
    end
=begin
    def configure(slot, value=TkComm::None)
      key2class = __get_validate_key2class

      if slot.kind_of?(Hash)
        slot = _symbolkey2str(slot)
        key2class.each{|key, klass|
          if slot[key].kind_of?(Array)
            cmd, *args = slot[key]
            slot[key] = klass.new(cmd, args.join(' '))
          elsif slot[key].kind_of?(Proc) || slot[key].kind_of?(Method)
            slot[key] = klass.new(slot[key])
          end
        }
        super(slot)

      else
        slot = slot.to_s
        if (klass = key2class[slot])
          if value.kind_of?(Array)
            cmd, *args = value
            value = klass.new(cmd, args.join(' '))
          elsif value.kind_of?(Proc) || value.kind_of?(Method)
            value = klass.new(value)
          end
        end
        super(slot, value)
      end

      self
    end
=end
  end

  module ItemValidateConfigure
    def self.__def_validcmd(scope, klass, keys=nil)
      keys = klass._config_keys unless keys
      keys.each{|key|
        eval("def item_#{key}(id, *args, &b)
                 __item_validcmd_call(#{klass.name}, '#{key}', id, *args, &b)
              end", scope)
      }
    end

    def __item_validcmd_call(tagOrId, klass, key, *args, &b)
      return itemcget(tagid(tagOrId), key) if args.empty? && !b

      cmd = (b)? proc(&b) : args.shift

      if cmd.kind_of?(klass)
        itemconfigure(tagid(tagOrId), key, cmd)
      elsif !args.empty?
        itemconfigure(tagid(tagOrId), key, [cmd, args])
      else
        itemconfigure(tagid(tagOrId), key, cmd)
      end
    end

    def __item_validation_class_list(id)
      # maybe need to override
      []
    end

    def __get_item_validate_key2class(id)
      k2c = {}
      __item_validation_class_list(id).each{|klass|
        klass._config_keys.each{|key|
          k2c[key.to_s] = klass
        }
      }
    end

    def __conv_item_vcmd_on_hash_kv(keys)
      key2class = __get_item_validate_key2class(tagid(tagOrId))

      keys = _symbolkey2str(keys)
      key2class.each{|key, klass|
        if keys[key].kind_of?(Array)
          cmd, *args = keys[key]
          #keys[key] = klass.new(cmd, args.join(' '))
          keys[key] = klass.new(cmd, *args)
        # elsif keys[key].kind_of?(Proc) || keys[key].kind_of?(Method)
        elsif TkComm._callback_entry?(keys[key])
          keys[key] = klass.new(keys[key])
        end
      }
      keys
    end

    def itemconfigure(tagOrId, slot, value=TkComm::None)
      if slot.kind_of?(Hash)
        super(__conv_item_vcmd_on_hash_kv(slot))
      else
        super(__conv_item_vcmd_on_hash_kv(slot=>value))
      end
      self
    end
=begin
    def itemconfigure(tagOrId, slot, value=TkComm::None)
      key2class = __get_item_validate_key2class(tagid(tagOrId))

      if slot.kind_of?(Hash)
        slot = _symbolkey2str(slot)
        key2class.each{|key, klass|
          if slot[key].kind_of?(Array)
            cmd, *args = slot[key]
            slot[key] = klass.new(cmd, args.join(' '))
          elsif slot[key].kind_of?(Proc) ||  slot[key].kind_of?(Method)
            slot[key] = klass.new(slot[key])
          end
        }
        super(slot)

      else
        slot = slot.to_s
        if (klass = key2class[slot])
          if value.kind_of?(Array)
            cmd, *args = value
            value = klass.new(cmd, args.join(' '))
          elsif value.kind_of?(Proc) || value.kind_of?(Method)
            value = klass.new(value)
          end
        end
        super(slot, value)
      end

      self
    end
=end
  end
end

# Wraps a validation callback for use with Entry/Spinbox widgets.
#
# Normally you don't need to use this class directly - just pass a
# proc to the `:validatecommand` option. But for advanced cases,
# you can create a TkValidateCommand explicitly.
#
# @example Direct usage (rarely needed)
#   vcmd = TkValidateCommand.new(proc { |args| args.value.length <= 10 })
#   entry.configure(validatecommand: vcmd)
#
# @see TkValidation Module included by Entry/Spinbox
class TkValidateCommand
  include TkComm
  extend  TkComm

  # Arguments passed to validation callbacks.
  #
  # When your callback receives a ValidateArgs object, you can access
  # all the validation context:
  #
  # @!attribute [r] action
  #   @return [Integer] 1=insert, 0=delete, -1=focus/forced/textvariable
  # @!attribute [r] index
  #   @return [Integer, nil] Character index of edit (nil if N/A)
  # @!attribute [r] current
  #   @return [String] Current value before the edit
  # @!attribute [r] value
  #   @return [String] Value if edit is accepted
  # @!attribute [r] string
  #   @return [String] Text being inserted/deleted
  # @!attribute [r] type
  #   @return [String] Validation mode (none/focus/focusin/focusout/key/all)
  # @!attribute [r] triggered
  #   @return [String] What triggered: key/focusin/focusout/forced
  # @!attribute [r] widget
  #   @return [TkEntry] The entry widget
  class ValidateArgs < TkUtil::CallbackSubst
    KEY_TBL = [
      [ ?d, ?n, :action ],
      [ ?i, ?x, :index ],
      [ ?s, ?e, :current ],
      [ ?v, ?s, :type ],
      [ ?P, ?e, :value ],
      [ ?S, ?e, :string ],
      [ ?V, ?s, :triggered ],
      [ ?W, ?w, :widget ],
      nil
    ]

    PROC_TBL = [
      [ ?n, TkComm.method(:number) ],
      [ ?s, TkComm.method(:string) ],
      [ ?w, TkComm.method(:window) ],

      [ ?e, proc{|val| TkComm::string(val) } ],

      [ ?x, proc{|val|
          idx = TkComm::number(val)
          if idx < 0
            nil
          else
            idx
          end
        }
      ],

      nil
    ]

=begin
    # for Ruby m17n :: ?x --> String --> char-code ( getbyte(0) )
    KEY_TBL.map!{|inf|
      if inf.kind_of?(Array)
        inf[0] = inf[0].getbyte(0) if inf[0].kind_of?(String)
        inf[1] = inf[1].getbyte(0) if inf[1].kind_of?(String)
      end
      inf
    }

    PROC_TBL.map!{|inf|
      if inf.kind_of?(Array)
        inf[0] = inf[0].getbyte(0) if inf[0].kind_of?(String)
      end
      inf
    }
=end

    _setup_subst_table(KEY_TBL, PROC_TBL);

    #
    # NOTE: The order of parameters which passed to callback procedure is
    #        <extra_arg>, <extra_arg>, ... , <subst_arg>, <subst_arg>, ...
    #

    #def self._get_extra_args_tbl
    #  # return an array of convert procs
    #  []
    #end

    def self.ret_val(val)
      (val)? '1': '0'
    end
  end

  ###############################################

  def self._config_keys
    # array of config-option key (string or symbol)
    ['vcmd', 'validatecommand', 'invcmd', 'invalidcommand']
  end

  def _initialize_for_cb_class(klass, cmd = nil, *args, &block)
    cmd ||= block
    extra_args_tbl = klass._get_extra_args_tbl

    if args.compact.size > 0
      args.map!{|arg| klass._sym2subst(arg)}
      args = args.join(' ')
      keys = klass._get_subst_key(args)
      if cmd.kind_of?(String)
        @id = cmd
      elsif cmd.kind_of?(TkCallbackEntry)
        @id = install_cmd(cmd)
      else
        @id = install_cmd(proc{|*arg|
             ex_args = []
             extra_args_tbl.reverse_each{|conv| ex_args << conv.call(arg.pop)}
             klass.ret_val(cmd.call(
               *(ex_args.concat(klass.scan_args(keys, arg)))
             ))
        }) + ' ' + args
      end
    else
      keys, args = klass._get_all_subst_keys
      if cmd.kind_of?(String)
        @id = cmd
      elsif cmd.kind_of?(TkCallbackEntry)
        @id = install_cmd(cmd)
      else
        @id = install_cmd(proc{|*arg|
             ex_args = []
             extra_args_tbl.reverse_each{|conv| ex_args << conv.call(arg.pop)}
             klass.ret_val(cmd.call(
               *(ex_args << klass.new(*klass.scan_args(keys, arg)))
             ))
        }) + ' ' + args
      end
    end
  end

  def initialize(cmd = nil, *args, &block)
    _initialize_for_cb_class(self.class::ValidateArgs, cmd || block, *args)
  end

  def to_eval
    @id
  end
end

# Input validation support for Entry, Spinbox, and Combobox widgets.
#
# This module is automatically included by TkEntry and TkSpinbox.
# It adds the `:validatecommand` and `:invalidcommand` options.
#
# Tk validation lets you control what users can type into entry widgets.
# A validation callback is called before changes are applied, and can
# accept or reject the input.
#
# ## Validation Modes
#
# Set the `:validate` option to control when validation runs:
#
# | Mode | When Validated |
# |------|----------------|
# | `:none` | Never (default) |
# | `:focus` | On focus in and focus out |
# | `:focusin` | On focus in only |
# | `:focusout` | On focus out only |
# | `:key` | On every keystroke |
# | `:all` | On focus changes and keystrokes |
#
# ## Validation Callback
#
# The `:validatecommand` (or `:vcmd`) callback receives information about
# the pending change and must return true to accept or false to reject:
#
#     entry = TkEntry.new(root,
#       validate: :key,
#       validatecommand: [proc { |p| p.match?(/^\d*$/) }, '%P']
#     )
#
# ## Substitution Codes
#
# Pass these as extra arguments to receive validation context:
#
# | Code | Ruby Symbol | Description |
# |------|-------------|-------------|
# | `%d` | `:action` | 1=insert, 0=delete, -1=other |
# | `%i` | `:index` | Character index of change |
# | `%P` | `:value` | Value if change is accepted |
# | `%s` | `:current` | Current value before change |
# | `%S` | `:string` | Text being inserted/deleted |
# | `%v` | `:type` | Validation mode setting |
# | `%V` | `:triggered` | What triggered: key/focusin/focusout/forced |
# | `%W` | `:widget` | The widget |
#
# ## Invalid Command
#
# The `:invalidcommand` (or `:invcmd`) callback runs when validation fails:
#
#     entry = TkEntry.new(root,
#       validate: :key,
#       validatecommand: [proc { |p| p.length <= 10 }, '%P'],
#       invalidcommand: proc { Tk.bell }
#     )
#
# @example Numeric-only entry
#   entry = TkEntry.new(root,
#     validate: :key,
#     vcmd: [proc { |new_val| new_val.match?(/^\d*$/) }, '%P']
#   )
#
# @example Maximum length
#   entry = TkEntry.new(root,
#     validate: :key,
#     vcmd: [proc { |p| p.length <= 20 }, '%P'],
#     invcmd: proc { Tk.bell }
#   )
#
# @example Using ValidateArgs object
#   entry = TkEntry.new(root,
#     validate: :all,
#     vcmd: proc { |args|
#       puts "Action: #{args.action}, New value: #{args.value}"
#       true
#     }
#   )
#
# @note Validation is automatically disabled if the callback raises an
#   error or returns a non-boolean value. Check your callback carefully.
#
# @note Combining `:textvariable` with `:validatecommand` can cause issues.
#   Changes via the variable trigger validation with action=-1.
#
# @see TkEntry Entry widget with validation
# @see TkSpinbox Spinbox widget with validation
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/entry.htm Entry validation docs
module TkValidation
  include Tk::ValidateConfigure

  # Validation command wrapper for Entry/Spinbox.
  class ValidateCmd < TkValidateCommand
    # Constants for the `action` field in validation callbacks.
    #
    # @example Checking action type
    #   vcmd = proc { |args|
    #     case args.action
    #     when TkValidation::ValidateCmd::Action::Insert
    #       # User is inserting text
    #     when TkValidation::ValidateCmd::Action::Delete
    #       # User is deleting text
    #     when TkValidation::ValidateCmd::Action::Focus
    #       # Focus change or forced validation
    #     end
    #     true
    #   }
    module Action
      # User is inserting text
      Insert = 1
      # User is deleting text
      Delete = 0
      # Focus change, forced validation, or textvariable change
      Others = -1
      # @!visibility private
      Focus  = -1
      # @!visibility private
      Forced = -1
      # @!visibility private
      Textvariable = -1
      # @!visibility private
      TextVariable = -1
    end
  end

  #####################################

  def __validation_class_list
    super() << ValidateCmd
  end

  Tk::ValidateConfigure.__def_validcmd(binding, ValidateCmd)
end
