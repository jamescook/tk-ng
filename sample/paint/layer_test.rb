#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for layer system building blocks
# Run: ruby sample/paint/layer_test.rb

require 'tk'
require_relative 'layer_manager'

class LayerTest
  WIDTH = 400
  HEIGHT = 300

  def initialize
    @root = TkRoot.new { title 'Layer System Test' }
    @root.geometry("#{WIDTH}x#{HEIGHT + 100}")

    setup_canvas
    setup_controls
    setup_layer_manager

    # Draw some test content
    draw_test_content
  end

  def setup_canvas
    @canvas = TkCanvas.new(@root, background: 'gray', width: WIDTH, height: HEIGHT)
    @canvas.pack(fill: 'both', expand: true)

    @canvas.bind('ButtonPress-1') { |e| on_click(e.x, e.y) }
    @canvas.bind('B1-Motion') { |e| on_drag(e.x, e.y) }
  end

  def setup_controls
    frame = Tk::Tile::Frame.new(@root)
    frame.pack(side: 'bottom', fill: 'x', pady: 5)

    Tk::Tile::Button.new(frame, text: 'Add Layer', command: proc { add_layer }).pack(side: 'left', padx: 2)
    Tk::Tile::Button.new(frame, text: 'Toggle Visible', command: proc { toggle_visible }).pack(side: 'left', padx: 2)
    Tk::Tile::Button.new(frame, text: 'Move Up', command: proc { move_up }).pack(side: 'left', padx: 2)
    Tk::Tile::Button.new(frame, text: 'Move Down', command: proc { move_down }).pack(side: 'left', padx: 2)
    Tk::Tile::Button.new(frame, text: 'Clear Layer', command: proc { clear_layer }).pack(side: 'left', padx: 2)
    Tk::Tile::Button.new(frame, text: 'Memory', command: proc { show_memory }).pack(side: 'left', padx: 2)

    @status_var = TkVariable.new
    Tk::Tile::Label.new(frame, textvariable: @status_var, width: 30).pack(side: 'right', padx: 5)
  end

  def setup_layer_manager
    @layers = LayerManager.new(@canvas, WIDTH, HEIGHT)
    update_status
  end

  def draw_test_content
    # Draw on background layer (pixels)
    bg = @layers.layers.first
    bg.ensure_photo!

    # Draw a red square on background
    50.times do |y|
      50.times do |x|
        bg.set_rgba(x + 20, y + 20, 255, 0, 0, 255)
      end
    end
    bg.refresh_display

    puts "Background layer: #{bg.pixels.pixel_count} pixels"
    puts @layers.to_s
  end

  def on_click(x, y)
    @last_x, @last_y = x, y
    draw_pixel(x, y)
  end

  def on_drag(x, y)
    draw_line(@last_x, @last_y, x, y) if @last_x && @last_y
    @last_x, @last_y = x, y
  end

  def draw_pixel(x, y)
    layer = @layers.active_layer
    return unless layer

    # Cycle through colors based on layer index
    colors = [[255, 0, 0], [0, 255, 0], [0, 0, 255], [255, 255, 0], [255, 0, 255]]
    r, g, b = colors[@layers.active_index % colors.size]

    # Draw a small brush (5x5)
    (-2..2).each do |dy|
      (-2..2).each do |dx|
        layer.set_rgba(x + dx, y + dy, r, g, b, 255)
      end
    end

    layer.refresh_display
    update_status
  end

  def draw_line(x1, y1, x2, y2)
    # Bresenham's line algorithm
    dx = (x2 - x1).abs
    dy = (y2 - y1).abs
    sx = x1 < x2 ? 1 : -1
    sy = y1 < y2 ? 1 : -1
    err = dx - dy

    loop do
      draw_pixel(x1, y1)
      break if x1 == x2 && y1 == y2
      e2 = 2 * err
      if e2 > -dy
        err -= dy
        x1 += sx
      end
      if e2 < dx
        err += dx
        y1 += sy
      end
    end
  end

  def add_layer
    @layers.add_layer
    update_status
    puts @layers.to_s
  end

  def toggle_visible
    layer = @layers.active_layer
    return unless layer
    layer.toggle_visibility
    update_status
  end

  def move_up
    @layers.move_up(@layers.active_index)
    update_status
    puts @layers.to_s
  end

  def move_down
    @layers.move_down(@layers.active_index)
    update_status
    puts @layers.to_s
  end

  def clear_layer
    layer = @layers.active_layer
    return unless layer
    layer.clear
    layer.refresh_display
    update_status
  end

  def show_memory
    total = @layers.memory_usage
    puts "\nMemory Usage:"
    @layers.layers.each_with_index do |layer, idx|
      mem = layer.memory_usage
      puts "  [#{idx}] #{layer.name}: #{mem[:total]} bytes (#{layer.pixels.pixel_count} pixels)"
    end
    puts "  Total: #{total} bytes"
  end

  def update_status
    layer = @layers.active_layer
    if layer
      vis = layer.visible ? 'V' : 'H'
      @status_var.value = "[#{@layers.active_index}] #{layer.name} #{vis} (#{layer.pixels.pixel_count}px)"
    end
  end

  def run
    @root.bind('Escape') { @root.destroy }
    @root.bind('1') { @layers.active_index = 0; update_status }
    @root.bind('2') { @layers.active_index = 1; update_status }
    @root.bind('3') { @layers.active_index = 2; update_status }
    @root.bind('4') { @layers.active_index = 3; update_status }
    @root.bind('v') { toggle_visible }

    puts "\nControls:"
    puts "  Click/drag to draw on active layer"
    puts "  1-4: Select layer"
    puts "  v: Toggle visibility"
    puts "  Escape: Exit"
    puts ""

    Tk.mainloop
  end
end

LayerTest.new.run
