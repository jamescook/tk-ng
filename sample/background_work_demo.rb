#!/usr/bin/env ruby
# frozen_string_literal: true

# Background Work Demo - Shows UI remains responsive during background processing
#
# This demo processes items with CPU-bound work (hash computation) while
# showing a progress indicator. The key point: you can click Pause/Resume
# and interact with the UI while work happens.
#
# Compare modes:
#
#   none:   Work runs on main thread. UI FREEZES during computation.
#           Use this to see what happens WITHOUT background processing.
#
#   thread: Work runs in a background Thread. UI stays responsive but
#           shares GVL with the worker. May see brief pauses during GC
#           or if the worker doesn't yield frequently enough. Good for
#           I/O-bound work or when Ractor isn't available.
#
#   ractor: Work runs in a background Ractor. True parallelism - no GVL
#           contention means smoothest UI. Requires Ractor-safe code
#           (no shared mutable state). Best for CPU-bound work.
#           ** Ruby 4.x+ only ** - on Ruby 3.x, use thread mode instead.
#
# Usage:
#   ruby sample/background_work_demo.rb

require 'tk'
require 'tk/background_none'
require 'digest'

# Register :none mode for demo (runs synchronously, shows UI freezing)
Tk.register_background_mode(:none, TkBackgroundNone::BackgroundWork)

# Check if Ractor mode is available (Ruby 4.x+ only)
RACTOR_AVAILABLE = TkRactorSupport::RACTOR_SUPPORTED

class BackgroundWorkDemo
  # Ractor mode only available on Ruby 4.x+
  MODE_OPTIONS = if RACTOR_AVAILABLE
    %w[none none+update thread ractor].freeze
  else
    %w[none none+update thread].freeze
  end

  # Process this many items
  TOTAL_ITEMS = 200

  # Hash iterations per item - tune this to ~16ms of CPU work per item
  # This is actual CPU-bound work, not sleep - will block UI in "none" mode
  HASH_ITERATIONS_PER_ITEM = 50

  # Generate a ~5MB fixture to hash (simulates file data)
  # Loaded once into memory, hashed repeatedly per item
  FIXTURE_DATA = Random.bytes(5 * 1024 * 1024).freeze

  def initialize
    @root = TkRoot.new { title 'Background Work Demo - Responsive UI' }
    @root.geometry('700x550')
    @running = false
    @paused = false
    @progress = 0.0
    @background_task = nil
    @items_processed = 0

    setup_ui
    reset_state
  end

  def setup_ui
    # Control frame
    control_frame = Tk::Tile::Frame.new(@root) { padding '10' }
    control_frame.pack(fill: 'x')

    # Mode selection
    Tk::Tile::Label.new(control_frame) { text 'Mode:' }.pack(side: 'left', padx: 5)
    @mode_var = TkVariable.new('thread')
    @mode_combo = Tk::Tile::Combobox.new(control_frame,
      textvariable: @mode_var,
      values: MODE_OPTIONS,
      state: 'readonly',
      width: 10
    )
    @mode_combo.pack(side: 'left', padx: 5)
    @mode_combo.current = 2  # Default to thread

    # Buttons
    @start_btn = Tk::Tile::Button.new(control_frame, text: 'Start') { }
    @start_btn.pack(side: 'left', padx: 5)
    @start_btn.command { start_work }

    @pause_btn = Tk::Tile::Button.new(control_frame, text: 'Pause', state: 'disabled') { }
    @pause_btn.pack(side: 'left', padx: 5)
    @pause_btn.command { toggle_pause }

    @reset_btn = Tk::Tile::Button.new(control_frame, text: 'Reset') { }
    @reset_btn.pack(side: 'left', padx: 5)
    @reset_btn.command { reset_state }

    # Responsive test button
    @test_btn = Tk::Tile::Button.new(control_frame, text: 'Click Me!') { }
    @test_btn.pack(side: 'left', padx: 15)
    @click_count = 0
    @test_btn.command { @click_count += 1; @test_btn.text = "Clicked #{@click_count}x" }

    # Status label
    @status_var = TkVariable.new('Ready')
    Tk::Tile::Label.new(control_frame, textvariable: @status_var).pack(side: 'right', padx: 10)

    # Canvas for progress visualization
    canvas_frame = Tk::Tile::Frame.new(@root) { padding '10' }
    canvas_frame.pack(fill: 'both', expand: true)

    @canvas = TkCanvas.new(canvas_frame,
      width: 300,
      height: 300,
      background: 'white',
      highlightthickness: 1,
      highlightbackground: 'gray'
    )
    @canvas.pack(fill: 'both', expand: true)

    # Allow drawing on canvas to show UI responsiveness
    # In thread/ractor mode: smooth lines. In none+update: jittery lines.
    @last_x = nil
    @last_y = nil
    @canvas.bind('ButtonPress-1') { |e| @last_x = e.x; @last_y = e.y }
    @canvas.bind('B1-Motion') { |e| draw_stroke(e.x, e.y) }
    @canvas.bind('ButtonRelease-1') { @last_x = nil; @last_y = nil }

    # Info frame
    info_frame = Tk::Tile::Frame.new(@root) { padding '5' }
    info_frame.pack(fill: 'x')

    info_text = <<~INFO
      Background processing modes:

      none:        UI FREEZES completely until work finishes. No progress visible.
      none+update: UI jittery - progress visible via Tk.update, but drawing is choppy.
      thread:      UI responsive - background Thread shares GVL. Drawing is smooth.
      #{RACTOR_AVAILABLE ? 'ractor:      UI smooth - background Ractor has true parallelism. No GVL contention.' : '(ractor mode available on Ruby 4.x+ for true parallelism)'}

      Draw on the canvas during processing to see the difference!
    INFO
    Tk::Tile::Label.new(info_frame, text: info_text, justify: 'left', font: 'TkFixedFont').pack(anchor: 'w')

    # Status bar at bottom
    statusbar = Tk::Tile::Frame.new(@root)
    statusbar.pack(side: 'bottom', fill: 'x', padx: 5, pady: 5)

    # Metrics (left side)
    metrics_frame = Tk::Tile::Frame.new(statusbar)
    metrics_frame.pack(side: 'left', fill: 'x', expand: true)

    @metrics_var = TkVariable.new('')
    Tk::Tile::Label.new(metrics_frame, textvariable: @metrics_var, font: 'TkFixedFont').pack(side: 'left', padx: 5)

    # Ruby version (right side)
    Tk::Tile::Label.new(statusbar, text: "Ruby #{RUBY_VERSION}").pack(side: 'right', padx: 10)

    # Handle window close
    @root.protocol('WM_DELETE_WINDOW') { on_close }
  end

  def reset_state
    stop_work
    @progress = 0.0
    @items_processed = 0
    @paused = false
    @click_count = 0
    @canvas.delete('stroke')  # Clear any drawn strokes
    draw_progress
    @status_var.value = 'Ready'
    @metrics_var.value = ''
    @start_btn.state = 'normal'
    @pause_btn.state = 'disabled'
    @pause_btn.text = 'Pause'
    @test_btn.text = 'Click Me!'
    @mode_combo.state = 'readonly'
  end

  def start_work
    return if @running

    @running = true
    @paused = false
    @progress = 0.0
    @items_processed = 0
    @canvas.delete('stroke')  # Clear strokes for fresh comparison
    draw_progress  # Reset visual before starting

    # Initialize metrics
    @metrics = {
      start_time: Process.clock_gettime(Process::CLOCK_MONOTONIC),
      progress_updates: 0,
      strokes: 0,
      stroke_intervals: [],  # Time between consecutive strokes (ms)
      last_stroke_time: nil
    }
    @metrics_var.value = ''

    # Disable controls during work
    @start_btn.state = 'disabled'
    @pause_btn.state = 'normal'
    @mode_combo.state = 'disabled'

    mode = @mode_var.value.to_sym
    @status_var.value = "Processing (#{mode})..."

    start_background_work(mode)
  end

  def start_background_work(mode)
    # Map UI mode to background_work_mode
    bg_mode = mode.to_s.start_with?('none') ? :none : mode
    Tk.background_work_mode = bg_mode

    work_data = {
      total: TOTAL_ITEMS,
      hash_iters: HASH_ITERATIONS_PER_ITEM,
      fixture: FIXTURE_DATA  # Frozen string is Ractor-shareable
    }

    # All modes use block syntax (Ruby 4.x ractor supports blocks via shareable_proc)
    @background_task = Tk.background_work(work_data, name: "hash-worker") do |task, data|
      total = data[:total]
      hash_iters = data[:hash_iters]
      fixture = data[:fixture]

      total.times do |i|
        # Check for pause/stop messages
        if (msg = task.check_message)
          case msg
          when :pause
            task.check_pause  # Block until :resume
          when :stop
            break
          end
        end

        # CPU-bound work: hash fixture data multiple times
        hash_iters.times { Digest::SHA256.digest(fixture) }

        # Yield progress - one yield per item processed
        task.yield((i + 1).to_f / total)
      end
    end

    @background_task.on_progress do |progress|
      @progress = progress
      @items_processed = (progress * TOTAL_ITEMS).round
      draw_progress

      # In none+update mode, force UI update so progress is visible
      Tk.update if mode == :'none+update'

      # Track progress and show stroke timing (lower avg = smoother drawing)
      @metrics[:progress_updates] += 1
      intervals = @metrics[:stroke_intervals]
      if intervals.any?
        avg_ms = intervals.sum / intervals.size
        max_ms = intervals.max
        @metrics_var.value = "Progress: #{@metrics[:progress_updates]}/#{TOTAL_ITEMS} | Strokes: #{@metrics[:strokes]} | Avg: #{'%.0f' % avg_ms}ms Max: #{'%.0f' % max_ms}ms"
      else
        @metrics_var.value = "Progress: #{@metrics[:progress_updates]}/#{TOTAL_ITEMS} | Strokes: #{@metrics[:strokes]}"
      end
    end.on_done do
      work_complete
    end
  end

  def toggle_pause
    if @paused
      @paused = false
      @pause_btn.text = 'Pause'
      @status_var.value = "Processing (#{@mode_var.value})..."
      @background_task&.resume
    else
      @paused = true
      @pause_btn.text = 'Resume'
      @status_var.value = 'Paused'
      @background_task&.pause
    end
  end

  def stop_work
    @running = false
    @paused = false
    @background_task&.stop
    @background_task = nil
  end

  def work_complete
    @running = false
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @metrics[:start_time]
    @status_var.value = "Complete! (#{'%.1f' % elapsed}s)"

    # Show final metrics - stroke timing shows UI responsiveness (lower = smoother)
    intervals = @metrics[:stroke_intervals]
    if intervals.any?
      avg_ms = intervals.sum / intervals.size
      max_ms = intervals.max
      @metrics_var.value = "Time: #{'%.1f' % elapsed}s | Strokes: #{@metrics[:strokes]} | Avg: #{'%.0f' % avg_ms}ms Max: #{'%.0f' % max_ms}ms"
    else
      @metrics_var.value = "Time: #{'%.1f' % elapsed}s | Strokes: #{@metrics[:strokes]}"
    end

    @start_btn.state = 'normal'
    @pause_btn.state = 'disabled'
    @mode_combo.state = 'readonly'
  end

  def draw_stroke(x, y)
    return unless @last_x && @last_y
    TkcLine.new(@canvas, @last_x, @last_y, x, y,
      fill: 'red',
      width: 3,
      capstyle: 'round',
      tags: 'stroke'
    )
    @last_x = x
    @last_y = y

    # Measure stroke timing to show UI responsiveness difference between modes
    if @running && @metrics
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      if @metrics[:last_stroke_time]
        interval_ms = (now - @metrics[:last_stroke_time]) * 1000
        @metrics[:stroke_intervals] << interval_ms
      end
      @metrics[:last_stroke_time] = now
      @metrics[:strokes] += 1
    end
  end

  def draw_progress
    @canvas.delete('progress')  # Keep strokes, only redraw progress

    # Canvas dimensions
    width = @canvas.winfo_width
    height = @canvas.winfo_height
    width = 300 if width < 10
    height = 300 if height < 10

    # Circle parameters
    margin = 20
    cx = width / 2
    cy = height / 2
    radius = [width, height].min / 2 - margin

    # Draw background circle (outline)
    TkcOval.new(@canvas,
      cx - radius, cy - radius,
      cx + radius, cy + radius,
      outline: 'lightgray',
      width: 2,
      tags: 'progress'
    )

    # Draw filled arc (progress) - clockwise from 12 o'clock
    # Note: 360-degree arc renders as nothing in Tk, so use filled oval at 100%
    if @progress >= 1.0
      TkcOval.new(@canvas,
        cx - radius, cy - radius,
        cx + radius, cy + radius,
        fill: '#4a90d9',
        outline: '#2d5a87',
        width: 2,
        tags: 'progress'
      )
    elsif @progress > 0
      extent = -(@progress * 360)
      TkcArc.new(@canvas,
        cx - radius, cy - radius,
        cx + radius, cy + radius,
        start: 90,
        extent: extent,
        style: 'pieslice',
        fill: '#4a90d9',
        outline: '#2d5a87',
        width: 2,
        tags: 'progress'
      )
    end

    # Draw progress text
    percent = (@progress * 100).round
    TkcText.new(@canvas, cx, cy - 15,
      text: "#{percent}%",
      font: 'Helvetica 28 bold',
      fill: 'black',
      tags: 'progress'
    )

    # Draw items count
    TkcText.new(@canvas, cx, cy + 20,
      text: "#{@items_processed}/#{TOTAL_ITEMS} items",
      font: 'Helvetica 14',
      fill: '#333',
      tags: 'progress'
    )
  end

  def on_close
    stop_work
    @root.destroy
  end

  def run
    Tk.mainloop
  end
end

# Run the demo
BackgroundWorkDemo.new.run
