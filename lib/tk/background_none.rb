# frozen_string_literal: true

# Synchronous "background" work - runs on main thread, blocks UI.
#
# FOR TESTING AND DEMONSTRATION ONLY.
#
# This mode exists to show what happens WITHOUT background processing:
# the UI freezes during work. Use it in demos to contrast with :thread
# and :ractor modes which keep the UI responsive.
#
# Not registered by default. To use:
#   require 'tk/background_none'
#   Tk.register_background_mode(:none, TkBackgroundNone::BackgroundWork)
#
# Note: pause/resume/stop work the same as other modes, but since work
# runs synchronously on the main thread, the UI may be idle and unable
# to respond to button clicks while work is in progress.

module TkBackgroundNone
  class BackgroundWork
    def initialize(data, worker: nil, &block)
      @data = data
      @work_block = block || (worker && proc { |t, d| worker.new.call(t, d) })
      @callbacks = { progress: nil, done: nil, message: nil }
      @message_queue = []
      @started = false
      @done = false
      @paused = false
    end

    def on_progress(&block)
      @callbacks[:progress] = block
      maybe_start
      self
    end

    def on_done(&block)
      @callbacks[:done] = block
      maybe_start
      self
    end

    def on_message(&block)
      @callbacks[:message] = block
      self
    end

    def send_message(msg)
      @message_queue << msg
      self
    end

    def pause
      @paused = true
      send_message(:pause)
      self
    end

    def resume
      @paused = false
      send_message(:resume)
      self
    end

    def stop
      send_message(:stop)
      self
    end

    def close
      self
    end

    def done?
      @done
    end

    def paused?
      @paused
    end

    def start
      maybe_start
      self
    end

    private

    def maybe_start
      return if @started
      @started = true
      # Defer start to next event loop iteration so @background_task
      # assignment completes before work begins. Without this, pause/stop
      # wouldn't work because @background_task would still be nil.
      Tk.after(0) { do_work }
    end

    def do_work
      task = TaskContext.new(@callbacks, @message_queue)
      begin
        @work_block.call(task, @data)
      rescue StopIteration
        # Worker requested stop
      rescue => e
        warn "[None] Background work error: #{e.class}: #{e.message}"
      end

      @done = true
      @callbacks[:done]&.call
    end

    # Synchronous task context - callbacks fire immediately
    class TaskContext
      def initialize(callbacks, message_queue)
        @callbacks = callbacks
        @message_queue = message_queue
        @paused = false
      end

      def yield(value)
        @callbacks[:progress]&.call(value)
      end

      def check_message
        msg = @message_queue.shift
        handle_control_message(msg) if msg
        msg
      end

      def wait_message
        # In sync mode, just check the queue
        check_message
      end

      def send_message(msg)
        @callbacks[:message]&.call(msg)
      end

      def check_pause
        while @paused
          # Must process Tk events so Resume button clicks are received
          Tk.update
          msg = check_message
          break unless @paused
        end
      end

      private

      def handle_control_message(msg)
        case msg
        when :pause
          @paused = true
        when :resume
          @paused = false
        when :stop
          raise StopIteration
        end
      end
    end
  end
end
