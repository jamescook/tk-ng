# frozen_string_literal: false
#
#   tk/namespace.rb : methods to manipulate Tcl/Tk namespace
#                           by Hidetoshi Nagai <nagai@ai.kyutech.ac.jp>
#
require 'tk/option_dsl'

# Tcl namespace manipulation from Ruby.
#
# Tcl namespaces organize commands and variables into hierarchical
# containers, similar to Ruby modules. Use TkNamespace to create
# namespaces, import/export procedures, and evaluate code in a
# namespace context.
#
# ## Namespace Paths
#
# Namespace names use `::` as separator (like C++):
# - `::` - global namespace
# - `::foo` - absolute path to namespace foo
# - `foo::bar` - relative path from current namespace
#
# ## Creating Namespaces
#
#     # Create with auto-generated name
#     ns = TkNamespace.new
#
#     # Create with specific name
#     ns = TkNamespace.new('myapp')
#
#     # Create nested namespace
#     child = TkNamespace.new('utils', ns)  # ::myapp::utils
#
# ## Evaluating in Namespace Context
#
#     ns = TkNamespace.new('myapp')
#     ns.eval { puts "In namespace: #{TkNamespace.current_path}" }
#
# ## Import/Export Procedures
#
#     # In source namespace, export procedures
#     TkNamespace.export('proc1', 'proc2')
#
#     # In target namespace, import them
#     TkNamespace.import('::source::proc1', '::source::proc2')
#
# ## Ensembles
#
# Ensembles group related commands under a single command name:
#
#     ens = TkNamespace::Ensemble.new(map: {'add' => '::mymath::add'})
#
# @see https://www.tcl-lang.org/man/tcl8.6/TclCmd/namespace.htm Tcl namespace docs
class TkNamespace < TkObject
  extend Tk

  # @!visibility private
  TkCommandNames = [
    'namespace'.freeze,
  ].freeze

  # @!visibility private
  Tk_Namespace_ID_TBL = TkCore::INTERP.create_table

  # @!visibility private
  (Tk_Namespace_ID = ["ns".freeze, "00000"]).instance_eval{
    @mutex = Mutex.new
    def mutex; @mutex; end
    freeze
  }

  # @!visibility private
  Tk_NsCode_RetObjID_TBL = TkCore::INTERP.create_table

  # @!visibility private
  TkCore::INTERP.init_ip_env{
    Tk_Namespace_ID_TBL.mutex.synchronize{ Tk_Namespace_ID_TBL.clear }
    Tk_NsCode_RetObjID_TBL.mutex.synchronize{ Tk_NsCode_RetObjID_TBL.clear }
  }

  # @!visibility private
  def TkNamespace.id2obj(id)
    Tk_Namespace_ID_TBL.mutex.synchronize{
      Tk_Namespace_ID_TBL[id]? Tk_Namespace_ID_TBL[id]: id
    }
  end

  #####################################

  # Namespace ensemble - groups commands under a single name.
  #
  # An ensemble is a command that dispatches to subcommands based on
  # the first argument. This is how Tcl implements OO-style command
  # grouping (e.g., `string length`, `string index`).
  #
  # @example Create an ensemble
  #   ens = TkNamespace::Ensemble.new(
  #     map: {'add' => '::mymath::add', 'sub' => '::mymath::subtract'}
  #   )
  #
  # @example Check if ensemble exists
  #   TkNamespace::Ensemble.exist?('string')  # => true
  #
  # @see https://www.tcl-lang.org/man/tcl8.6/TclCmd/namespace.htm#M28 Ensemble docs
  #
  # @todo Rewrite to not depend on OptionDSL (it's not a widget)
  class Ensemble < TkObject
    extend Tk::OptionDSL

    # @!attribute [rw] prefixes
    #   Allow unambiguous prefixes of subcommand names.
    #   @return [Boolean]
    option :prefixes,    type: :boolean

    # @!attribute [rw] map
    #   Mapping of subcommand names to implementation commands.
    #   @return [Hash]
    option :map,         type: :list

    # @!attribute [rw] subcommands
    #   List of subcommands to expose (subset of map keys).
    #   @return [Array<String>]
    option :subcommands, type: :list

    # @!attribute [rw] unknown
    #   Handler for unknown subcommands.
    #   @return [Array]
    option :unknown,     type: :list

    # Check if a command is an ensemble.
    # @param ensemble [String] Command name to check
    # @return [Boolean]
    def self.exist?(ensemble)
      bool(tk_call('namespace', 'ensemble', 'exists', ensemble))
    end

    # Create a new ensemble command.
    # @param keys [Hash] Configuration options
    # @option keys [Hash] :map Subcommand to implementation mapping
    # @option keys [Boolean] :prefixes Allow prefix matching
    # @option keys [Array] :subcommands Exposed subcommand list
    # @return [Ensemble]
    def initialize(keys = {})
      @ensemble = @path = tk_call('namespace', 'ensemble', 'create', *hash_kv(keys))
    end

    # Configure ensemble options.
    # @param slot [String, Symbol, Hash] Option name or hash of options
    # @param value [Object] Option value (ignored if slot is Hash)
    # @return [self]
    def configure(slot, value = None)
      if slot.is_a?(Hash)
        slot.each { |k, v| configure(k, v) }
        self
      else
        slot = slot.to_s
        if self.class.respond_to?(:options)
          opt = self.class.options[slot.to_sym]
          value = opt.to_tcl(value) if opt && value != None
        end
        tk_call('namespace', 'ensemble', 'configure', @path, "-#{slot}", value)
        self
      end
    end

    # Get an ensemble option value.
    # @param slot [String, Symbol] Option name
    # @return [Object] Option value
    def cget(slot)
      slot = slot.to_s
      val = tk_call('namespace', 'ensemble', 'configure', @path, "-#{slot}")

      if slot == 'namespace'
        Tk_Namespace_ID_TBL.mutex.synchronize{
          return TkNamespace::Tk_Namespace_ID_TBL[val] if TkNamespace::Tk_Namespace_ID_TBL.key?(val)
        }
        return val
      end

      if self.class.respond_to?(:options)
        opt = self.class.options[slot.to_sym]
        return opt.from_tcl(val) if opt
      end
      val
    end
    # (see #cget)
    alias cget_strict cget

    # Check if this ensemble still exists.
    # @return [Boolean]
    def exists?
      bool(tk_call('namespace', 'ensemble', 'exists', @path))
    end
  end

  #####################################

  # @!visibility private
  # Helper for evaluating code in namespace context.
  # Wraps arguments and redirects tk_call to the namespace.
  class ScopeArgs < Array
    include Tk

    # alias __tk_call             tk_call
    # alias __tk_call_without_enc tk_call_without_enc
    # alias __tk_call_with_enc    tk_call_with_enc
    def tk_call(*args)
      #super('namespace', 'eval', @namespace, *args)
      args = args.collect{|arg| (s = _get_eval_string(arg, true))? s: ''}
      super('namespace', 'eval', @namespace,
            TkCore::INTERP._merge_tklist(*args))
    end
    def tk_call_without_enc(*args)
      #super('namespace', 'eval', @namespace, *args)
      args = args.collect{|arg| (s = _get_eval_string(arg, true))? s: ''}
      super('namespace', 'eval', @namespace,
            TkCore::INTERP._merge_tklist(*args))
    end
    def tk_call_with_enc(*args)
      #super('namespace', 'eval', @namespace, *args)
      args = args.collect{|arg| (s = _get_eval_string(arg, true))? s: ''}
      super('namespace', 'eval', @namespace,
            TkCore::INTERP._merge_tklist(*args))
    end

    def initialize(namespace, *args)
      @namespace = namespace
      super(args.size)
      self.replace(args)
    end
  end

  #####################################

  # @!visibility private
  # Wrapper for namespace-scoped code returned by `namespace code`.
  class NsCode < TkObject
    def initialize(scope, use_obj_id = false)
      @scope = scope + ' '
      @use_obj_id = use_obj_id
    end
    def path
      @scope
    end
    def to_eval
      @scope
    end
    def call(*args)
      ret = TkCore::INTERP._eval_without_enc(@scope + array2tk_list(args))
      if @use_obj_id
        ret = TkNamespace::Tk_NsCode_RetObjID_TBL.delete(ret.to_i)
      end
      ret
    end
  end

  #####################################

  # @!visibility private
  def install_cmd(cmd)
    lst = tk_split_simplelist(super(cmd), false, false)
    if lst[1] =~ /^::/
      lst[1] = @fullname
    else
      lst.insert(1, @fullname)
    end
    TkCore::INTERP._merge_tklist(*lst)
  end

  # @!visibility private
  alias __tk_call             tk_call
  # @!visibility private
  alias __tk_call_without_enc tk_call_without_enc
  # @!visibility private
  alias __tk_call_with_enc    tk_call_with_enc

  # @!visibility private
  def tk_call(*args)
    #super('namespace', 'eval', @fullname, *args)
    args = args.collect{|arg| (s = _get_eval_string(arg, true))? s: ''}
    super('namespace', 'eval', @fullname,
          TkCore::INTERP._merge_tklist(*args))
  end
  # @!visibility private
  def tk_call_without_enc(*args)
    #super('namespace', 'eval', @fullname, *args)
    args = args.collect{|arg| (s = _get_eval_string(arg, true))? s: ''}
    super('namespace', 'eval', @fullname,
          TkCore::INTERP._merge_tklist(*args))
  end
  # @!visibility private
  def tk_call_with_enc(*args)
    #super('namespace', 'eval', @fullname, *args)
    args = args.collect{|arg| (s = _get_eval_string(arg, true))? s: ''}
    super('namespace', 'eval', @fullname,
          TkCore::INTERP._merge_tklist(*args))
  end
  # @!visibility private
  alias ns_tk_call             tk_call
  # @!visibility private
  alias ns_tk_call_without_enc tk_call_without_enc
  # @!visibility private
  alias ns_tk_call_with_enc    tk_call_with_enc

  # Create or access a Tcl namespace.
  #
  # @param name [String, nil] Namespace name (auto-generated if nil)
  # @param parent [String, TkNamespace, nil] Parent namespace
  # @return [TkNamespace]
  #
  # @example Create with auto name
  #   ns = TkNamespace.new
  #
  # @example Create with specific name
  #   ns = TkNamespace.new('myapp')
  #
  # @example Create nested
  #   parent = TkNamespace.new('myapp')
  #   child = TkNamespace.new('utils', parent)  # => ::myapp::utils
  def initialize(name = nil, parent = nil)
    unless name
      Tk_Namespace_ID.mutex.synchronize{
        # name = Tk_Namespace_ID.join('')
        name = Tk_Namespace_ID.join(TkCore::INTERP._ip_id_)
        Tk_Namespace_ID[1].succ!
      }
    end
    name = __tk_call('namespace', 'current') if name == ''
    if parent
      if parent =~ /^::/
        if name =~ /^::/
          @fullname = parent + name
        else
          @fullname = parent + '::' + name
        end
      else
        ancestor = __tk_call('namespace', 'current')
        ancestor = '' if ancestor == '::'
        if name =~ /^::/
          @fullname = ancestor + '::' + parent + name
        else
          @fullname = ancestor + '::' + parent + '::' + name
        end
      end
    else # parent == nil
      ancestor = __tk_call('namespace', 'current')
      ancestor = '' if ancestor == '::'
      if name =~ /^::/
        @fullname = name
      else
        @fullname = ancestor + '::' + name
      end
    end
    @path = @fullname
    @parent = __tk_call('namespace', 'qualifiers', @fullname)
    @name = __tk_call('namespace', 'tail', @fullname)

    # create namespace
    __tk_call('namespace', 'eval', @fullname, '')

    Tk_Namespace_ID_TBL.mutex.synchronize{
      Tk_Namespace_ID_TBL[@fullname] = self
    }
  end

  # Get child namespaces.
  # @param args [Array] Optional: namespace path and/or glob pattern
  # @return [Array<TkNamespace, String>] Child namespaces
  #
  # @example Get all children of current namespace
  #   TkNamespace.children
  #
  # @example Get children matching pattern
  #   TkNamespace.children('::myapp', 'util*')
  def self.children(*args)
    # args ::= [<namespace>] [<pattern>]
    # <pattern> must be glob-style pattern
    tk_split_simplelist(tk_call('namespace', 'children', *args)).collect{|ns|
      # ns is fullname
      Tk_Namespace_ID_TBL.mutex.synchronize{
        if Tk_Namespace_ID_TBL.key?(ns)
          Tk_Namespace_ID_TBL[ns]
        else
          ns
        end
      }
    }
  end
  # Get child namespaces of this namespace.
  # @param pattern [String] Optional glob pattern
  # @return [Array<TkNamespace, String>]
  def children(pattern=None)
    TkNamespace.children(@fullname, pattern)
  end

  # Create a scoped script that runs in a namespace context.
  # @param script [String, Proc, nil] Code to scope
  # @yield Block to scope (alternative to script)
  # @return [NsCode] Callable scoped code object
  def self.code(script = nil, &block)
    TkNamespace.new('').code(script || block)
  end

  # Create a scoped script that runs in this namespace.
  # @param script [String, Proc, nil] Code to scope
  # @yield Block to scope
  # @return [NsCode] Callable scoped code object
  def code(script = nil, &block)
    script ||= block
    if script.kind_of?(String)
      cmd = proc{|*args|
        ret = ScopeArgs.new(@fullname,*args).instance_eval(script)
        id = ret.object_id
        TkNamespace::Tk_NsCode_RetObjID_TBL[id] = ret
        id
      }
    elsif script.kind_of?(Proc)
      cmd = proc{|*args|
        obj = ScopeArgs.new(@fullname,*args)
        ret = obj.instance_exec(obj, &script)
        id = ret.object_id
        TkNamespace::Tk_NsCode_RetObjID_TBL[id] = ret
        id
      }
    else
      fail ArgumentError, "String or Proc is expected"
    end
    TkNamespace::NsCode.new(tk_call_without_enc('namespace', 'code',
                                                _get_eval_string(cmd, false)),
                            true)
  end

  # Get the current namespace path as a string.
  # @return [String] Fully qualified namespace path
  def self.current_path
    tk_call('namespace', 'current')
  end

  # Get this namespace's full path.
  # @return [String]
  def current_path
    @fullname
  end

  # Get the current namespace as an object.
  # @return [TkNamespace, String] TkNamespace if known, path string otherwise
  def self.current
    ns = self.current_path
    Tk_Namespace_ID_TBL.mutex.synchronize{
      if Tk_Namespace_ID_TBL.key?(ns)
        Tk_Namespace_ID_TBL[ns]
      else
        ns
      end
    }
  end
  def current_namespace
    # ns_tk_call('namespace', 'current')
    # @fullname
    self
  end
  alias current current_namespace

  # Delete one or more namespaces.
  # @param ns_list [Array<TkNamespace, String>] Namespaces to delete
  # @return [void]
  def self.delete(*ns_list)
    tk_call('namespace', 'delete', *ns_list)
    ns_list.each{|ns|
      Tk_Namespace_ID_TBL.mutex.synchronize{
        if ns.kind_of?(TkNamespace)
          Tk_Namespace_ID_TBL.delete(ns.path)
        else
          Tk_Namespace_ID_TBL.delete(ns.to_s)
        end
      }
    }
  end
  # Delete this namespace.
  # @return [void]
  def delete
    TkNamespece.delete(@fullname)
  end

  # @!visibility private
  # @deprecated Use {Ensemble} class instead
  def self.ensemble_create(*keys)
    tk_call('namespace', 'ensemble', 'create', *hash_kv(keys))
  end
  # @!visibility private
  # @deprecated Use {Ensemble} class instead
  def self.ensemble_configure(cmd, slot, value=None)
    if slot.kind_of?(Hash)
      tk_call('namespace', 'ensemble', 'configure', cmd, *hash_kv(slot))
    else
      tk_call('namespace', 'ensemble', 'configure', cmd, '-'+slot.to_s, value)
    end
  end
  # @!visibility private
  # @deprecated Use {Ensemble} class instead
  def self.ensemble_configinfo(cmd, slot = nil)
    if slot
      tk_call('namespace', 'ensemble', 'configure', cmd, '-' + slot.to_s)
    else
      inf = {}
      Hash(*tk_split_simplelist(tk_call('namespace', 'ensemble', 'configure', cmd))).each{|k, v| inf[k[1..-1]] = v}
      inf
    end
  end
  # @!visibility private
  # @deprecated Use {Ensemble.exist?} instead
  def self.ensemble_exist?(cmd)
    bool(tk_call('namespace', 'ensemble', 'exists', cmd))
  end

  # Evaluate code in a namespace context.
  # @param namespace [String, TkNamespace] Namespace to evaluate in
  # @param cmd [String, Proc, nil] Code to evaluate
  # @param args [Array] Arguments passed to the code
  # @yield Block to evaluate (alternative to cmd)
  # @return [Object] Result of evaluation
  def self.eval(namespace, cmd = nil, *args, &block)
    cmd ||= block
    #tk_call('namespace', 'eval', namespace, cmd, *args)
    TkNamespace.new(namespace).eval(cmd, *args)
  end
  # Evaluate code in this namespace context.
  # @param cmd [String, Proc, nil] Code to evaluate
  # @param args [Array] Arguments passed to the code
  # @yield Block to evaluate
  # @return [Object] Result of evaluation
  def eval(cmd = nil, *args, &block)
    cmd ||= block
    code_obj = code(cmd)
    ret = code_obj.call(*args)
    uninstall_cmd(TkCore::INTERP._split_tklist(code_obj.path)[-1])
    ret
  end

  # Check if a namespace exists.
  # @param ns [String] Namespace path
  # @return [Boolean]
  def self.exist?(ns)
    bool(tk_call('namespace', 'exists', ns))
  end
  # Check if this namespace exists.
  # @return [Boolean]
  def exist?
    TkNamespece.exist?(@fullname)
  end

  # Export procedures from current namespace.
  #
  # Exported procedures can be imported by other namespaces.
  # Patterns use glob syntax.
  #
  # @param patterns [Array<String>] Procedure names or patterns to export
  # @return [void]
  #
  # @example
  #   TkNamespace.export('public_*', 'api_*')
  def self.export(*patterns)
    tk_call('namespace', 'export', *patterns)
  end
  # Export procedures, clearing previous exports first.
  # @param patterns [Array<String>] Procedure names or patterns
  # @return [void]
  def self.export_with_clear(*patterns)
    tk_call('namespace', 'export', '-clear', *patterns)
  end

  # (see .export)
  def export
    TkNamespace.export(@fullname)
  end

  # (see .export_with_clear)
  def export_with_clear
    TkNamespace.export_with_clear(@fullname)
  end

  # Remove imported procedures.
  #
  # Removes commands previously imported via {.import}.
  #
  # @param patterns [Array<String>] Qualified procedure names/patterns
  # @return [void]
  def self.forget(*patterns)
    tk_call('namespace', 'forget', *patterns)
  end
  # (see .forget)
  def forget
    TkNamespace.forget(@fullname)
  end

  # Import procedures from other namespaces.
  #
  # Creates local commands that call the exported procedures.
  # Use fully qualified names (e.g., `::other::proc`).
  #
  # @param patterns [Array<String>] Qualified procedure names/patterns
  # @return [void]
  # @raise [TclError] If procedure already exists (use {.force_import})
  #
  # @example
  #   TkNamespace.import('::math::sin', '::math::cos')
  def self.import(*patterns)
    tk_call('namespace', 'import', *patterns)
  end
  # Import procedures, overwriting existing commands.
  # @param patterns [Array<String>] Qualified procedure names/patterns
  # @return [void]
  def self.force_import(*patterns)
    tk_call('namespace', 'import', '-force', *patterns)
  end

  # (see .import)
  def import
    TkNamespace.import(@fullname)
  end

  # (see .force_import)
  def force_import
    TkNamespace.force_import(@fullname)
  end

  # Execute script in namespace with additional arguments.
  #
  # Like {.eval} but allows passing arguments to the script.
  # Arguments are appended to the script command.
  #
  # @param namespace [String] Namespace path
  # @param script [String] Script to execute
  # @param args [Array] Arguments appended to script
  # @return [Object] Script result
  def self.inscope(namespace, script, *args)
    tk_call('namespace', 'inscope', namespace, script, *args)
  end
  # (see .inscope)
  def inscope(script, *args)
    TkNamespace.inscope(@fullname, script, *args)
  end

  # Get the original command an imported command refers to.
  # @param cmd [String] Command name
  # @return [String] Fully qualified original command
  def self.origin(cmd)
    tk_call('namespace', 'origin', cmd)
  end

  # Get the parent namespace.
  # @param namespace [String] Namespace path (default: current)
  # @return [TkNamespace, String] Parent namespace
  def self.parent(namespace=None)
    ns = tk_call('namespace', 'parent', namespace)
    Tk_Namespace_ID_TBL.mutex.synchronize{
      if Tk_Namespace_ID_TBL.key?(ns)
        Tk_Namespace_ID_TBL[ns]
      else
        ns
      end
    }
  end

  # Get this namespace's parent.
  # @return [String] Parent namespace path
  def parent
    tk_call('namespace', 'parent', @fullname)
  end

  # Get the namespace search path.
  # @return [String] Current search path
  def self.get_path
    tk_call('namespace', 'path')
  end
  # Set the namespace search path.
  # @param namespace_list [Array<String>] Namespaces to search
  # @return [void]
  def self.set_path(*namespace_list)
    tk_call('namespace', 'path', array2tk_list(namespace_list))
  end

  # Add this namespace to the search path.
  # @return [void]
  def set_path
    tk_call('namespace', 'path', @fullname)
  end

  # Get the namespace qualifier portion of a name.
  #
  # Returns everything before the last `::`.
  #
  # @param str [String] Qualified name
  # @return [String] Namespace portion
  #
  # @example
  #   TkNamespace.qualifiers('::foo::bar::baz')  # => '::foo::bar'
  def self.qualifiers(str)
    tk_call('namespace', 'qualifiers', str)
  end

  # Get the tail portion of a qualified name.
  #
  # Returns everything after the last `::`.
  #
  # @param str [String] Qualified name
  # @return [String] Tail portion (simple name)
  #
  # @example
  #   TkNamespace.tail('::foo::bar::baz')  # => 'baz'
  def self.tail(str)
    tk_call('namespace', 'tail', str)
  end

  # Link variables between namespaces.
  #
  # Creates local variables that refer to variables in another namespace.
  #
  # @param namespace [String] Source namespace
  # @param var_pairs [Array] Pairs of [other_var, my_var] names
  # @return [void]
  def self.upvar(namespace, *var_pairs)
    tk_call('namespace', 'upvar', namespace, *(var_pairs.flatten))
  end
  # (see .upvar)
  def upvar(*var_pairs)
    TkNamespace.inscope(@fullname, *(var_pairs.flatten))
  end

  # Get the unknown command handler.
  # @return [Object] Current handler
  def self.get_unknown_handler
    tk_tcl2ruby(tk_call('namespace', 'unknown'))
  end
  # Set the unknown command handler.
  #
  # Called when a command is not found in the namespace.
  #
  # @param cmd [Proc, nil] Handler procedure
  # @yield Handler block (alternative to cmd)
  # @return [void]
  def self.set_unknown_handler(cmd = nil, &block)
    tk_call('namespace', 'unknown', cmd || block)
  end

  # Resolve a name to its fully qualified form.
  # @param name [String] Name to resolve
  # @return [String] Fully qualified name, or empty if not found
  def self.which(name)
    tk_call('namespace', 'which', name)
  end
  # Resolve a command name to its fully qualified form.
  # @param name [String] Command name to resolve
  # @return [String] Fully qualified name, or empty if not found
  def self.which_command(name)
    tk_call('namespace', 'which', '-command', name)
  end

  # Resolve a variable name to its fully qualified form.
  # @param name [String] Variable name to resolve
  # @return [String] Fully qualified name, or empty if not found
  def self.which_variable(name)
    tk_call('namespace', 'which', '-variable', name)
  end
end

# The global (root) Tcl namespace.
# @return [TkNamespace]
TkNamespace::Global = TkNamespace.new('::')
