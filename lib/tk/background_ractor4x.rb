# frozen_string_literal: true

# Ruby 4.x Ractor-based background work for Tk applications.
# Uses Ractor::Port for streaming and Ractor.shareable_proc for blocks.
# Uses thread-inside-ractor pattern for non-blocking message handling.
#
# == Ruby 4.x vs 3.x Ractor Differences
#
# | Aspect                      | 3.x                          | 4.x                           |
# |-----------------------------|------------------------------|-------------------------------|
# | Output mechanism            | Ractor.yield (BLOCKS)        | Port.send (non-blocking)      |
# | Orphaned threads on exit    | Hangs in rb_ractor_terminate | Exits cleanly                 |
# | Block support               | Must use worker class        | Ractor.shareable_proc works   |
# | close_incoming after yield  | Bug: doesn't wake threads    | Works correctly               |
#
# Because of these differences, the 3.x implementation requires workarounds
# that are NOT needed here:
# - Yielder thread (to decouple worker from blocking Ractor.yield)
# - Timeout-based polling for messages (to avoid receiver thread cleanup bug)
# - at_exit Ractor tracking (to handle cleanup issues)
#
# This 4.x implementation is simpler because Ruby 4.x Ractors just work.

module TkBackgroundRactor4x
  # Poll interval when paused (slower to save CPU)
  PAUSED_POLL_MS = 500

  class BackgroundWork
    def initialize(data, worker: nil, &block)
      # Ruby 4.x supports both block and worker class
      @data = data
      @work_block = block || (worker && proc { |t, d| worker.new.call(t, d) })
      @callbacks = { progress: nil, done: nil, message: nil }
      @started = false
      @done = false
      @paused = false

      # Communication
      @output_queue = Thread::Queue.new
      @control_port = nil  # Set by worker, received back
      @pending_messages = []  # Queued until control_port ready
      @worker_ractor = nil
      @bridge_thread = nil
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
      if @control_port
        begin
          @control_port.send(msg)
        rescue Ractor::ClosedError
          # Port already closed, task is done - ignore
        end
      else
        @pending_messages << msg
      end
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
      @done = true
      @control_port = nil  # Prevent further message sends
      begin
        @worker_ractor&.close_incoming
        @worker_ractor&.close_outgoing
      rescue Ractor::ClosedError
        # Already closed
      end
      self
    end

    def start
      return self if @started
      @started = true

      # Wrap in isolated proc for Ractor sharing. The block can only access
      # its parameters (task, data), not outer-scope variables.
      shareable_block = Ractor.shareable_proc(&@work_block)

      start_ractor(shareable_block)
      start_polling
      self
    end

    def done?
      @done
    end

    def paused?
      @paused
    end

    private

    def maybe_start
      start unless @started
    end

    def start_ractor(shareable_block)
      data = @data
      output_port = Ractor::Port.new

      @worker_ractor = Ractor.new(data, output_port, shareable_block) do |d, out, blk|
        # Worker creates its own control port for receiving messages
        control_port = Ractor::Port.new
        msg_queue = Thread::Queue.new

        # Send control port back to main thread
        out.send([:control_port, control_port])

        # Background thread receives from control port, forwards to queue
        Thread.new do
          loop do
            begin
              msg = control_port.receive
              msg_queue << msg
              break if msg == :stop
            rescue Ractor::ClosedError
              break
            end
          end
        end

        Thread.current[:tk_in_background_work] = true
        task = TaskContext.new(out, msg_queue)
        begin
          blk.call(task, d)
          out.send([:done])
        rescue StopIteration
          out.send([:done])
        rescue => e
          out.send([:error, "#{e.class}: #{e.message}\n#{e.backtrace.first(3).join("\n")}"])
          out.send([:done])
        end
      end

      # Bridge thread: Port.receive -> Queue
      @bridge_thread = Thread.new do
        loop do
          begin
            result = output_port.receive
            if result.is_a?(Array) && result[0] == :control_port
              @control_port = result[1]
              @pending_messages.each { |m| @control_port.send(m) }
              @pending_messages.clear
            else
              @output_queue << result
              break if result[0] == :done
            end
          rescue Ractor::ClosedError
            @output_queue << [:done]
            break
          end
        end
      end
    end

    def start_polling
      @dropped_count = 0
      @choke_warned = false

      poll = proc do
        next if @done

        drop_intermediate = Tk.background_work_drop_intermediate
        # Drain queue. If drop_intermediate, only use LATEST progress value.
        # This prevents UI choking when worker yields faster than UI polls.
        last_progress = nil
        results_this_poll = 0
        begin
          while (msg = @output_queue.pop(true))
            type, value = msg
            case type
            when :done
              @done = true
              @control_port = nil  # Clear to prevent send to closed port
              # Call progress with final value before done callback
              @callbacks[:progress]&.call(last_progress) if last_progress
              last_progress = nil  # Prevent duplicate call after loop
              warn_if_choked
              @callbacks[:done]&.call
              break
            when :result
              results_this_poll += 1
              if drop_intermediate
                last_progress = value  # Keep only latest
              else
                @callbacks[:progress]&.call(value)  # Call for every value
              end
            when :message
              @callbacks[:message]&.call(value)
            when :error
              if Tk.abort_on_ractor_error
                raise RuntimeError, "[Ractor] Background work error: #{value}"
              else
                warn "[Ractor] Background work error: #{value}"
              end
            end
          end
        rescue ThreadError
          # Queue empty
        end

        # Track dropped messages (all but the last one we processed)
        if drop_intermediate && results_this_poll > 1
          dropped = results_this_poll - 1
          @dropped_count += dropped
          warn_choke_start(dropped) unless @choke_warned
        end

        # Call progress callback once with latest value (only if dropping)
        @callbacks[:progress]&.call(last_progress) if drop_intermediate && last_progress && !@done

        unless @done
          # Use slower polling when paused to save CPU
          interval = @paused ? PAUSED_POLL_MS : Tk.background_work_poll_ms
          Tk.after(interval, &poll)
        end
      end

      Tk.after(0, &poll)
    end

    def warn_choke_start(dropped)
      @choke_warned = true
      warn "[Tk::BackgroundWork] UI choking: worker yielding faster than UI can poll. " \
           "#{dropped} progress values dropped this cycle. " \
           "Consider yielding less frequently or increasing Tk.background_work_poll_ms."
    end

    def warn_if_choked
      return unless @dropped_count > 0
      warn "[Tk::BackgroundWork] Total #{@dropped_count} progress values dropped during task. " \
           "Only latest values were shown to UI."
    end

    # Task context for Ractor mode (runs inside Ractor)
    class TaskContext
      def initialize(output_port, msg_queue)
        @output_port = output_port
        @msg_queue = msg_queue
        @paused = false
      end

      def yield(value)
        check_pause_loop
        @output_port.send([:result, value])
      end

      def check_message
        msg = @msg_queue.pop(true)
        handle_control_message(msg)
        msg
      rescue ThreadError
        nil
      end

      def wait_message
        msg = @msg_queue.pop
        handle_control_message(msg)
        msg
      end

      def send_message(msg)
        @output_port.send([:message, msg])
      end

      def check_pause
        check_pause_loop
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

      def check_pause_loop
        while @paused
          msg = @msg_queue.pop
          handle_control_message(msg)
        end
      end
    end
  end
end
