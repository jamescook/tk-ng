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
      return unless active?
      raise ArgumentError, "block required" unless block

      @demo_started = false
      Tk.root.bind('Visibility') {
        next if @demo_started
        @demo_started = true

        # Capture thumbnail when recording
        capture_thumbnail if recording?

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
      return unless active?
      raise ArgumentError, "block required" unless block

      @demo_started = false
      Tk.after_idle {
        next if @demo_started
        @demo_started = true

        # Capture thumbnail when recording
        capture_thumbnail if recording?

        # Safety timeout to prevent stuck demos
        Tk.after(timeout * 1000) {
          $stderr.puts "TkDemo: timeout after #{timeout}s, forcing exit"
          finish
        }

        block.call
      }
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
    # Handles both TK_READY_PORT (test) and TK_STOP_PIPE (record)
    def finish
      signal_ready

      # Signal recording harness
      if (pipe = ENV['TK_STOP_PIPE'])
        begin
          File.write(pipe, "1")
        rescue StandardError
          # Ignore errors (pipe may not exist)
        end
      end

      # Exit cleanly outside of event processing
      Tk.after_idle { Tk.root.destroy }
    end
  end
end
