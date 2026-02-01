# frozen_string_literal: false
#
# tk/menubar.rb
#
# Original version:
#   Copyright (C) 1998 maeda shugo. All rights reserved.
#   This file can be distributed under the terms of the Ruby.

require 'tk'
require 'tk/frame'
require 'tk/composite'
require 'tk/menuspec'

# A menubar widget built from a declarative specification.
#
# TkMenubar creates a complete menubar from nested arrays describing
# the menu structure. Use with TkRoot or TkToplevel, or pack into
# any container for standalone use.
#
# ## Quick Start
#
#     menu_spec = [
#       [['File', 0],
#         ['Open', proc { open_file }, 0, 'Ctrl+O'],
#         '---',
#         ['Quit', proc { exit }, 0]
#       ],
#       [['Edit', 0],
#         ['Cut', proc { cut }, 2, 'Ctrl+X'],
#         ['Copy', proc { copy }, 0, 'Ctrl+C'],
#         ['Paste', proc { paste }, 0, 'Ctrl+V']
#       ]
#     ]
#
#     menubar = TkMenubar.new(root, menu_spec, tearoff: false)
#     menubar.pack(side: :top, fill: :x)
#
# ## Building Incrementally
#
#     menubar = TkMenubar.new
#     menubar.add_menu([['File', 0], ['New', proc { }], ['Open', proc { }]])
#     menubar.add_menu([['Edit', 0], ['Undo', proc { }]])
#     menubar.configure(tearoff: false, font: 'Helvetica 12')
#     menubar.pack(side: :top, fill: :x)
#
# ## Common Options
#
# - `:tearoff` - Allow tearoff menus (default: true)
# - `:foreground`, `:background` - Colors
# - `:activeforeground`, `:activebackground` - Highlight colors
# - `:font` - Menu font
#
# @example With checkbuttons and radiobuttons
#   @bold = TkVariable.new(false)
#   @size = TkVariable.new(12)
#
#   menu_spec = [
#     [['Format', 0],
#       ['Bold', @bold, 0],           # Checkbutton
#       '---',
#       ['10pt', [@size, 10]],        # Radiobutton group
#       ['12pt', [@size, 12]],
#       ['14pt', [@size, 14]]
#     ]
#   ]
#
# @see TkMenuSpec For menu specification format details
# @see TkMenu For manual menu construction
class TkMenubar<Tk::Frame
  include TkComposite
  include TkMenuSpec

  # Create a new menubar.
  #
  # @param parent [TkWindow, nil] Parent widget (nil for default root)
  # @param spec [Array, nil] Menu specification (see {TkMenuSpec})
  # @param options [Hash] Configuration options
  # @option options [Boolean] :tearoff Allow tearoff menus
  # @option options [String] :font Menu font
  # @option options [String] :foreground Text color
  # @option options [String] :background Background color
  def initialize(parent = nil, spec = nil, options = {})
    if parent.kind_of? Hash
      options = parent
      parent = nil
      spec = (options.has_key?('spec'))? options.delete('spec'): nil
    end

    _symbolkey2str(options)
    menuspec_opt = {}
    TkMenuSpec::MENUSPEC_OPTKEYS.each{|key|
      menuspec_opt[key] = options.delete(key) if options.has_key?(key)
    }

    super(parent, options)

    @menus = []

    spec.each{|info| add_menu(info, menuspec_opt)} if spec

    options.each{|key, value| configure(key, value)} if options
  end

  # Add a menu to the menubar.
  #
  # @param menu_info [Array] Single menu specification
  #   `[[button_text, underline], entry, entry, ...]`
  # @param menuspec_opt [Hash] Additional options
  # @return [void]
  #
  # @example
  #   menubar.add_menu([['Help', 0],
  #     ['About', proc { show_about }]
  #   ])
  def add_menu(menu_info, menuspec_opt={})
    mbtn, menu = _create_menubutton(@frame, menu_info, menuspec_opt)

    submenus = _get_cascade_menus(menu).flatten

    @menus.push([mbtn, menu])
    delegate('tearoff', menu, *submenus)
    delegate('foreground', mbtn, menu, *submenus)
    delegate('background', mbtn, menu, *submenus)
    delegate('disabledforeground', mbtn, menu, *submenus)
    delegate('activeforeground', mbtn, menu, *submenus)
    delegate('activebackground', mbtn, menu, *submenus)
    delegate('font', mbtn, menu, *submenus)
  end

  # Access a menu by index.
  #
  # @param index [Integer] Menu index (0 = first menu)
  # @return [Array] `[menubutton, menu]` pair
  #
  # @example Get the File menu
  #   file_btn, file_menu = menubar[0]
  #   file_menu.entryconfigure(0, state: :disabled)
  def [](index)
    return @menus[index]
  end
end
