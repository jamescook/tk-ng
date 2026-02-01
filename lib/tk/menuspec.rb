# frozen_string_literal: false
#
# tk/menuspec.rb
#                              Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#
# based on tkmenubar.rb :
#   Copyright (C) 1998 maeda shugo. All rights reserved.
#   This file can be distributed under the terms of the Ruby.

# DSL for declaratively creating menus and menubars.
#
# TkMenuSpec provides a way to define complex menu structures using
# nested arrays instead of manual TkMenu/add calls. It supports all
# menu entry types: command, checkbutton, radiobutton, cascade, and separator.
#
# ## Basic Structure
#
# A menu specification is a nested array:
#
#     menu_spec = [
#       [['File', 0],                    # Menu button (underline F)
#         ['New', proc { new_file }, 0, 'Ctrl+N'],    # Command
#         ['Open...', proc { open_file }, 0, 'Ctrl+O'],
#         '---',                                       # Separator
#         ['Exit', proc { exit }]
#       ],
#       [['Edit', 0],
#         ['Cut', proc { cut }, 2, 'Ctrl+X'],
#         ['Copy', proc { copy }, 0, 'Ctrl+C'],
#         ['Paste', proc { paste }, 0, 'Ctrl+V']
#       ]
#     ]
#
# ## Entry Formats
#
# Each entry can be an Array or Hash:
#
# ### Command Entry (Array)
#     [label, command, underline, accelerator, options]
#
# ### Checkbutton Entry
#     [label, TkVariable, underline, accelerator, options]
#
# ### Radiobutton Entry
#     [label, [TkVariable, value], underline, accelerator, options]
#
# ### Cascade (Submenu) Entry
#     [label, [[...entries...]], underline, accelerator, options]
#
# ### Separator
#     '---'
#
# ### Hash Form (more explicit)
#     { type: 'command', label: 'New', command: proc { }, underline: 0 }
#     { type: 'checkbutton', label: 'Bold', variable: @bold_var }
#     { type: 'cascade', label: 'Recent', menu: [[...entries...]] }
#
# ## Underline Shortcuts
#
# The underline parameter supports multiple formats:
# - Integer: character index (0 = first char)
# - `true`: find '&' in label, remove it, underline next char
# - String/Regexp: find pattern, underline at match position
#
#     ['&File', true]        # Underline 'F', label becomes 'File'
#     ['Edit', 'E']          # Underline 'E' (first occurrence)
#     ['Help', /H/]          # Same, using Regexp
#
# ## Platform-Specific Menus
#
# Special menu names for platform conventions:
# - `menu_name: 'help'` - Help menu (right-aligned on Unix/X11)
# - `menu_name: 'system'` - System menu (Windows)
# - `menu_name: 'apple'` - Apple menu (macOS)
#
#     [['Help', 0, { menu_name: 'help' }],
#       ['About', proc { show_about }]
#     ]
#
# ## Layout Options
#
# For menubutton-based bars (non-toplevel parents):
# - `layout_proc: :horizontal` - Pack left-to-right (default)
# - `layout_proc: :vertical` - Pack top-to-bottom
# - `layout_proc: proc { |parent, btn| ... }` - Custom layout
#
# @example Complete menubar
#   menu_spec = [
#     [['&File', true],
#       ['&New', proc { new_doc }, true, 'Ctrl+N'],
#       ['&Open...', proc { open_doc }, true, 'Ctrl+O'],
#       ['&Save', proc { save_doc }, true, 'Ctrl+S'],
#       '---',
#       ['Recent Files', [
#         ['file1.txt', proc { open('file1.txt') }],
#         ['file2.txt', proc { open('file2.txt') }]
#       ]],
#       '---',
#       ['E&xit', proc { exit }, true]
#     ],
#     [['&Edit', true],
#       ['&Undo', proc { undo }, true, 'Ctrl+Z'],
#       '---',
#       ['Cu&t', proc { cut }, true, 'Ctrl+X'],
#       ['&Copy', proc { copy }, true, 'Ctrl+C'],
#       ['&Paste', proc { paste }, true, 'Ctrl+V']
#     ],
#     [['&View', true],
#       ['Show &Toolbar', @show_toolbar, true],  # Checkbutton
#       '---',
#       ['Zoom', [
#         ['100%', [@zoom_var, 100]],  # Radiobutton group
#         ['150%', [@zoom_var, 150]],
#         ['200%', [@zoom_var, 200]]
#       ]]
#     ]
#   ]
#
#   # Apply to window
#   root = TkRoot.new
#   TkMenubar.new(root, menu_spec)
#
# @see TkMenu For manual menu construction
# @see TkMenubar For applying menu specs to windows
module TkMenuSpec
  extend TkMenuSpec

  MENUSPEC_OPTKEYS = [ 'layout_proc' ]

  def _create_menu(parent, menu_info, menu_name = nil,
                   tearoff = false, default_opts = nil)
    if tearoff.kind_of?(Hash)
      default_opts = tearoff
      tearoff = false
    end

    if menu_name.kind_of?(Hash)
      default_opts = menu_name
      menu_name = nil
      tearoff = false
    end

    if default_opts.kind_of?(Hash)
      orig_opts = _symbolkey2str(default_opts)
    else
      orig_opts = {}
    end

    tearoff = orig_opts.delete('tearoff') if orig_opts.key?('tearoff')
    tearoff = false unless tearoff # nil --> false

    if menu_name
      #menu = Tk::Menu.new(parent, :widgetname=>menu_name, :tearoff=>tearoff)
      # --> use current TkMenu class
      menu = TkMenu.new(parent, :widgetname=>menu_name, :tearoff=>tearoff)
    else
      #menu = Tk::Menu.new(parent, :tearoff=>tearoff)
      # --> use current TkMenu class
      menu = TkMenu.new(parent, :tearoff=>tearoff)
    end

    for item_info in menu_info
      if item_info.kind_of?(Hash)
        options = orig_opts.dup
        options.update(_symbolkey2str(item_info))
        item_type = (options.delete('type') || 'command').to_s
        menu_name = options.delete('menu_name')
        menu_opts = orig_opts.dup
        menu_opts.update(_symbolkey2str(options.delete('menu_config') || {}))
        if item_type == 'cascade' && options['menu'].kind_of?(Array)
          # create cascade menu
          submenu = _create_menu(menu, options['menu'], menu_name,
                                 tearoff, menu_opts)
          options['menu'] = submenu
        end
        case options['underline']
        when String, Regexp
          if options['label'] &&
              (idx = options['label'].index(options['underline']))
            options['underline'] = idx
          else
            options['underline'] = -1
          end
        when true
          if options['label'] && (idx = options['label'].index('&'))
            options['label'] = options['label'].dup
            options['label'][idx] = ''
            options['underline'] = idx
          else
            options['underline'] = -1
          end
        end
        menu.add(item_type, options)

      elsif item_info.kind_of?(Array)
        options = orig_opts.dup

        options['label'] = item_info[0] if item_info[0]

        case item_info[1]
        when TkVariable
          # checkbutton
          item_type = 'checkbutton'
          options['variable'] = item_info[1]
          options['onvalue']  = true
          options['offvalue'] = false

        when Array
          # radiobutton or cascade
          if item_info[1][0].kind_of?(TkVariable)
            # radiobutton
            item_type = 'radiobutton'
            options['variable'] = item_info[1][0]
            options['value'] = item_info[1][1] if item_info[1][1]

          else
            # cascade
            item_type = 'cascade'
            menu_opts = orig_opts.dup
            if item_info[4] && item_info[4].kind_of?(Hash)
              opts = _symbolkey2str(item_info[4])
              menu_name = opts.delete('menu_name')
              menu_config = opts.delete('menu_config') || {}
              menu_opts.update(_symbolkey2str(menu_config))
            end
            submenu = _create_menu(menu, item_info[1], menu_name,
                                   tearoff, menu_opts)
            options['menu'] = submenu
          end

        else
          # command
          item_type = 'command'
          options['command'] = item_info[1] if item_info[1]
        end

        options['underline'] = item_info[2] if item_info[2]
        options['accelerator'] = item_info[3] if item_info[3]
        if item_info[4] && item_info[4].kind_of?(Hash)
          opts = _symbolkey2str(item_info[4])
          if item_type == 'cascade'
            opts.delete('menu_name')
            opts.delete('menu_config')
          end
          options.update(opts)
        end

        case options['underline']
        when String, Regexp
          if options['label'] &&
              (idx = options['label'].index(options['underline']))
            options['underline'] = idx
          else
            options['underline'] = -1
          end
        when true
          if options['label'] && (idx = options['label'].index('&'))
            options['label'] = options['label'].dup
            options['label'][idx] = ''
            options['underline'] = idx
          else
            options['underline'] = -1
          end
        end

        menu.add(item_type, options)

      elsif /^-+$/ =~ item_info
        menu.add('separator')

      else
        menu.add('command', 'label' => item_info)
      end
    end

    menu
  end
  private :_create_menu

  def _use_menubar?(parent)
    if parent.kind_of?(Tk::Root) || parent.kind_of?(Tk::Toplevel)
      true
    elsif parent.current_configinfo.has_key?('menu')
      true
    else
      false
    end
  end
  private :_use_menubar?

  def _create_menu_for_menubar(parent)
    #unless (mbar = parent.menu).kind_of?(TkMenu)
    # --> use current TkMenu class
    mbar = parent.menu
    unless mbar.kind_of?(Tk::Menu) || mbar.kind_of?(TkMenu)
      #mbar = Tk::Menu.new(parent, :tearoff=>false)
      mbar = TkMenu.new(parent, :tearoff=>false)
      parent.menu(mbar)
    end
    mbar
  end
  private :_create_menu_for_menubar

  def _create_menubutton(parent, menu_info, tearoff=false, default_opts = {})
    btn_info = menu_info[0]

    if tearoff.kind_of?(Hash)
      default_opts = tearoff
      tearoff = false
    end

    if default_opts.kind_of?(Hash)
      default_opts = _symbolkey2str(default_opts)

      if default_opts.has_key?('layout_proc')
        layout_proc = default_opts.delete('layout_proc')
      end

      _vertical_mbar_bind_proc = proc{|m, dir|
        Tk::Menu::TkInternalFunction.next_menu(m, dir) rescue nil
        # ignore error when the internal function doesn't exist
      }

      case layout_proc
      when :vertical, 'vertical', :vertical_left, 'vertical_left'
        layout_proc = proc{|_parent, _mbtn|
          _mbtn.direction :right
          _mbtn.pack(:side=>:top, :fill=>:x)

          menu = _mbtn.menu
          menu.bind('Tab', _vertical_mbar_bind_proc, :widget, 'forward')
          menu.bind('Alt-Tab', _vertical_mbar_bind_proc, :widget, 'backward')
        }
      when :vertical_right, 'vertical_right'
        layout_proc = proc{|_parent, _mbtn|
          _mbtn.direction :left
          _mbtn.pack(:side=>:top, :fill=>:x)

          menu = _mbtn.menu
          menu.bind('Tab', _vertical_mbar_bind_proc, :widget, 'forward')
          menu.bind('Alt-Tab', _vertical_mbar_bind_proc, :widget, 'backward')
        }
      when :horizontal, 'horizontal'
        layout_proc = proc{|_parent, _mbtn| _mbtn.pack(:side=>:left)}
      else
        # do nothing
      end
    end

    keys = (default_opts)? default_opts.dup: {}

    tearoff = keys.delete('tearoff') if keys.key?('tearoff')
    tearoff = false unless tearoff # nil --> false

    if _use_menubar?(parent) && ! layout_proc
      # menubar by menu entries
      mbar = _create_menu_for_menubar(parent)

      menu_name = nil

      if btn_info.kind_of?(Hash)
        keys.update(_symbolkey2str(btn_info))
        menu_name = keys.delete('menu_name')
        keys['label'] = keys.delete('text') || ''

        case keys['underline']
        when String, Regexp
          if idx = keys['label'].index(keys['underline'])
            keys['underline'] = idx
          else
            keys['underline'] = -1
          end
        when true
          if idx = keys['label'].index('&')
            keys['label'] = keys['label'].dup
            keys['label'][idx] = ''
            keys['underline'] = idx
          else
            keys['underline'] = -1
          end
        end

      elsif btn_info.kind_of?(Array)
        keys['label'] = btn_info[0] if btn_info[0]

        case btn_info[1]
        when Integer
          keys['underline'] = btn_info[1]
        when String, Regexp
          if idx = keys['label'].index(btn_info[1])
            keys['underline'] = idx
          else
            keys['underline'] = -1
          end
        when true
          if idx = keys['label'].index('&')
            keys['label'] = keys['label'].dup
            keys['label'][idx] = ''
            keys['underline'] = idx
          else
            keys['underline'] = -1
          end
        end

        if btn_info[2]&&btn_info[2].kind_of?(Hash)
          keys.update(_symbolkey2str(btn_info[2]))
          menu_name = keys.delete('menu_name')
        end

      else
        keys = {:label=>btn_info}
      end

      menu = _create_menu(mbar, menu_info[1..-1], menu_name,
                          tearoff, default_opts)
      menu.tearoff(tearoff)

      keys['menu'] = menu
      mbar.add('cascade', keys)

      [mbar, menu]

    else
      # menubar by menubuttons
      #mbtn = Tk::Menubutton.new(parent)
      # --> use current TkMenubutton class
      mbtn = TkMenubutton.new(parent)

      menu_name = nil

      if btn_info.kind_of?(Hash)
        keys.update(_symbolkey2str(btn_info))
        menu_name = keys.delete('menu_name')
        keys['text'] = keys.delete('label') || ''
        case keys['underline']
        when String, Regexp
          if idx = keys['text'].index(keys['underline'])
            keys['underline'] = idx
          else
            keys['underline'] = -1
          end
        when true
          if idx = keys['text'].index('&')
            keys['text'] = keys['text'].dup
            keys['text'][idx] = ''
            keys['underline'] = idx
          else
            keys['underline'] = -1
          end
        end
        mbtn.configure(keys)

      elsif btn_info.kind_of?(Array)
        case btn_info[1]
        when String, Regexp
          if btn_info[0] && (idx = btn_info[0].index(btn_info[1]))
            btn_info[1] = idx
          else
            btn_info[1] = -1
          end
        when true
          if btn_info[0] && (idx = btn_info[0].index('&'))
            btn_info[0] = btn_info[0].dup
            btn_info[0][idx] = ''
            btn_info[1] = idx
          else
            btn_info[1] = -1
          end
        end
        mbtn.configure('text', btn_info[0]) if btn_info[0]
        mbtn.configure('underline', btn_info[1]) if btn_info[1]
        # mbtn.configure('accelerator', btn_info[2]) if btn_info[2]
        if btn_info[2]&&btn_info[2].kind_of?(Hash)
          keys.update(_symbolkey2str(btn_info[2]))
          menu_name = keys.delete('menu_name')
          mbtn.configure(keys)
        end

      else
        mbtn.configure('text', btn_info)
      end

      menu = _create_menu(mbtn, menu_info[1..-1], menu_name,
                          tearoff, default_opts)
      mbtn.menu(menu)

      if layout_proc.kind_of?(Proc) || layout_proc.kind_of?(Method)
        # e.g. make a vertical menubar
        #  :layout_proc => proc{|parent, btn| btn.pack(:side=>:top, :fill=>:x)}
        layout_proc.call(parent, mbtn)
      else
        mbtn.pack('side' => 'left')
      end

      [mbtn, menu]
    end
  end
  private :_create_menubutton

  def _create_menubar(parent, menu_spec, tearoff = false, opts = nil)
    if tearoff.kind_of?(Hash)
      opts = tearoff
      tearoff = false
    end
    tearoff = false unless tearoff # nil --> false
    menu_spec.each{|menu_info|
      _create_menubutton(parent, menu_info, tearoff, opts)
    }
    parent
  end
  private :_create_menubar

  def _get_cascade_menus(menu)
    menus = []
    (0..(menu.index('last'))).each{|idx|
      if menu.menutype(idx) == 'cascade'
        submenu = menu.entrycget(idx, 'menu')
        menus << [submenu, _get_cascade_menus(submenu)]
      end
    }
    menus
  end
  private :_get_cascade_menus
end
