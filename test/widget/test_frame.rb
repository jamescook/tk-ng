# frozen_string_literal: true

# Comprehensive test for Tk::Frame widget options.
# Runs in a single subprocess to minimize overhead.
#
# See: https://www.tcl-lang.org/man/tcl/TkCmd/frame.html

require_relative '../test_helper'
require_relative '../tk_test_helper'

class TestFrameWidget < Minitest::Test
  include TkTestHelper

  def test_frame_comprehensive
    assert_tk_app("Frame widget comprehensive test", method(:frame_app))
  end

  def frame_app
    require 'tk'
    require 'tk/frame'

    errors = []

    # --- Basic creation ---
    frame_default = TkFrame.new(root)
    errors << "frame not created" unless frame_default.path

    # --- Size options (width/height in pixels) ---
    frame_sized = TkFrame.new(root, width: 200, height: 100)
    errors << "width mismatch" unless frame_sized.cget(:width).to_i == 200
    errors << "height mismatch" unless frame_sized.cget(:height).to_i == 100

    # --- Relief options ---
    %w[flat raised sunken groove ridge solid].each do |relief|
      frame = TkFrame.new(root, relief: relief, borderwidth: 2)
      errors << "relief #{relief} not set" unless frame.cget(:relief) == relief
    end

    # --- Borderwidth ---
    frame_border = TkFrame.new(root, borderwidth: 5, relief: "raised")
    errors << "borderwidth not set" unless frame_border.cget(:borderwidth).to_i == 5

    # --- Padding ---
    frame_padded = TkFrame.new(root, padx: 10, pady: 20)
    errors << "padx not set" if frame_padded.cget(:padx).to_i == 0
    errors << "pady not set" if frame_padded.cget(:pady).to_i == 0

    # --- Dynamic configure ---
    frame_dynamic = TkFrame.new(root)
    frame_dynamic.configure(width: 150, height: 75, relief: "groove")
    errors << "dynamic width failed" unless frame_dynamic.cget(:width).to_i == 150
    errors << "dynamic height failed" unless frame_dynamic.cget(:height).to_i == 75
    errors << "dynamic relief failed" unless frame_dynamic.cget(:relief) == "groove"

    # --- Nested frames ---
    outer = TkFrame.new(root, borderwidth: 2, relief: "raised")
    inner = TkFrame.new(outer, borderwidth: 1, relief: "sunken")
    errors << "nested frame parent wrong" unless inner.path.start_with?(outer.path)

    # --- Container option (boolean) ---
    # Note: container=true makes frame an embedding container, can't have children
    # Just test that boolean conversion works correctly
    frame_container = TkFrame.new(root, container: false)
    errors << "container should be false" if frame_container.cget(:container)
    errors << "container should return boolean" unless frame_container.cget(:container).is_a?(FalseClass)

    # Check errors before tk_end (which may block in visual mode)
    unless errors.empty?
      raise "Frame test failures:\n  " + errors.join("\n  ")
    end

  end

  def test_grid_instance_methods
    assert_tk_app("Frame grid instance methods", method(:grid_instance_app))
  end

  def grid_instance_app
    require 'tk'
    require 'tk/frame'

    errors = []

    container = TkFrame.new(root, width: 300, height: 200)
    container.pack

    lbl1 = TkLabel.new(container, text: "A")
    lbl2 = TkLabel.new(container, text: "B")
    lbl3 = TkLabel.new(container, text: "C")

    lbl1.grid(row: 0, column: 0)
    lbl2.grid(row: 0, column: 1)
    lbl3.grid(row: 1, column: 0)

    # --- grid_rowconfigure ---
    container.grid_rowconfigure(0, weight: 1, minsize: 30)
    container.grid_rowconfigure(1, weight: 2)

    # --- grid_columnconfigure ---
    container.grid_columnconfigure(0, weight: 1, minsize: 50)
    container.grid_columnconfigure(1, weight: 3)

    # --- grid_size ---
    size = container.grid_size
    errors << "expected 2 columns, got #{size[0]}" unless size[0] == 2
    errors << "expected 2 rows, got #{size[1]}" unless size[1] == 2

    # --- grid_slaves ---
    slaves = container.grid_slaves
    errors << "expected 3 slaves, got #{slaves.size}" unless slaves.size == 3

    slaves_row0 = container.grid_slaves(row: 0)
    errors << "expected 2 slaves in row 0, got #{slaves_row0.size}" unless slaves_row0.size == 2

    slaves_col0 = container.grid_slaves(column: 0)
    errors << "expected 2 slaves in col 0, got #{slaves_col0.size}" unless slaves_col0.size == 2

    # --- grid_info (on a child widget) ---
    info = lbl1.grid_info
    errors << "grid_info row should be 0" unless info['row'] == 0
    errors << "grid_info column should be 0" unless info['column'] == 0

    # --- grid_propagate ---
    container.grid_propagate(false)
    errors << "grid_propagate should be false" if container.grid_propagate
    container.grid_propagate(true)
    errors << "grid_propagate should be true" unless container.grid_propagate

    # --- grid_anchor ---
    container.grid_anchor('center')
    errors << "grid_anchor should be center" unless container.grid_anchor == 'center'
    container.grid_anchor('nw')
    errors << "grid_anchor should be nw" unless container.grid_anchor == 'nw'

    # --- grid_bbox ---
    Tk.update
    bbox = container.grid_bbox
    errors << "grid_bbox should return 4 ints" unless bbox.is_a?(Array) && bbox.size == 4

    cell_bbox = container.grid_bbox(0, 0)
    errors << "cell grid_bbox should return 4 ints" unless cell_bbox.is_a?(Array) && cell_bbox.size == 4

    # --- grid_location ---
    loc = container.grid_location(5, 5)
    errors << "grid_location should return [col, row]" unless loc.is_a?(Array) && loc.size == 2

    # --- grid_remove ---
    lbl3.grid_remove
    errors << "lbl3 should be removed from grid" unless lbl3.winfo_manager == ""

    # --- grid_forget ---
    lbl2.grid_forget
    errors << "lbl2 should be forgotten" unless lbl2.winfo_manager == ""

    raise "Grid instance method failures:\n  " + errors.join("\n  ") unless errors.empty?
  end
end
