# frozen_string_literal: false
#
#  TkDND (Tk Drag & Drop Extension) support
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/tkDND/setup.rb'

module Tk
  # Drag and drop support for Tk applications.
  #
  # TkDND provides native drag-and-drop functionality across platforms:
  # - Windows: OLE drag-and-drop
  # - Linux/Unix: XDND protocol
  # - macOS: Native drag-and-drop
  #
  # ## Installation
  #
  # TkDND must be installed separately:
  # - Download from https://github.com/petasis/tkdnd
  # - Or via package manager if available
  #
  # ## Basic Usage
  #
  # Register a widget as a drop target:
  #
  #     require 'tkextlib/tkDND'
  #
  #     label = TkLabel.new(text: 'Drop files here')
  #     label.pack
  #
  #     # Register as drop target
  #     Tk::TkDND::DND.drop_target_register(label, 'DND_Files')
  #
  #     # Bind drop event
  #     label.bind('<<Drop>>', proc { |data|
  #       puts "Dropped: #{data}"
  #     }, '%D')
  #
  # ## Data Types
  #
  # Common drop types:
  # - `DND_Files` - File paths
  # - `DND_Text` - Plain text
  # - `*` - Accept any type
  #
  # @see Tk::TkDND::DND Main drag-and-drop interface
  # @see https://wiki.tcl-lang.org/page/TkDND Tcl Wiki: TkDND
  module TkDND
    autoload :DND,   'tkextlib/tkDND/tkdnd'
    autoload :Shape, 'tkextlib/tkDND/shape'
  end
end
