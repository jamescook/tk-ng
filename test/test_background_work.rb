# frozen_string_literal: true

# Tests for TkCore.ractor_stream and Tk.background_work
#
# Note: Ractor mode requires Ruby 4.x+ (Ractor.shareable_proc).
# On Ruby 3.x, only thread mode is available.
# Ractor tests are skipped on Ruby 3.x.

require_relative 'test_helper'
require_relative 'tk_test_helper'

class TestBackgroundWork < Minitest::Test
  include TkTestHelper

  # Basic ractor_stream test - values should be yielded and received
  def test_ractor_stream_basic
    assert_tk_app("ractor_stream should yield values to callback", method(:app_ractor_stream_basic))
  end

  def app_ractor_stream_basic
    require 'tk'

    # Disable choking prevention for deterministic test
    Tk.background_work_drop_intermediate = false

    results = []
    done = false

    TkCore.ractor_stream([1, 2, 3]) do |yielder, data|
      data.each { |n| yielder.yield(n * 10) }
    end.on_progress do |result|
      results << result
    end.on_done do
      done = true
    end

    # Pump event loop until done or timeout
    start = Time.now
    while !done && (Time.now - start) < 5
      Tk.update
      sleep 0.01
    end

    Tk.background_work_drop_intermediate = true  # Reset for other tests

    raise "Stream did not complete (done=#{done})" unless done
    raise "Expected [10, 20, 30], got #{results.inspect}" unless results == [10, 20, 30]
  end

  # Test that many values can be streamed
  def test_ractor_stream_many_values
    assert_tk_app("ractor_stream should handle many values", method(:app_ractor_stream_many_values))
  end

  def app_ractor_stream_many_values
    require 'tk'

    # Disable choking prevention for deterministic test
    Tk.background_work_drop_intermediate = false

    count = 0
    done = false

    TkCore.ractor_stream(100) do |yielder, n|
      n.times { |i| yielder.yield(i) }
    end.on_progress do |_|
      count += 1
    end.on_done do
      done = true
    end

    start = Time.now
    while !done && (Time.now - start) < 10
      Tk.update
      sleep 0.01
    end

    Tk.background_work_drop_intermediate = true  # Reset for other tests

    raise "Stream did not complete" unless done
    raise "Expected 100 values, got #{count}" unless count == 100
  end

  # Thread mode basic test
  def test_background_work_thread_basic
    assert_tk_app("background_work :thread mode should work", method(:app_background_work_thread_basic))
  end

  def app_background_work_thread_basic
    require 'tk'

    Tk.background_work_mode = :thread
    Tk.background_work_drop_intermediate = false

    results = []
    done = false

    Tk.background_work([1, 2, 3]) do |t, data|
      data.each { |n| t.yield(n * 10) }
    end.on_progress do |result|
      results << result
    end.on_done do
      done = true
    end

    start = Time.now
    while !done && (Time.now - start) < 5
      Tk.update
      sleep 0.01
    end

    Tk.background_work_drop_intermediate = true  # Reset for other tests

    raise "Thread task did not complete" unless done
    raise "Expected [10, 20, 30], got #{results.inspect}" unless results == [10, 20, 30]
  end

  # Thread mode pause/resume test
  def test_background_work_thread_pause
    assert_tk_app("background_work :thread pause should work", method(:app_background_work_thread_pause))
  end

  def app_background_work_thread_pause
    require 'tk'

    Tk.background_work_mode = :thread

    counter = 0
    done = false

    task = Tk.background_work(50) do |t, count|
      count.times do |i|
        t.check_pause
        t.yield(i)
        sleep 0.02  # Slow down so pause can take effect
      end
    end.on_progress do |i|
      counter = i
    end.on_done do
      done = true
    end

    # Let it run a bit
    start = Time.now
    while counter < 10 && (Time.now - start) < 2
      Tk.update
      sleep 0.01
    end

    # Pause
    task.pause
    paused_at = counter

    # Wait and pump events - counter should stop
    sleep 0.2
    10.times { Tk.update; sleep 0.02 }
    after_pause = counter

    # Should not have advanced much (maybe 1-2 in flight)
    advance = after_pause - paused_at
    raise "Counter advanced too much while paused: #{advance}" if advance > 3

    # Resume
    task.resume

    # Wait for completion
    start = Time.now
    while !done && (Time.now - start) < 5
      Tk.update
      sleep 0.01
    end

    raise "Task did not complete after resume" unless done
    raise "Counter should reach 49, got #{counter}" unless counter == 49
  end

  # Ractor mode basic test (Ruby 4.x+ only)
  def test_background_work_ractor_basic
    skip "Ractor mode requires Ruby 4.x+" unless Ractor.respond_to?(:shareable_proc)
    assert_tk_app("background_work :ractor mode should work", method(:app_background_work_ractor_basic), pipe_capture: true)
  end

  def app_background_work_ractor_basic
    require 'tk'

    Tk.background_work_mode = :ractor
    Tk.background_work_drop_intermediate = false

    results = []
    done = false

    # Ruby 4.x supports blocks via shareable_proc
    Tk.background_work([1, 2, 3]) do |t, data|
      data.each { |n| t.yield(n * 10) }
    end.on_progress do |result|
      results << result
    end.on_done do
      done = true
    end

    start = Time.now
    while !done && (Time.now - start) < 5
      Tk.update
      sleep 0.01
    end

    Tk.background_work_drop_intermediate = true  # Reset for other tests

    raise "Ractor task did not complete" unless done
    raise "Expected [10, 20, 30], got #{results.inspect}" unless results == [10, 20, 30]
  end

  # Test that final progress value (100%) is received before done callback
  def test_background_work_thread_final_progress
    assert_tk_app("background_work :thread should receive final progress", method(:app_background_work_thread_final_progress))
  end

  def app_background_work_thread_final_progress
    require 'tk'

    Tk.background_work_mode = :thread

    progress_values = []
    final_progress_before_done = nil
    done = false

    Tk.background_work({ total: 5 }) do |t, data|
      data[:total].times do |i|
        t.yield((i + 1).to_f / data[:total])
      end
    end.on_progress do |progress|
      progress_values << progress
    end.on_done do
      final_progress_before_done = progress_values.last
      done = true
    end

    start = Time.now
    while !done && (Time.now - start) < 5
      Tk.update
      sleep 0.01
    end

    raise "Task did not complete" unless done
    raise "Expected final progress 1.0 before done, got #{final_progress_before_done.inspect}" unless final_progress_before_done == 1.0
    raise "Should have received progress value 1.0, got #{progress_values.inspect}" unless progress_values.include?(1.0)
  end

  # Test that final progress value (100%) is received before done callback in ractor mode (Ruby 4.x+ only)
  def test_background_work_ractor_final_progress
    skip "Ractor mode requires Ruby 4.x+" unless Ractor.respond_to?(:shareable_proc)
    assert_tk_app("background_work :ractor should receive final progress", method(:app_background_work_ractor_final_progress), pipe_capture: true)
  end

  def app_background_work_ractor_final_progress
    require 'tk'

    Tk.background_work_mode = :ractor

    progress_values = []
    final_progress_before_done = nil
    done = false

    # Ruby 4.x supports blocks via shareable_proc
    Tk.background_work({ total: 5 }) do |t, data|
      data[:total].times do |i|
        t.yield((i + 1).to_f / data[:total])
      end
    end.on_progress do |progress|
      progress_values << progress
    end.on_done do
      final_progress_before_done = progress_values.last
      done = true
    end

    start = Time.now
    while !done && (Time.now - start) < 5
      Tk.update
      sleep 0.01
    end

    raise "Task did not complete" unless done
    raise "Expected final progress 1.0 before done, got #{final_progress_before_done.inspect}" unless final_progress_before_done == 1.0
    raise "Should have received progress value 1.0, got #{progress_values.inspect}" unless progress_values.include?(1.0)
  end

  # Test that errors in ractor work block are caught and reported
  def test_ractor_stream_error_handling
    assert_tk_app("ractor_stream should handle errors in work block", method(:app_ractor_stream_error))
  end

  def app_ractor_stream_error
    require 'tk'

    done = false
    warning_output = nil

    # Capture warnings
    original_warn = $stderr
    captured = StringIO.new
    $stderr = captured

    TkCore.ractor_stream(:unused) do |yielder, _data|
      raise "Intentional test error"
    end.on_done do
      done = true
    end

    # Pump event loop until done or timeout
    start = Time.now
    while !done && (Time.now - start) < 5
      Tk.update
      sleep 0.01
    end

    $stderr = original_warn
    warning_output = captured.string

    # Should still complete (on_done called)
    raise "Task should complete even with error" unless done

    # Should have warning about the error
    raise "Expected warning about error, got: #{warning_output.inspect}" unless warning_output.include?("Intentional test error")
  end
end
