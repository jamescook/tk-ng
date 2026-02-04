# frozen_string_literal: false
#
# tk/optiondb.rb : treat option database
#

# Interface to Tk's X11-style option (resource) database.
#
# The option database allows setting widget options using patterns,
# similar to X11 resource files (.Xdefaults). This enables theming and
# default configuration without modifying widget creation code.
#
# ## Pattern Syntax
#
# Patterns use dots (`.`) for direct parent-child and asterisks (`*`) for
# any-depth matching:
#
# - `*Button.background` - All Button backgrounds
# - `*Frame.Button.foreground` - Buttons directly in Frames
# - `.myapp*Label.font` - Labels anywhere under .myapp toplevel
#
# Conventionally, uppercase words match class names; others match instance names.
#
# @example Setting default button colors
#   TkOptionDB.add("*Button.background", "navy")
#   TkOptionDB.add("*Button.foreground", "white")
#
# @example Loading from X resource file
#   TkOptionDB.readfile("/home/user/.Xdefaults", TkOptionDB::Priority::UserDefault)
#
# @example Querying an option
#   color = TkOptionDB.get(my_button, "background", "Background")
#
# @note On some platforms, certain options (like foreground) may be ignored
#   by the system theme despite proper specification.
#
# @see https://www.tcl-lang.org/man/tcl8.6/TkCmd/option.htm Tcl/Tk option manual
require_relative 'core/callable'

module TkOptionDB
  include Tk::Core::Callable
  extend Tk::Core::Callable
  extend TkUtil

  TkCommandNames = ['option'.freeze].freeze

  # Priority levels for option database entries.
  #
  # Higher priority values override lower ones. When priorities are equal,
  # the most recently added option wins.
  #
  # @example Using priority constants
  #   TkOptionDB.add("*Button.bg", "red", TkOptionDB::Priority::UserDefault)
  module Priority
    # Hard-coded widget defaults (lowest priority)
    WidgetDefault = 20
    # Application startup file settings
    StartupFile   = 40
    # User preference files (.Xdefaults, etc.)
    UserDefault   = 60
    # Runtime/interactive specifications (highest, default if unspecified)
    Interactive   = 80
  end

  # Adds an entry to the option database.
  # @param pat [String] Pattern (e.g., "*Button.background")
  # @param value [String] Option value
  # @param pri [Integer, Symbol] Priority (default: Interactive/80)
  # @return [String] Empty string
  def add(pat, value, pri=TkUtil::None)
    tk_call('option', 'add', pat, value, pri)
  end

  # Clears all entries from the option database.
  # @note Widget defaults will reload automatically on next add operation.
  # @return [void]
  def clear
    tk_call('option', 'clear')
  end

  # Retrieves an option value for a window.
  # @param win [TkWindow] The window to query
  # @param name [String] Option name (e.g., "background")
  # @param klass [String] Option class (e.g., "Background")
  # @return [String] The option value, or empty string if not found
  def get(win, name, klass)
    tk_call('option', 'get', win ,name, klass)
  end

  # Loads options from an X resource file.
  # @param file [String] Path to resource file (UTF-8 encoded)
  # @param pri [Integer, Symbol] Priority for all loaded options
  # @return [void]
  def readfile(file, pri=TkUtil::None)
    tk_call('option', 'readfile', file, pri)
  end
  alias read_file readfile
  module_function :add, :clear, :get, :readfile, :read_file

  def read_entries(file, _f_enc=nil)
    if TkCore::INTERP.safe?
      fail SecurityError,
        "can't call 'TkOptionDB.read_entries' on a safe interpreter"
    end

    # Note: f_enc parameter kept for API compatibility but unused
    # Modern Ruby/Tcl use UTF-8 natively

    ent = []
    cline = ''
    open(file, 'r') {|f|
      while line = f.gets
        #cline += line.chomp!
        cline.concat(line.chomp!)
        case cline
        when /\\$/    # continue
          cline.chop!
          next
        when /^\s*(!|#)/     # comment
          cline = ''
          next
        when /^([^:]+):(.*)$/
          pat = $1.strip
          val = $2.lstrip
          p "ResourceDB: #{[pat, val].inspect}" if $DEBUG
          ent << [pat, val]
          cline = ''
        else          # unknown --> ignore
          cline = ''
          next
        end
      end
    }
    ent
  end
  module_function :read_entries

  def read_with_encoding(file, f_enc=nil, pri=TkUtil::None)
    # try to read the file as an OptionDB file
    read_entries(file, f_enc).each{|pat, val|
      add(pat, val, pri)
    }

=begin
    i_enc = Tk.encoding()

    unless f_enc
      f_enc = i_enc
    end

    cline = ''
    open(file, 'r') {|f|
      while line = f.gets
        cline += line.chomp!
        case cline
        when /\\$/    # continue
          cline.chop!
          next
        when /^\s*!/     # comment
          cline = ''
          next
        when /^([^:]+):\s(.*)$/
          pat = $1
          val = $2
          p "ResourceDB: #{[pat, val].inspect}" if $DEBUG
          pat = TkCore::INTERP._toUTF8(pat, f_enc)
          pat = TkCore::INTERP._fromUTF8(pat, i_enc)
          val = TkCore::INTERP._toUTF8(val, f_enc)
          val = TkCore::INTERP._fromUTF8(val, i_enc)
          add(pat, val, pri)
          cline = ''
        else          # unknown --> ignore
          cline = ''
          next
        end
      end
    }
=end
  end
  module_function :read_with_encoding

  # Extend with compat stubs for removed proc class methods
  # (new_proc_class, new_proc_class_random, eval_under_random_base)
  extend TkOptionDBCompat
end
TkOption = TkOptionDB
TkResourceDB = TkOptionDB
