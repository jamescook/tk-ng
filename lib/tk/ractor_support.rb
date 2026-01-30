# frozen_string_literal: true

# Ractor and background work support for Tk applications.
#
# This module provides a unified API across Ruby versions:
# - Ruby 4.x: Uses Ractor::Port, Ractor.shareable_proc for true parallelism
# - Ruby 3.x: Ractor mode NOT supported (falls back to thread mode)
# - Thread fallback: Always available, works everywhere
#
# The implementation is selected automatically based on Ruby version.

require_relative 'background_thread'

# Feature detection
RUBY_4_OR_LATER = RUBY_VERSION.split('.').first.to_i >= 4
RACTOR_PORT_API = defined?(Ractor::Port)
RACTOR_SHAREABLE_PROC = Ractor.respond_to?(:shareable_proc)

if RACTOR_SHAREABLE_PROC
  require_relative 'background_ractor4x'
end

module TkRactorSupport
  # Re-export feature flags
  RACTOR_PORT_API = ::RACTOR_PORT_API
  RACTOR_SHAREABLE_PROC = ::RACTOR_SHAREABLE_PROC

  # Ractor mode requires Ruby 4.x (shareable_proc support)
  RACTOR_SUPPORTED = RACTOR_SHAREABLE_PROC

  # Registry for background work modes.
  # Each mode maps to an implementation class that must respond to:
  #   .new(data, worker: nil, &block) - constructor
  #   #on_progress(&block) - register progress callback
  #   #on_done(&block) - register done callback
  #   #on_message(&block) - register message callback
  #   #send_message(msg) - send message to worker
  #   #pause, #resume, #stop, #close, #start - control methods
  #   #done? - completion status
  @background_modes = {}

  def self.register_background_mode(name, klass)
    @background_modes[name.to_sym] = klass
  end

  def self.background_modes
    @background_modes
  end

  def self.background_mode_class(name)
    @background_modes[name.to_sym]
  end

  # Register built-in modes
  register_background_mode :thread, TkBackgroundThread::BackgroundWork

  # Ractor mode only available on Ruby 4.x+
  if RACTOR_SUPPORTED
    register_background_mode :ractor, TkBackgroundRactor4x::BackgroundWork
  end

  # Unified BackgroundWork API
  #
  # Creates background work with the specified mode.
  # Mode :ractor uses true parallel execution (Ruby 4.x+ only).
  # Mode :thread uses traditional threading (GVL limited but always works).
  #
  # Example:
  #   task = TkRactorSupport::BackgroundWork.new(data, mode: :ractor) do |t, d|
  #     d.each { |item| t.yield(process(item)) }
  #   end.on_progress { |r| update_ui(r) }
  #
  class BackgroundWork
    attr_accessor :name

    def initialize(data, mode: :ractor, worker: nil, &block)
      impl_class = TkRactorSupport.background_mode_class(mode)
      unless impl_class
        available = TkRactorSupport.background_modes.keys.join(', ')
        raise ArgumentError, "Unknown mode: #{mode}. Available: #{available}"
      end

      @impl = impl_class.new(data, worker: worker, &block)
      @mode = mode
      @name = nil
    end

    def mode
      @mode
    end

    def done?
      @impl.done?
    end

    def paused?
      @impl.paused?
    end

    def on_progress(&block)
      @impl.on_progress(&block)
      self
    end

    def on_done(&block)
      @impl.on_done(&block)
      self
    end

    def on_message(&block)
      @impl.on_message(&block)
      self
    end

    def send_message(msg)
      @impl.send_message(msg)
      self
    end

    def pause
      @impl.pause
      self
    end

    def resume
      @impl.resume
      self
    end

    def stop
      @impl.stop
      self
    end

    def close
      @impl.close if @impl.respond_to?(:close)
      self
    end

    def start
      @impl.start
      self
    end
  end

  # Simple streaming API (no pause support, simpler interface)
  #
  # Example:
  #   TkRactorSupport::RactorStream.new(files) do |yielder, data|
  #     data.each { |f| yielder.yield(process(f)) }
  #   end.on_progress { |r| update_ui(r) }
  #     .on_done { puts "Done!" }
  #
  class RactorStream
    def initialize(data, &block)
      # Ruby 4.x: use Ractor with shareable_proc for true parallelism
      # Ruby 3.x: use threads (Ractor mode not supported)
      if RACTOR_SUPPORTED
        shareable_block = Ractor.shareable_proc(&block)
        wrapped_block = Ractor.shareable_proc do |task, d|
          yielder = StreamYielder.new(task)
          shareable_block.call(yielder, d)
        end
        @impl = TkBackgroundRactor4x::BackgroundWork.new(data, &wrapped_block)
      else
        wrapped_block = proc do |task, d|
          yielder = StreamYielder.new(task)
          block.call(yielder, d)
        end
        @impl = TkBackgroundThread::BackgroundWork.new(data, &wrapped_block)
      end
    end

    def on_progress(&block)
      @impl.on_progress(&block)
      self
    end

    def on_done(&block)
      @impl.on_done(&block)
      self
    end

    def cancel
      @impl.stop
    end

    # Adapter for old yielder API
    class StreamYielder
      def initialize(task)
        @task = task
      end

      def yield(value)
        @task.yield(value)
      end
    end
  end
end
