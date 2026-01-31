#!/usr/bin/env ruby
# frozen_string_literal: true
# tk-record: title=Concurrency Demo - File Hasher
#
# Concurrency Demo - File Hasher
#
# Compares concurrency modes:
# - None: Direct execution, UI updates via Tk.update. Fast but blocks controls.
# - Thread: Background thread with on_main_thread. Enables Pause but has GVL overhead.
# - Ractor: True parallelism (separate GVL). Best throughput. (Ruby 4.x+ only)
#
require 'tk'
require 'tk/background_none'
require 'digest'
require 'tmpdir'
require_relative 'tkballoonhelp'

# Register :none mode for demo (runs synchronously, shows UI freezing)
Tk.register_background_mode(:none, TkBackgroundNone::BackgroundWork)

# Check if Ractor mode is available (Ruby 4.x+ only)
RACTOR_AVAILABLE = TkRactorSupport::RACTOR_SUPPORTED

class ThreadingDemo
  ALGORITHMS = %w[SHA256 SHA512 SHA384 SHA1 MD5].freeze

  # Ractor mode only available on Ruby 4.x+
  MODES = if RACTOR_AVAILABLE
    ['None', 'None+update', 'Thread', 'Ractor'].freeze
  else
    ['None', 'None+update', 'Thread'].freeze
  end

  def initialize
    @root = Tk.root
    @root.title('Concurrency Demo - File Hasher')
    @root.minsize(600, 400)
    @chunk_size = TkVariable.new(3)
    @algorithm = TkVariable.new('SHA256')
    @mode = TkVariable.new('Thread')
    @allow_pause = TkVariable.new(0)  # Checkbox: 0=off, 1=on
    @running = false
    @paused = false
    @stop_requested = false
    @background_task = nil  # Tk.background_work task

    build_ui
    collect_files

    Tk.update
    # Position at 0,0 for recording, preserve calculated size
    @root.geometry("#{@root.winfo_width}x#{@root.winfo_height}+0+0")
    @root.resizable(true, true)

    # Clean up background task on window close
    @root.protocol('WM_DELETE_WINDOW') do
      @background_task&.close
      @root.destroy
    end

    # Report calculated size for recording setup
    puts "Window size: #{@root.winfo_width}x#{@root.winfo_height}"
  end

  def build_ui
    ractor_note = RACTOR_AVAILABLE ? "Ractor: true parallel." : "(Ractor available on Ruby 4.x+)"
    TkLabel.new(@root,
      text: "File hasher demo - compares concurrency modes.\n" \
            "None: UI frozen. None+update: progress visible, pause works. " \
            "Thread: responsive, GVL shared. #{ractor_note}",
      justify: :left
    ).pack(fill: :x, padx: 10, pady: 10)

    ctrl_frame = TkFrame.new(@root).pack(fill: :x, padx: 10, pady: 5)

    @start_btn = TkButton.new(ctrl_frame, text: 'Start', command: proc { start_hashing })
    @start_btn.pack(side: :left)

    @pause_btn = TkButton.new(ctrl_frame, text: 'Pause', state: :disabled, command: proc { toggle_pause })
    @pause_btn.pack(side: :left, padx: 5)

    @reset_btn = TkButton.new(ctrl_frame, text: 'Reset', command: proc { reset })
    @reset_btn.pack(side: :left)

    TkLabel.new(ctrl_frame, text: 'Algorithm:').pack(side: :left, padx: 10)
    @algo_combo = Tk::Tile::Combobox.new(ctrl_frame,
      textvariable: @algorithm,
      values: ALGORITHMS,
      width: 8,
      state: :readonly
    )
    @algo_combo.pack(side: :left)

    TkLabel.new(ctrl_frame, text: 'Batch:').pack(side: :left, padx: 10)
    @batch_label = TkLabel.new(ctrl_frame, text: '3', width: 3)
    @batch_label.pack(side: :left)

    Tk::Tile::Scale.new(ctrl_frame,
      orient: :horizontal,
      from: 1,
      to: 100,
      length: 100,
      variable: @chunk_size,
      command: proc { |v| @batch_label.text = v.to_f.round.to_s }
    ).pack(side: :left, padx: 5)

    TkLabel.new(ctrl_frame, text: 'Mode:').pack(side: :left, padx: 10)
    @mode_combo = Tk::Tile::Combobox.new(ctrl_frame,
      textvariable: @mode,
      values: MODES,
      width: 7,
      state: :readonly
    )
    @mode_combo.pack(side: :left)

    @pause_check = Tk::Tile::Checkbutton.new(ctrl_frame,
      text: 'Allow Pause',
      variable: @allow_pause
    )
    @pause_check.pack(side: :left, padx: 10)
    # Tooltip for pause checkbox (skip in recording mode - Ttk incompatible)
    unless ENV['TK_RECORD']
      Tk::RbWidget::BalloonHelp.new(@pause_check,
        text: "Enables pause for Ractor mode.\nAdds overhead on Ruby 3.x (~16ms/batch).\nRuby 4.0+ has no overhead.",
        interval: 500)
    end

    # Statusbar
    statusbar = TkFrame.new(@root)
    statusbar.pack(side: :bottom, fill: :x, padx: 5, pady: 5)

    # Progress section (left)
    progress_frame = TkFrame.new(statusbar, relief: :sunken, borderwidth: 2)
    progress_frame.pack(side: :left, fill: :x, expand: true, padx: 2)

    @progress_var = TkVariable.new(0)
    Tk::Tile::Progressbar.new(progress_frame,
      orient: :horizontal,
      length: 200,
      mode: :determinate,
      variable: @progress_var,
      maximum: 100
    ).pack(side: :left, padx: 5, pady: 4)

    @status_label = TkLabel.new(progress_frame, text: 'Ready', width: 20, anchor: :w)
    @status_label.pack(side: :left, padx: 10)

    @current_file_label = TkLabel.new(progress_frame, text: '', width: 28, anchor: :w)
    @current_file_label.pack(side: :left, padx: 5)

    # Info section (right)
    info_frame = TkFrame.new(statusbar, relief: :sunken, borderwidth: 2)
    info_frame.pack(side: :right, padx: 2)

    @file_count_label = TkLabel.new(info_frame, text: '', width: 12, anchor: :e)
    @file_count_label.pack(side: :left, padx: 8, pady: 4)

    Tk::Tile::Separator.new(info_frame, orient: :vertical).pack(side: :left, fill: :y, pady: 4)

    TkLabel.new(info_frame, text: "Ruby #{RUBY_VERSION}", anchor: :e).pack(side: :left, padx: 8, pady: 4)

    # Log
    log_outer = TkLabelFrame.new(@root, text: 'Output', relief: :groove)
    log_outer.pack(fill: :both, expand: true, padx: 10, pady: 5)

    log_frame = TkFrame.new(log_outer)
    log_frame.pack(fill: :both, expand: true, padx: 5, pady: 5)
    log_frame.pack_propagate(false)

    @log = TkText.new(log_frame, width: 80, height: 15, wrap: :none)
    @log.pack(side: :left, fill: :both, expand: true)

    scrollbar = TkScrollbar.new(log_frame)
    scrollbar.pack(side: :right, fill: :y)
    @log.yscrollbar(scrollbar)
  end

  def collect_files
    base = File.exist?('/app') ? '/app' : Dir.pwd
    @files = Dir.glob("#{base}/**/*", File::FNM_DOTMATCH).select { |f| File.file?(f) }
    @files.reject! { |f| f.include?('/.git/') }
    @files.sort!

    # Limit files via --max-files=N, DEMO_MAX_FILES env var, or auto-limit in demo mode
    max_files = ARGV.find { |a| a.start_with?('--max-files=') }&.split('=')&.last&.to_i
    max_files ||= ENV['DEMO_MAX_FILES']&.to_i
    max_files ||= 50 if ENV['TK_RECORD'] || ENV['TK_READY_PORT']  # Demo/test mode
    @files = @files.first(max_files) if max_files && max_files > 0

    @file_count_label.text = "#{@files.size} files"
  end

  def current_mode
    @mode.to_s
  end

  def start_hashing
    @running = true
    @paused = false
    @stop_requested = false
    @start_btn.state = :disabled
    @algo_combo.state = :disabled
    @mode_combo.state = :disabled
    @log.delete('1.0', :end)
    @progress_var.value = 0
    @status_label.text = "Hashing..."

    # Pause available in Thread mode always, Ractor mode only if Allow Pause checked
    # None+update mode can pause (via Tk.update in check_pause)
    @pause_btn.state = case current_mode
      when 'None' then :disabled
      when 'None+update' then :normal
      when 'Thread' then :normal
      when 'Ractor' then @allow_pause.to_i == 1 ? :normal : :disabled
    end

    # Disable resize during hashing (resize events block main thread)
    @root.resizable(false, false) unless current_mode == 'Ractor'

    @metrics = {
      start_time: Process.clock_gettime(Process::CLOCK_MONOTONIC),
      ui_update_count: 0,
      ui_update_total_ms: 0.0,
      total: @files.size,
      files_done: 0,
      mode: current_mode
    }

    # Map UI mode to background_work mode
    mode_sym = case current_mode
      when 'None', 'None+update' then :none
      else current_mode.downcase.to_sym
    end
    start_background_work(mode_sym)
  end

  def toggle_pause
    @paused = !@paused
    @pause_btn.text = @paused ? 'Resume' : 'Pause'
    @status_label.text = @paused ? 'Paused' : 'Hashing...'
    @root.resizable(@paused, @paused)
    @mode_combo.state = @paused ? :readonly : :disabled

    # Send pause/resume message to background task
    if @background_task
      @paused ? @background_task.pause : @background_task.resume
    end

    write_metrics("PAUSED") if @paused && @metrics
  end

  def reset
    @stop_requested = true
    @paused = false
    @running = false

    # Stop background task if running
    @background_task&.stop
    @background_task = nil

    @start_btn.state = :normal
    @pause_btn.state = :disabled
    @pause_btn.text = 'Pause'
    @algo_combo.state = :readonly
    @mode_combo.state = :readonly
    @root.resizable(true, true)
    @log.delete('1.0', :end)
    @progress_var.value = 0
    @status_label.text = 'Ready'
    @current_file_label.text = ''

    # Reset all inputs to initial values
    @mode.value = 'Thread'
    @algorithm.value = 'SHA256'
    @chunk_size.value = 3
    @batch_label.text = '3'
    @allow_pause.value = 0
  end

  def write_metrics(status = "DONE")
    return unless @metrics
    m = @metrics
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - m[:start_time]
    # Use tmpdir if sample dir isn't writable (e.g., Docker read-only mount)
    dir = File.writable?(__dir__) ? __dir__ : Dir.tmpdir
    File.open(File.join(dir, 'threading_demo_metrics.log'), 'a') do |f|
      f.puts "=" * 60
      f.puts "Status: #{status} at #{Time.now}"
      f.puts "Mode: #{m[:mode]}"
      f.puts "Algorithm: #{@algorithm}"
      f.puts "Files processed: #{m[:files_done]}/#{m[:total]}"
      f.puts "Batch size: #{[@chunk_size.to_f.round, 1].max}"
      f.puts "-" * 40
      f.puts "Elapsed: #{elapsed.round(3)}s"
      f.puts "UI updates: #{m[:ui_update_count]}"
      f.puts "UI update total: #{m[:ui_update_total_ms].round(1)}ms" if m[:ui_update_total_ms]
      f.puts "UI update avg: #{(m[:ui_update_total_ms] / m[:ui_update_count]).round(2)}ms" if m[:ui_update_count] > 0 && m[:ui_update_total_ms]
      f.puts "Files/sec: #{(m[:files_done] / elapsed).round(1)}" if elapsed > 0
      f.puts
    end
  end

  def truncate_filename(name, max = 25)
    name.length > max ? "#{name[0, max]}..." : name
  end

  def finish_hashing
    write_metrics("DONE") unless @stop_requested
    return if @stop_requested

    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @metrics[:start_time]
    files_per_sec = (@metrics[:files_done] / elapsed).round(1)
    @status_label.text = "Done #{elapsed.round(2)}s (#{files_per_sec}/s)"
    @current_file_label.text = ''
    @start_btn.state = :normal
    @pause_btn.state = :disabled
    @algo_combo.state = :readonly
    @mode_combo.state = :readonly
    @root.resizable(true, true)
    @running = false
  end

  # ─────────────────────────────────────────────────────────────
  # All modes use unified Tk.background_work API
  # ─────────────────────────────────────────────────────────────

  def start_background_work(mode)
    ui_mode = current_mode  # Capture for closure (before work starts)

    # Prepare shareable data for the worker
    files = @files.dup
    algo_name = @algorithm.to_s
    chunk_size = [@chunk_size.to_f.round, 1].max
    base_dir = Dir.pwd
    allow_pause = @allow_pause.to_i == 1

    work_data = {
      files: files,
      algo_name: algo_name,
      chunk_size: chunk_size,
      base_dir: base_dir,
      allow_pause: allow_pause
    }

    # For Ractor mode, data must be shareable
    if mode == :ractor
      work_data = Ractor.make_shareable({
        files: Ractor.make_shareable(files.freeze),
        algo_name: algo_name.freeze,
        chunk_size: chunk_size,
        base_dir: base_dir.freeze,
        allow_pause: allow_pause
      })
    end

    # All modes use block syntax (Ruby 4.x ractor supports blocks via shareable_proc)
    @background_task = Tk.background_work(work_data, mode: mode, name: "file-hasher") do |task, data|
      algo_class = Digest.const_get(data[:algo_name])
      total = data[:files].size
      pending = []

      data[:files].each_with_index do |path, index|
        if data[:allow_pause] && pending.empty?
          task.check_pause
        end

        begin
          hash = algo_class.file(path).hexdigest
          short_path = path.sub(%r{^/app/}, '').sub(data[:base_dir] + '/', '')
          pending << "#{short_path}: #{hash}\n"
        rescue StandardError => e
          short_path = path.sub(%r{^/app/}, '').sub(data[:base_dir] + '/', '')
          pending << "#{short_path}: ERROR - #{e.message}\n"
        end

        is_last = index == total - 1
        if pending.size >= data[:chunk_size] || is_last
          task.yield({
            index: index,
            total: total,
            updates: pending.join
          })
          pending = []
        end
      end
    end

    @background_task.on_progress do |msg|
      ui_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      @log.insert(:end, msg[:updates])
      @log.see(:end)
      @progress_var.value = ((msg[:index] + 1).to_f / msg[:total] * 100).round
      @status_label.text = "Hashing... #{msg[:index] + 1}/#{msg[:total]}"

      @metrics[:ui_update_count] += 1
      @metrics[:ui_update_total_ms] ||= 0.0
      @metrics[:ui_update_total_ms] += (Process.clock_gettime(Process::CLOCK_MONOTONIC) - ui_start) * 1000
      @metrics[:files_done] = msg[:index] + 1

      # In None+update mode, force UI update so progress is visible
      Tk.update if ui_mode == 'None+update'
    end.on_done do
      @background_task = nil
      finish_hashing
    end
  end

  def run
    Tk.mainloop
  end
end

# Automated demo support (testing and recording)
require 'tk/demo_support'

if TkDemo.active?
  # Create demo first, then set up automation
  demo = ThreadingDemo.new

  TkDemo.after_idle {
    Tk.after(100) {
      # Quick mode: just run Thread mode once for smoke test
      quick_mode = ARGV.include?('--quick')

      puts "[DEMO] Threading demo starting (Ruby #{RUBY_VERSION}, Ractor: #{RACTOR_AVAILABLE})"
      if quick_mode
        puts "[DEMO] Quick smoke test (Thread mode only)"
      else
        puts "[DEMO] Testing all modes with batch=100"
      end

      # Get UI widgets
      chunk_var = demo.instance_variable_get(:@chunk_size)
      mode_combo = demo.instance_variable_get(:@mode_combo)
      start_btn = demo.instance_variable_get(:@start_btn)
      reset_btn = demo.instance_variable_get(:@reset_btn)
      allow_pause_var = demo.instance_variable_get(:@allow_pause)

      # Set batch size to 100
      chunk_var.value = 100

      # Test matrix: [mode, pause_enabled]
      # Skip 'None' mode - it freezes UI, not useful for demo
      # Skip Ractor on Ruby < 4 - not fully supported
      tests = if quick_mode
        [['Thread', false]]  # Just one quick test
      elsif RUBY_VERSION.to_f >= 4.0
        [
          ['Thread', false],
          ['Thread', true],
          ['Ractor', false],
          ['Ractor', true]
        ]
      else
        [
          ['Thread', false],
          ['Thread', true]
        ]
      end
      test_index = 0

      run_next_test = proc do
        if test_index < tests.size
          mode, pause = tests[test_index]
          puts "[DEMO] ====== Running mode: #{mode}#{pause ? ' +pause' : ''} (#{test_index + 1}/#{tests.size}) ======"

          # Configure mode and pause
          mode_combo.set(mode)
          allow_pause_var.value = pause ? 1 : 0

          # Start hashing
          Tk.after(100) { start_btn.invoke }

          # Wait for completion
          check_done = proc do
            if demo.instance_variable_get(:@running)
              Tk.after(200, &check_done)
            else
              puts "[DEMO] #{mode} complete"
              test_index += 1
              if test_index < tests.size
                Tk.after(200) {
                  reset_btn.invoke
                  Tk.after(200, &run_next_test)
                }
              else
                puts "[DEMO] All tests completed"
                Tk.after(200) { TkDemo.finish }
              end
            end
          end
          Tk.after(500, &check_done)
        end
      end

      run_next_test.call
    }
  }

  Tk.mainloop
else
  ThreadingDemo.new.run
end
