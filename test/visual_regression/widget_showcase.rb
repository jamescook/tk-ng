# frozen_string_literal: false

require 'tk'
require 'tkextlib/tile'
require 'fileutils'

module VisualRegression
  # A comprehensive Tk/Ttk widget showcase for visual regression testing.
  # Displays all major widgets in static states across multiple tabs,
  # then captures screenshots of each tab.
  class WidgetShowcase
    TABS = [
      { name: '01_basic',       label: 'Basic Widgets' },
      { name: '02_selection',   label: 'Selection' },
      { name: '03_range',       label: 'Range/Numeric' },
      { name: '04_text_canvas', label: 'Text/Canvas' },
      { name: '05_treeview',    label: 'Treeview' },
      { name: '06_misc',        label: 'Misc' }
    ].freeze

    TITLE_BAR_HEIGHT = 28 # macOS title bar height

    attr_reader :output_dir, :tcl_version, :tk_version

    def initialize(output_dir:)
      @output_dir = output_dir
      @tcl_version = Tk::TCL_VERSION rescue "unknown"
      @tk_version = Tk::TK_VERSION rescue "unknown"
      FileUtils.mkdir_p(output_dir)
    end

    def run
      build_ui
      schedule_captures
      Tk.mainloop
    end

    private

    def build_ui
      @root = TkRoot.new { title "Tk Widget Showcase" }
      @root.geometry("700x500+100+100")
      @root.raise
      @root.focus(true)

      Ttk::Label.new(@root) {
        text "Tk/Ttk Widget Showcase"
        font 'Helvetica 14 bold'
      }.pack(pady: 10)

      @notebook = Ttk::Notebook.new(@root)
      @notebook.pack(fill: 'both', expand: true, padx: 10, pady: 5)

      build_basic_tab
      build_selection_tab
      build_range_tab
      build_text_canvas_tab
      build_treeview_tab
      build_misc_tab
    end

    def build_basic_tab
      tab = Ttk::Frame.new(@notebook)
      @notebook.add(tab, text: 'Basic Widgets')

      # Labels
      lf = Ttk::Labelframe.new(tab, text: 'Labels')
      lf.pack(fill: 'x', padx: 10, pady: 5)
      TkLabel.new(lf) { text 'Classic Tk Label' }.pack(anchor: 'w', padx: 5)
      Ttk::Label.new(lf) { text 'Ttk Themed Label' }.pack(anchor: 'w', padx: 5)
      Ttk::Label.new(lf, relief: 'sunken', padding: 5) { text 'Sunken Label' }.pack(anchor: 'w', padx: 5, pady: 2)

      # Buttons
      lf = Ttk::Labelframe.new(tab, text: 'Buttons')
      lf.pack(fill: 'x', padx: 10, pady: 5)
      frame = Ttk::Frame.new(lf)
      frame.pack(fill: 'x', padx: 5, pady: 5)
      TkButton.new(frame) { text 'Classic Button' }.pack(side: 'left', padx: 2)
      Ttk::Button.new(frame) { text 'Ttk Button' }.pack(side: 'left', padx: 2)
      Ttk::Button.new(frame, state: 'disabled') { text 'Disabled' }.pack(side: 'left', padx: 2)

      # Entries
      lf = Ttk::Labelframe.new(tab, text: 'Entry Widgets')
      lf.pack(fill: 'x', padx: 10, pady: 5)
      frame = Ttk::Frame.new(lf)
      frame.pack(fill: 'x', padx: 5, pady: 5)

      e1 = TkEntry.new(frame, width: 25)
      e1.pack(side: 'left', padx: 2)
      e1.insert(0, 'Classic Entry')

      e2 = Ttk::Entry.new(frame, width: 25)
      e2.pack(side: 'left', padx: 2)
      e2.insert(0, 'Ttk Entry')

      e3 = Ttk::Entry.new(frame, width: 15)
      e3.pack(side: 'left', padx: 2)
      e3.insert(0, 'Disabled')
      e3.state(['disabled'])
    end

    def build_selection_tab
      tab = Ttk::Frame.new(@notebook)
      @notebook.add(tab, text: 'Selection')

      container = Ttk::Frame.new(tab)
      container.pack(fill: 'both', expand: true, padx: 10, pady: 5)

      # Checkbuttons
      lf = Ttk::Labelframe.new(container, text: 'Checkbuttons')
      lf.pack(side: 'left', fill: 'both', expand: true, padx: 5)
      check_var1 = TkVariable.new(1)
      check_var2 = TkVariable.new(0)
      check_var3 = TkVariable.new(1)
      TkCheckbutton.new(lf, variable: check_var1) { text 'Classic (checked)' }.pack(anchor: 'w', padx: 5)
      Ttk::Checkbutton.new(lf, text: 'Ttk (unchecked)', variable: check_var2).pack(anchor: 'w', padx: 5)
      Ttk::Checkbutton.new(lf, text: 'Ttk (checked)', variable: check_var3).pack(anchor: 'w', padx: 5)
      Ttk::Checkbutton.new(lf, text: 'Disabled', state: 'disabled').pack(anchor: 'w', padx: 5)

      # Radiobuttons
      lf = Ttk::Labelframe.new(container, text: 'Radiobuttons')
      lf.pack(side: 'left', fill: 'both', expand: true, padx: 5)
      radio_var = TkVariable.new('option2')
      TkRadiobutton.new(lf, variable: radio_var, value: 'option1') { text 'Classic' }.pack(anchor: 'w', padx: 5)
      Ttk::Radiobutton.new(lf, text: 'Ttk Selected', variable: radio_var, value: 'option2').pack(anchor: 'w', padx: 5)
      Ttk::Radiobutton.new(lf, text: 'Ttk Unselected', variable: radio_var, value: 'option3').pack(anchor: 'w', padx: 5)

      # List selection
      lf = Ttk::Labelframe.new(container, text: 'List Selection')
      lf.pack(side: 'left', fill: 'both', expand: true, padx: 5)
      combo_var = TkVariable.new('Option B')
      Ttk::Combobox.new(lf, textvariable: combo_var, values: ['Option A', 'Option B', 'Option C'], state: 'readonly', width: 15).pack(padx: 5, pady: 5)
      listbox = TkListbox.new(lf, height: 4, width: 18)
      listbox.pack(padx: 5, pady: 5)
      ['Item One', 'Item Two', 'Item Three', 'Item Four'].each { |item| listbox.insert('end', item) }
      listbox.selection_set(1)
    end

    def build_range_tab
      tab = Ttk::Frame.new(@notebook)
      @notebook.add(tab, text: 'Range/Numeric')

      # Scales
      lf = Ttk::Labelframe.new(tab, text: 'Scale Widgets')
      lf.pack(fill: 'x', padx: 10, pady: 5)
      frame = Ttk::Frame.new(lf)
      frame.pack(fill: 'x', padx: 5, pady: 5)

      scale1 = TkScale.new(frame, orient: 'horizontal', from: 0, to: 100, length: 150)
      scale1.set(35)
      scale1.pack(side: 'left', padx: 10)

      scale2 = Ttk::Scale.new(frame, orient: 'horizontal', from: 0, to: 100, length: 150)
      scale2.set(65)
      scale2.pack(side: 'left', padx: 10)

      scale3 = TkScale.new(frame, orient: 'vertical', from: 0, to: 100, length: 100)
      scale3.set(50)
      scale3.pack(side: 'left', padx: 10)

      # Spinboxes
      lf = Ttk::Labelframe.new(tab, text: 'Spinbox Widgets')
      lf.pack(fill: 'x', padx: 10, pady: 5)
      frame = Ttk::Frame.new(lf)
      frame.pack(fill: 'x', padx: 5, pady: 5)

      spin1 = TkSpinbox.new(frame, from: 0, to: 100, width: 10)
      spin1.set(42)
      spin1.pack(side: 'left', padx: 5)
      Ttk::Spinbox.new(frame, from: 0, to: 100, width: 10).pack(side: 'left', padx: 5)
      Ttk::Spinbox.new(frame, values: ['Small', 'Medium', 'Large'], width: 10).pack(side: 'left', padx: 5)

      # Progress bars
      lf = Ttk::Labelframe.new(tab, text: 'Progress Bars')
      lf.pack(fill: 'x', padx: 10, pady: 5)
      frame = Ttk::Frame.new(lf)
      frame.pack(fill: 'x', padx: 5, pady: 5)
      Ttk::Label.new(frame, text: '25%:').pack(side: 'left', padx: 5)
      Ttk::Progressbar.new(frame, orient: 'horizontal', length: 150, mode: 'determinate', value: 25).pack(side: 'left', padx: 5)
      Ttk::Label.new(frame, text: '75%:').pack(side: 'left', padx: 5)
      Ttk::Progressbar.new(frame, orient: 'horizontal', length: 150, mode: 'determinate', value: 75).pack(side: 'left', padx: 5)
    end

    def build_text_canvas_tab
      tab = Ttk::Frame.new(@notebook)
      @notebook.add(tab, text: 'Text/Canvas')

      container = Ttk::Frame.new(tab)
      container.pack(fill: 'both', expand: true, padx: 10, pady: 5)

      # Text widget
      lf = Ttk::Labelframe.new(container, text: 'Text Widget')
      lf.pack(side: 'left', fill: 'both', expand: true, padx: 5)
      text = TkText.new(lf, width: 30, height: 12, wrap: 'word')
      text.pack(fill: 'both', expand: true, padx: 5, pady: 5)
      text.insert('end', "This is a Tk Text widget.\n\n")
      text.insert('end', "It supports multiple lines,\n")
      text.insert('end', "word wrapping, and various\n")
      text.insert('end', "text formatting options.\n\n")
      text.insert('end', "Tcl/Tk #{@tcl_version}")

      # Canvas widget
      lf = Ttk::Labelframe.new(container, text: 'Canvas Widget')
      lf.pack(side: 'left', fill: 'both', expand: true, padx: 5)
      canvas = TkCanvas.new(lf, width: 250, height: 200, bg: 'white')
      canvas.pack(fill: 'both', expand: true, padx: 5, pady: 5)
      TkcRectangle.new(canvas, 20, 20, 100, 80, fill: 'lightblue', outline: 'blue', width: 2)
      TkcOval.new(canvas, 120, 20, 220, 80, fill: 'lightgreen', outline: 'green', width: 2)
      TkcLine.new(canvas, 20, 100, 220, 100, fill: 'red', width: 3)
      TkcPolygon.new(canvas, 70, 120, 20, 180, 120, 180, fill: 'yellow', outline: 'orange', width: 2)
      TkcArc.new(canvas, 140, 110, 230, 190, start: 0, extent: 270, fill: 'lightpink', outline: 'purple', width: 2)
      TkcText.new(canvas, 125, 195, text: 'Canvas Shapes', font: 'Helvetica 10')
    end

    def build_treeview_tab
      tab = Ttk::Frame.new(@notebook)
      @notebook.add(tab, text: 'Treeview')

      lf = Ttk::Labelframe.new(tab, text: 'Treeview Widget')
      lf.pack(fill: 'both', expand: true, padx: 10, pady: 5)

      tree = Ttk::Treeview.new(lf, columns: ['size', 'modified'], height: 10)
      tree.pack(fill: 'both', expand: true, padx: 5, pady: 5)
      tree.heading_configure('#0', text: 'Name')
      tree.heading_configure('size', text: 'Size')
      tree.heading_configure('modified', text: 'Modified')
      tree.column_configure('#0', width: 200)
      tree.column_configure('size', width: 100)
      tree.column_configure('modified', width: 150)

      folder1 = tree.insert('', 'end', text: 'Documents', values: ['--', '2024-01-15'])
      tree.insert(folder1, 'end', text: 'report.pdf', values: ['2.4 MB', '2024-01-10'])
      tree.insert(folder1, 'end', text: 'notes.txt', values: ['12 KB', '2024-01-14'])

      folder2 = tree.insert('', 'end', text: 'Images', values: ['--', '2024-01-12'])
      tree.insert(folder2, 'end', text: 'photo.jpg', values: ['4.1 MB', '2024-01-11'])
      tree.insert(folder2, 'end', text: 'icon.png', values: ['24 KB', '2024-01-12'])

      tree.insert('', 'end', text: 'readme.md', values: ['8 KB', '2024-01-15'])
      folder1.open
    end

    def build_misc_tab
      tab = Ttk::Frame.new(@notebook)
      @notebook.add(tab, text: 'Misc')

      # Separators
      lf = Ttk::Labelframe.new(tab, text: 'Separators')
      lf.pack(fill: 'x', padx: 10, pady: 5)
      Ttk::Label.new(lf, text: 'Horizontal separator below:').pack(anchor: 'w', padx: 5, pady: 5)
      Ttk::Separator.new(lf, orient: 'horizontal').pack(fill: 'x', padx: 5, pady: 5)
      Ttk::Label.new(lf, text: 'Content after separator').pack(anchor: 'w', padx: 5, pady: 5)

      # Menubutton
      lf = Ttk::Labelframe.new(tab, text: 'Menubutton')
      lf.pack(fill: 'x', padx: 10, pady: 5)
      mb = Ttk::Menubutton.new(lf, text: 'Select Option')
      menu = TkMenu.new(mb, tearoff: false)
      menu.add('command', label: 'Option 1')
      menu.add('command', label: 'Option 2')
      menu.add('separator')
      menu.add('command', label: 'Option 3')
      mb.menu(menu)
      mb.pack(padx: 5, pady: 5, anchor: 'w')

      # Sizegrip
      lf = Ttk::Labelframe.new(tab, text: 'Sizegrip (bottom-right of this frame)')
      lf.pack(fill: 'both', expand: true, padx: 10, pady: 5)
      container = Ttk::Frame.new(lf)
      container.pack(fill: 'both', expand: true)
      Ttk::Sizegrip.new(container).pack(side: 'right', anchor: 'se')
    end

    def schedule_captures
      Tk.after(2000) do
        capture_all_tabs(0)
      end
    end

    def capture_all_tabs(index)
      if index < TABS.length
        tab = TABS[index]
        @notebook.select(index)

        Tk.after(500) do
          capture_screenshot(tab)
          Tk.after(500) { capture_all_tabs(index + 1) }
        end
      else
        puts "Screenshots saved to: #{output_dir}/"
        Tk.after(500) { exit 0 }
      end
    end

    def capture_screenshot(tab)
      x = @root.winfo_rootx
      y = @root.winfo_rooty
      w = @root.winfo_width
      h = @root.winfo_height

      y -= TITLE_BAR_HEIGHT
      h += TITLE_BAR_HEIGHT

      file = File.join(output_dir, "#{tab[:name]}.png")
      system("screencapture", "-R#{x},#{y},#{w},#{h}", file)
      puts "  Captured: #{tab[:name]}.png"
    end
  end
end

# Allow running standalone
if __FILE__ == $0
  output_dir = ARGV[0] || 'screenshots/unverified'
  VisualRegression::WidgetShowcase.new(output_dir: output_dir).run
end
