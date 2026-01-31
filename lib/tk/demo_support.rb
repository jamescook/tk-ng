# frozen_string_literal: true
#
# TkDemo - Helper module for automated sample testing and recording
#
# Two independent modes:
#   - Test mode (TK_READY_PORT): Quick verification that sample loads/runs
#   - Record mode (TK_RECORD): Video capture with longer delays
#
# Usage:
#   require 'tk/demo_support'
#
#   if TkDemo.active?
#     TkDemo.on_visible {
#       button.invoke
#       Tk.after(TkDemo.delay(test: 200, record: 500)) {
#         button.invoke
#         TkDemo.finish
#       }
#     }
#   end
#
require 'socket'

module TkDemo
  # When recording, use Ttk for modern themed look and hide cursor
  if ENV['TK_RECORD']
    require 'tkextlib/tile'
    Tk.default_widget_set = :Ttk
    Tk.root.configure(:cursor => 'none')
  end

  class << self
    # Check if running in test mode (quick smoke test)
    def testing?
      !!ENV['TK_READY_PORT']
    end

    # Check if running in record mode (video capture)
    def recording?
      !!ENV['TK_RECORD']
    end

    # Check if either automated mode is active
    def active?
      testing? || recording?
    end

    # Get appropriate delay for current mode
    # @param test [Integer] delay in ms for test mode (default: 100)
    # @param record [Integer] delay in ms for record mode (default: 1000)
    # @return [Integer] delay in milliseconds
    def delay(test: 100, record: 1000)
      recording? ? record : test
    end

    # Capture a thumbnail screenshot using tkimg
    # @param window [TkWindow] window to capture (default: Tk.root)
    # @param path [String] output path (default: TK_THUMBNAIL_PATH env var)
    def capture_thumbnail(window: Tk.root, path: ENV['TK_THUMBNAIL_PATH'])
      return unless path

      begin
        require 'tkextlib/tkimg/window'
        require 'tkextlib/tkimg/png'

        # Ensure all widgets are fully drawn
        Tk.update

        img = TkPhotoImage.new(:format => 'window', :data => window.path)
        img.write(path, :format => 'png')
        $stderr.puts "TkDemo: thumbnail saved to #{path}"
      rescue => e
        $stderr.puts "TkDemo: thumbnail capture failed: #{e.message}"
      end
    end

    # Run block once when window becomes visible
    # Handles the Visibility binding, "run once" guard, and safety timeout
    #
    # PREFERRED: Use this when you can set up the binding BEFORE creating UI.
    # The Visibility event fires when the window first appears on screen.
    #
    # @param timeout [Integer] safety timeout in seconds (default: 60)
    # @see after_idle for cases where UI is created before binding can be set up
    def on_visible(timeout: 60, &block)
      $stderr.puts "DEBUG on_visible: called, active?=#{active?}, recording?=#{recording?}"
      return unless active?
      raise ArgumentError, "block required" unless block

      @demo_started = false
      Tk.root.bind('Visibility') {
        $stderr.puts "DEBUG on_visible: Visibility event fired, @demo_started=#{@demo_started}"
        next if @demo_started
        @demo_started = true

        # Signal recording harness that window is ready (also captures thumbnail)
        $stderr.puts "DEBUG on_visible: calling signal_recording_ready"
        signal_recording_ready if recording?

        # Safety timeout to prevent stuck demos
        Tk.after(timeout * 1000) {
          $stderr.puts "TkDemo: timeout after #{timeout}s, forcing exit"
          finish
        }

        Tk.after(50) { block.call }
      }
    end

    # Run block once when event loop is idle
    # Alternative to on_visible for samples where UI is created before
    # the demo binding can be set up.
    #
    # Use this when:
    # - The sample creates windows before requiring tk/demo_support
    # - The Visibility event has already fired by the time binding is set up
    #
    # @param timeout [Integer] safety timeout in seconds (default: 60)
    # @see on_visible (preferred when binding can be set up before UI creation)
    def after_idle(timeout: 60, &block)
      $stderr.puts "DEBUG after_idle: called, active?=#{active?}, recording?=#{recording?}"
      return unless active?
      raise ArgumentError, "block required" unless block

      @demo_started = false
      Tk.after_idle {
        $stderr.puts "DEBUG after_idle: callback fired, @demo_started=#{@demo_started}"
        next if @demo_started
        @demo_started = true

        # Signal recording harness that window is ready (also captures thumbnail)
        $stderr.puts "DEBUG after_idle: calling signal_recording_ready"
        signal_recording_ready if recording?

        # Safety timeout to prevent stuck demos
        Tk.after(timeout * 1000) {
          $stderr.puts "TkDemo: timeout after #{timeout}s, forcing exit"
          finish
        }

        block.call
      }
    end

    # Signal recording harness that window is visible and ready to record
    # Polls until geometry is valid, then captures thumbnail and signals
    # Called automatically by on_visible/after_idle when recording
    def signal_recording_ready(window: Tk.root)
      $stderr.puts "DEBUG signal_recording_ready: TK_STOP_PORT=#{ENV['TK_STOP_PORT'].inspect}"
      return unless (port = ENV['TK_STOP_PORT'])
      return if @_recording_ready_sent
      $stderr.puts "DEBUG signal_recording_ready: will signal on port #{port}"

      try_signal = proc do
        Tk.update_idletasks
        width = window.winfo_width
        height = window.winfo_height

        if width >= 10 && height >= 10
          @_recording_ready_sent = true
          @_initial_geometry = [width, height]
          $stderr.puts "DEBUG signal_recording_ready: geometry valid #{width}x#{height}, sending signal"

          # Capture thumbnail now that geometry is valid
          capture_thumbnail

          begin
            $stderr.puts "DEBUG signal_recording_ready: connecting to 127.0.0.1:#{port}"
            sock = TCPSocket.new('127.0.0.1', port.to_i)
            msg = "R:#{width}x#{height}"
            $stderr.puts "DEBUG signal_recording_ready: writing '#{msg}'"
            sock.write(msg)
            sock.close
            $stderr.puts "DEBUG signal_recording_ready: sent successfully"
          rescue StandardError => e
            $stderr.puts "DEBUG signal_recording_ready: ERROR #{e.class}: #{e.message}"
          end
        else
          # Geometry not ready, try again in 10ms
          Tk.after(10) { try_signal.call }
        end
      end

      try_signal.call
    end

    # Signal test harness that sample is ready (without exiting)
    # Use this for samples with custom shutdown logic.
    # For normal samples, use finish() instead.
    def signal_ready
      $stdout.flush

      # Signal test harness via TCP connection
      if (port = ENV.delete('TK_READY_PORT'))
        begin
          TCPSocket.new('127.0.0.1', port.to_i).close
        rescue StandardError
          # Ignore errors (server may have timed out)
        end
      end
    end

    # Signal completion and exit cleanly
    # Handles TK_READY_PORT (test) and TK_STOP_PORT (record)
    def finish
      signal_ready

      # Check if geometry changed during demo
      if recording? && @_initial_geometry
        Tk.update_idletasks
        width = Tk.root.winfo_width
        height = Tk.root.winfo_height
        if [width, height] != @_initial_geometry
          $stderr.puts "TkDemo: geometry changed from #{@_initial_geometry.join('x')} to #{width}x#{height}"
        end
      end

      # Signal recording harness via socket and wait for "ok to exit"
      if (port = ENV['TK_STOP_PORT'])
        Thread.new do
          begin
            sock = TCPSocket.new('127.0.0.1', port.to_i)
            sock.read(1)  # Block until harness sends byte or closes
            sock.close
          rescue StandardError
            # Ignore errors
          end
          Tk.after_idle { Tk.root.destroy }
        end
      else
        # Exit cleanly outside of event processing
        Tk.after_idle { Tk.root.destroy }
      end
    end
  end
end
