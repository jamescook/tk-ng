# frozen_string_literal: false
require 'tk/menuspec'
require 'tk/option_dsl'
require 'tk/item_option_dsl'
require_relative 'core/callable'
require_relative 'core/configurable'
require_relative 'core/widget'
require_relative 'callback'

# @!visibility private
# Mixin for menu entry configuration methods.
module TkMenuEntryConfig
  include Tk::ItemOptionDSL::InstanceMethods

  # Item command configuration moved to DSL:
  #   item_commands cget: 'entrycget', configure: 'entryconfigure'
  # Set on Tk::Menu class after including Tk::Generated::MenuItems

  alias entrycget_tkstring itemcget_tkstring
  alias entrycget itemcget
  alias entrycget_strict itemcget_strict
  alias entryconfigure itemconfigure
  alias entryconfiginfo itemconfiginfo
  alias current_entryconfiginfo current_itemconfiginfo

  private :itemcget_tkstring, :itemcget, :itemcget_strict
  private :itemconfigure, :itemconfiginfo, :current_itemconfiginfo
end

# A menu widget for menubars, popup menus, and cascading submenus.
#
# == Entry Types
# - `:command` - executes a callback when clicked
# - `:checkbutton` - toggleable on/off item
# - `:radiobutton` - one-of-many selection
# - `:cascade` - submenu
# - `:separator` - horizontal divider line
#
# @example Menubar
#   root = TkRoot.new
#   menubar = Tk::Menu.new(root)
#   root.menu = menubar
#
#   file_menu = Tk::Menu.new(menubar, tearoff: false)
#   menubar.add(:cascade, menu: file_menu, label: 'File')
#   file_menu.add(:command, label: 'Open', command: -> { open_file })
#   file_menu.add(:separator)
#   file_menu.add(:command, label: 'Exit', command: -> { exit })
#
# @example Popup (context) menu
#   popup = Tk::Menu.new(tearoff: false)
#   popup.add(:command, label: 'Cut', command: -> { cut })
#   popup.add(:command, label: 'Copy', command: -> { copy })
#
#   widget.bind('Button-3') do |e|
#     popup.popup(e.x_root, e.y_root)
#   end
#
# @note Menu entries are not separate widgets - the whole menu is one widget.
#   Entry options cannot be set via the option database.
#
# @note The `:tearoff` option (default false) adds a dashed line that lets
#   users "tear off" the menu into a separate window. Ignored on macOS.
#
# @see Tk::Menubutton for a button that displays a menu
# @see https://www.tcl-lang.org/man/tcl/TkCmd/menu.html Tcl/Tk menu manual
#
class Tk::Menu
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include TkMenuEntryConfig
  extend TkMenuSpec

  # TkMenuSpec methods call _symbolkey2str.
  # Provide it here since Tk::Menu doesn't inherit TkWindow.
  def self._symbolkey2str(hash)
    hash.transform_keys(&:to_s)
  end
  private_class_method :_symbolkey2str
  include Tk::Generated::Menu
  include Tk::Generated::MenuItems

  # Declare item command structure (menu entries use 'entry*' commands)
  item_commands cget: 'entrycget', configure: 'entryconfigure'

  None = TkUtil::None

  TkCommandNames = ['menu'.freeze].freeze
  WidgetClassName = 'Menu'.freeze
  Tk::Core::Widget.registry[WidgetClassName] ||= self

  def self.new_menuspec(menu_spec, parent = nil, tearoff = false, keys = nil)
    if parent.kind_of?(Hash)
      keys = parent.transform_keys(&:to_s)
      parent = keys.delete('parent')
      tearoff = keys.delete('tearoff')
    elsif tearoff.kind_of?(Hash)
      keys = tearoff.transform_keys(&:to_s)
      tearoff = keys.delete('tearoff')
    elsif keys
      keys = keys.transform_keys(&:to_s)
    else
      keys = {}
    end

    widgetname = keys.delete('widgetname')
    _create_menu(parent, menu_spec, widgetname, tearoff, keys)
  end

  def tagid(id)
    if id.respond_to?(:path)
      id.path
    elsif id.respond_to?(:to_eval)
      id.to_eval
    else
      id.to_s
    end
  end

  def activate(index)
    tk_send('activate', index.to_s)
    self
  end

  def add(type, keys=nil)
    args = ['add', type.to_s]
    _menu_hash_kv(keys, args) if keys
    tk_send(*args)
    self
  end

  def add_cascade(keys=nil)
    add('cascade', keys)
  end
  def add_checkbutton(keys=nil)
    add('checkbutton', keys)
  end
  def add_command(keys=nil)
    add('command', keys)
  end
  def add_radiobutton(keys=nil)
    add('radiobutton', keys)
  end
  def add_separator(keys=nil)
    add('separator', keys)
  end

  def clone_menu(*args)
    if args[0].respond_to?(:path)
      parent = args.shift
    else
      parent = self
    end

    if args[0].kind_of?(String) || args[0].kind_of?(Symbol)
      type = args.shift
    else
      type = None
    end

    if args[0].kind_of?(Hash)
      keys = args.shift
      parent = keys.delete(:parent) || keys.delete('parent') || parent
      type = keys.delete(:type) || keys.delete('type') || type
    else
      keys = {}
    end

    if keys.empty?
      Tk::MenuClone.new(self, parent, type)
    else
      Tk::MenuClone.new(self, parent, type, keys)
    end
  end

  def index(idx)
    ret = tk_send('index', idx.to_s)
    ret == 'none' ? nil : ret.to_i
  end

  def invoke(index)
    tk_send('invoke', index.to_s)
  end

  def insert(index, type, keys=nil)
    args = ['insert', index.to_s, type.to_s]
    _menu_hash_kv(keys, args) if keys
    tk_send(*args)
    self
  end

  def delete(first, last=nil)
    if last
      tk_send('delete', first.to_s, last.to_s)
    else
      tk_send('delete', first.to_s)
    end
    self
  end

  def popup(x, y, index=nil)
    if index
      tk_call('tk_popup', path, x, y, index.to_s)
    else
      tk_call('tk_popup', path, x, y)
    end
    self
  end

  def post(x, y)
    tk_send('post', x, y)
  end

  def postcascade(index)
    tk_send('postcascade', index.to_s)
    self
  end

  def postcommand(cmd=nil, &block)
    configure_cmd('postcommand', cmd || block)
    self
  end

  def set_focus
    tk_call('tk_menuSetFocus', path)
    self
  end

  def tearoffcommand(cmd=nil, &block)
    configure_cmd('tearoffcommand', cmd || block)
    self
  end

  def menutype(index)
    tk_send('type', index.to_s)
  end

  def unpost
    tk_send('unpost')
    self
  end

  def xposition(index)
    tk_send('xposition', index.to_s).to_i
  end

  def yposition(index)
    tk_send('yposition', index.to_s).to_i
  end

  private

  # Convert a hash of menu entry options to -key value args.
  # Handles Proc values (install as callbacks) and widget/variable objects.
  def _menu_hash_kv(keys, args)
    args.concat(hash_to_args(keys))
  end
end

#TkMenu = Tk::Menu unless Object.const_defined? :TkMenu
#Tk.__set_toplevel_aliases__(:Tk, Tk::Menu, :TkMenu)
Tk.__set_loaded_toplevel_aliases__('tk/menu.rb', :Tk, Tk::Menu, :TkMenu)


module Tk::Menu::TkInternalFunction; end
class << Tk::Menu::TkInternalFunction
  # These methods calls internal functions of Tcl/Tk.
  # So, They may not work on your Tcl/Tk.
  def next_menu(menu, dir='next')
    dir = dir.to_s
    case dir
    when 'next', 'forward', 'down'
      dir = 'right'
    when 'previous', 'backward', 'up'
      dir = 'left'
    end

    Tk.tk_call('::tk::MenuNextMenu', menu, dir)
  end

  def next_entry(menu, delta)
    # delta is increment value of entry index.
    # For example, +1 denotes 'next entry' and -1 denotes 'previous entry'.
    Tk.tk_call('::tk::MenuNextEntry', menu, delta)
  end
end

class Tk::MenuClone<Tk::Menu
  def initialize(src_menu, *args)
    if args[0].respond_to?(:path)
      parent = args.shift
    else
      parent = src_menu
    end

    if args[0].kind_of?(String) || args[0].kind_of?(Symbol)
      type = args.shift
    else
      type = None
    end

    if args[0].kind_of?(Hash)
      keys = args.shift
      parent = keys.delete(:parent) || keys.delete('parent') || parent
      type = keys.delete(:type) || keys.delete('type') || type
    else
      keys = nil
    end

    @src_menu = src_menu
    @parent = parent
    @type = type

    # Generate path under parent and register
    id = Tk::Core::Widget.next_id
    parent_path = @parent.respond_to?(:path) ? @parent.path : '.'
    @path = parent_path == '.' ? ".w#{id}" : "#{parent_path}.w#{id}"
    TkCore::INTERP.tk_windows[@path] = self

    # Clone the source menu
    tk_call(@src_menu.path, 'clone', @path, @type)
    configure(keys) if keys && !keys.empty?
  end

  def source_menu
    @src_menu
  end
end
Tk::CloneMenu = Tk::MenuClone
#TkMenuClone = Tk::MenuClone unless Object.const_defined? :TkMenuClone
#TkCloneMenu = Tk::CloneMenu unless Object.const_defined? :TkCloneMenu
#Tk.__set_toplevel_aliases__(:Tk, Tk::MenuClone, :TkMenuClone, :TkCloneMenu)
Tk.__set_loaded_toplevel_aliases__('tk/menu.rb', :Tk, Tk::MenuClone,
                                   :TkMenuClone, :TkCloneMenu)

module Tk::SystemMenu
  def initialize(parent, keys=nil)
    if parent.kind_of?(Hash)
      keys = parent
      parent = keys.delete(:parent) || keys.delete('parent')
    end

    @path = parent.path + '.' + self.class::SYSMENU_NAME
    TkCore::INTERP.tk_windows[@path] = self
    tk_call('menu', @path)
    configure(keys) if keys && !keys.empty?
  end
end
TkSystemMenu = Tk::SystemMenu


class Tk::SysMenu_Help<Tk::Menu
  # for all platform
  include Tk::SystemMenu
  SYSMENU_NAME = 'help'
end
#TkSysMenu_Help = Tk::SysMenu_Help unless Object.const_defined? :TkSysMenu_Help
#Tk.__set_toplevel_aliases__(:Tk, Tk::SysMenu_Help, :TkSysMenu_Help)
Tk.__set_loaded_toplevel_aliases__('tk/menu.rb', :Tk, Tk::SysMenu_Help,
                                   :TkSysMenu_Help)


class Tk::SysMenu_System<Tk::Menu
  # for Windows
  include Tk::SystemMenu
  SYSMENU_NAME = 'system'
end
#TkSysMenu_System = Tk::SysMenu_System unless Object.const_defined? :TkSysMenu_System
#Tk.__set_toplevel_aliases__(:Tk, Tk::SysMenu_System, :TkSysMenu_System)
Tk.__set_loaded_toplevel_aliases__('tk/menu.rb', :Tk, Tk::SysMenu_System,
                                   :TkSysMenu_System)


class Tk::SysMenu_Apple<Tk::Menu
  # for Macintosh
  include Tk::SystemMenu
  SYSMENU_NAME = 'apple'
end
#TkSysMenu_Apple = Tk::SysMenu_Apple unless Object.const_defined? :TkSysMenu_Apple
#Tk.__set_toplevel_aliases__(:Tk, Tk::SysMenu_Apple, :TkSysMenu_Apple)
Tk.__set_loaded_toplevel_aliases__('tk/menu.rb', :Tk, Tk::SysMenu_Apple,
                                   :TkSysMenu_Apple)


# A button that displays an associated menu when clicked.
#
# Menubuttons are typically used in toolbars or custom menu systems.
# For standard menubars, attach a {Tk::Menu} directly to a Toplevel instead.
#
# @example Menubutton with dropdown
#   mb = Tk::Menubutton.new(text: "Options", relief: :raised)
#   menu = Tk::Menu.new(mb, tearoff: false)
#   menu.add(:command, label: "Option 1")
#   menu.add(:command, label: "Option 2")
#   mb.menu = menu
#   mb.pack
#
# @note The `:direction` option controls where the menu appears:
#   `:below` (default), `:above`, `:left`, `:right`, or `:flush`.
#
# @note For modern menubars, prefer attaching a Menu to a Toplevel's
#   `:menu` option rather than using multiple Menubuttons.
#
# @see Tk::Menu for the menu widget
# @see https://www.tcl-lang.org/man/tcl/TkCmd/menubutton.html Tcl/Tk menubutton manual
#
class Tk::Menubutton
  include Tk::Core::Callable
  include Tk::Core::Configurable
  include TkCallback
  include Tk::Core::Widget
  include Tk::Generated::Menubutton
  # @generated:options:start
  # Available options (auto-generated from Tk introspection):
  #
  #   :activebackground
  #   :activeforeground
  #   :anchor
  #   :background
  #   :bitmap
  #   :borderwidth
  #   :compound
  #   :cursor
  #   :direction
  #   :disabledforeground
  #   :font
  #   :foreground
  #   :height
  #   :highlightbackground
  #   :highlightcolor
  #   :highlightthickness
  #   :image
  #   :indicatoron
  #   :justify
  #   :menu
  #   :padx
  #   :pady
  #   :relief
  #   :state
  #   :takefocus
  #   :text
  #   :textvariable (tkvariable)
  #   :underline
  #   :width
  #   :wraplength
  # @generated:options:end


  TkCommandNames = ['menubutton'.freeze].freeze
  WidgetClassName = 'Menubutton'.freeze
end
Tk::MenuButton = Tk::Menubutton
#TkMenubutton = Tk::Menubutton unless Object.const_defined? :TkMenubutton
#TkMenuButton = Tk::MenuButton unless Object.const_defined? :TkMenuButton
#Tk.__set_toplevel_aliases__(:Tk, Tk::Menubutton, :TkMenubutton, :TkMenuButton)
Tk.__set_loaded_toplevel_aliases__('tk/menu.rb', :Tk, Tk::Menubutton,
                                   :TkMenubutton, :TkMenuButton)


class Tk::OptionMenubutton<Tk::Menubutton
  TkCommandNames = ['tk_optionMenu'.freeze].freeze

  class OptionMenu<TkMenu
    def initialize(path)  #==> return value of tk_optionMenu
      @path = path
      TkCore::INTERP.tk_windows[@path] = self
    end
  end

  def initialize(*args)
    # args :: [parent,] [var,] [value[, ...],] [keys]
    #    parent --> TkWindow or nil
    #    var    --> TkVariable or nil
    #    keys   --> Hash
    #       keys[:parent] or keys['parent']     --> parent
    #       keys[:variable] or keys['variable'] --> var
    #       keys[:values] or keys['values']     --> value, ...
    #       other Hash keys are menubutton options
    keys = {}
    keys = args.pop if args[-1].kind_of?(Hash)
    keys = keys.transform_keys(&:to_s)

    parent = nil
    if !args.empty? && (args[0].respond_to?(:path) || args[0] == nil)
      keys.delete('parent') # ignore
      parent = args.shift
    else
      parent = keys.delete('parent')
    end

    @variable = nil
    if !args.empty? && (args[0].kind_of?(TkVariable) || args[0] == nil)
      keys.delete('variable') # ignore
      @variable = args.shift
    else
      @variable = keys.delete('variable')
    end
    @variable = TkVariable.new unless @variable

    (args = keys.delete('values') || []) if args.empty?
    if args.empty?
      args << @variable.value
    else
      @variable.value = args[0]
    end

    @path = generate_path(parent)
    TkCore::INTERP.tk_windows[@path] = self
    @menu = OptionMenu.new(tk_call('tk_optionMenu',
                                   @path, @variable.id, *args))

    configure(keys) if keys
  end

  def value
    @variable.value
  end

  def value=(val)
    @variable.value = val
  end

  def activate(index)
    @menu.activate(index)
    self
  end
  def add(value)
    @menu.add('radiobutton', 'variable'=>@variable,
              'label'=>value, 'value'=>value)
    self
  end
  def index(index)
    @menu.index(index)
  end
  def invoke(index)
    @menu.invoke(index)
  end
  def insert(index, value)
    @menu.insert(index, 'radiobutton', 'variable'=>@variable,
              'label'=>value, 'value'=>value)
    self
  end
  def delete(index, last=None)
    @menu.delete(index, last)
    self
  end
  def xposition(index)
    @menu.xposition(index)
  end
  def yposition(index)
    @menu.yposition(index)
  end
  def menu
    @menu
  end
  def menucget(key)
    @menu.cget(key)
  end
  def menucget_strict(key)
    @menu.cget_strict(key)
  end
  def menuconfigure(key, val=None)
    @menu.configure(key, val)
    self
  end
  def menuconfiginfo(key=nil)
    @menu.configinfo(key)
  end
  def current_menuconfiginfo(key=nil)
    @menu.current_configinfo(key)
  end
  def entrycget(index, key)
    @menu.entrycget(index, key)
  end
  def entrycget_strict(index, key)
    @menu.entrycget_strict(index, key)
  end
  def entryconfigure(index, key, val=None)
    @menu.entryconfigure(index, key, val)
    self
  end
  def entryconfiginfo(index, key=nil)
    @menu.entryconfiginfo(index, key)
  end
  def current_entryconfiginfo(index, key=nil)
    @menu.current_entryconfiginfo(index, key)
  end
end

Tk::OptionMenuButton = Tk::OptionMenubutton
#TkOptionMenubutton = Tk::OptionMenubutton unless Object.const_defined? :TkOptionMenubutton
#TkOptionMenuButton = Tk::OptionMenuButton unless Object.const_defined? :TkOptionMenuButton
#Tk.__set_toplevel_aliases__(:Tk, Tk::OptionMenubutton,
#                            :TkOptionMenubutton, :TkOptionMenuButton)
Tk.__set_loaded_toplevel_aliases__('tk/menu.rb', :Tk, Tk::OptionMenubutton,
                                   :TkOptionMenubutton, :TkOptionMenuButton)
