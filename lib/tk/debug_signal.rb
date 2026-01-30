# frozen_string_literal: true

# Debug signal handler for Tk applications.
# Send SIGUSR1 (default) to dump thread/ractor info to stderr.
#
# Usage:
#   kill -USR1 <pid>
#
# Configure:
#   Tk.debug_signal = :SIGUSR2  # use different signal
#   Tk.debug_signal = nil       # disable
#
# Environment:
#   TK_DEBUG_SIGNAL=0           # disable auto-install on require
module TkDebugSignal
  def self.included(base)
    base.extend(ClassMethods)
    # Auto-install unless disabled via ENV
    unless ENV['TK_DEBUG_SIGNAL'] == '0'
      base.install_debug_signal_handler
    end
  end

  module ClassMethods
    # Debug signal configuration.
    # Send this signal to dump thread/ractor info to stderr.
    # Default: :SIGUSR1. Set to nil to disable.
    def debug_signal
      return @debug_signal if defined?(@debug_signal)
      @debug_signal = :SIGUSR1
    end

    def debug_signal=(sig)
      # Remove old handler if changing
      if defined?(@debug_signal) && @debug_signal && @debug_signal_installed
        Signal.trap(@debug_signal, 'DEFAULT') rescue nil
      end
      @debug_signal = sig
      @debug_signal_installed = false
      install_debug_signal_handler if sig
    end

    def install_debug_signal_handler
      return unless debug_signal
      return if @debug_signal_installed
      Signal.trap(debug_signal) { dump_debug_info }
      @debug_signal_installed = true
    rescue ArgumentError => e
      # Signal not supported on this platform
      warn "[Tk] Could not install debug signal handler: #{e.message}"
    end

    def dump_debug_info
      info = []
      info << "=== Tk Debug Info (#{Time.now}) ==="
      info << "Ruby: #{RUBY_VERSION} (#{RUBY_PLATFORM})"
      info << "Process: #{Process.pid}"
      info << ""
      info << "Background work mode: #{background_work_mode}"
      info << "Background poll interval: #{background_work_poll_ms}ms"
      info << ""

      # Active background tasks
      active = background_tasks.reject(&:done?)
      if active.any?
        info << "Active background tasks: #{active.size}"
        active.each_with_index do |task, i|
          name = task.name || "(unnamed)"
          status = task.paused? ? " (paused)" : ""
          info << "  #{i}: #{name} [#{task.mode}]#{status}"
        end
        info << ""
      end

      info << "Threads: #{Thread.list.count}"
      Thread.list.each_with_index do |t, i|
        status = t.status || 'dead'
        name = t.name || "(unnamed)"
        current = t == Thread.current ? " [current]" : ""
        main = t == Thread.main ? " [main]" : ""
        info << "  #{i}: #{name} (#{status})#{current}#{main}"
      end
      if defined?(Ractor) && Ractor.respond_to?(:count)
        info << ""
        info << "Ractors: #{Ractor.count}"
      end
      if defined?(TkBackgroundRactor3x)
        count = TkBackgroundRactor3x.instance_variable_get(:@active_ractors)&.size || 0
        info << "Active background ractors (3.x): #{count}" if count > 0
      end
      info << "=== End Debug Info ==="
      $stderr.puts info.join("\n")
    end
  end
end
