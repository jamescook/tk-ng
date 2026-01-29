# frozen_string_literal: true

# Ruby 3.x Ractor-based background work for Tk applications.
# Uses Ractor.yield/take for streaming (no Port API).
#
# In Ruby 3.x, procs cannot be passed to Ractors because they carry
# their lexical binding. Instead, provide a worker CLASS which is
# shareable and gets instantiated inside the Ractor.
#
# Example:
#   class FileHasher
#     def call(task, data)
#       data[:files].each { |f| task.yield(Digest::SHA256.file(f).hexdigest) }
#     end
#   end
#
#   TkCore.background_work(data, worker: FileHasher)
#     .on_progress { |hash| puts hash }

module TkBackgroundRactor3x
  # Default poll interval: 16ms ≈ 60fps
  DEFAULT_POLL_MS = 16

  # Track active Ractors for cleanup at exit
  @active_ractors = []
  @mutex = Mutex.new

  def self.register_ractor(r)
    @mutex.synchronize { @active_ractors << r }
  end

  def self.unregister_ractor(r)
    @mutex.synchronize { @active_ractors.delete(r) }
  end

  def self.close_all_ractors
    @mutex.synchronize do
      @active_ractors.each do |r|
        r.close_incoming rescue nil
        r.close_outgoing rescue nil
      end
      @active_ractors.clear
    end
  end

  at_exit { close_all_ractors }

  class BackgroundWork
    def initialize(data, worker: nil, &block)
      if block
        raise ArgumentError, <<~MSG
          Ruby 3.x Ractors cannot accept blocks (they carry lexical bindings).
          Provide a worker class instead:

            class MyWorker
              def call(task, data)
                data[:items].each { |item| task.yield(process(item)) }
              end
            end

            TkCore.background_work(data, mode: :ractor, worker: MyWorker)
        MSG
      end

      unless worker
        raise ArgumentError, "worker: class is required for Ruby 3.x Ractor mode"
      end

      @data = data
      @worker_class = worker
      @callbacks = { progress: nil, done: nil, message: nil }
      @started = false
      @done = false

      # Communication
      @output_queue = Thread::Queue.new
      @pending_messages = []
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
      if @worker_ractor
        @worker_ractor.send(msg)
      else
        @pending_messages << msg
      end
      self
    end

    def pause
      send_message(:pause)
      self
    end

    def resume
      send_message(:resume)
      self
    end

    def stop
      send_message(:stop)
      self
    end

    # Forcibly close the Ractor (for app shutdown)
    def close
      @done = true
      @worker_ractor&.close_incoming
      @worker_ractor&.close_outgoing
      self
    end

    def start
      return self if @started
      @started = true

      start_ractor
      start_polling
      self
    end

    private

    def maybe_start
      start unless @started
    end

    def start_ractor
      data = @data
      worker_class = @worker_class

      @worker_ractor = Ractor.new(data, worker_class) do |d, klass|
        # Ractor.yield blocks until someone takes, so we use a queue + yielder
        # thread to decouple the worker from blocking yields.
        yield_queue = Thread::Queue.new

        # Yielder thread: drains yield_queue and does blocking Ractor.yield
        yielder = Thread.new do
          loop do
            msg = yield_queue.pop
            begin
              Ractor.yield(msg)
            rescue Ractor::ClosedError
              break  # Outgoing port closed (app shutdown)
            end
            break if msg[0] == :done
          end
        end

        # NOTE: No receiver thread. Ruby 3.x has a bug where close_incoming
        # doesn't wake up threads blocked on Ractor.receive after yield/take
        # interactions have occurred. Instead, we poll with timeouts.

        # Let yielder thread start before worker begins pushing to queue
        Thread.pass

        Thread.current[:tk_in_background_work] = true
        begin
          task = TaskContext.new(yield_queue)
          worker = klass.new
          worker.call(task, d)
          yield_queue << [:done]
        rescue StopIteration
          yield_queue << [:done]
        rescue => e
          yield_queue << [:error, "#{e.class}: #{e.message}\n#{e.backtrace.first(3).join("\n")}"]
          yield_queue << [:done]
        ensure
          yielder.join
        end
      end

      TkBackgroundRactor3x.register_ractor(@worker_ractor)

      # Flush any messages queued before ractor was ready
      @pending_messages.each { |m| @worker_ractor.send(m) }
      @pending_messages.clear

      # Bridge thread: Ractor.take -> Queue
      @bridge_thread = Thread.new do
        loop do
          begin
            result = @worker_ractor.take
            @output_queue << result
            break if result[0] == :done
          rescue Ractor::ClosedError
            @output_queue << [:done]
            break
          rescue Ractor::RemoteError => e
            # Ractor died with uncaught exception - report and finish
            @output_queue << [:error, "Ractor died: #{e.cause&.class}: #{e.cause&.message}"]
            @output_queue << [:done]
            break
          rescue => e
            # Any other error
            @output_queue << [:error, "Bridge thread error: #{e.class}: #{e.message}"]
            @output_queue << [:done]
            break
          end
        end
      end
    end

    def start_polling
      poll = proc do
        next if @done

        begin
          while (msg = @output_queue.pop(true))
            type, value = msg
            case type
            when :done
              @done = true
              # Close the Ractor to unblock any threads inside
              @worker_ractor&.close_incoming
              @worker_ractor&.close_outgoing
              TkBackgroundRactor3x.unregister_ractor(@worker_ractor)
              @callbacks[:done]&.call
              break
            when :result
              @callbacks[:progress]&.call(value)
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

        Tk.after(DEFAULT_POLL_MS, &poll) unless @done
      end

      Tk.after(0, &poll)
    end

    # Task context for Ractor mode (runs inside Ractor)
    # Uses timeout-based polling for messages to avoid receiver thread.
    class TaskContext
      # Timeout for non-blocking message check (10ms)
      CHECK_TIMEOUT = 0.01

      def initialize(yield_queue)
        @yield_queue = yield_queue
        @paused = false
      end

      def yield(value)
        check_pause_loop
        @yield_queue << [:result, value]
      end

      # Non-blocking check for messages. Uses short timeout.
      def check_message
        msg = receive_with_timeout(CHECK_TIMEOUT)
        return nil unless msg
        handle_control_message(msg)
        msg
      end

      # Blocking wait for next message.
      def wait_message
        msg = Ractor.receive
        handle_control_message(msg)
        msg
      rescue Ractor::ClosedError
        nil
      end

      def send_message(msg)
        @yield_queue << [:message, msg]
      end

      def check_pause
        check_pause_loop
      end

      private

      # Receive with timeout - creates temporary thread, joins with timeout
      def receive_with_timeout(timeout)
        t = Thread.new { Ractor.receive }
        if t.join(timeout)
          t.value
        else
          t.kill
          nil
        end
      rescue Ractor::ClosedError
        nil
      end

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
          msg = wait_message
          break unless msg  # Closed
          handle_control_message(msg)
        end
      end
    end
  end
end
