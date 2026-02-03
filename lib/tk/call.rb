# frozen_string_literal: true
#
# TkCall - Low-level Tcl command invocation
#
# This module provides the fundamental methods for calling Tcl commands
# from Ruby. It's the bridge between Ruby code and the Tcl interpreter.
#
# Most code should include this module (along with TkUtil) rather than
# the heavier TkCore or Tk modules.
#
# ## Usage
#
#     module MyGeometryManager
#       include TkUtil  # for _epath, list, etc.
#       include TkCall  # for tk_call_without_enc
#
#       def configure(win, **opts)
#         tk_call_without_enc('mymanager', 'configure', _epath(win), *hash_kv(opts))
#       end
#     end
#
# ## Methods
#
# - `tk_call(*args)` - Call Tcl command with auto encoding
# - `tk_call_without_enc(*args)` - Call without encoding conversion (most common)
# - `tk_call_with_enc(*args)` - Call with forced encoding conversion
# - `ip_invoke(*args)` - Lower-level invoke (less error handling)
# - `ip_eval(script)` - Evaluate raw Tcl script string
#
# @see TkUtil for type conversion utilities
# @see TkCore for the full interpreter interface (mainloop, after, etc.)

require_relative 'util'

module TkCall
  include TkUtil
  extend TkUtil

  # The interpreter is initialized in TkCore.
  # These methods reference TkCore::INTERP which is resolved at call time.
  #
  # List parsing methods (tk_split_simplelist, list, etc.) are in TkUtil.

  def _ip_eval_core(enc_mode, cmd_string)
    # encoding mode is ignored - everything is UTF-8 now
    res = TkCore::INTERP._eval(cmd_string)
    if TkCore::INTERP._return_value() != 0
      fail RuntimeError, res, error_at
    end
    res
  end
  private :_ip_eval_core

  # Evaluate a raw Tcl script string.
  # Prefer tk_call for most uses - it handles argument quoting.
  def ip_eval(cmd_string)
    _ip_eval_core(nil, cmd_string)
  end

  def ip_eval_without_enc(cmd_string)
    _ip_eval_core(false, cmd_string)
  end

  def ip_eval_with_enc(cmd_string)
    _ip_eval_core(true, cmd_string)
  end

  def _ip_invoke_core(enc_mode, *args)
    # encoding mode is ignored - everything is UTF-8 now
    res = TkCore::INTERP._invoke(*args)
    if TkCore::INTERP._return_value() != 0
      fail RuntimeError, res, error_at
    end
    res
  end
  private :_ip_invoke_core

  # Low-level Tcl command invocation.
  # Arguments are passed directly to the interpreter.
  def ip_invoke(*args)
    _ip_invoke_core(nil, *args)
  end

  def ip_invoke_without_enc(*args)
    _ip_invoke_core(false, *args)
  end

  def ip_invoke_with_enc(*args)
    _ip_invoke_core(true, *args)
  end

  def _tk_call_core(enc_mode, *args)
    args = _conv_args([], enc_mode, *args)
    puts 'invoke args => ' + args.inspect if $DEBUG
    begin
      res = _ip_invoke_core(enc_mode, *args)
    rescue NameError => err
      begin
        args.unshift "unknown"
        res = _ip_invoke_core(enc_mode, *args)
      rescue StandardError => err2
        fail err2 unless /^invalid command/ =~ err2.message
        fail err
      end
    end
    if TkCore::INTERP._return_value() != 0
      fail RuntimeError, res, error_at
    end
    res
  end
  private :_tk_call_core

  # Execute a Tcl command with automatic argument conversion.
  #
  # This is the primary interface for calling Tcl/Tk commands.
  # Ruby values are automatically converted to Tcl strings.
  #
  # @param args [Array] the Tcl command and arguments
  # @return [String] the Tcl result
  #
  # @example Create a button
  #   tk_call('button', '.b', '-text', 'Click me')
  #
  # @example Query widget info
  #   tk_call('winfo', 'width', '.frame')
  #
  def tk_call(*args)
    _tk_call_core(nil, *args)
  end

  # Like tk_call but skips encoding conversion.
  # Use when arguments are already properly encoded.
  # This is the most commonly used variant.
  def tk_call_without_enc(*args)
    _tk_call_core(false, *args)
  end

  # Like tk_call but forces encoding conversion.
  def tk_call_with_enc(*args)
    _tk_call_core(true, *args)
  end

  def _tk_call_to_list_core(depth, arg_enc, val_enc, *args)
    args = _conv_args([], arg_enc, *args)
    val = _tk_call_core(false, *args)
    if !depth.kind_of?(Integer) || depth == 0
      tk_split_simplelist(val, false, val_enc)
    else
      tk_split_list(val, depth, false, val_enc)
    end
  end

  def tk_call_to_list(*args)
    _tk_call_to_list_core(-1, nil, true, *args)
  end

  def tk_call_to_list_without_enc(*args)
    _tk_call_to_list_core(-1, false, false, *args)
  end

  def tk_call_to_list_with_enc(*args)
    _tk_call_to_list_core(-1, true, true, *args)
  end

  def tk_call_to_simplelist(*args)
    _tk_call_to_list_core(0, nil, true, *args)
  end

  def tk_call_to_simplelist_without_enc(*args)
    _tk_call_to_list_core(0, false, false, *args)
  end

  def tk_call_to_simplelist_with_enc(*args)
    _tk_call_to_list_core(0, true, true, *args)
  end

  # Load a Tcl command into the interpreter if not already present.
  def load_cmd_on_ip(tk_cmd)
    bool(tk_call('auto_load', tk_cmd))
  end

  # Helper for error backtraces - filters out internal tk frames
  def error_at
    frames = caller()
    frames.delete_if do |c|
      c =~ %r!/tk(|core|thcore|canvas|text|entry|scrollbox)\.rb:\d+!
    end
    frames
  end
  private :error_at

  # Methods are included as instance methods when `include TkCall` is used.
  # For module-level calls like Tk.tk_call, Tk extends itself.
end
