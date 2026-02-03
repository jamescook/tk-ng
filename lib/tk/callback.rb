# frozen_string_literal: true

require_relative 'util'

module Tk
  module Core
    # Callback registration and dispatch.
    #
    # This module handles registering Ruby procs/blocks as Tcl callbacks
    # and dispatching calls from Tcl back to Ruby.
    #
    # ## How Callbacks Work
    #
    # 1. Ruby registers a proc via install_cmd, getting back a Tcl command string
    #    like "rb_out <ip_id> <callback_id>"
    # 2. Tcl stores this string in a widget option (e.g., -command)
    # 3. When the widget fires, Tcl calls "rb_out ..."
    # 4. The C bridge intercepts rb_out and calls Callback.callback
    # 5. Callback looks up the proc in tk_cmd_tbl and calls it
    #
    # ## Usage
    #
    #     # Register a callback
    #     cmd_string = install_cmd(proc { puts "clicked!" })
    #     tk_call('button', '.b', '-command', cmd_string)
    #
    #     # Later, unregister it
    #     uninstall_cmd(cmd_string)
    #
    # @see TkCore for INTERP and callback table setup
    module Callback
  include TkUtil
  extend TkUtil

  # Check if a class is a callback entry type
  def _callback_entry_class?(cls)
    cls <= Proc || cls <= Method || cls <= TkCallbackEntry
  end
  private :_callback_entry_class?

  # Check if an object is a callback entry
  def _callback_entry?(obj)
    obj.kind_of?(Proc) || obj.kind_of?(Method) || obj.kind_of?(TkCallbackEntry)
  end
  private :_callback_entry?

  # Get current callback ID (without incrementing)
  def _curr_cmd_id
    "c" + TkCore::INTERP._ip_id_ + TkComm::Tk_IDs[0]
  end
  private :_curr_cmd_id

  # Get next callback ID (thread-safe)
  def _next_cmd_id
    TkComm::Tk_IDs.mutex.synchronize {
      id = _curr_cmd_id
      TkComm::Tk_IDs[0].succ!
      id
    }
  end
  private :_next_cmd_id

  # Register a Ruby proc/block as a Tcl callback.
  #
  # Returns a Tcl command string like "rb_out <ip_id> <callback_id>" that
  # Tcl can invoke. When Tcl calls this command, it triggers the callback.
  #
  # @param cmd [Proc, Method, TkCallbackEntry] the callback to register
  # @return [String] Tcl command string to use in widget options
  #
  def self.install_cmd(cmd, local_cmdtbl=nil)
    return '' if cmd == ''
    begin
      ns = TkCore::INTERP._invoke_without_enc('namespace', 'current')
      ns = nil if ns == '::' # for backward compatibility
    rescue
      ns = nil
    end
    id = TkCallback._next_cmd_id
    if cmd.kind_of?(TkCallbackEntry)
      TkCore::INTERP.tk_cmd_tbl[id] = cmd
    else
      TkCore::INTERP.tk_cmd_tbl[id] = TkCore::INTERP.get_cb_entry(cmd)
    end
    @cmdtbl ||= []
    @cmdtbl.push id

    if local_cmdtbl && local_cmdtbl.kind_of?(Array)
      begin
        local_cmdtbl << id
      rescue StandardError
        # ignore
      end
    end

    if ns
      "rb_out#{TkCore::INTERP._ip_id_} #{ns} #{id}"
    else
      "rb_out#{TkCore::INTERP._ip_id_} #{id}"
    end
  end

  # Remove a previously registered callback.
  #
  # @param id [String] the callback ID or full rb_out string
  #
  def self.uninstall_cmd(id, local_cmdtbl=nil)
    id = $4 if id =~ /rb_out\S*(?:\s+(::\S*|[{](::.*)[}]|["](::.*)["]))? (c(_\d+_)?(\d+))/

    if local_cmdtbl && local_cmdtbl.kind_of?(Array)
      begin
        local_cmdtbl.delete(id)
      rescue StandardError
        # ignore
      end
    end
    @cmdtbl ||= []
    @cmdtbl.delete(id)

    TkCore::INTERP.tk_cmd_tbl.delete(id)
  end

  # Instance method wrappers
  def install_cmd(cmd)
    TkCallback.install_cmd(cmd, @cmdtbl)
  end

  def uninstall_cmd(id)
    TkCallback.uninstall_cmd(id, @cmdtbl)
  end

  # Raise to signal Tk should stop event propagation
  def callback_break
    fail TkCallbackBreak, "Tk callback returns 'break' status"
  end

  # Raise to signal Tk should continue to next binding
  def callback_continue
    fail TkCallbackContinue, "Tk callback returns 'continue' status"
  end

  # Raise to signal early return from callback
  def callback_return
    fail TkCallbackReturn, "Tk callback returns 'return' status"
  end

  # Main callback dispatcher - called from C when Tcl invokes "rb_out"
  #
  # Looks up the callback in tk_cmd_tbl and calls it.
  # Formats exception messages with backtrace for Tcl error reporting.
  #
  def self.callback(*arg)
    begin
      if TkCore::INTERP.tk_cmd_tbl.kind_of?(Hash)
        normal_ret = false
        ret = catch(:IRB_EXIT) do  # IRB hack
          retval = TkCore::INTERP.tk_cmd_tbl[arg.shift].call(*arg)
          normal_ret = true
          retval
        end
        unless normal_ret
          exit(ret)
        end
        ret
      end
    rescue SystemExit => e
      exit(e.status)
    rescue Interrupt => e
      fail(e)
    rescue StandardError => e
      begin
        msg = e.class.inspect + ': ' +
              e.message + "\n" +
              "\n---< backtrace of Ruby side >-----\n" +
              e.backtrace.join("\n") +
              "\n---< backtrace of Tk side >-------"
        msg.force_encoding('utf-8')
      rescue StandardError
        msg = e.class.inspect + ': ' + e.message + "\n" +
              "\n---< backtrace of Ruby side >-----\n" +
              e.backtrace.join("\n") +
              "\n---< backtrace of Tk side >-------"
      end
      fail(e, msg)
    end
  end

  # Generate next callback ID (thread-safe) - class method for self.install_cmd
  # @api private
  def self._next_cmd_id
    TkComm::Tk_IDs.mutex.synchronize {
      id = "c" + TkCore::INTERP._ip_id_ + TkComm::Tk_IDs[0]
      TkComm::Tk_IDs[0].succ!
      id
    }
  end

  # Class method versions for backward compat (called as TkComm._callback_entry?)
  # @api private
  def self._callback_entry?(obj)
    obj.kind_of?(Proc) || obj.kind_of?(Method) || obj.kind_of?(TkCallbackEntry)
  end

  # @api private
  def self._callback_entry_class?(cls)
    cls <= Proc || cls <= Method || cls <= TkCallbackEntry
  end
    end
  end
end

# Backward compat shim
TkCallback = Tk::Core::Callback
