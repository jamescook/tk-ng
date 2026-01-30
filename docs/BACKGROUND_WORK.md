# Background Work in Tk

This guide covers solutions for running background tasks while keeping your Tk UI responsive.

## Do You Need This?

**Maybe not.** Many Tk apps work fine without background threads. You only need `background_work` if:

- The UI freezes noticeably during operations (buttons unresponsive, window won't move)
- You're doing CPU-intensive work (image processing, hashing large files, complex calculations)
- Operations take more than ~100ms and you want the UI to stay interactive

If your app feels responsive, don't add complexity. Start simple with direct execution, and only reach for `background_work` when you see actual UI freezing.

See [`sample/background_work_demo.rb`](../sample/background_work_demo.rb) to compare modes - "none" mode shows what freezing looks like, thread/ractor modes show the fix.

## Overview

Tk runs on a single main thread. Long-running operations block the UI, making it unresponsive. The `Tk.background_work` API lets you run work in a background Thread or Ractor while safely updating the UI.

## Quick Start

```ruby
require 'tk'

# Process items in background, update UI with progress
Tk.background_work({ files: file_list }) do |task, data|
  data[:files].each_with_index do |file, i|
    process_file(file)  # Your actual work
    task.yield((i + 1).to_f / data[:files].size)  # Report progress
  end
end.on_progress do |progress|
  update_progress_bar(progress)  # Runs on main thread, safe for UI
end.on_done do
  show_completion_message
end
```

## Modes

The default mode is selected automatically based on Ruby version:
- **Ruby 4.x+**: defaults to `:ractor` (stable Ractor API, true parallelism)
- **Ruby 3.x**: defaults to `:thread` (Ractor works but implementation is more complex)

### Thread Mode
```ruby
Tk.background_work_mode = :thread  # default on Ruby 3.x
```
- Works on all Ruby versions
- Limited by GVL (Global VM Lock) - no true parallelism for CPU work
- Good for I/O-bound tasks (file operations, network requests)
- UI stays responsive because Thread yields during I/O

### Ractor Mode
```ruby
Tk.background_work_mode = :ractor  # default on Ruby 4.x+
```
- Requires Ruby 3.1+ (full support in Ruby 4.0+)
- True parallelism - separate GVL, not blocked by main thread
- Data must be shareable (no proc closures in Ruby 3.x)
- Best for CPU-intensive tasks (image processing, calculations)

## Best Practices

### Yield at the Right Frequency

**Problem: UI Choking**

Background work uses a queue: the worker yields values, and the main thread polls the queue to update the UI. If the worker yields faster than the UI polls (default: 60 times/sec), the queue backs up.

To prevent the UI from freezing while processing a huge backlog, we drop intermediate values and only use the latest. This keeps the UI responsive but means some progress updates are lost. You'll see warnings when this happens:

```
[Tk::BackgroundWork] UI choking: worker yielding faster than UI can poll.
15 progress values dropped this cycle.
```

**Bad - yields too fast:**
```ruby
Tk.background_work(data) do |task, d|
  loop do
    task.yield(calculate_progress)
    sleep 0.001  # 1000 yields/sec - way too fast!
  end
end
```

**Good - yield after meaningful work:**
```ruby
Tk.background_work(data) do |task, d|
  d[:items].each_with_index do |item, i|
    process(item)  # This takes ~30ms
    task.yield((i + 1).to_f / d[:items].size)  # ~33 yields/sec
  end
end
```

**Rule of thumb:** Yield after each "unit of work", not in a tight loop. If your work units are very fast (<10ms each), batch them:

```ruby
# If each item takes only 1ms, batch progress updates
BATCH_SIZE = 50
d[:items].each_slice(BATCH_SIZE).with_index do |batch, batch_i|
  batch.each { |item| process(item) }
  task.yield((batch_i + 1) * BATCH_SIZE.to_f / d[:items].size)
end
```

### Handle Pause/Stop Messages

Always check for control messages in long-running loops:

```ruby
Tk.background_work(data) do |task, d|
  d[:items].each do |item|
    # Check at the start of each iteration
    if (msg = task.check_message)
      case msg
      when :pause
        task.check_pause  # Blocks until :resume
      when :stop
        break  # Exit cleanly
      end
    end

    process(item)
    task.yield(progress)
  end
end
```

### Keep Data Shareable (Ractor Mode)

In Ractor mode, the data hash must be Ractor-shareable:

```ruby
# Good - simple values are shareable
Tk.background_work({ count: 100, prefix: "item" }) do |task, d|
  # ...
end

# Bad - procs aren't shareable in Ruby 3.x
Tk.background_work({ callback: -> { puts "hi" } }) do |task, d|
  d[:callback].call  # Error!
end
```

### Don't Touch UI from Worker

The worker block runs in a background Thread/Ractor. Never call Tk methods from it:

```ruby
# WRONG - crashes or undefined behavior
Tk.background_work(data) do |task, d|
  @label.text = "Processing..."  # NO! This is in background thread
end

# RIGHT - update UI in callbacks (run on main thread)
Tk.background_work(data) do |task, d|
  task.yield(:started)
end.on_progress do |status|
  @label.text = "Processing..." if status == :started  # Safe
end
```

## Configuration

### Poll Interval

Controls how often `Tk.after` fires to check the queue for background work results:

```ruby
Tk.background_work_poll_ms = 16   # ~60 checks/sec (default)
Tk.background_work_poll_ms = 33   # ~30 checks/sec (less CPU)
Tk.background_work_poll_ms = 100  # ~10 checks/sec (minimal overhead)
```

Lower values = more frequent progress updates but slightly higher CPU usage. This only affects active background work tasks.

### Multiple Tasks

Multiple `Tk.background_work` calls can run concurrently. Each task has its own queue and polling timer - they don't block or interfere with each other.

### Error Handling

By default, worker errors are logged. To raise them instead:

```ruby
Tk.abort_on_ractor_error = true
```

## Common Patterns

### File Processing with Progress

```ruby
def process_files(files)
  @progress_bar.value = 0

  Tk.background_work({ files: files }) do |task, d|
    d[:files].each_with_index do |path, i|
      break if task.check_message == :stop

      File.read(path)  # Your file operation
      task.yield((i + 1).to_f / d[:files].size)
    end
  end.on_progress do |progress|
    @progress_bar.value = (progress * 100).round
  end.on_done do
    @progress_bar.value = 100
    show_message("Done!")
  end
end
```

### Cancellable Search

```ruby
def start_search(query)
  @current_search&.stop  # Cancel previous search

  @current_search = Tk.background_work({ query: query, items: @all_items }) do |task, d|
    results = []
    d[:items].each_with_index do |item, i|
      break if task.check_message == :stop

      results << item if item.match?(d[:query])
      task.yield(results.dup) if i % 100 == 0  # Batch updates
    end
    task.yield(results)  # Final results
  end.on_progress do |results|
    update_results_list(results)
  end
end
```

## Troubleshooting

### "UI choking" warnings

Your worker is yielding faster than the UI can process. Solutions:
1. Yield less frequently (after batches of work, not every iteration)
2. Increase `Tk.background_work_poll_ms` (but UI updates will be less frequent)

### Progress updates are delayed

The UI only sees progress when it polls. If work is CPU-intensive and doesn't yield often enough, progress appears jumpy. Solution: yield more frequently or accept batch-style updates.
