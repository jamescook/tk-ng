#!/usr/bin/env ruby
# frozen_string_literal: true

# Font Chooser Demo - Shows TkFont::Chooser in action
#
# Click "Choose Font..." to open the system font picker.
# Selected font is applied to the sample text.

require 'tk'
require 'tk/fontchooser'

class FontChooserDemo
  def initialize
    @root = TkRoot.new { title 'Font Chooser Demo' }
    @root.geometry('500x300')

    setup_ui
  end

  def setup_ui
    # Sample text with large default font
    @sample_font = TkFont.new(size: 24)

    @sample_label = TkLabel.new(@root,
      text: "The quick brown fox\njumps over the lazy dog",
      font: @sample_font,
      justify: 'center'
    )
    @sample_label.pack(expand: true, fill: 'both', padx: 20, pady: 20)

    # Button frame
    btn_frame = Tk::Tile::Frame.new(@root)
    btn_frame.pack(fill: 'x', padx: 10, pady: 10)

    # Choose font button
    @choose_btn = Tk::Tile::Button.new(btn_frame, text: 'Choose Font...')
    @choose_btn.pack(side: 'left', padx: 5)
    @choose_btn.command { open_font_chooser }

    # Current font label
    @font_var = TkVariable.new(describe_font)
    Tk::Tile::Label.new(btn_frame, textvariable: @font_var).pack(side: 'left', padx: 10)

    # Quit button
    Tk::Tile::Button.new(btn_frame, text: 'Quit', command: proc { @root.destroy }).pack(side: 'right', padx: 5)

    @root.protocol('WM_DELETE_WINDOW') { @root.destroy }
  end

  def open_font_chooser
    puts "Font chooser opened"
    TkFont::Chooser.configure(
      parent: @root,
      title: 'Choose a Font',
      font: @sample_font.to_s
    )

    TkFont::Chooser.command do |font_spec|
      apply_font(font_spec)
    end

    TkFont::Chooser.show
  end

  def apply_font(font_spec)
    return if font_spec.to_s.empty?

    # Update the sample font
    actual = TkCore::INTERP._split_tklist(Tk.tk_call('font', 'actual', font_spec))
    attrs = Hash[*actual]

    @sample_font.family = attrs['-family'] if attrs['-family']
    @sample_font.size = attrs['-size'].to_i if attrs['-size']
    @sample_font.weight = attrs['-weight'] if attrs['-weight']
    @sample_font.slant = attrs['-slant'] if attrs['-slant']

    @font_var.value = describe_font
  end

  def describe_font
    "#{@sample_font.family} #{@sample_font.actual_size}pt"
  end

  def run
    Tk.mainloop
  end

  attr_reader :choose_btn
end

# Automated demo support (testing and recording)
require 'tk/demo_support'

demo = FontChooserDemo.new

if TkDemo.active?
  TkDemo.on_visible {
    puts "UI loaded"
    demo.choose_btn.invoke
    Tk.after(TkDemo.delay(test: 300, record: 1000)) {
      TkFont::Chooser.hide
      puts "Font chooser closed"
      TkDemo.finish
    }
  }
end

demo.run
