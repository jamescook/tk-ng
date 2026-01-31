#!/usr/bin/env ruby
# frozen_string_literal: true

# Paint Demo - Simple MS Paint-style drawing application
#
# Features:
# - Main window with canvas for drawing
# - Separate color palette window
# - 16 classic colors
# - Click and drag to draw
# - Real flood fill using photo image layer
# - Spray paint tool
# - Multiple layers with sparse pixel storage

require 'tk'
require 'set'
require_relative 'paint/layer_manager'

class PaintDemo
  # Classic 16-color palette (Windows/VGA style)
  COLORS = [
    '#000000', '#808080', '#800000', '#808000',
    '#008000', '#008080', '#000080', '#800080',
    '#FFFFFF', '#C0C0C0', '#FF0000', '#FFFF00',
    '#00FF00', '#00FFFF', '#0000FF', '#FF00FF'
  ].freeze

  MAX_UNDO = 10

  PHOTO_WIDTH = 800
  PHOTO_HEIGHT = 600

  def initialize
    @brush_color = '#000000'
    @bg_color_hex = '#FFFFFF'         # Hex for canvas items (eraser)
    @brush_size = 1
    @last_x = nil
    @last_y = nil

    # Undo/redo stacks
    @undo_stack = []
    @redo_stack = []
    @current_stroke_items = []  # Items in current stroke being drawn
    @edit_menus = []  # Track edit menus for state updates
    @layer_menus = [] # Track layer menus for state updates

    # Layer manager (created after canvas in setup_main_window)
    @layers = nil

    setup_main_window
    setup_tools_window
    setup_palette_window
  end

  def setup_main_window
    @root = TkRoot.new { title 'Paint' }
    @root.geometry('800x600+100+100')

    # Menu bar
    menubar = TkMenu.new(@root)
    @root.configure(menu: create_window_menu(menubar))

    # Canvas fills the window
    @canvas = TkCanvas.new(@root,
      background: 'gray',
      cursor: 'crosshair'
    )
    @canvas.pack(fill: 'both', expand: true)

    # Layer manager handles photo images and pixel buffers
    @layers = LayerManager.new(@canvas, PHOTO_WIDTH, PHOTO_HEIGHT)
    @layers.active_layer.ensure_photo!
    @layers.active_layer.refresh_display

    # Drawing bindings
    @canvas.bind('ButtonPress-1') { |e| start_stroke(e.x, e.y) }
    @canvas.bind('B1-Motion') { |e| continue_stroke(e.x, e.y) }
    @canvas.bind('ButtonRelease-1') { end_stroke }

    # Keyboard shortcuts
    @root.bind('c') { clear_active_layer }
    @root.bind('Escape') { @root.destroy }
    @root.bind('Control-z') { undo }
    @root.bind('Control-Z') { redo_action }  # Shift+Ctrl+Z
    @root.bind('Control-y') { redo_action }

    # Layer shortcuts
    @root.bind('Control-N') { add_layer }           # Ctrl+Shift+N
    @root.bind('Control-bracketright') { move_layer_up }
    @root.bind('Control-bracketleft') { move_layer_down }
    @root.bind('Control-period') { toggle_layer_visibility }
    # Number keys to select layer (must use Key- prefix to avoid conflict with Button-1)
    (1..9).each do |n|
      @root.bind("Key-#{n}") { select_layer_by_number(n - 1) }
    end

    # Status bar
    status_frame = Tk::Tile::Frame.new(@root)
    status_frame.pack(side: 'bottom', fill: 'x')

    @color_indicator = TkCanvas.new(status_frame, width: 20, height: 20, highlightthickness: 1)
    @color_indicator.pack(side: 'left', padx: 5, pady: 3)
    update_color_indicator

    @layer_var = TkVariable.new('[0] Background')
    Tk::Tile::Label.new(status_frame, textvariable: @layer_var, width: 20).pack(side: 'left', padx: 5)

    # Brush size control
    Tk::Tile::Label.new(status_frame, text: 'Size:').pack(side: 'left', padx: 5)
    @brush_size_var = TkVariable.new(@brush_size)
    size_spinbox = Tk::Tile::Spinbox.new(status_frame,
      from: 1, to: 10, width: 3,
      textvariable: @brush_size_var,
      command: proc { update_brush_size }
    )
    size_spinbox.pack(side: 'left')
    size_spinbox.bind('KeyRelease') { update_brush_size }

    @coords_var = TkVariable.new('0, 0')
    Tk::Tile::Label.new(status_frame, textvariable: @coords_var, width: 12).pack(side: 'left', padx: 10)

    Tk::Tile::Label.new(status_frame, text: "Ruby #{RUBY_VERSION}").pack(side: 'right', padx: 10)

    # Track mouse position (debounced to max 5ms updates)
    @last_coords_update = 0
    @canvas.bind('Motion') do |e|
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      if (now - @last_coords_update) >= 0.005
        @coords_var.value = "#{e.x}, #{e.y}"
        @last_coords_update = now
      end
    end

    @root.protocol('WM_DELETE_WINDOW') { on_close }
    update_title
  end

  def setup_tools_window
    @tools = TkToplevel.new(@root) { title 'Tools' }
    @tools.geometry('50x280+50+100')
    @tools.resizable(false, false)

    @current_tool = :brush
    @tool_buttons = {}

    # Cursor tool
    cursor_btn = TkCanvas.new(@tools, width: 36, height: 36,
      background: 'white', highlightthickness: 2, highlightbackground: 'gray')
    cursor_btn.pack(padx: 4, pady: 4)
    # Draw arrow icon
    TkcPolygon.new(cursor_btn, 8, 6, 8, 28, 14, 22, 20, 30, 24, 28, 18, 20, 26, 18,
      fill: 'black', outline: 'black')
    cursor_btn.bind('ButtonPress-1') { select_tool(:cursor, cursor_btn) }
    @tool_buttons[:cursor] = cursor_btn

    # Brush tool
    brush_btn = TkCanvas.new(@tools, width: 36, height: 36,
      background: 'white', highlightthickness: 2, highlightbackground: 'gray')
    brush_btn.pack(padx: 4, pady: 4)
    # Draw brush icon (simple circle with handle)
    TkcOval.new(brush_btn, 6, 18, 20, 32, fill: 'black')
    TkcLine.new(brush_btn, 13, 20, 28, 5, width: 4, fill: 'brown', capstyle: 'round')
    brush_btn.bind('ButtonPress-1') { select_tool(:brush, brush_btn) }
    @tool_buttons[:brush] = brush_btn

    # Eraser tool
    eraser_btn = TkCanvas.new(@tools, width: 36, height: 36,
      background: 'white', highlightthickness: 2, highlightbackground: 'gray')
    eraser_btn.pack(padx: 4, pady: 4)
    # Draw eraser icon (rectangle)
    TkcRectangle.new(eraser_btn, 8, 12, 28, 28, fill: '#FFB6C1', outline: 'black', width: 2)
    TkcRectangle.new(eraser_btn, 8, 8, 28, 14, fill: '#4169E1', outline: 'black', width: 2)
    eraser_btn.bind('ButtonPress-1') { select_tool(:eraser, eraser_btn) }
    @tool_buttons[:eraser] = eraser_btn

    # Paint bucket tool
    bucket_btn = TkCanvas.new(@tools, width: 36, height: 36,
      background: 'white', highlightthickness: 2, highlightbackground: 'gray')
    bucket_btn.pack(padx: 4, pady: 4)
    # Draw bucket icon
    TkcPolygon.new(bucket_btn, 8, 14, 18, 8, 28, 14, 28, 26, 8, 26, fill: '#FFD700', outline: 'black')
    TkcLine.new(bucket_btn, 24, 26, 30, 32, width: 3, fill: @brush_color)
    bucket_btn.bind('ButtonPress-1') { select_tool(:bucket, bucket_btn) }
    @tool_buttons[:bucket] = bucket_btn

    # Spray paint tool
    spray_btn = TkCanvas.new(@tools, width: 36, height: 36,
      background: 'white', highlightthickness: 2, highlightbackground: 'gray')
    spray_btn.pack(padx: 4, pady: 4)
    # Draw spray can icon (dots pattern)
    [12, 18, 24].each do |x|
      [10, 14, 18].each do |y|
        TkcOval.new(spray_btn, x - 1, y - 1, x + 1, y + 1, fill: 'gray40', outline: '')
      end
    end
    TkcRectangle.new(spray_btn, 14, 22, 22, 32, fill: 'gray60', outline: 'black')
    spray_btn.bind('ButtonPress-1') { select_tool(:spray, spray_btn) }
    @tool_buttons[:spray] = spray_btn

    # Shapes tool with flyout
    @current_shape = :rectangle
    shapes_btn = TkCanvas.new(@tools, width: 36, height: 36,
      background: 'white', highlightthickness: 2, highlightbackground: 'gray')
    shapes_btn.pack(padx: 4, pady: 4)
    @shapes_btn = shapes_btn
    @tool_buttons[:shapes] = shapes_btn
    draw_shape_icon(shapes_btn, :rectangle)

    # Shapes flyout menu
    shapes_menu = TkMenu.new(@tools, tearoff: false)
    shapes_menu.add_command(label: 'Rectangle', command: proc { select_shape(:rectangle, shapes_btn) })
    shapes_menu.add_command(label: 'Oval', command: proc { select_shape(:oval, shapes_btn) })
    shapes_menu.add_command(label: 'Line', command: proc { select_shape(:line, shapes_btn) })

    shapes_btn.bind('ButtonPress-1') { |e|
      select_tool(:shapes, shapes_btn)
      Tk.tk_call('tk_popup', shapes_menu.path, e.x_root, e.y_root + 10)
    }

    # Start with brush selected
    select_tool(:brush, brush_btn)

    @tools.protocol('WM_DELETE_WINDOW') { @tools.withdraw }

    # Add menu to tools window too
    tools_menu = TkMenu.new(@tools, tearoff: false)
    @tools.configure(menu: create_window_menu(tools_menu))
  end

  def select_tool(tool, btn)
    @current_tool = tool

    # Update button appearance - selected gets blue background
    @tool_buttons.each do |_name, b|
      b.configure(background: 'white', highlightbackground: 'gray', highlightthickness: 2)
    end
    btn.configure(background: '#ADD8E6', highlightbackground: 'black', highlightthickness: 3)

    # Update cursor
    case tool
    when :cursor
      @canvas.configure(cursor: 'arrow')
    when :brush
      @canvas.configure(cursor: 'crosshair')
    when :eraser
      @canvas.configure(cursor: 'dotbox')
    when :bucket
      @canvas.configure(cursor: 'target')
    when :spray
      @canvas.configure(cursor: 'spraycan')
    when :shapes
      @canvas.configure(cursor: 'crosshair')
    end
  end

  def select_shape(shape, btn)
    @current_shape = shape
    select_tool(:shapes, btn)
    draw_shape_icon(@shapes_btn, shape)
  end

  def draw_shape_icon(canvas, shape)
    canvas.delete('icon')
    case shape
    when :rectangle
      TkcRectangle.new(canvas, 8, 10, 28, 26, outline: 'black', width: 2, tags: 'icon')
    when :oval
      TkcOval.new(canvas, 8, 10, 28, 26, outline: 'black', width: 2, tags: 'icon')
    when :line
      TkcLine.new(canvas, 8, 26, 28, 10, fill: 'black', width: 2, tags: 'icon')
    end
  end

  def setup_palette_window
    @palette = TkToplevel.new(@root) { title 'Colors' }
    @palette.geometry('170x160+910+100')
    @palette.resizable(false, false)

    # Grid of color buttons (4x4)
    COLORS.each_with_index do |color, i|
      row = i / 4
      col = i % 4

      btn = TkCanvas.new(@palette,
        width: 32,
        height: 32,
        background: color,
        highlightthickness: 2,
        highlightbackground: 'gray'
      )
      btn.grid(row: row, column: col, padx: 2, pady: 2)

      # Click to select color
      btn.bind('ButtonPress-1') { select_color(color, btn) }
    end

    # Prevent closing palette from closing app
    @palette.protocol('WM_DELETE_WINDOW') { @palette.withdraw }

    # Add menu to palette window too
    palette_menu = TkMenu.new(@palette, tearoff: false)
    @palette.configure(menu: create_window_menu(palette_menu))
  end

  def select_color(color, btn = nil)
    @brush_color = color
    update_color_indicator

    # Update palette button highlights
    @palette.winfo_children.each do |child|
      if child.is_a?(TkCanvas)
        child.configure(highlightbackground: 'gray', highlightthickness: 2)
      end
    end
    btn&.configure(highlightbackground: 'black', highlightthickness: 3)
  end

  def update_color_indicator
    @color_indicator.configure(background: @brush_color)
  end

  def update_brush_size
    size = @brush_size_var.to_i
    size = 1 if size < 1
    size = 10 if size > 10
    @brush_size = size
  end

  def create_window_menu(menubar)
    # Edit menu
    edit_menu = TkMenu.new(menubar, tearoff: false)
    menubar.add_cascade(label: 'Edit', menu: edit_menu)
    edit_menu.add_command(label: 'Undo', accelerator: 'Ctrl+Z', command: proc { undo })
    edit_menu.add_command(label: 'Redo', accelerator: 'Ctrl+Shift+Z', command: proc { redo_action })
    edit_menu.add_separator
    edit_menu.add_command(label: 'Clear Layer', command: proc { clear_active_layer })
    edit_menu.add_command(label: 'Clear All Layers', command: proc { clear_canvas })

    @edit_menus << edit_menu
    update_menu_states

    # Layer menu
    layer_menu = TkMenu.new(menubar, tearoff: false)
    menubar.add_cascade(label: 'Layer', menu: layer_menu)
    layer_menu.add_command(label: 'Add Layer', accelerator: 'Ctrl+Shift+N', command: proc { add_layer })
    layer_menu.add_command(label: 'Delete Layer', command: proc { delete_layer })
    layer_menu.add_separator
    layer_menu.add_command(label: 'Move Up', accelerator: 'Ctrl+]', command: proc { move_layer_up })
    layer_menu.add_command(label: 'Move Down', accelerator: 'Ctrl+[', command: proc { move_layer_down })
    layer_menu.add_separator
    layer_menu.add_command(label: 'Toggle Visibility', accelerator: 'Ctrl+.', command: proc { toggle_layer_visibility })
    layer_menu.add_separator
    layer_menu.add_command(label: 'Flatten All', command: proc { flatten_layers })

    @layer_menus << layer_menu

    # Window menu
    window_menu = TkMenu.new(menubar, tearoff: false)
    menubar.add_cascade(label: 'Window', menu: window_menu)
    window_menu.add_command(label: 'Show Tools', command: proc { @tools.deiconify })
    window_menu.add_command(label: 'Show Colors', command: proc { @palette.deiconify })
    window_menu.add_separator
    window_menu.add_command(label: 'Show Layers', command: proc { show_layers_window })

    # Debug menu (memory, etc.)
    debug_menu = TkMenu.new(menubar, tearoff: false)
    menubar.add_cascade(label: 'Debug', menu: debug_menu)
    debug_menu.add_command(label: 'Memory Usage', command: proc { show_memory_usage })
    debug_menu.add_command(label: 'Layer Info', command: proc { show_layer_info })

    menubar
  end

  def update_menu_states
    undo_state = @undo_stack.empty? ? 'disabled' : 'normal'
    redo_state = @redo_stack.empty? ? 'disabled' : 'normal'

    @edit_menus.each do |menu|
      menu.entryconfigure(0, state: undo_state)  # Undo is index 0
      menu.entryconfigure(1, state: redo_state)  # Redo is index 1
    end
  end

  def start_stroke(x, y)
    if @current_tool == :bucket
      flood_fill(x, y)
      return
    end

    if @current_tool == :spray
      layer = @layers.active_layer
      @spray_old_pixels = layer.snapshot_pixels
      spray_paint(x, y)
      return
    end

    if @current_tool == :shapes
      @shape_start_x = x
      @shape_start_y = y
      @shape_preview = nil
      return
    end

    return unless @current_tool == :brush || @current_tool == :eraser
    @current_stroke_items = []
    @last_x = x
    @last_y = y
    # Draw a dot for single clicks
    draw_point(x, y)
  end

  def continue_stroke(x, y)
    if @current_tool == :shapes
      update_shape_preview(x, y)
      return
    end

    if @current_tool == :spray
      spray_paint(x, y)
      return
    end

    return unless @current_tool == :brush || @current_tool == :eraser
    return unless @last_x && @last_y

    color = @current_tool == :eraser ? @bg_color_hex : @brush_color
    size = @current_tool == :eraser ? @brush_size * 3 : @brush_size

    item = TkcLine.new(@canvas, @last_x, @last_y, x, y,
      fill: color,
      width: size,
      capstyle: 'round',
      joinstyle: 'round'
    )
    @current_stroke_items << item

    @last_x = x
    @last_y = y
  end

  def end_stroke
    if @current_tool == :shapes
      finalize_shape
      return
    end

    if @current_tool == :spray
      # Push undo for spray stroke if pixels changed
      layer = @layers.active_layer
      if @spray_old_pixels
        push_undo(LayerPixelsCommand.new(layer, @spray_old_pixels, layer.snapshot_pixels))
      end
      @spray_old_pixels = nil
      return
    end

    # Save stroke for undo if we drew anything
    if @current_stroke_items && @current_stroke_items.any?
      push_undo(StrokeCommand.new(@canvas, @current_stroke_items.dup))
    end
    @current_stroke_items = []
    @last_x = nil
    @last_y = nil
  end

  def update_shape_preview(x, y)
    return unless @shape_start_x && @shape_start_y

    # Delete old preview
    @canvas.delete(@shape_preview) if @shape_preview

    # Draw new preview
    @shape_preview = create_shape(@shape_start_x, @shape_start_y, x, y)
  end

  def finalize_shape
    return unless @shape_preview

    # The preview becomes the final shape - wrap it for undo
    push_undo(StrokeCommand.new(@canvas, [@shape_preview]))

    @shape_preview = nil
    @shape_start_x = nil
    @shape_start_y = nil
  end

  def create_shape(x1, y1, x2, y2)
    case @current_shape
    when :rectangle
      TkcRectangle.new(@canvas, x1, y1, x2, y2,
        outline: @brush_color, width: @brush_size)
    when :oval
      TkcOval.new(@canvas, x1, y1, x2, y2,
        outline: @brush_color, width: @brush_size)
    when :line
      TkcLine.new(@canvas, x1, y1, x2, y2,
        fill: @brush_color, width: @brush_size)
    end
  end

  def draw_point(x, y)
    color = @current_tool == :eraser ? @bg_color_hex : @brush_color
    size = @current_tool == :eraser ? @brush_size * 3 : @brush_size
    r = size / 2.0
    item = TkcOval.new(@canvas, x - r, y - r, x + r, y + r,
      fill: color,
      outline: color
    )
    @current_stroke_items << item if @current_stroke_items
  end

  def clear_canvas
    @layers.clear_all
    @layers.refresh_all
  end

  def clear_active_layer
    layer = @layers.active_layer
    return unless layer
    layer.clear
    layer.refresh_display
  end

  # ---------------------------------------------------------------
  # Layer menu actions
  # ---------------------------------------------------------------

  def add_layer
    @layers.add_layer
    update_title
  end

  def delete_layer
    return if @layers.layers.size <= 1
    @layers.remove_layer(@layers.active_index)
    @layers.refresh_all
    update_title
  end

  def move_layer_up
    @layers.move_up(@layers.active_index)
    update_title
  end

  def move_layer_down
    @layers.move_down(@layers.active_index)
    update_title
  end

  def toggle_layer_visibility
    layer = @layers.active_layer
    return unless layer
    layer.toggle_visibility
  end

  def flatten_layers
    @layers.flatten
    update_title
  end

  def show_layers_window
    # TODO: Create a proper layers panel
    puts @layers.to_s
  end

  def show_memory_usage
    total = @layers.memory_usage
    msg = "Total: #{total} bytes\n\n"
    @layers.layers.each_with_index do |layer, idx|
      mem = layer.memory_usage
      msg += "[#{idx}] #{layer.name}: #{mem[:total]} bytes\n"
      msg += "     Pixels: #{layer.pixels.pixel_count}, Density: #{(layer.pixels.density * 100).round(1)}%\n"
    end
    Tk.messageBox(title: 'Memory Usage', message: msg, type: 'ok')
  end

  def show_layer_info
    puts @layers.to_s
    Tk.messageBox(title: 'Layer Info', message: @layers.to_s, type: 'ok')
  end

  def update_title
    layer = @layers.active_layer
    layer_info = layer ? "[#{@layers.active_index}] #{layer.name}" : ""
    @root.title("Paint - #{layer_info}")
    @layer_var.value = layer_info if @layer_var
  end

  def select_layer_by_number(index)
    return unless index >= 0 && index < @layers.layers.size
    @layers.active_index = index
    update_title
  end

  # ---------------------------------------------------------------
  # Pixel operations (delegate to active layer)
  # ---------------------------------------------------------------

  def get_pixel(x, y)
    @layers.active_layer&.get_rgba(x, y)
  end

  def set_pixel(x, y, rgba)
    layer = @layers.active_layer
    return unless layer
    layer.set_rgba(x, y, *rgba)
  end

  def parse_hex_color(hex)
    hex = hex.delete('#')
    r = hex[0, 2].to_i(16)
    g = hex[2, 2].to_i(16)
    b = hex[4, 2].to_i(16)
    [r, g, b, 255]
  end

  def colors_match?(c1, c2, tolerance = 0)
    return false unless c1 && c2
    (c1[0] - c2[0]).abs <= tolerance &&
      (c1[1] - c2[1]).abs <= tolerance &&
      (c1[2] - c2[2]).abs <= tolerance
  end

  # ---------------------------------------------------------------
  # Flood fill - scanline algorithm for performance
  # ---------------------------------------------------------------

  def flood_fill(x, y)
    x = x.to_i
    y = y.to_i
    layer = @layers.active_layer
    return unless layer
    return if x < 0 || x >= PHOTO_WIDTH || y < 0 || y >= PHOTO_HEIGHT

    target_color = get_pixel(x, y)
    fill_color = parse_hex_color(@brush_color)

    return if colors_match?(target_color, fill_color)

    # Save state for undo
    old_pixels = layer.snapshot_pixels

    # Scanline flood fill
    scanline_fill(x, y, target_color, fill_color)

    # Update display
    layer.refresh_display

    # Push undo command
    push_undo(LayerPixelsCommand.new(layer, old_pixels, layer.snapshot_pixels))
  end

  def scanline_fill(start_x, start_y, target_color, fill_color)
    stack = [[start_x, start_y]]

    while !stack.empty?
      x, y = stack.pop
      next if y < 0 || y >= PHOTO_HEIGHT

      # Find left edge
      lx = x
      while lx > 0 && colors_match?(get_pixel(lx - 1, y), target_color)
        lx -= 1
      end

      # Find right edge and fill
      span_above = false
      span_below = false

      while lx < PHOTO_WIDTH && colors_match?(get_pixel(lx, y), target_color)
        set_pixel(lx, y, fill_color)

        # Check pixel above
        if y > 0
          above_matches = colors_match?(get_pixel(lx, y - 1), target_color)
          if !span_above && above_matches
            stack.push([lx, y - 1])
            span_above = true
          elsif span_above && !above_matches
            span_above = false
          end
        end

        # Check pixel below
        if y < PHOTO_HEIGHT - 1
          below_matches = colors_match?(get_pixel(lx, y + 1), target_color)
          if !span_below && below_matches
            stack.push([lx, y + 1])
            span_below = true
          elsif span_below && !below_matches
            span_below = false
          end
        end

        lx += 1
      end
    end
  end

  # ---------------------------------------------------------------
  # Spray paint - random dots in radius
  # ---------------------------------------------------------------

  def spray_paint(x, y)
    x = x.to_i
    y = y.to_i
    layer = @layers.active_layer
    return unless layer

    fill_color = parse_hex_color(@brush_color)
    radius = @brush_size * 5
    density = @brush_size * 3

    density.times do
      # Random point within circle
      angle = rand * 2 * Math::PI
      r = rand * radius
      px = x + (r * Math.cos(angle)).to_i
      py = y + (r * Math.sin(angle)).to_i
      set_pixel(px, py, fill_color)
    end

    # Update display
    layer.refresh_display
  end

  # Undo/Redo system
  def push_undo(command)
    @undo_stack << command
    @undo_stack.shift if @undo_stack.size > MAX_UNDO
    @redo_stack.clear  # New action clears redo history
    update_menu_states
  end

  def undo
    return if @undo_stack.empty?
    command = @undo_stack.pop
    command.undo
    @redo_stack << command
    update_menu_states
  end

  def redo_action
    return if @redo_stack.empty?
    command = @redo_stack.pop
    command.redo
    @undo_stack << command
    update_menu_states
  end

  # Command classes for undo/redo
  class StrokeCommand
    def initialize(canvas, items)
      @canvas = canvas
      @items = items
      # Store item configurations for redo
      @configs = items.map do |item|
        {
          type: item.class,
          coords: item.coords,
          fill: (item.cget('fill') rescue nil),
          width: (item.cget('width') rescue nil),
          outline: (item.cget('outline') rescue nil),
          capstyle: (item.cget('capstyle') rescue nil),
          joinstyle: (item.cget('joinstyle') rescue nil)
        }
      end
    end

    def undo
      @items.each { |item| @canvas.delete(item) }
    end

    def redo
      @items = @configs.map do |cfg|
        case cfg[:type].to_s
        when /TkcLine/
          opts = { fill: cfg[:fill], width: cfg[:width] }
          opts[:capstyle] = cfg[:capstyle] if cfg[:capstyle]
          opts[:joinstyle] = cfg[:joinstyle] if cfg[:joinstyle]
          TkcLine.new(@canvas, *cfg[:coords], **opts)
        when /TkcRectangle/
          TkcRectangle.new(@canvas, *cfg[:coords], outline: cfg[:outline], width: cfg[:width])
        when /TkcOval/
          if cfg[:outline] && cfg[:outline] != ''
            TkcOval.new(@canvas, *cfg[:coords], outline: cfg[:outline], width: cfg[:width])
          else
            TkcOval.new(@canvas, *cfg[:coords], fill: cfg[:fill], outline: cfg[:fill])
          end
        end
      end
    end
  end

  # Command for layer pixel changes (flood fill, spray paint)
  class LayerPixelsCommand
    def initialize(layer, old_pixels, new_pixels)
      @layer = layer
      @old_pixels = old_pixels
      @new_pixels = new_pixels
    end

    def undo
      @layer.restore_pixels(@old_pixels)
    end

    def redo
      @layer.restore_pixels(@new_pixels)
    end
  end

  def on_close
    @tools.destroy
    @palette.destroy
    @root.destroy
  end

  def run
    Tk.mainloop
  end
end

PaintDemo.new.run
